class_name PotatoPerson
extends Sprite2D

# Signals
signal path_completed
signal state_changed(old_state, new_state)
signal destroyed(position)

# Tater States
enum TaterState { QUEUED, IN_OFFICE, APPROVED, REJECTED, RUNNING, DESTROYED }

enum PotatoBrainState { IDLE, TALKING, THINKING, SURPRISED, HAPPY, SAD, ANGRY }

# Current Tater State
var current_state := TaterState.QUEUED

# Properties
var potato_info: Dictionary = {}
var current_point: int = 0
var target_point: int = 0
var speed_multiplier: float = 1.0
var runner_base_speed: float = 0.35  # Default to Normal difficulty
var regular_path_speed: float = 0.50  # Default to Normal difficulty
var footprint_timer: float = 0.0
var footprint_interval: float = 0.15  # Time between footprints
var footprints: Array = []
var max_footprints: int = 24

# Path following
var current_path_follow: PathFollow2D
var current_path: Path2D

# Character generator component
var character_generator: Node

# Preload all the textures
var textures = {
	"Russet": preload("res://assets/potatoes/sprite_sheets/russet_small_5x8.png"),
	"Yukon Gold": preload("res://assets/potatoes/sprite_sheets/yukon_gold_small_5x8.png"),
	"Sweet Potato": preload("res://assets/potatoes/sprite_sheets/sweet_potato_small_5x8.png"),
	"Purple Majesty": preload("res://assets/potatoes/sprite_sheets/purple_majesty_small_5x8.png"),
}

# Potato Brain State
var current_potato_brain_state: int = PotatoBrainState.IDLE

## Reference to the EmoteSystem node
var emote_system: PotatoEmoteSystem
@onready var emote_sprite: AnimatedSprite2D = %PotatoEmote

func _ready() -> void:
	var NodeHighlightShader = preload(
		"res://scripts/shaders/node_highlight/node_highlight.gdshader"
	)
	var node_highlight_material = ShaderMaterial.new()
	node_highlight_material.shader = NodeHighlightShader
	# After setting the material
	%PotatoSprite.material = node_highlight_material

	# TODO: This doesn't actually set the shader parameters, no idea why but I give up, fuck this.
	# Set shader parameters
	node_highlight_material.set_shader_parameter("edge_width", 0.1)
	node_highlight_material.set_shader_parameter("ignore_colors", true)
	node_highlight_material.set_shader_parameter("ignored_color_1", Color("#3c354a"))  # Purple color from inspector

	# Get reference to the emote sprite
	emote_sprite = %PotatoEmote

	# Get reference to the emote system that's already attached to the sprite
	# in the scene (as seen in your tscn file)
	emote_system = %PotatoEmote

	# Initialize character generator if not already present
	if !has_node("CharacterGenerator"):
		var gen_scene = load("res://scripts/systems/character_generator.tscn")
		if gen_scene:
			character_generator = gen_scene.instantiate()
			add_child(character_generator)
	else:
		character_generator = $CharacterGenerator

	# Set initial appearance based on potato_info
	update_appearance()


func _process(delta):
	# Handle path following if on a path
	if current_path_follow and current_state != TaterState.IN_OFFICE:
		follow_path(delta)

	# Footprint creation
	if (
		current_state == TaterState.APPROVED
		or current_state == TaterState.REJECTED
		or current_state == TaterState.RUNNING
	):
		footprint_timer += delta
		if footprint_timer >= footprint_interval:
			footprint_timer = 0
			spawn_footprint()


## Changes the potato's brain state and shows an appropriate emote
## @param new_state The PotatoBrainState to transition to
func change_brain_state(new_state: int) -> void:
	current_potato_brain_state = new_state

	match new_state:
		PotatoBrainState.IDLE:
			# No emote for idle state
			emote_system._hide_emote()
		PotatoBrainState.TALKING:
			# When implemented, the emote system will handle the wiggle
			pass
		PotatoBrainState.THINKING:
			emote_system.show_random_emote_from_category("thinking")
		PotatoBrainState.SURPRISED:
			emote_system.show_random_emote_from_category("surprise")
		PotatoBrainState.HAPPY:
			emote_system.show_random_emote_from_category("positive")
		PotatoBrainState.SAD:
			emote_system.show_random_emote_from_category("negative")
		PotatoBrainState.ANGRY:
			emote_system.show_random_emote_from_category("negative")


