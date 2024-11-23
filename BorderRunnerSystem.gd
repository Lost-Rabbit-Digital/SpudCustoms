extends Node2D
## Manages the spawning of runners, missile targeting, and giblet effects when potatoes are destroyed
class_name BorderRunnerSystem

@export_group("Debugging")
## Unlimited ammunition for fox hunting
@export var unlimited_missiles = false
## Force Spuds to run the border for your entertainment
@export var rapid_runners = false
##
@export var crater_spawn_on_click = false

@export_group("System References")
## Main root node of the game scene
@export var root_node: Node2D
## Manager for handling the potato queue
@export var queue_manager: Node2D
## Label used to display the current score
@export var score_label: Label
## Label used to display alerts and notifications to the player
@export var alert_label: Label

@export_group("Runner System")
@export_subgroup("Spawn Settings")
@export_range(0, 1, 0.001) var runner_chance: float = 0.025
## Minimum time that must pass between runner spawn attempts (Seconds)
@export var min_time_between_runs: float = 10 # Default: 10
## Maximum time that can pass between runner spawn attempts (Seconds)
@export var max_time_between_runs: float = 120 # Default: 120 seconds - 2 minutes
## Movement speed of runners along their escape path
@export var runner_speed: float = 0.14

@export_subgroup("Score Settings")
## Base score awarded for successfully catching a runner
@export var runner_base_points: int = 250
## Additional points awarded for perfect accuracy hits
@export var perfect_hit_bonus: int = 150
## Bonus points multiplier for consecutive successful catches
@export var streak_bonus: int = 100
## Points penalty when a runner successfully escapes
@export var escape_penalty: int = 500

## Settings controlling missile launch, targeting and explosion behavior
@export_group("Missile System")
## Speed at which missiles travel toward their target
@export var missile_speed: float = 550
## Initial height from which missiles are launched
@export var missile_start_height: float = 600
## Radius of explosion effect and damage area
@export var explosion_size: float = 50

@export_group("Crater System")
@export var crater_size_multiplier: float = 1.2  # Size multiplier for explosion craters

@export_group("Giblet System")
@export_subgroup("Visual Settings")
## Number of potato pieces that spawn when a runner is destroyed
@export var num_gibs: int = 40
## Size scaling applied to giblet sprites
@export var gib_scale: Vector2 = Vector2(0.35, 0.35)
## Duration giblets remain visible before disappearing
@export var gib_lifetime: float = 2.0

@export_subgroup("Physics Settings")
## Slowest initial speed for spawned giblets
@export var gib_min_speed: float = 250
## Fastest initial speed for spawned giblets
@export var gib_max_speed: float = 375
## Downward acceleration applied to giblets over time
@export var gib_gravity: float = 300
## Rotation speed applied to giblets while in motion
@export var gib_spin_speed: float = 13

# Audio/Visual node references
@onready var alarm_sound = $AlarmSound
@onready var explosion_sound = $ExplosionSound
@onready var missile_sound = $MissileSound
@onready var explosion_vfx = $ExplosionVFX
@onready var missile_sprite = $MissileSprite
@onready var smoke_particles = $MissileSprite/CPUParticles2D
@onready var crater_system = $CraterSystem

# Internal state tracking
var runner_streak: int = 0
var time_since_last_run: float = 0.0
var active_runner = null
var missile_active: bool = false
var missile_position: Vector2 = Vector2.ZERO
var missile_target: Vector2 = Vector2.ZERO
var explosion_active: bool = false
var explosion_position: Vector2 = Vector2.ZERO
var has_runner_escaped: bool = false
var gib_textures: Array = []
var difficulty_level


func _ready():
	# Create missile sprite if it doesn't exist
	if not missile_sprite:
		missile_sprite = Sprite2D.new()
		missile_sprite.texture = preload("res://assets/missiles/missile_sprite.png")
		add_child(missile_sprite)
	missile_sprite.visible = false
	missile_sprite.z_index = 15
	
	# Configure difficulty level and set runner chance based on difficulty level
	difficulty_level = Global.difficulty_level
	print("Setting Border Runner System to:" + difficulty_level)
	## Chance per second for a queued potato to attempt escape
	# 0.025 for Easy (1 per 40 seconds)
	# 0.042 for Normal (1 per 23 seconds)
	# 0.085 for Expert (1 per 11 seconds)
	match difficulty_level:
		"Easy":
			runner_speed = 0.10
			runner_chance = 0.025
		"Normal":
			runner_speed = 0.14
			runner_chance = 0.042
		"Expert":
			runner_speed = 0.16
			runner_chance = 0.085
		_: 
			runner_speed = 0.10
			runner_chance = 0.10
			
	if rapid_runners == true:
		runner_chance = 1.0

	if not queue_manager:
		push_error("BorderRunnerSystem: Could not find QueueManager!")
	print("BorderRunnerSystem initialized with chance: ", runner_chance)
	
	# Load gib textures
	for i in range(1, 9):  # Assuming you have 3 giblet sprites
		var texture = load("res://assets/potato_giblets/giblet_" + str(i) + ".png")
		if texture:
			gib_textures.append(texture)
		else:
			push_error("Failed to load giblet_" + str(i))
			
