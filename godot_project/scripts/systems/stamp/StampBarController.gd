class_name StampBarController
extends Node2D

# Signals
signal stamp_selected(stamp_type, stamp_texture)
signal stamp_requested(stamp_type, stamp_texture)
signal stamp_animation_started(stamp_type)
signal stamp_animation_completed(stamp_type)

# Constants for UI animation
const DURATION = 0.5

# Constants for stamp animation
const STAMP_ANIM_DURATION = 0.3
const STAMP_COOLDOWN = 1.0

@export var stamp_point_offset: Vector2 = Vector2(0, 80)  # Offset below the stamp bar

# Stamp textures
var stamp_textures = {"approve": null, "reject": null}  # These will be set in _ready()

# Result textures for final stamps
var stamp_result_textures = {
	"approve": preload("res://assets/stamps/approved_stamp.png"),
	"reject": preload("res://assets/stamps/denied_stamp.png")
}

# State tracking
var is_visible = false
var is_animating = false
var is_stamping = false
var stamp_cooldown_timer = 0.0
var current_stamp_type = ""
var current_stamp_texture: Texture2D
var last_mouse_position: Vector2

var alignment_guide: ColorRect
var is_showing_guide: bool = false

# References to other nodes
@onready var stamp_bar_audio: AudioStreamPlayer2D = $StampBar/StampBarAudio
@onready var passport: Sprite2D = $"../Passport"
@onready var stats_manager: Node = $"../../../SystemManagers/StatsManager"
@onready var sfx_player = $"../../../SystemManagers/AudioManager/SFXPool"

# REFACTORED: Cache DragAndDropManager reference (scene node, not autoload)
var drag_and_drop_manager: DragAndDropManager

# UI components
@onready var approval_stamp: TextureButton = %ApprovalButton
@onready var rejection_stamp: TextureButton = %RejectionButton
@onready var stamp_bar = $StampBar
@onready var toggle_position_button = $StampBar/Background/TogglePositionButton
@onready var start_node = $StartNode
@onready var end_node = $EndNode

@onready var stamp_point_marker: Sprite2D


func _ready():
	if not passport:
		push_error("Passport reference not set in StampBarController!")

	if not stats_manager:
		push_error("StatsManager reference not set in StampBarController!")

	# REFACTORED: Find DragAndDropManager in scene tree (not an autoload)
	# Search scene tree for DragAndDropManager using class name
	var root = get_tree().current_scene
	if root:
		for child in root.get_children():
			if child is DragAndDropManager:
				drag_and_drop_manager = child
				break
		# If not found as direct child, search deeper
		if not drag_and_drop_manager:
			drag_and_drop_manager = root.find_child("*", true, false) as DragAndDropManager
			# More targeted search using unique name
			if not drag_and_drop_manager:
				drag_and_drop_manager = get_node_or_null("%DragAndDropManager")

	# Initialize textures from the actual buttons
	stamp_textures["approve"] = approval_stamp.texture_normal
	stamp_textures["reject"] = rejection_stamp.texture_normal

	# Set initial position (hidden - at start_node position)
	stamp_bar.position = start_node.position

	# Connect toggle button signal (check if not already connected from scene)
	if not toggle_position_button.pressed.is_connected(_on_toggle_position_button_pressed):
		toggle_position_button.pressed.connect(_on_toggle_position_button_pressed)
	if not toggle_position_button.mouse_entered.is_connected(_on_toggle_position_button_mouse_entered):
		toggle_position_button.mouse_entered.connect(_on_toggle_position_button_mouse_entered)

	# Connect stamp buttons
	approval_stamp.pressed.connect(
		func():
			# Don't perform any stamp application logic here
			# Just emit the signal
			emit_signal("stamp_selected", "approve", stamp_textures["approve"])
	)

	rejection_stamp.pressed.connect(
		func():
			# Don't perform any stamp application logic here
			# Just emit the signal
			emit_signal("stamp_selected", "reject", stamp_textures["reject"])
	)

	# Ensure toggle button is visible
	toggle_position_button.visible = true
	# Create a visual indicator for the stamp point (only visible in debug)
	stamp_point_marker = Sprite2D.new()
	# Create this small texture
	stamp_point_marker.texture = preload("res://assets/stamps/stamp_point_marker.png")
	stamp_point_marker.position = stamp_point_offset
	stamp_point_marker.scale = Vector2(0.5, 0.5)

	# Only show in debug mode
	if OS.is_debug_build():
		add_child(stamp_point_marker)

	# Calculate the fixed stamp position
	update_stamp_position()

	# Create alignment guide
	alignment_guide = ColorRect.new()
	alignment_guide.color = Color(0.2, 0.8, 0.2, 0.3)  # Semi-transparent green
	alignment_guide.size = Vector2(100, 50)  # Size of the guide
	alignment_guide.position = stamp_point_offset - Vector2(50, 25)  # Center on stamp point
	alignment_guide.visible = false
	add_child(alignment_guide)


