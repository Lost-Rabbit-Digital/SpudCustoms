extends Node2D
class_name OfficeGateController

var gate_opened_this_shift: bool = false

@onready var gate: Node2D = $Gate
@onready var start_node: Node2D = $StartNode
@onready var end_node: Node2D = $EndNode
@onready var gate_audio: AudioStreamPlayer2D = $Gate/GateAudio

# Raises the gate with animation
func raise_gate(duration: float = 2.0):
	# Calculate the target position (fully raised)
	
	# Create a tween for smoother animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Start gate raise sound
	# "D:\Godot\SpudCustoms\godot_project\assets\audio\mechanical\lever big 3.wav"
	# "D:\Godot\SpudCustoms\godot_project\assets\audio\mechanical\lever big 1.wav"
	# "D:\Godot\SpudCustoms\godot_project\assets\audio\mechanical\metal spinning 3.wav"
	
	gate_audio.stream = preload("res://assets/audio/environmental/gate_open.mp3")
	gate_audio.volume_db = 0
	gate_audio.bus = "SFX"  
	gate_audio.autoplay = true
	add_child(gate_audio)
	
	# Set up auto-cleanup after playing
	gate_audio.finished.connect(gate_audio.queue_free)
	
	# Animate the gate position
	tween.tween_property(gate, "position:y", end_node.y, duration)
	
	# Optional: Add slight screen shake for more impact
	#tween.tween_callback(func(): shake_screen(3.0, 0.2))

# Lowers the gate with animation
func lower_gate(duration: float = 1):
	# Calculate the target position (fully lowered)
	var end_node = Vector2(gate.position.x, 0)
	
	# Create a tween for smoother animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)  # Gives it a bit of "slam" effect
		
	gate_audio.stream = preload("res://assets/audio/environmental/gate_shut.mp3")
	gate_audio.volume_db = 0
	gate_audio.bus = "SFX"  
	gate_audio.autoplay = true
	add_child(gate_audio)
	
	# Animate the gate position
	tween.tween_property(gate, "position:y", end_node.y, duration)
	
	# Add screen shake for impact
	#tween.tween_callback(func(): shake_screen(8.0, 0.3))
