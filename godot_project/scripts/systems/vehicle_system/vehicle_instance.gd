extends Node2D
## Basic vehicle node script.
##
## This script is attached to vehicle_instance.tscn and provides
## functionality for vehicles spawned by the vehicle_spawner system.

# You can add vehicle-specific properties here
@export var vehicle_type: String = "truck"

# Optional: Add your own custom initialization
func _ready() -> void:
	# You could randomize the vehicle appearance here
	# For example, by changing the texture or modulating the color
	if has_node("VehicleTexture"):
		var sprite = get_node("VehicleTexture")
		
		# Example: Random slight color variation
		var hue_variation = randf_range(-0.05, 0.05)
		sprite.modulate = sprite.modulate.from_hsv(
			sprite.modulate.h + hue_variation,
			sprite.modulate.s,
			sprite.modulate.v
		)

# Optional: Add custom behavior if needed
func _process(delta: float) -> void:
	# The movement is handled by the vehicle_spawner,
	# but you could add vehicle-specific animations or effects here
	pass
