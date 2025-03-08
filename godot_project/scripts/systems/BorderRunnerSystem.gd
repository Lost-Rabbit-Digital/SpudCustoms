extends Node2D
## Manages the spawning of runners, missile targeting, and giblet effects when potatoes are destroyed
class_name BorderRunnerSystem
signal game_over_triggered

@export_group("Debugging")
## Unlimited ammunition for fox hunting
@export var unlimited_missiles = false
## Force Spuds to run the border for your entertainment
@export var rapid_runners = false
## Generates a crater sprite where you click
@export var crater_spawn_on_click = false

@export_group("System References")
## Manager for handling the potato queue
@export var queue_manager: Node2D
## Label used to display the current score
@export var score_label: Label
## Label used to display strikes
@export var strike_label: Label
## Label used to display alerts and notifications to the player
@export var alert_label: Label
@export var alert_timer: Timer
@export var missile_collision_shape: CollisionShape2D  # Reference to missile zone shape

@export_group("Runner System")
@export_subgroup("Spawn Settings")
## Maximum number of simultaneous runners 
@export var max_active_runners: int = 3
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
## Maximum number of simultaneous missiles
@export var max_missiles: int = 3
## Cooldown time between missile launches (seconds)
@export var missile_cooldown: float = 1.0
## Speed at which missiles travel toward their target
@export var missile_speed: float = 1200
## Initial height from which missiles are launched
@export var missile_start_height: float = 400
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
@onready var shift_stats = ShiftStats.new()

# Internal state tracking
var is_enabled = true  # Track if system is enabled
var is_in_dialogic = false # Track if game is in dialogue mode
var runner_streak: int = 0
var time_since_last_run: float = 0.0
var active_runners = []  # Array of active runners
var active_missiles = []  # Array of active missiles
var missile_cooldown_timer: float = 0.0
var gib_textures: Array = []
var difficulty_level

# Missile class to track multiple missiles
class Missile:
	var sprite: Sprite2D
	var particles: GPUParticles2D
	var position: Vector2
	var target: Vector2
	var rotation: float
	var active: bool = true

	func _init(sprite_texture, particle_scene):
		sprite = Sprite2D.new()
		sprite.texture = sprite_texture
		sprite.visible = true
		sprite.z_index = 15
		
		if particle_scene:
			particles = particle_scene.duplicate()
			sprite.add_child(particles)

# Runner class to track multiple border runners
class Runner:
	var potato: Node2D
	var path_follow: PathFollow2D
	var has_escaped: bool = false
	
	func _init(p, pf):
		potato = p
		path_follow = pf
	
	func update(delta, speed):
		if not potato or not path_follow or has_escaped:
			return false
		
		path_follow.progress_ratio += delta * speed
		
		# Check if runner reached the end
		if path_follow.progress_ratio >= 0.99:
			has_escaped = true
			return true
		return false
	
	func get_position() -> Vector2:
		if potato:
			return potato.global_position
		return Vector2.ZERO
	
	func cleanup():
		if path_follow:
			path_follow.queue_free()
		if potato:
			potato.queue_free()

func _ready():
	# Create missile sprite if it doesn't exist
	if not missile_sprite:
		missile_sprite = Sprite2D.new()
		missile_sprite.texture = preload("res://assets/missiles/missile_sprite.png")
		add_child(missile_sprite)
	missile_sprite.visible = false
	missile_sprite.z_index = 15
	
	if missile_collision_shape == null:
		missile_collision_shape = $Area2D/CollisionShape2D
	
	# Configure difficulty level and set runner chance based on difficulty level
	difficulty_level = Global.difficulty_level
	print("Setting Border Runner System to:", difficulty_level)
	
	match difficulty_level:
		"Easy":
			runner_speed = 0.10
			runner_chance = 0.025
			max_active_runners = 1
		"Normal":
			runner_speed = 0.14
			runner_chance = 0.042
			max_active_runners = 2
		"Expert":
			runner_speed = 0.16
			runner_chance = 0.085
			max_active_runners = 3
		_: 
			runner_speed = 0.10
			runner_chance = 0.10
			max_active_runners = 2
			
	if rapid_runners:
		runner_chance = 1.0

	if not queue_manager:
		push_error("BorderRunnerSystem: Could not find QueueManager!")
	print("BorderRunnerSystem initialized with chance: ", runner_chance)
	
	# Load gib textures
	for i in range(1, 9):
		var texture = load("res://assets/potato_giblets/giblet_" + str(i) + ".png")
		if texture:
			gib_textures.append(texture)
		else:
			push_error("Failed to load giblet_" + str(i))
			
