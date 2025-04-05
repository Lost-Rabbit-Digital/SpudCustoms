extends Node2D
class_name OfficeShutterController

# The texture of the shutter itself
@onready var shutter: Node2D = $Shutter
# The position which the shutter begins the tweens, this is "closed"
@onready var start_node: Node2D = $StartNode
# The position which the shutter finishes the tweens, this is "opened"
@onready var end_node: Node2D = $EndNode
# Audio played during the tween of the shutter
@onready var shutter_audio: AudioStreamPlayer2D = $Shutter/ShutterAudioStream
# Lever animated sprite
@onready var lever_sprite: AnimatedSprite2D = $LeverButton/ShutterLever
# Lever button
@onready var lever_button: TextureButton = $LeverButton

# Used to track whether the shutter was opened during this shift
# This is mainly used in the ShiftSummaryScreen at the end of mainGame.gd
var shutter_opened_this_shift: bool = false

# State tracking for the shutter
enum shutter_state {OPEN, CLOSED}
var active_shutter_state = shutter_state.CLOSED

# Shutter delay
var can_toggle_shutter_state: bool = true
@onready var shutter_state_delay: Timer = $ShutterStateDelay

@export var character_generator: CharacterGenerator

func _ready():
	# Make sure we set up the animation frames for the lever
	if lever_sprite:
		# When shutter is CLOSED, lever is DOWN (frame 7)
		# When shutter is OPEN, lever is UP (frame 0)
		lever_sprite.frame = 7 if active_shutter_state == shutter_state.CLOSED else 0
	
	# Connect the button press signal
	if lever_button and not lever_button.pressed.is_connected(shutter_state_toggle):
		lever_button.pressed.connect(shutter_state_toggle)
		#print("Connected lever button pressed signal")

func _process(_delta):
	if can_toggle_shutter_state:
		can_toggle_shutter_state = false
		shutter_state_delay.start()

# Mechanical shutter raising with multiple easing functions
func raise_shutter(duration: float = 0.5):
	active_shutter_state = shutter_state.OPEN
	
	# Now we animate to UP position (frame 0) when opening
	animate_lever(true)  # true = animate to open/up position
	
	# Start shutter raise sound
	shutter_audio.stream = preload("res://assets/office_shutter/shutter_open.mp3")
	shutter_audio.volume_db = 0
	shutter_audio.bus = "SFX"
	shutter_audio.play()
	
	#print("Fading out the foreground shadow on potato due to shutter_lower()")
	# Play the shadow fade 0.5s faster than duration
	character_generator.fade_out_foreground_shadow(duration - 0.5)
	
	# Create a more complex tween with multiple easing functions
	var tween = create_tween()
	
	# Divide the movement into stages with different easing
	tween.set_parallel(true)
	
	# Stage 1: Initial slow, hesitant start (EASE_IN)
	tween.tween_property(shutter, "position", 
		Vector2(shutter.position.x, end_node.position.y), 
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Optional screen shake for mechanical feel
	tween.chain().tween_callback(func(): 
		# Find the main game node (assuming it has a shake_screen method)
		var main_game = get_tree().current_scene
		if main_game and main_game.has_method("shake_screen"):
			main_game.shake_screen(4.0, 0.2)  # Mild shake
	)

func lower_shutter(duration: float = 3.0):
	active_shutter_state = shutter_state.CLOSED
	
	# Now we animate to DOWN position (frame 7) when closing
	animate_lever(false)  # false = animate to closed/down position
	
	# Mechanical shutter lowering with different easing
	shutter_audio.stream = preload("res://assets/office_shutter/shutter_shut.mp3")
	shutter_audio.volume_db = 0
	shutter_audio.bus = "SFX"  
	shutter_audio.play()
	
	print("Fading in the foreground shadow on potato due to shutter_lower()")
	# Play the shadow fade 0.5s faster than duration
	character_generator.fade_in_foreground_shadow(duration - 0.5)
	
	# Create a more dynamic lowering tween
	var tween = create_tween()
	
	# Stage 1: Fast initial drop (with gravity-like acceleration)
	tween.tween_property(shutter, "position", 
		Vector2(shutter.position.x, start_node.position.y + 0.8),
		0.7 # Drop time
	).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)

	# Stage 2: Hard impact with significant bounce
	tween.tween_property(shutter, "position", 
		Vector2(shutter.position.x, start_node.position.y - 35), # Bounce height
		0.25 # Bounce time
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(0)

	# Stage 3: Final settling with smaller secondary bounce
	tween.tween_property(shutter, "position",
		start_node.position,
		0.25 # Settling time
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(0)
	
	# Optional heavy impact sound or screen shake
	tween.chain().tween_callback(func(): 
		# Find the main game node (assuming it has a shake_screen method)
		var main_game = get_tree().current_scene
		if main_game and main_game.has_method("shake_screen"):
			main_game.shake_screen(8.0, 0.3)  # Stronger shake for slamming
	)
	
# FIXED: Completely reworked this function to fix the animation
# Now, true = animate to UP position (frame 0), false = animate to DOWN position (frame 7)
func animate_lever(to_up: bool):
	if not lever_sprite:
		push_warning("lever_sprite is null")
		return
		
	# Stop any existing animation
	lever_sprite.stop()
	
	# Set target frame based on direction
	# FIXED: Swapped target frames - frame 0 is UP/open, frame 7 is DOWN/closed
	var target_frame = 0 if to_up else 7
	
	# Get current frame
	var starting_frame = lever_sprite.frame
	#print("Animating lever - starting frame: ", starting_frame, " target frame: ", target_frame)
	
	# Force animation even if starting frame is the same as target frame
	# This is needed when the shutter animation is triggered programmatically
	if starting_frame == target_frame:
		# If already at target frame, temporarily move to middle frame to force animation
		starting_frame = 4  # Middle frame
		lever_sprite.frame = starting_frame
		#print("Forcing animation from temporary middle frame")
	
	# Create a tween to animate through frames
	var tween = create_tween()
	
	# Calculate animation duration
	var frame_distance = abs(target_frame - starting_frame)
	var duration = frame_distance * 0.05  # 0.05 seconds per frame
	
	# FIXED: Reworked animation logic
	# If going to UP position (frame 0)
	if to_up:
		for i in range(starting_frame, -1, -1):
			var frame_index = i  # Capture the current value
			tween.tween_callback(func(): 
				lever_sprite.frame = frame_index
				#print("Setting lever frame to: ", frame_index)
			)
			tween.tween_interval(0.05)  # Wait between frames
	# If going to DOWN position (frame 7)
	else:
		for i in range(starting_frame, 8):
			var frame_index = i  # Capture the current value
			tween.tween_callback(func():
				lever_sprite.frame = frame_index
				#print("Setting lever frame to: ", frame_index)
			)
			tween.tween_interval(0.05)  # Wait between frames

func shutter_state_toggle() -> void:
	#print("Shutter Lever button pressed!")
	
	# Only proceed if we can toggle the state
	if not can_toggle_shutter_state:
		#print("Cannot toggle shutter state yet, on cooldown")
		pass
		#return
	
	# Check current shutter state and toggle it
	if active_shutter_state == shutter_state.CLOSED:
		#print("Attempt to open shutter")
		# If the shutter is closed, open it upon the click
		raise_shutter()
	else:
		#print("Attempt to shut shutter")
		# If the shutter is already open, close it upon the click
		lower_shutter(1.5)

func allow_shutter_state_changes() -> void:
	can_toggle_shutter_state = true
	#print("Shutter state changes now allowed")