func _process(delta):
	# Update cooldown timer
	if stamp_cooldown_timer > 0:
		stamp_cooldown_timer -= delta

	# Show guide when a passport is being dragged near the stamp area
	# REFACTORED: Use cached drag_and_drop_manager reference instead of get_node
	if drag_and_drop_manager and drag_and_drop_manager.has_method("get_dragged_item"):
		var dragged_item = drag_and_drop_manager.get_dragged_item()
		if dragged_item and dragged_item.name == "Passport":
			var distance = dragged_item.global_position.distance_to(
				global_position + stamp_point_offset
			)

			# Show guide when passport is near the stamp position
			if distance < 200 and !is_showing_guide:
				show_alignment_guide()
			elif distance >= 200 and is_showing_guide:
				hide_alignment_guide()
		elif is_showing_guide:
			hide_alignment_guide()


func _input(event):
	# Track mouse position for stamp placement
	if event is InputEventMouseMotion:
		last_mouse_position = event.global_position


func update_stamp_position():
	# This updates the global position of the stamp point based on the stamp bar's position
	var global_stamp_point = global_position + stamp_point_offset
	if stamp_point_marker:
		stamp_point_marker.global_position = global_stamp_point


# UI Management Functions
func _on_toggle_position_button_pressed():
	if !is_animating:
		if is_visible:
			hide_stamp_bar()
		else:
			show_stamp_bar()


func show_alignment_guide():
	alignment_guide.visible = true
	is_showing_guide = true

	# Add animation for better visibility
	var tween = create_tween()
	tween.tween_property(alignment_guide, "modulate", Color(1, 1, 1, 1), 0.3)


func hide_alignment_guide():
	var tween = create_tween()
	tween.tween_property(alignment_guide, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_callback(func(): alignment_guide.visible = false)
	is_showing_guide = false


func show_stamp_bar():
	is_animating = true

	# Mechanical gate lowering with different easing
	stamp_bar_audio.stream = preload("res://scripts/systems/stamp/audio/stamp_bar_slide.mp3")
	stamp_bar_audio.volume_db = 0
	stamp_bar_audio.bus = "SFX"
	stamp_bar_audio.play()

	# Create a more dynamic lowering tween
	var tween = create_tween()

	# Stage 1: Initial quick move (EASE_IN with acceleration)
	tween.set_parallel(true)
	(
		tween
		. tween_property(
			stamp_bar,
			"position",
			Vector2(stamp_bar.position.x, end_node.position.y * 0.7),
			DURATION * 0.3
		)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_IN)
	)

	# Stage 2: Sudden stop with slight bounce
	(
		tween
		. tween_property(
			stamp_bar,
			"position",
			Vector2(stamp_bar.position.x, end_node.position.y * 1.2),
			DURATION * 0.4
		)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
		. set_delay(DURATION * 0.2)
	)

	# Stage 3: Final settling
	(
		tween
		. tween_property(stamp_bar, "position", end_node.position, DURATION)
		. set_trans(Tween.TRANS_BOUNCE)
		. set_ease(Tween.EASE_OUT)
		. set_delay(DURATION * 0.4)
	)

	# Optional heavy impact sound or screen shake
	tween.chain().tween_callback(
		func():
			# Find the main game node (assuming it has a shake_screen method)
			var main_game = get_tree().current_scene
			if main_game and main_game.has_method("shake_screen"):
				main_game.shake_screen(8.0, 0.3)  # Stronger shake for slamming
	)
	# When complete
	tween.chain().tween_callback(
		func():
			is_animating = false
			is_visible = true
	)


