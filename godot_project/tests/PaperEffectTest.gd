extends Node2D

# Test script to demonstrate the paper crunch effect

@onready var paper_effect = preload("res://scripts/systems/PaperCrunchEffect.gd")


func _ready():
	# Set up a simple input handler for testing
	print("Click anywhere to test the paper crunch effect")


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Create the effect at mouse position
			var effect = paper_effect.new()
			add_child(effect)

			# Configure effect parameters
			effect.num_bits = 15  # More bits for testing
			effect.bit_lifetime = 1  # Longer lifetime to observe

			# Test with various intensities
			#var intensity = randf_range(0.7, 1.5)
			#effect.max_initial_velocity = 180.0 * intensity
			#effect.arc_height_factor = 100.0 * intensity

			# Spawn at mouse position
			effect.spawn_at(get_global_mouse_position())

			# Optional - play a paper sound
			# If you have SFX player access
			# $SFXPlayer.stream = preload("res://assets/audio/paper_crunch.wav")
			# $SFXPlayer.play()
