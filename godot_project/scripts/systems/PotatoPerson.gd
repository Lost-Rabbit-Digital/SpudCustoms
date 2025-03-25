extends Sprite2D
class_name PotatoPerson

# Signals
signal path_completed
signal state_changed(old_state, new_state)
signal destroyed(position)
	
# States
enum TaterState {
	QUEUED,
	IN_OFFICE,
	APPROVED,
	REJECTED,
	RUNNING,
	DESTROYED
}

# Properties
var potato_info: Dictionary = {}
var current_point: int = 0
var target_point: int = 0
var speed_multiplier: float = 1.0
var runner_base_speed: float = 0.35  # Default to Normal difficulty
var regular_path_speed: float = 0.50 # Default to Normal difficulty
var footprint_timer: float = 0.0
var footprint_interval: float = 0.15 # Time between footprints
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


## Potato state tracking
enum PotatoBrainState { IDLE, TALKING, THINKING, SURPRISED, HAPPY, SAD, ANGRY }
var current_state: = TaterState.QUEUED
var current_potato_brain_state: int = PotatoBrainState.IDLE

## Reference to the EmoteSystem node
var emote_system: Node
@onready var emote_sprite: AnimatedSprite2D = %PotatoEmote


func _ready() -> void:	
	# Find the PotatoEmote node in the scene
	var emote_sprite = $"./PotatoEmote"
	
	# Create a new instance of the emote system
	var emote_system_instance = PotatoEmoteSystem.new()
	add_child(emote_system_instance)
	
	# Initialize it with our sprite
	emote_system_instance.init(emote_sprite)
	
	# Update the reference to use this instance
	emote_system = emote_system_instance
	
	# Show thinking dots when the character first appears
	_show_thinking()
	
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
	# EXAMPLE: Random chance to show emote while idle
	if current_potato_brain_state == PotatoBrainState.IDLE and randf() < 0.001:  # 0.1% chance per frame
		_show_idle_emote()
	
	# Handle path following if on a path
	if current_path_follow and current_state != TaterState.IN_OFFICE:
		follow_path(delta)
		
	# Footprint creation
	if current_state == TaterState.APPROVED or current_state == TaterState.REJECTED or current_state == TaterState.RUNNING:
		footprint_timer += delta
		if footprint_timer >= footprint_interval:
			footprint_timer = 0
			spawn_footprint()

### EMOTE SYSTEM ###
## Changes the potato's brain state and shows an appropriate emote
## @param new_state The PotatoBrainState to transition to
func change_brain_state(new_state: int) -> void:
	current_potato_brain_state = new_state
	
	match new_state:
		PotatoBrainState.IDLE:
			# No emote for idle state
			emote_system.hide_emote()
		PotatoBrainState.TALKING:
			emote_system.show_thinking_dots(5.0)  # Show dots for 5 seconds
		PotatoBrainState.THINKING:
			_show_thinking()
		PotatoBrainState.SURPRISED:
			emote_system.show_emote(emote_system.EmoteType.DOUBLE_EXCLAMATION)
		PotatoBrainState.HAPPY:
			emote_system.show_random_emote_from_category("happy")
		PotatoBrainState.SAD:
			emote_system.show_emote(emote_system.EmoteType.SAD_FACE)
		PotatoBrainState.ANGRY:
			emote_system.show_emote(emote_system.EmoteType.ANGRY_FACE)

## Bind this to an input action or call it when the character is interacted with
func interact() -> void:
	# Show a happy emote when interacted with
	change_brain_state(PotatoBrainState.HAPPY)
	
	# Return to idle state after emote duration
	await get_tree().create_timer(emote_system.emote_duration).timeout
	change_brain_state(PotatoBrainState.IDLE)

## Shows the thinking dots animation
func _show_thinking() -> void:
	# Choose between dots or question mark
	if randf() < 0.7:  # 70% chance for dots
		emote_system.show_thinking_dots()
	else:
		emote_system.show_emote(emote_system.EmoteType.QUESTION)

## Shows a random idle emote based on mood probabilities
func _show_idle_emote() -> void:
	# Distribution: 40% happy, 30% thinking, 20% surprised, 10% negative
	var rand = randf()
	if rand < 0.4:
		emote_system.show_random_emote_from_category("happy")
	elif rand < 0.7:
		emote_system.show_random_emote_from_category("thinking")
	elif rand < 0.9:
		emote_system.show_random_emote_from_category("surprise")
	else:
		emote_system.show_random_emote_from_category("negative")

## Shows a love emote (heart)
func show_love() -> void:
	emote_system.show_emote(emote_system.EmoteType.SINGULAR_HEART)

## Shows anger
func show_anger() -> void:
	change_brain_state(PotatoBrainState.ANGRY)

## Shows confusion
func show_confusion() -> void:
	emote_system.show_emote(emote_system.EmoteType.CONFUSED)

### END OF POTATO EMOTE SYSTEM ###

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
			$Area2D/Sprite2D.visible = false
		TaterState.QUEUED, TaterState.APPROVED, TaterState.REJECTED, TaterState.RUNNING:
			# Show detailed view, hide silhouette
			$CharacterGenerator.visible = false
			# You might want to hide the silhouette when detailed view is shown
			$Area2D/Sprite2D.visible = true
		TaterState.DESTROYED:
			visible = false
			$Area2D/Sprite2D.visible = false
			
	# Update character appearance from character data if available
	if potato_info.has("character_data") and $CharacterGenerator:
		$CharacterGenerator.set_character_data(potato_info.character_data)
	
	# Update body sprite based on race if specified
	if potato_info.has("race") and potato_info.race in textures:
		# Apply the texture to the child sprite instead of self
		$Area2D/Sprite2D.texture = textures[potato_info.race]

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
			if current_state == TaterState.APPROVED or current_state == TaterState.REJECTED or current_state == TaterState.RUNNING:
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
	$Area2D/Sprite2D.visible = true
	
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
	footprint.texture = preload("res://assets/effects/footstep.png") # Create this small texture
	footprint.global_position = global_position
	footprint.global_position.y += 11
	footprint.z_index = 0 # Below the potato
	footprint.z_as_relative = true
	footprint.rotation = rotation # Align with movement direction
	footprint.modulate.a = 0.8
	
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
