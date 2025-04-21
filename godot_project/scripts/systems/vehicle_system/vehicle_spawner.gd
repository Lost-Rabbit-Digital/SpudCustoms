extends Node2D
## Handles spawning and management of vehicles that pass by on the screen.
##
## This system combines both the main controller and spawner functionality.
## It randomly spawns vehicles on either the left or right lane, moves them
## vertically up or down the screen, and removes them when they cross the desk border.
## Implementation is inspired by background vehicles in Papers Please.

# Enums for clear direction definition
enum Direction { DOWN = 0, UP = 1 }

# Exported variables for easy configuration in the editor
## The minimum time between vehicle spawns in seconds
@export_range(1.0, 30.0) var min_spawn_time: float = 5.0

## The maximum time between vehicle spawns in seconds
@export_range(1.0, 60.0) var max_spawn_time: float = 15.0

## The speed of the vehicles in pixels per second
@export_range(50.0, 500.0) var vehicle_speed: float = 150.0

## The horizontal position of the left lane
@export var left_lane_x: float = 40.0

## The horizontal position of the right lane
@export var right_lane_x: float = 106.0

## The vertical position where vehicles start when moving downward
@export var top_spawn_y: float = -50.0

## The vertical position where vehicles start when moving upward
@export var bottom_spawn_y: float = 250.0

## The vertical position where vehicles are destroyed when moving downward
@export var bottom_despawn_y: float = 250.0

## The vertical position where vehicles are destroyed when moving upward
@export var top_despawn_y: float = -50.0

# Internal variables
var _spawn_timer: Timer
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _vehicle_scene: PackedScene


func _ready() -> void:
	# Load the vehicle scene
	_vehicle_scene = preload("res://scripts/systems/vehicle_system/vehicle_instance.tscn")
	if not _vehicle_scene:
		push_error("Failed to load vehicle_instance.tscn!")
		return

	# Initialize random number generator
	_rng.randomize()

	# Create and configure the spawn timer
	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)

	# Start the spawning process
	_schedule_next_spawn()

	print("Vehicle spawning system initialized!")


## Schedule the next vehicle spawn with random timing
func _schedule_next_spawn() -> void:
	var wait_time = _rng.randf_range(min_spawn_time, max_spawn_time)
	_spawn_timer.start(wait_time)


## Spawns a vehicle and sets its initial position and movement direction
func _spawn_vehicle() -> void:
	# Randomly choose direction (0 = down, 1 = up)
	var direction: int = _rng.randi() % 2

	# Instance the vehicle
	var vehicle = _vehicle_scene.instantiate()
	add_child(vehicle)

	# Set the default z-index for all vehicles
	vehicle.z_index = ConstantZIndexes.Z_INDEX.VEHICLES

	# Configure the vehicle based on direction
	if direction == Direction.DOWN:
		# Set initial position (top of screen)
		vehicle.position = Vector2(right_lane_x, top_spawn_y)

		# If the vehicle has a sprite, ensure it's facing down
		if vehicle.has_node("VehicleTexture"):
			# Rotate the vehicle to face downward
			vehicle.rotation_degrees = 180
	else:
		# Set initial position (bottom of screen)
		vehicle.position = Vector2(left_lane_x, bottom_spawn_y)

		# If the vehicle has a sprite, ensure it's facing up
		if vehicle.has_node("VehicleTexture"):
			# Rotate the vehicle to face upward
			vehicle.rotation_degrees = 0

	# Store the direction as a property on the vehicle instance for movement
	vehicle.set_meta("direction", direction)


## Process function to move all vehicles
func _process(delta: float) -> void:
	for vehicle in get_children():
		# Skip any child that isn't a vehicle (like our timer)
		if not vehicle.has_meta("direction"):
			continue

		var direction = vehicle.get_meta("direction")

		# Move the vehicle based on its direction
		if direction == Direction.DOWN:
			vehicle.position.y += vehicle_speed * delta

			# Define the desk border position (where vehicles should disappear)
			var desk_border_y = 580  # Adjust this to match your exact border position

			# Check if vehicle has reached the desk border
			if vehicle.position.y >= desk_border_y:
				# Remove the vehicle immediately when it reaches the border
				vehicle.queue_free()
				continue

			# If we didn't remove the vehicle, check standard despawn
			if vehicle.position.y > bottom_despawn_y:
				vehicle.queue_free()
		else:
			vehicle.position.y -= vehicle_speed * delta

			# Check if the vehicle should be removed
			if vehicle.position.y < top_despawn_y:
				vehicle.queue_free()


## Timer timeout handler - spawns a new vehicle and schedules the next spawn
func _on_spawn_timer_timeout() -> void:
	_spawn_vehicle()
	_schedule_next_spawn()