func hide_stamp_bar():
	is_animating = true

	# Mechanical gate lowering with different easing
	# We only play the sound because show_stamp_bar() sets and configures the sound
	stamp_bar_audio.play()

	# Create a more dynamic lowering tween
	var tween = create_tween()

	# Stage 1: Initial quick drop (EASE_IN with acceleration)
	tween.set_parallel(true)
	(
		tween
		. tween_property(
			stamp_bar,
			"position",
			Vector2(stamp_bar.position.x, start_node.position.y * 0.7),
			DURATION * 0.3
		)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_IN)
	)

	# Stage 2: Sudden stop with slight bounce
	(
		tween
		. tween_property(
			stamp_bar,
			"position",
			Vector2(stamp_bar.position.x, start_node.position.y * 1.2),
			DURATION * 0.4
		)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
		. set_delay(DURATION * 0.2)
	)

	# Stage 3: Final settling
	(
		tween
		. tween_property(stamp_bar, "position", start_node.position, DURATION)
		. set_trans(Tween.TRANS_BOUNCE)
		. set_ease(Tween.EASE_OUT)
		. set_delay(DURATION * 0.4)
	)

	# Optional heavy impact sound or screen shake
	tween.chain().tween_callback(
		func():
			# Find the main game node (assuming it has a shake_screen method)
			var main_game = get_tree().current_scene
			if main_game and main_game.has_method("shake_screen"):
				main_game.shake_screen(8.0, 0.3)  # Stronger shake for slamming
	)
	# When complete
	tween.chain().tween_callback(
		func():
			is_animating = false
			is_visible = false
	)


# Call this from game logic to force-hide the stamp bar
func force_hide():
	if is_visible and !is_animating:
		hide_stamp_bar()


# Stamp Logic Functions
# When a stamp button is pressed
func _on_stamp_button_pressed(stamp_type):
	if is_stamping or stamp_cooldown_timer > 0:
		return

	print("Stamp button pressed: ", stamp_type)
	current_stamp_type = stamp_type
	current_stamp_texture = stamp_textures[stamp_type]

	# Emit both signals for compatibility
	emit_signal("stamp_selected", stamp_type, current_stamp_texture)
	emit_signal("stamp_requested", stamp_type, current_stamp_texture)


## Get the center position of the currently active stamp button.
## @param current_stamp_type The stamp type ("approve" or "reject").
## @return The global position at the center of the stamp button.
func get_stamp_origin(current_stamp_type) -> Vector2:
	var stamp_button = null
	var stamp_origin = null

	# Figure out if it's an approval or rejection stamp
	if current_stamp_type == "approve":
		stamp_button = approval_stamp
		stamp_origin = stamp_button.global_position
	else:
		stamp_button = rejection_stamp
		stamp_origin = stamp_button.global_position

	# Adjust to be at the center of the stamp
	stamp_origin.y += stamp_button.size.y / 2
	stamp_origin.x += stamp_button.size.x / 2
	return stamp_origin