func _process(delta):
	if not is_enabled or is_in_dialogic:
		return
		
	if get_tree().paused:
		return

	
	if not queue_manager:
		print("No queue manager found!")
		return
	
	# Update missile cooldown timer
	if missile_cooldown_timer > 0:
		missile_cooldown_timer -= delta
	
	# Update all active missiles
	update_missiles(delta)
	
	# Update all active runners
	update_runners(delta)
	
	# Check if we can spawn a new runner
	if active_runners.size() < max_active_runners:
		time_since_last_run += delta
		if rapid_runners:
			min_time_between_runs = 1
			max_time_between_runs = 1
		
		if time_since_last_run >= randi_range(min_time_between_runs, max_time_between_runs):
			var roll = randf() # Random float between 0 and 1
			var threshold = runner_chance * delta
			
			if roll < threshold:
				attempt_spawn_runner()

# Update all active missiles
func update_missiles(delta):
	var fixed_delta = 1.0/60.0
	var i = active_missiles.size() - 1
	
	while i >= 0:
		var missile = active_missiles[i]
		if not missile.active:
			active_missiles.remove_at(i)
			i -= 1
			continue
		
		# Calculate direction and move missile
		var direction = (missile.target - missile.position).normalized()
		var distance_to_move = missile_speed * fixed_delta
		missile.position += direction * distance_to_move
		
		# Update sprite position and rotation
		missile.sprite.position = missile.position
		missile.sprite.rotation = direction.angle() + PI/2
		
		# Update particle rotation if it exists
		if missile.particles:
			missile.particles.rotation = missile.sprite.rotation - PI/2
		
		# Check if missile reached target
		var distance_squared = missile.position.distance_squared_to(missile.target)
		if distance_squared < 25: # 5 units squared
			trigger_explosion(missile)
			active_missiles.remove_at(i)
		
		i -= 1

# Update all active runners
func update_runners(delta):
	var i = active_runners.size() - 1
	
	while i >= 0:
		var runner = active_runners[i]
		
		# Update runner and check if escaped
		if runner.update(delta, runner_speed):
			handle_runner_escape(runner)
			runner.cleanup()
			active_runners.remove_at(i)
		
		i -= 1

func attempt_spawn_runner():
	print("Attempting to spawn runner...")
	if queue_manager.potatoes.size() > 0 and active_runners.size() < max_active_runners:
		var potato = queue_manager.remove_front_potato()
		if potato:
			print("Starting new runner")
			start_runner(potato)
			time_since_last_run = 0.0

func start_runner(potato):
	if not is_enabled or is_in_dialogic:
		print("BorderRunnerSystem disabled or in dialogue, no runners allowed.")
		return
		
	# Ensure the potato is visible
	potato.visible = true
	potato.modulate.a = 1.0
	potato.z_index = 10  # Ensure it's above background elements
	
	# Play alarm and show alert
	if alarm_sound and not alarm_sound.playing:
		alarm_sound.play()
	Global.display_red_alert(alert_label, alert_timer, "BORDER RUNNER DETECTED!\nClick to launch missile!")
	
	# Get all available runner paths
	var paths_node = get_parent().get_node("Gameplay/Paths/RunnerPaths")
	if not paths_node:
		push_error("Runner paths node not found!")
		return
		
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
	
	# Create a new runner and add it to the active runners list
	var runner = Runner.new(potato, path_follow)
	active_runners.append(runner)
	
	print("Runner setup complete")

func force_start_runner(potato):
	if not is_enabled or is_in_dialogic:
		return
		
	print("Force starting runner with rejected potato")
		
	# Ensure the potato is visible
	potato.visible = true
	potato.modulate.a = 1.0
	potato.z_index = 10  # Ensure it's above background elements
	
	# Play alarm and show alert
	if alarm_sound and not alarm_sound.playing:
		alarm_sound.play()
	Global.display_red_alert(alert_label, alert_timer, "BORDER RUNNER DETECTED!\nClick to launch missile!")
	
	# Get all available runner paths
	var paths_node = get_parent().get_node("Gameplay/Paths/RunnerPaths")
	if not paths_node:
		push_error("Runner paths node not found!")
		return
		
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
	
	# Create a new runner and add it to the active runners list
	var runner = Runner.new(potato, path_follow)
	active_runners.append(runner)
	
	print("Forced runner setup complete")