## Handles user interaction with the potato character.
##
## Triggers a random emote animation and brain state change when the player
## clicks on or otherwise interacts with the potato. This includes:
## - Playing a wiggle animation using tweens
## - Setting a random brain state (emotion)
## - Showing the appropriate emote bubble
## - Automatically returning to idle state after the emote duration
##
## The brain state affects both the visual emote displayed and the
## physical animation of the potato character.
func interact_with_potato() -> void:
	# Pick a random PotatoBrainState
	var random_brain_state_index: int = randi_range(0, PotatoBrainState.size() - 1)
	var random_brain_state: int = random_brain_state_index  # The index is the enum value

	# Use the random state instead of hardcoding
	change_brain_state(random_brain_state)

	# Return to idle state after emote duration
	await get_tree().create_timer(emote_system.emote_duration).timeout
	change_brain_state(PotatoBrainState.IDLE)


func explode():
	# Emit signal with our position for gib creation
	emit_signal("destroyed", global_position)
	# Set state to destroyed which will queue_free()
	set_state(TaterState.DESTROYED)


func apply_damage():
	# Trigger explosion
	explode()
	return true


func set_state(new_state: TaterState):
	var old_state = current_state
	current_state = new_state
	update_appearance()
	# Handle state-specific logic
	match new_state:
		TaterState.QUEUED:
			modulate.a = 1.0
		TaterState.IN_OFFICE:
			# Stop path following when in office
			if current_path_follow:
				leave_path()
		TaterState.APPROVED, TaterState.REJECTED:
			# Visual feedback for approved/rejected
			pass
		TaterState.RUNNING:
			# When running, could increase speed?
			speed_multiplier = 1.0
		TaterState.DESTROYED:
			queue_free()

	# Emit signal for state change
	emit_signal("state_changed", old_state, new_state)


func update_potato(new_potato_info: Dictionary):
	potato_info = new_potato_info
	update_appearance()


func update_appearance():
	match current_state:
		TaterState.IN_OFFICE:
			# Hide detailed view, show silhouette
			$CharacterGenerator.visible = true
			# Make sure the silhouette is visible
			%PotatoSprite.visible = false
		TaterState.QUEUED, TaterState.APPROVED, TaterState.REJECTED, TaterState.RUNNING:
			# Show detailed view, hide silhouette
			$CharacterGenerator.visible = false
			# You might want to hide the silhouette when detailed view is shown
			%PotatoSprite.visible = true
		TaterState.DESTROYED:
			visible = false
			%PotatoSprite.visible = false

	# Update character appearance from character data if available
	if potato_info.has("character_data") and has_node("CharacterGenerator"):
		var character_gen = get_node("CharacterGenerator")
		character_gen.set_character_data(potato_info.character_data)
		print(
			"Debug: PotatoPerson updated with character data: ",
			"Race: ",
			potato_info.race,
			"Sex: ",
			potato_info.sex,
			"Head Frame: ",
			potato_info.character_data.get("head_frame", "??")
		)

	# Update body sprite based on race if specified
	if potato_info.has("race") and potato_info.race in textures:
		# Apply the texture to the child sprite
		%PotatoSprite.texture = textures[potato_info.race]


func move_toward(target: Vector2, speed: float):
	position = position.move_toward(target, speed)


func follow_path(delta):
	if current_path_follow:
		# Update path position based on speed
		var path_speed = delta * runner_base_speed * speed_multiplier  # Base speed * multiplier

		# Progress along the path
		current_path_follow.progress_ratio += path_speed

		# Check if we reached the end of the path
		if current_path_follow.progress_ratio >= 0.99:
			emit_signal("path_completed")

			# Auto-cleanup if needed
			if (
				current_state == TaterState.APPROVED
				or current_state == TaterState.REJECTED
				or current_state == TaterState.RUNNING
			):
				set_state(TaterState.DESTROYED)


func cleanup():
	if current_path_follow:
		leave_path()
	queue_free()