func _process(delta):
	if not queue_manager:
		print("No queue manager found!")
		return
	
	# Always update missile if active, regardless of runner state
	if missile_active:
		update_missile(delta)
	
	# Handle runner logic only if no missile is active
	if active_runner and not has_runner_escaped:
		update_runner(delta)
	elif not active_runner and not has_runner_escaped:
		time_since_last_run += delta
		if rapid_runners == true:
			min_time_between_runs = 1
			max_time_between_runs = 1
		
		if time_since_last_run >= randi_range(min_time_between_runs, max_time_between_runs):
			var roll = randf() # Random float between 0 and 1
			var threshold = runner_chance * delta # 10% chance per-frame probability
			
			# Runners cannot spawn more frequently than min_time_between_runs
			# After that minimum time, there's a 10% chance per second of spawning
			if roll < threshold:
				attempt_spawn_runner()

func attempt_spawn_runner():
	print("Attempting to spawn runner...")
	if queue_manager.potatoes.size() > 0 and not active_runner:
		var runner = queue_manager.remove_front_potato()
		if runner:
			print("Starting new runner")
			start_runner(runner)
			time_since_last_run = 0.0

func start_runner(potato):
	active_runner = potato
	has_runner_escaped = false
	
	# Play alarm and show alert
	alarm_sound.play()
	alert_label.visible = true
	alert_label.text = "BORDER RUNNER DETECTED!\nClick to launch missile!"
	alert_label.add_theme_color_override("font_color", Color.RED)
	
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(Callable(self, "clear_alert"))
	
	# Get all available runner paths
	var paths_node = $"../Gameplay/Paths/RunnerPaths"
	var available_paths = []
	
	# Collect all valid runner paths
	for child in paths_node.get_children():
		if child.name.begins_with("RunnerPath"):
			available_paths.append(child)
	
	if available_paths.is_empty():
		push_error("No runner paths found!")
		return
		
	# Randomly select a path
	var path = available_paths[randi() % available_paths.size()]
	print("Selected runner path: ", path.name)
		
	var path_follow = PathFollow2D.new()
	path_follow.rotates = false
	path.add_child(path_follow)
	path_follow.progress_ratio = 0.0
	
	# Add the potato to the path_follow
	if potato.get_parent():
		potato.get_parent().remove_child(potato)
	path_follow.add_child(potato)
	potato.position = Vector2.ZERO
	print("Runner setup complete")

func force_start_runner(potato):
	# If there's already an active runner, clean it up first
	if active_runner:
		clean_up_runner()
		
	print("Force starting runner with rejected potato")
	active_runner = potato
	has_runner_escaped = false
	
	# Play alarm and show alert
	alarm_sound.play()
	alert_label.visible = true
	alert_label.text = "BORDER RUNNER DETECTED!\nClick to launch missile!"
	alert_label.add_theme_color_override("font_color", Color.RED)
	
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(Callable(self, "clear_alert"))
	
	# Get all available runner paths
	var paths_node = $"../Gameplay/Paths/RunnerPaths"
	var available_paths = []
	
	# Collect all valid runner paths
	for child in paths_node.get_children():
		if child.name.begins_with("RunnerPath"):
			available_paths.append(child)
	
	if available_paths.is_empty():
		push_error("No runner paths found!")
		return
		
	# Randomly select a path
	var path = available_paths[randi() % available_paths.size()]
	print("Selected runner path: ", path.name)
	
	var path_follow = PathFollow2D.new()
	path_follow.rotates = false
	path.add_child(path_follow)
	path_follow.progress_ratio = 0.0
	
	# Add the potato to the path_follow
	if potato.get_parent():
		potato.get_parent().remove_child(potato)
	path_follow.add_child(potato)
	potato.position = Vector2.ZERO
	print("Forced runner setup complete")

