extends Node2D

var original_position: Vector2
var max_distance: float = 10.0  # Maximum distance from origin
var speed: float = 20.0  # Movement speed
var direction: Vector2 = Vector2.ZERO
var change_direction_time: float = 2.0  # Time before changing direction
var timer: float = 0.0

func _ready() -> void:
	original_position = global_position
	randomize()  # Initialize random number generator
	change_direction()

func _process(delta: float) -> void:
	timer += delta
	if timer >= change_direction_time:
		change_direction()
		timer = 0.0
	
	var movement = direction * speed * delta
	var new_position = global_position + movement
	
	# Check if new position is within bounds
	if new_position.distance_to(original_position) <= max_distance:
		global_position = new_position
	else:
		# If out of bounds, move back towards the origin
		direction = (original_position - global_position).normalized()

func change_direction() -> void:
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
