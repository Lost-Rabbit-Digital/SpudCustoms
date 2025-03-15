# StampBarController.gd
extends Node2D

# References to other nodes
@onready var passport: Sprite2D = $"../Passport"
@onready var stats_manager: Node = $"../../../SystemManagers/StatsManager"
@onready var sfx_player = $"../../../SystemManagers/AudioManager/SFXPool"

# UI components
@onready var approval_stamp: TextureButton = %ApprovalButton
@onready var rejection_stamp: TextureButton = %RejectionButton
@onready var stamp_bar = $StampBar
@onready var fold_out_button = $FoldOutButton
@onready var hide_button = $StampBar/HideButton

# Stamp textures
var stamp_textures = {
	"approve": null,  # These will be set in _ready()
	"reject": null
}

# Result textures for final stamps
var stamp_result_textures = {
	"approve": preload("res://assets/stamps/approved_stamp.png"),
	"reject": preload("res://assets/stamps/denied_stamp.png")
}

# Constants for UI animation
const HIDDEN_X = -625  # Position when bar is hidden
const SHOWN_X = -10    # Position when bar is visible
const TWEEN_DURATION = 0.5

# Constants for stamp animation
const STAMP_ANIM_DURATION = 0.3
const STAMP_COOLDOWN = 1.0

# State tracking
var is_visible = false
var is_animating = false
var is_stamping = false
var stamp_cooldown_timer = 0.0
var current_stamp_type = ""
var current_stamp_texture: Texture2D
var last_mouse_position: Vector2

# Signals
signal stamp_selected(stamp_type, stamp_texture)
signal stamp_requested(stamp_type, stamp_texture)
signal stamp_animation_started(stamp_type)
signal stamp_animation_completed(stamp_type)

func _ready():
	if not passport:
		push_error("Passport reference not set in StampBarController!")
	
	if not stats_manager:
		push_error("StatsManager reference not set in StampBarController!")
	
	# Initialize textures from the actual buttons
	stamp_textures["approve"] = approval_stamp.texture_normal
	stamp_textures["reject"] = rejection_stamp.texture_normal
	
	# Set initial position (hidden)
	stamp_bar.position.x = HIDDEN_X
	
	# Connect button signals
	fold_out_button.pressed.connect(_on_fold_out_pressed)
	hide_button.pressed.connect(_on_hide_pressed)
	
	# Connect stamp buttons
	approval_stamp.pressed.connect(func():
		# Don't perform any stamp application logic here
		# Just emit the signal
		emit_signal("stamp_selected", "approve", stamp_textures["approve"])
	)

	rejection_stamp.pressed.connect(func():
		# Don't perform any stamp application logic here
		# Just emit the signal
		emit_signal("stamp_selected", "reject", stamp_textures["reject"])
	)
	
	# Show the fold-out button initially
	fold_out_button.visible = true
	fold_out_button.modulate.a = 1.0
	
func _process(delta):
	# Update cooldown timer
	if stamp_cooldown_timer > 0:
		stamp_cooldown_timer -= delta

func _input(event):
	# Track mouse position for stamp placement
	if event is InputEventMouseMotion:
		last_mouse_position = event.global_position

# UI Management Functions
func _on_fold_out_pressed():
	if !is_animating and !is_visible:
		show_stamp_bar()

func _on_hide_pressed():
	if !is_animating and is_visible:
		hide_stamp_bar()

func show_stamp_bar():
	is_animating = true
	
	# Create tween for showing stamp bar
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move stamp bar in
	tween.tween_property(stamp_bar, "position:x", SHOWN_X, TWEEN_DURATION)\
		 .set_trans(Tween.TRANS_CUBIC)\
		 .set_ease(Tween.EASE_OUT)
	
	# Fade out fold button
	tween.tween_property(fold_out_button, "modulate:a", 0.0, TWEEN_DURATION/2)
	
	# When complete
	tween.chain().tween_callback(func():
		fold_out_button.visible = false
		is_animating = false
		is_visible = true
	)

func hide_stamp_bar():
	is_animating = true
	
	# Create tween for hiding stamp bar
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move stamp bar out
	tween.tween_property(stamp_bar, "position:x", HIDDEN_X, TWEEN_DURATION)\
		 .set_trans(Tween.TRANS_CUBIC)\
		 .set_ease(Tween.EASE_OUT)
	
	# Show fold button
	fold_out_button.visible = true
	tween.tween_property(fold_out_button, "modulate:a", 1.0, TWEEN_DURATION/2)\
		 .set_delay(TWEEN_DURATION/2)
	
	# When complete
	tween.chain().tween_callback(func():
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
	
# Get the position of the currently active stamp button
func get_stamp_origin() -> Vector2:
	var stamp_button = approval_stamp if current_stamp_type == "approve" else rejection_stamp
	var origin = stamp_button.global_position
	
	# Adjust to be at the center of the stamp
	origin.y += stamp_button.size.y / 2
	origin.x += stamp_button.size.x / 2
	return origin

func animate_stamp(stamp_type: String, target_position: Vector2):
	# Show animation of stamp moving from button to target
	# This doesn't actually apply a stamp to any document
	
	# Create temporary stamp for animation only
	var temp_stamp = Sprite2D.new()
	temp_stamp.texture = stamp_textures[stamp_type]
	temp_stamp.z_index = 20
	
	# Start from the appropriate button
	var start_pos = get_stamp_origin()
	temp_stamp.global_position = start_pos
	
	add_child(temp_stamp)
	
	# Play sound effect
	play_random_stamp_sound()
	
	# Animate stamp movement
	var tween = create_tween()
	tween.tween_property(temp_stamp, "global_position", target_position, STAMP_ANIM_DURATION/2)
	
	# Return animation
	var return_tween = create_tween()
	return_tween.tween_property(temp_stamp, "global_position", start_pos, STAMP_ANIM_DURATION/2)
	return_tween.tween_callback(func():
		temp_stamp.queue_free()
	)

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
	final_stamp.z_index = 1  # Ensure stamp appears above passport background
	
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
		var is_perfect = stats_manager.check_stamp_accuracy(
			final_stamp.global_position,
			passport
		)
		if is_perfect:
			stats_manager.current_stats.perfect_stamps += 1
			# Add bonus for perfect stamp if Global is available
			if get_node_or_null("/root/Global"):
				Global.add_score(100)
	
	# Fade in the stamp
	var tween = create_tween()
	tween.tween_property(final_stamp, "modulate:a", 1.0, 0.1)\
		 .set_delay(STAMP_ANIM_DURATION/2)
