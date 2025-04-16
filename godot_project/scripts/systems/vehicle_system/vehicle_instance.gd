extends Node2D
## Basic vehicle node script.
##
## This script is attached to vehicle_instance.tscn and provides
## functionality for vehicles spawned by the vehicle_spawner system.
## Handles randomizing vehicle appearance from available frames.


func _ready() -> void:
	randomize_vehicle_appearance()


## Randomizes the vehicle appearance by
## selecting a random frame
## from the AnimatedSprite2D
func randomize_vehicle_appearance() -> void:
	var texture_node = $VehicleTexture

	# Random frame selection
	var random_frame = randi() % 54  # Hardcoded frame count

	# Set the selected frame
	texture_node.frame = random_frame

	# Add a slight color variation for additional uniqueness
	var hue_variation = randf_range(-0.05, 0.05)
	texture_node.modulate = texture_node.modulate.from_hsv(
		texture_node.modulate.h + hue_variation, texture_node.modulate.s, texture_node.modulate.v
	)
