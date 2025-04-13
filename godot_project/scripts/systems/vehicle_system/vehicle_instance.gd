extends Node2D
## Basic vehicle node script.
##
## This script is attached to vehicle_instance.tscn and provides
## functionality for vehicles spawned by the vehicle_spawner system.
## Handles randomizing vehicle appearance from available frames.

# Vehicle properties
@export var vehicle_type: String = "truck"

func _ready() -> void:
	randomize_vehicle_appearance()

## Randomizes the vehicle appearance by 
## selecting a random frame
## from the AnimatedSprite2D
func randomize_vehicle_appearance() -> void:
	if has_node("VehicleTexture"):
		var texture_node = get_node("VehicleTexture")
		
		# Check if the texture is using an AnimatedSprite2D
		if texture_node.texture is AnimatedSprite2D:
			var animated_texture = texture_node.texture
			var frame_count = animated_texture.frames
			
			# Only proceed if we have frames to choose from
			if frame_count > 0:
				# Random frame selection
				var random_frame = randi() % frame_count
				
				# Stop the animation if it's playing
				animated_texture.pause = true
				
				# Set the selected frame
				animated_texture.current_frame = random_frame
				
				# Add a slight color variation for additional uniqueness
				var hue_variation = randf_range(-0.05, 0.05)
				texture_node.modulate = texture_node.modulate.from_hsv(
					texture_node.modulate.h + hue_variation,
					texture_node.modulate.s,
					texture_node.modulate.v
				)
				
				# Store the vehicle type based on frame number
				match random_frame:
					0, 1, 2, 3, 4: vehicle_type = "car"
					5, 6, 7, 8, 9: vehicle_type = "truck" 
					10, 11: vehicle_type = "utility"
					12, 13, 14: vehicle_type = "transport"
					_: vehicle_type = "unknown"