func update_runner(delta):
	if not active_runner or has_runner_escaped:
		return
		
	var path_follow = active_runner.get_parent()
	if not path_follow or not path_follow is PathFollow2D:
		push_error("Runner's parent is not a PathFollow2D!")
		return
		
	path_follow.progress_ratio += delta * runner_speed
	
	# Check if runner reached the end
	if path_follow.progress_ratio >= 0.99 and not has_runner_escaped:
		print("Runner has reached the end")
		has_runner_escaped = true
		runner_escaped()

func runner_escaped():
	if not active_runner:
		return
		
	print("Runner has escaped!")
	runner_streak = 0
	root_node.strikes += 1
	
	# Apply score penalty
	root_node.score = max(0, root_node.score - escape_penalty)  # Prevent negative score
	score_label.text = "Score: {total_points}".format({
		"total_points": root_node.score
	})
	
	# Update alert to show penalty
	alert_label.visible = true
	alert_label.text = "Runner escaped!\nStrike added!\n-{penalty} points!".format({
		"penalty": escape_penalty
	})
	alert_label.add_theme_color_override("font_color", Color.RED)
	
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(Callable(self, "clear_alert"))
	
	clean_up_runner()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if active_runner and not missile_active and not has_runner_escaped:
				launch_missile(event.position)
			if unlimited_missiles == true:
				if not missile_active and not has_runner_escaped:
					launch_missile(event.position)

func _unhandled_input(event):
	if crater_spawn_on_click == true:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				if crater_system:
					var local_pos = crater_system.to_local(event.global_position)
					crater_system.add_crater(local_pos)

func launch_missile(target_pos):
	print("Launching missile at: ", target_pos)
	missile_active = true
	missile_target = target_pos
	
	# Start from bottom center of screen
	var viewport_rect = get_viewport_rect()
	missile_position = Vector2((viewport_rect.size.x / 2) + 200, viewport_rect.size.y - 1000)
	
	# Set up missile sprite
	missile_sprite.visible = true
	missile_sprite.position = missile_position
	missile_sprite.modulate.a = 1.0
	
	# Point missile toward target - add PI/2 to rotate 90 degrees since missile sprite points up
	var direction = (target_pos - missile_position).normalized()
	missile_sprite.rotation = direction.angle() + PI/2
	
	# Play activation and launch sound
	missile_sound.play()
	
	# Start particle emission and position at missile
	smoke_particles.rotation = missile_sprite.rotation - PI/2  # Adjust for particle direction
	print("Missile launched from: ", missile_position)

func update_missile(delta):
	if not missile_active:
		return
	
	print("Updating missile position")  # Debug print
	# Calculate direction and move missile
	var direction = (missile_target - missile_position).normalized()
	var distance_to_move = missile_speed * delta
	missile_position += direction * distance_to_move
	
	# Update sprite position and rotation
	missile_sprite.position = missile_position
	missile_sprite.rotation = direction.angle() + PI/2
	
	# Update smoke trail position and rotation
	smoke_particles.rotation = missile_sprite.rotation - PI/2
	
	# Check if missile reached target (use squared distance for efficiency)
	var distance_squared = missile_position.distance_squared_to(missile_target)
	print("Distance to target: ", sqrt(distance_squared))  # Debug print
	if distance_squared < 25: # 5 units squared
		print("Missile reached target!")
		trigger_explosion()

func trigger_explosion():
	print("Triggering explosion")
	explosion_active = true
	explosion_position = missile_position
	explosion_vfx.position = missile_position
	explosion_vfx.visible = true
	explosion_vfx.start_explosion()
	
	# Add crater at explosion position
	print("Invoking crater system")
	# Convert global explosion position to local coordinates for crater system
	if crater_system:
		var local_pos = crater_system.to_local(explosion_position)
		crater_system.add_crater(local_pos, crater_size_multiplier)
	
	missile_active = false
	missile_sprite.visible = false
	
	if explosion_sound:
		explosion_sound.play()
	
	check_runner_hit()

func check_runner_hit():
	if not active_runner:
		print("No active runner to check for hit")
		return
		
	var distance = active_runner.global_position.distance_to(explosion_position)
	print("Distance to runner: ", distance)
	
	if distance < explosion_size:
		handle_successful_hit()
	else:
		print("Missile missed the runner")
		runner_streak = 0