func handle_runner_escape(runner):
	print("Runner has escaped!")
	# Reset the runner streak
	runner_streak = 0 

	# Store original score to check if points were deducted
	var original_score = Global.score
	var points_to_remove = min(escape_penalty, Global.score)  # Only remove what's available

	# Apply score penalty and prevent negative score
	Global.score = max(0, Global.score - points_to_remove)
	if score_label:
		score_label.text = "Score: {total_points}".format({
			"total_points": Global.score
		})

	# Update alert to show penalty
	if points_to_remove == 0:
		# No points were deducted
		Global.display_red_alert(alert_label, alert_timer, "RUNNER ESCAPED!\nStrike added!")
	else:
		# Points were deducted, show the penalty
		Global.display_red_alert(alert_label, alert_timer, "RUNNER ESCAPED!\nStrike added!\n-{penalty} points!".format({
			"penalty": points_to_remove
		}))
			
	print("Before strike: " + str(Global.strikes))
	# Add one strike to the total strikes stored in the root node of the scene
	Global.strikes += 1
	if Global.strikes >= Global.max_strikes:
		emit_signal("game_over_triggered")
	print("After strike: " + str(Global.strikes))
	
	if strike_label:
		strike_label.text = "Strikes: " + str(Global.strikes) + " / " + str(Global.max_strikes)

func _input(event):
	if not is_enabled or is_in_dialogic:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check if the click is within the missile zone
			var missile_zone = get_missile_zone()
			if missile_zone.has_point(event.position):
				# Check if we can launch a missile
				if unlimited_missiles or missile_cooldown_timer <= 0:
					if active_runners.size() > 0 or unlimited_missiles:
						launch_missile(event.position)
						# Reset cooldown timer
						missile_cooldown_timer = missile_cooldown

func _unhandled_input(event):
	if not is_enabled or is_in_dialogic:
		return
		
	if crater_spawn_on_click:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				if crater_system:
					var local_pos = crater_system.to_local(event.global_position)
					crater_system.add_crater(local_pos)

func launch_missile(target_pos):
	if active_missiles.size() >= max_missiles and not unlimited_missiles:
		print("Maximum number of missiles reached")
		return
		
	print("Launching missile at: ", target_pos)
	
	# Create a new missile sprite
	var new_missile_sprite = Sprite2D.new()
	new_missile_sprite.texture = missile_sprite.texture
	new_missile_sprite.visible = true
	new_missile_sprite.z_index = 15
	add_child(new_missile_sprite)
	
	# Create a new particle effect for this missile
	var new_particles = null
	if smoke_particles:
		new_particles = GPUParticles2D.new()
		new_particles.process_material = smoke_particles.process_material.duplicate()
		new_particles.amount = smoke_particles.amount
		new_particles.lifetime = smoke_particles.lifetime
		new_particles.one_shot = false
		new_particles.explosiveness = smoke_particles.explosiveness
		new_missile_sprite.add_child(new_particles)
	
	# Create the missile object
	var missile = Missile.new(new_missile_sprite.texture, new_particles)
	missile.sprite = new_missile_sprite
	
	# Start from bottom center of screen
	var viewport_rect = get_viewport_rect()
	missile.position = Vector2((viewport_rect.size.x / 2) - 800, viewport_rect.size.y - 900)
	missile.target = target_pos
	
	# Set up missile sprite
	missile.sprite.position = missile.position
	missile.sprite.modulate.a = 1.0
	
	# Point missile toward target - add PI/2 to rotate 90 degrees since missile sprite points up
	var direction = (target_pos - missile.position).normalized()
	missile.sprite.rotation = direction.angle() + PI/2
	
	# Update shift stats
	shift_stats.missiles_fired += 1
	
	# Play activation and launch sound
	if missile_sound and not missile_sound.playing:
		missile_sound.play()
	
	# Start particle emission and position at missile
	if missile.particles:
		missile.particles.rotation = missile.sprite.rotation - PI/2
	
	# Add the missile to the active missiles list
	active_missiles.append(missile)
	
	print("Missile launched from: ", missile.position)

