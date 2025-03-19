extends Node2D
class_name OfficeGateController

var gate_opened_this_shift: bool = false

@onready var gate: Node2D = $Gate
@onready var start_node: Node2D = $StartNode
@onready var end_node: Node2D = $EndNode
@onready var gate_audio: AudioStreamPlayer2D = $Gate/GateAudio

# Mechanical gate raising with multiple easing functions
func raise_gate(duration: float = 1.5):
	# Start gate raise sound
	gate_audio.stream = preload("res://assets/audio/environmental/gate_open.mp3")
	gate_audio.volume_db = 0
	gate_audio.bus = "SFX"  
	gate_audio.play()
	
	# Create a more complex tween with multiple easing functions
	var tween = create_tween()
	
	# Divide the movement into stages with different easing
	tween.set_parallel(true)
	
	# Stage 1: Initial slow, hesitant start (EASE_IN)
	tween.tween_property(gate, "position", 
		Vector2(gate.position.x, end_node.position.y * 0.8), 
		duration * 0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Stage 2: Quick jerk upwards (EASE_OUT with BACK transition for overshooting)
	tween.tween_property(gate, "position", 
		Vector2(gate.position.x, end_node.position.y * 1.1), 
		duration * 0.2
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(duration * 0.3)
	
	# Stage 3: Final settling with slight bounce (EASE_IN_OUT)
	tween.tween_property(gate, "position", 
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

func lower_gate(duration: float = 3.0):
	# Mechanical gate lowering with different easing
	gate_audio.stream = preload("res://assets/audio/environmental/gate_shut.mp3")
	gate_audio.volume_db = 0
	gate_audio.bus = "SFX"  
	gate_audio.play()
	
	# Create a more dynamic lowering tween
	var tween = create_tween()
	
	# Stage 1: Initial quick drop (EASE_IN with acceleration)
	tween.set_parallel(true)
	tween.tween_property(gate, "position", 
		Vector2(gate.position.x, start_node.position.y * 0.7), 
		duration * 0.4
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Stage 2: Sudden stop with slight bounce
	tween.tween_property(gate, "position", 
		Vector2(gate.position.x, start_node.position.y * 1.1), 
		duration * 0.3
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(duration * 0.4)
	
	# Stage 3: Final settling
	tween.tween_property(gate, "position", 
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
