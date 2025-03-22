extends Node2D
class_name OfficeShutterController

# The texture of the shutter itself
@onready var shutter: Node2D = $shutter
# The position which the shutter begins the tweens, this is "closed"
@onready var start_node: Node2D = $StartNode
# The position which the shutter finishes the tweens, this is "opened"
@onready var end_node: Node2D = $EndNode

# The interactable UI which opens and closes the shutter
@onready var shutter_lever: Sprite2D = $ShutterLever

# Audio played during the tween of the shutter
@onready var shutter_audio: AudioStreamPlayer2D = $Shutter/ShutterAudioStream

# Used to track whether the shutter was opened during this shift
# TODO: I'm going to replace this with a shutter_open boolean, that will be used to determine the
# current state of the shutter and let the player freely open and close it using the shutter_level
# interactable.
var shutter_opened_this_shift: bool = false

func _ready():
	# Connect the input event signal for the ShutterLever
	if shutter_lever.has_node("Sprite2D"):
		var lever_sprite = shutter_lever.get_node("Sprite2D")
		lever_sprite.input_pickable = true
		lever_sprite.connect("input_event", _on_ShutterLever_input_event)
	else:
		push_error("Warning: ShutterLever or its Sprite2D not found")

# Handle input events on the ShutterLever
func _on_ShutterLever_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Player clicked on the ShutterLever!")
		# You can also add logic here to toggle the shutter
		if shutter.position.y == end_node.position.y:
			lower_shutter()
		else:
			raise_shutter()

# Mechanical shutter raising with multiple easing functions
func raise_shutter(duration: float = 1.5):
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