func attach_to_path(path: Path2D):
	# Leave current path if already on one
	if current_path_follow:
		leave_path()

	# Ensure visibility
	visible = true
	%PotatoSprite.visible = true

	# Create new PathFollow2D
	current_path = path
	current_path_follow = PathFollow2D.new()
	current_path_follow.rotates = false
	path.add_child(current_path_follow)

	# If we have a parent, remove ourselves
	if get_parent():
		get_parent().remove_child(self)

	# Add to path follow
	current_path_follow.add_child(self)
	position = Vector2.ZERO
	current_path_follow.progress_ratio = 0.0

	# Explicitly set state
	set_state(TaterState.RUNNING)


func leave_path():
	if current_path_follow:
		# Get global position before detaching
		var global_pos = global_position

		# Remove from path
		if get_parent() == current_path_follow:
			current_path_follow.remove_child(self)

			# Add back to previous parent if still valid
			if current_path_follow.get_parent() and current_path_follow.get_parent().get_parent():
				current_path_follow.get_parent().get_parent().add_child(self)
				global_position = global_pos

		# Remove path follow
		current_path_follow.queue_free()
		current_path_follow = null
		current_path = null


func get_potato_info() -> Dictionary:
	return potato_info


# Helper function to fade in the potato
func fade_in(duration: float = 0.5):
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration)


# Helper function to fade out the potato
func fade_out(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(func(): queue_free())


func spawn_footprint():
	var footprint = Sprite2D.new()

	# Determine if on concrete (you'll need to implement this based on your game)
	var is_on_concrete = is_potato_on_concrete()

	# Load the appropriate texture
	if is_on_concrete:
		footprint.texture = preload("res://assets/effects/footstep_concrete.png")
		# Random scale for concrete footprints - slightly smaller than grass
		footprint.scale = Vector2(
			randf_range(0.65, 0.75),
			randf_range(0.65, 0.75)
		)
		# Darker color for concrete footprints
		footprint.modulate = Color(1, 1, 1, 0.7)
	else:
		footprint.texture = preload("res://assets/effects/footstep_grass.png")
		# Random scale for grass footprints
		footprint.scale = Vector2(
			randf_range(0.75, 0.85),
			randf_range(0.75, 0.85)
		)
		# Normal color
		footprint.modulate = Color(1, 1, 1, 0.8)
		
	# Add random rotation to make footprints look more natural
	# Limit rotation to a realistic range for footsteps (slight variations)
	footprint.rotation = randf_range(-0.1, 0.15)  # About +/-8.6 degrees
	# Base position starts at the player's position
	footprint.global_position = global_position
	# Add random offsets to create more natural-looking footstep patterns
	var x_offset = randf_range(-5, 5)  # Random horizontal offset of +/-5 pixels
	var y_offset = randf_range(8, 14)  # Random vertical offset between 8-14 pixels
	# Apply the offsets
	footprint.global_position.x += x_offset
	footprint.global_position.y += y_offset
	# Set z-index to ensure footprints appear below the potato
	footprint.z_index = ConstantZIndexes.Z_INDEX.FOOTPRINTS

	# Add the footprint to a group for easier management
	footprint.add_to_group("FootprintGroup")

	# Get the root node to add footprints
	var root = get_tree().current_scene
	root.add_child(footprint)

	# Store footprint
	footprints.append(footprint)

	# Fade out footprint
	var tween = create_tween()
	tween.tween_property(footprint, "modulate:a", 0.3, 3.0)

	# Limit the number of footprints
	if footprints.size() > max_footprints:
		var old_footprint = footprints.pop_front()
		if old_footprint and is_instance_valid(old_footprint):
			old_footprint.queue_free()


func _on_potato_button_pressed() -> void:
	interact_with_potato()


# TODO: Add error handling for these two functions incase the potato does not have a material
func _on_potato_button_mouse_entered() -> void:
	%PotatoSprite.material.set_shader_parameter("enable_highlight", true)


func _on_potato_button_mouse_exited() -> void:
	%PotatoSprite.material.set_shader_parameter("enable_highlight", false)


func is_potato_on_concrete() -> bool:
	var concrete_areas = get_tree().get_nodes_in_group("ConcreteAreas")
	for area in concrete_areas:
		if area is Polygon2D:
			# Convert global position to area's local coordinates
			var local_point = area.global_transform.affine_inverse() * self.global_position
			
			# Use Geometry2D to check if point is in polygon
			if Geometry2D.is_point_in_polygon(local_point, area.polygon):
				return true
	
	# Default to grass
	return false