func handle_successful_hit():
	# Spawn gibs at the runner's position before cleaning it up
	spawn_gibs(active_runner.global_position)
	
	runner_streak += 1
	var points_earned = runner_base_points
	var bonus_text = ""
	
	# Calculate bonuses
	var distance = active_runner.global_position.distance_to(explosion_position)
	if distance < explosion_size / 3:
		# Spawn even more gibs on a perfect hit
		spawn_gibs(active_runner.global_position)
		points_earned += perfect_hit_bonus
		bonus_text += "PERFECT HIT! +{perfect} accuracy bonus points\n".format({"perfect": perfect_hit_bonus})
	
	if runner_streak > 1:
		var streak_points = streak_bonus * (runner_streak - 1)
		points_earned += streak_points
		bonus_text += "COMBO x{mult}! +{streak} combo bonus points\n".format({
			"mult": runner_streak,
			"streak": streak_points
		})
	
	# Remove a strike if any present
	if root_node.strikes > 0:
		root_node.strikes -= 1
		bonus_text += "Strike removed!\n"
	
	# Add points
	root_node.score += points_earned
	score_label.text = "Score: {total_points}".format({
		"total_points": root_node.score
	})

	# Update display
	alert_label.visible = true
	alert_label.text = "{bonus} +{points} points!".format({
		"bonus": bonus_text,
		"points": points_earned
	})
	alert_label.add_theme_color_override("font_color", Color.GREEN)
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(Callable(self, "clear_alert"))
	clean_up_runner()
	
func clean_up_runner():
	print("Cleaning up runner")
	if active_runner:
		var path_follow = active_runner.get_parent()
		if path_follow:
			path_follow.queue_free()
		active_runner.queue_free()
		active_runner = null
	
	has_runner_escaped = false
	missile_active = false
	time_since_last_run = 0
	print("Runner cleanup complete")

func clear_alert():
	alert_label.visible = false
	alert_label.add_theme_color_override("font_color", Color.WHITE)

class Gib extends Sprite2D:
	var velocity = Vector2.ZERO
	var spin = 0.0
	var lifetime = 0.0
	var max_lifetime = 1.0
	
	func _process(delta):
		# Update position
		position += velocity * delta
		
		# Apply gravity
		velocity.y += get_parent().gib_gravity * delta
		
		# Rotate
		rotation += spin * delta
		
		# Update lifetime and fade
		lifetime += delta
		modulate.a = 1.0 - (lifetime / max_lifetime)
		
		# Remove when lifetime expires
		if lifetime >= max_lifetime:
			queue_free()

# Function to spawn gibs
func spawn_gibs(pos):
	if gib_textures.size() == 0:
		push_error("No gib textures loaded!")
		return
		
	for i in range(num_gibs):
		var gib = Gib.new()
		add_child(gib)
		
		gib.z_index = 20
		gib.z_as_relative = false
		
		# Set random gib texture
		gib.texture = gib_textures[randi() % gib_textures.size()]
		
		# Set initial position
		gib.position = pos
		
		# Set random velocity
		var angle = randf_range(-PI, 0)  # Only spawn in upward half-circle (-180° to 0°)
		var speed = randf_range(gib_min_speed, gib_max_speed)
		gib.velocity = Vector2(cos(angle), sin(angle)) * speed
		
		# Set random rotation and spin
		gib.rotation = randf() * 2 * PI
		gib.spin = randf_range(-gib_spin_speed, gib_spin_speed)
		
		# Set lifetime
		gib.max_lifetime = gib_lifetime
		
		# Set scale
		gib.scale = gib_scale  # Adjust this based on your gib sprite sizes

class StampStats:
	var total_stamps: int = 0
	var perfect_stamps: int = 0
	var potatoes_approved: int = 0
	var potatoes_rejected: int = 0
	var missiles_fired: int = 0
	var missiles_hit: int = 0
	var perfect_hits: int = 0
	var time_taken: float = 0.0

	func get_accuracy_bonus() -> int:
		return perfect_stamps * 100  # 100 points per perfect stamp

var shift_stats = StampStats.new()

func check_stamp_accuracy(stamp_pos: Vector2, passport: Node2D) -> bool:
	# Get the visa outline rectangle in global coordinates
	var visa_rect = Rect2(
		passport.global_position + Vector2(20, 20),  # Adjust based on your visa position
		Vector2(160, 80)  # Adjust based on your visa size
	)
	
	# Get stamp rectangle
	var stamp_rect = Rect2(
		stamp_pos - Vector2(25, 25),  # Half stamp size
		Vector2(50, 50)  # Stamp size
	)
	
	# Calculate overlap percentage
	var overlap_area = stamp_rect.intersection(visa_rect).get_area()
	var stamp_area = stamp_rect.get_area()
	
	var accuracy = overlap_area / stamp_area
	
	# Return true if within 10% of perfect placement
	return abs(1.0 - accuracy) <= 0.1
