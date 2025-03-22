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

# Used to track whether the shutter was opened during this shift
# This is mainly used in the ShiftSummaryScreen at the end of mainGame.gd
var shutter_opened_this_shift: bool = false

# State tracking for the shutter
enum shutter_state {OPEN, CLOSED}
var active_shutter_state

# Shutter delay
var can_toggle_shutter_state: bool = true
@onready var shutter_state_delay: Timer = $ShutterStateDelay

func _process(_delta):
	if can_toggle_shutter_state:
		can_toggle_shutter_state = false
		shutter_state_delay.start()

# Mechanical shutter raising with multiple easing functions
func raise_shutter(duration: float = 1.5):
	active_shutter_state = shutter_state.OPEN
	
	# Start shutter raise sound
	shutter_audio.stream = preload("res://assets/office_shutter/shutter_open.mp3")
	shutter_audio.volume_db = 0
	shutter_audio.bus = "SFX"  
	shutter_audio.play()
	
	# Create a more complex tween with multiple easing functions
	var tween = create_tween()
	
	# Divide the movement into stages with different easing
	tween.set_parallel(true)
	
	# Stage 1: Initial slow, hesitant start (EASE_IN)
	tween.tween_property(shutter, "position", 
		Vector2(shutter.position.x, end_node.position.y * 0.8), 
		duration * 0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Stage 2: Quick jerk upwards (EASE_OUT with BACK transition for overshooting)
	tween.tween_property(shutter, "position", 
		Vector2(shutter.position.x, end_node.position.y * 1.1), 
		duration * 0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(duration * 0.3)
	
	# Stage 3: Final settling with slight bounce (EASE_IN_OUT)
	tween.tween_property(shutter, "position", 
		end_node.position, 
		duration * 0.5
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(duration * 0.5)
	
	# Optional screen shake for mechanical feel
	tween.chain().tween_callback(func(): 
		# Find the main game node (assuming it has a shake_screen method)
		var main_game = get_tree().current_scene
		if main_game and main_game.has_method("shake_screen"):
			main_game.shake_screen(4.0, 0.2)  # Mild shake
	)

func lower_shutter(duration: float = 3.0):
	active_shutter_state = shutter_state.CLOSED
	
	# Mechanical shutter lowering with different easing
	shutter_audio.stream = preload("res://assets/office_shutter/shutter_shut.mp3")
	shutter_audio.volume_db = 0
	shutter_audio.bus = "SFX"  
	shutter_audio.play()
	
	# Create a more dynamic lowering tween
	var tween = create_tween()
	
	# Stage 1: Initial quick drop (EASE_IN with acceleration)
	tween.set_parallel(true)
	tween.tween_property(shutter, "position", 
		Vector2(shutter.position.x, start_node.position.y * 0.7), 
		duration * 0.4
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Stage 2: Sudden stop with slight bounce
	tween.tween_property(shutter, "position", 
		Vector2(shutter.position.x, start_node.position.y * 1.1), 
		duration * 0.3
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(duration * 0.4)
	
	# Stage 3: Final settling
	tween.tween_property(shutter, "position", 
		start_node.position, 
		duration * 0.3
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(duration * 0.7)
	
	# Optional heavy impact sound or screen shake
	tween.chain().tween_callback(func(): 
		# Find the main game node (assuming it has a shake_screen method)
		var main_game = get_tree().current_scene
		if main_game and main_game.has_method("shake_screen"):
			main_game.shake_screen(8.0, 0.3)  # Stronger shake for slamming
	)

func shutter_state_toggle(toggled_on: bool) -> void:
	print("Shutter Lever pressed!")
	# Check current shutter state and toggle it
	if toggled_on:
		print("Attempt to shut shutter")
		# If the shutter is open, close it upon the click
		lower_shutter(1.5)
	else:
		print("Attempt to open shutter")
		# If the shutter is already closed, open it upon the click
		raise_shutter(1.5)


func allow_shutter_state_changes() -> void:
	can_toggle_shutter_state = true