func trigger_explosion(missile):
	print("Triggering explosion")
	var explosion_active = true
	var explosion_position = missile.position
	
	# Setup explosion VFX
	explosion_vfx.position = explosion_position
	explosion_vfx.visible = true
	explosion_vfx.start_explosion()
	
	# Add crater at explosion position
	if crater_system:
		var local_pos = crater_system.to_local(explosion_position)
		crater_system.add_crater(local_pos, crater_size_multiplier)
	
	# Hide the missile sprite
	missile.sprite.visible = false
	missile.active = false
	
	# Play explosion sound
	if explosion_sound and not explosion_sound.playing:
		explosion_sound.play()
	
	# Check if we hit any runners
	check_runner_hits(explosion_position)

func check_runner_hits(explosion_pos):
	var hit_any = false
	var i = active_runners.size() - 1
	
	while i >= 0:
		var runner = active_runners[i]
		var distance = runner.get_position().distance_to(explosion_pos)
		
		if distance < explosion_size:
			# We hit this runner!
			hit_any = true
			handle_successful_hit(runner, explosion_pos)
			runner.cleanup()
			active_runners.remove_at(i)
		
		i -= 1
		
	if not hit_any:
		print("Missile missed all runners")
		runner_streak = 0

func handle_successful_hit(runner, explosion_pos):
	# Spawn gibs at the runner's position
	spawn_gibs(runner.get_position())
	
	# Update stats with successful hits
	shift_stats.missiles_hit += 1
	
	runner_streak += 1
	var points_earned = runner_base_points
	var bonus_text = ""
	
	# Calculate bonuses
	var distance = runner.get_position().distance_to(explosion_pos)
	if distance < explosion_size / 3:
		# Update shift stats for perfect hits
		shift_stats.perfect_hits += 1
		# Spawn even more gibs on a perfect hit
		spawn_gibs(runner.get_position())
		points_earned += perfect_hit_bonus
		bonus_text += "PERFECT HIT! +{perfect} accuracy bonus points\n".format({"perfect": perfect_hit_bonus})
	
	if runner_streak > 1:
		var streak_points = streak_bonus * (runner_streak - 1)
		points_earned += streak_points
		bonus_text += "COMBO x{mult}! +{streak} combo bonus points\n".format({
			"mult": runner_streak,
			"streak": streak_points
		})
	
	# Add points
	Global.score += points_earned
	if score_label:
		score_label.text = "Score: {total_points}".format({
			"total_points": Global.score
		})
	
	# Remove a strike if any present
	if Global.strikes > 0:
		Global.strikes -= 1 
		bonus_text += "Strike removed!\n"
	
	Global.display_green_alert(alert_label, alert_timer, "{bonus} +{points} points!".format({
		"bonus": bonus_text,
		"points": points_earned
	}))

	if strike_label:
		strike_label.text = "Strikes: " + str(Global.strikes) + " / " + str(Global.max_strikes)

func enable():
	is_enabled = true
	if missile_collision_shape:
		missile_collision_shape.disabled = false

func disable():
	is_enabled = false
	if missile_collision_shape:
		missile_collision_shape.disabled = true
	clean_up_all()

func set_dialogic_mode(in_dialogic: bool):
	is_in_dialogic = in_dialogic
	
	if in_dialogic:
		clean_up_all()

func clean_up_all():
	# Clean up all active runners
	for runner in active_runners:
		runner.cleanup()
	active_runners.clear()
	
	# Clean up all active missiles
	for missile in active_missiles:
		missile.sprite.queue_free()
		missile.active = false
	active_missiles.clear()
	
	# Reset timers and state
	time_since_last_run = 0
	missile_cooldown_timer = 0

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

func get_missile_zone() -> Rect2:
	if not is_enabled or not missile_collision_shape:
		return Rect2()
		
	var shape = missile_collision_shape.shape
	if shape is RectangleShape2D:
		var extents = shape.extents
		var pos = missile_collision_shape.global_position
		return Rect2(pos - extents, extents * 2)
	return Rect2()