func animate_stamp(stamp_type: String, target_position: Vector2):
	# Show animation of stamp moving from button to target
	# This doesn't actually apply a stamp to any document

	# Create temporary stamp for animation only
	var temp_stamp = Sprite2D.new()
	temp_stamp.texture = stamp_textures[stamp_type]
	temp_stamp.z_index = 20
	temp_stamp.z_as_relative = false

	# Start from the appropriate button
	var start_pos = get_stamp_origin(stamp_type)
	temp_stamp.global_position = start_pos

	add_child(temp_stamp)

	# Play sound effect
	play_random_stamp_sound()

	# Animate stamp movement
	var tween = create_tween()
	tween.tween_property(temp_stamp, "global_position", target_position, STAMP_ANIM_DURATION / 2)

	# Return animation
	var return_tween = create_tween()
	return_tween.tween_property(temp_stamp, "global_position", start_pos, STAMP_ANIM_DURATION / 2)
	return_tween.tween_callback(func(): temp_stamp.queue_free())


# Play a random stamp sound effect
func play_random_stamp_sound():
	var stamp_sounds = []

	# Try to load sound effects
	for i in range(1, 6):
		var sound_path = "res://assets/audio/mechanical/stamp_sound_" + str(i) + ".mp3"
		var sound = load(sound_path)
		if sound:
			stamp_sounds.append(sound)
		else:
			push_warning("Could not load stamp sound: " + sound_path)

	if sfx_player and stamp_sounds.size() > 0:
		sfx_player.stream = stamp_sounds[randi() % stamp_sounds.size()]
		sfx_player.play()
	else:
		push_warning("STAMP CONTROLLER: NO AUDIO SETUP FOR STAMPS")


# Create the final stamp on the document
func create_final_stamp(stamp_type: String, pos: Vector2):
	var final_stamp = Sprite2D.new()
	final_stamp.texture = stamp_result_textures[stamp_type]

	# Get the OpenPassport node (assuming similar structure as in StampCrossbarSystem)
	var open_passport = passport.get_node("OpenPassport")

	# Convert position to be relative to OpenPassport
	var relative_pos = passport.to_local(pos)
	relative_pos = open_passport.get_transform().affine_inverse() * relative_pos
	final_stamp.position = relative_pos

	final_stamp.modulate.a = 0  # Start invisible
	final_stamp.z_index = 0  # Ensure stamp appears above passport background
	final_stamp.z_as_relative = true

	# Add stamp to OpenPassport
	open_passport.add_child(final_stamp)

	# Find the main game node for screen shake
	var main_game = self
	while main_game and main_game.get_parent() and main_game.name != "Root":
		main_game = main_game.get_parent()

	# Trigger screen shake if available
	if main_game and main_game.has_method("shake_screen"):
		main_game.shake_screen(4.0, 0.2)  # Mild shake for stamping

	# Update stats if available
	if stats_manager:
		stats_manager.current_stats.total_stamps += 1
		var is_perfect = stats_manager.check_stamp_accuracy(final_stamp.global_position, passport)
		if is_perfect:
			stats_manager.current_stats.perfect_stamps += 1
			# REFACTORED: Global is an autoload, use direct reference
			Global.add_score(100)

	# Fade in the stamp
	var tween = create_tween()
	tween.tween_property(final_stamp, "modulate:a", 1.0, 0.1).set_delay(STAMP_ANIM_DURATION / 2)


# Hover sound for stamp bar
var hover_sound_stamp_bar = preload("res://assets/audio/ui_feedback/ui_hover_stamp_bar.mp3")


func _on_toggle_position_button_mouse_entered() -> void:
	_play_hover_sound(hover_sound_stamp_bar)


func _on_toggle_position_button_mouse_exited() -> void:
	pass


func _play_hover_sound(sound: AudioStream) -> void:
	var hover_player = AudioStreamPlayer.new()
	hover_player.stream = sound
	hover_player.bus = "SFX"
	hover_player.volume_db = -6.0
	hover_player.pitch_scale = randf_range(0.95, 1.05)
	add_child(hover_player)
	hover_player.play()
	hover_player.finished.connect(hover_player.queue_free)
