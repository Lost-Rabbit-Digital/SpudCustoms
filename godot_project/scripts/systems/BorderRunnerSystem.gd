class_name BorderRunnerSystem
extends Node2D
## Manages the spawning of runners, missile targeting,
## and giblet effects when potatoes are destroyed

signal game_over_triggered

@export_group("Debugging")
## Unlimited ammunition for fox hunting
@export var unlimited_missiles = false
## Force Spuds to run the border for your entertainment
@export var rapid_runners = false

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
@export var min_time_between_runs: float = 5  # Default: 10
## Maximum time that can pass between runner spawn attempts (Seconds)
@export var max_time_between_runs: float = 120  # Default: 120 seconds - 2 minutes
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
@export var missile_cooldown: float = 0.5
## Speed at which missiles travel toward their target
@export var missile_speed: float = 1200
## Initial height from which missiles are launched
@export var missile_start_height: float = 400
## Radius of explosion effect and damage area
@export var explosion_size: float = 80

@export_group("Giblet System")
@export_subgroup("Visual Settings")
## Number of potato pieces that spawn when a runner is destroyed
@export var num_gibs: int = 40
## Size scaling applied to giblet sprites
@export var gib_scale: Vector2 = Vector2(0.1, 0.4)
## Duration giblets remain visible before disappearing
@export var gib_lifetime: float = 3.0

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

var smoke_particle_pool = []
var max_smoke_particles = 50

var explosion_sound_pool = [
	preload("res://assets/audio/explosions/big distant thump 4.wav"),
	preload("res://assets/audio/explosions/big distant thump 5.wav"),
	preload("res://assets/audio/explosions/big distant thump 6.wav"),
]

# Internal state tracking
var is_enabled = true  # Track if system is enabled
var is_in_dialogic = false  # Track if game is in dialogue mode
var runner_streak: int = 0
var time_since_last_run: float = 0.0
var active_runners = []  # Array of active runners
var active_missiles = []  # Array of active missiles
var missile_cooldown_timer: float = 0.0
var gib_textures: Array = []
var difficulty_level

@onready var alarm_sound = $AlarmSound
@onready var explosion_sound = $ExplosionSound
@onready var missile_sound = $MissileSound
@onready var explosion_vfx = $ExplosionVFX
@onready var missile_sprite = $MissileSprite
@onready var smoke_particles = $MissileSprite/CPUParticles2D
@onready var shift_stats = ShiftStats.new()

@onready var missile_frames: SpriteFrames
@onready var smoke_frames: SpriteFrames
@onready var explosion_frames: SpriteFrames


class Missile:
	var sprite: AnimatedSprite2D
	var smoke_trail: Array[AnimatedSprite2D] = []  # Array to store smoke trail sprites
	var position: Vector2
	var target: Vector2
	var rotation: float
	var active: bool = true
	var time_elapsed: float = 0.0
	var smoke_spawn_timer: float = 0.0
	var smoke_spawn_interval: float = 0.05  # Adjust for density of smoke trail

	func _init(sprite_frames):
		sprite = AnimatedSprite2D.new()
		sprite.sprite_frames = sprite_frames
		sprite.visible = true
		sprite.z_index = 8
		if sprite.sprite_frames.has_animation("default"):
			sprite.play("default")  # Start animation
		else:
			print("Error: No 'default' animation in sprite frames!")


# Runner class to track multiple border runners
class Runner:
	var potato: Sprite2D
	var path_follow: PathFollow2D
	var has_escaped: bool = false

	func _init(p, pf):
		potato = p
		path_follow = pf

	func update(delta, speed):
		if not potato or not path_follow or has_escaped:
			return false

		var old_ratio = path_follow.progress_ratio
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
	# Create separate SpriteFrames instances for each animation type
	var missile_frames = SpriteFrames.new()
	var smoke_frames = SpriteFrames.new()
	var explosion_frames = SpriteFrames.new()

	# Load the frames for explosion
	var ExplosionTexture = preload("res://assets/effects/explosion_spritesheet_1.png")
	var explosion_hframes = 26  # Adjust based on the actual spritesheet
	var explosion_vframes = 1

	# Add animation frames for explosion
	for i in range(explosion_hframes):
		var region = Rect2(
			i * ExplosionTexture.get_width() / explosion_hframes,
			0,
			ExplosionTexture.get_width() / explosion_hframes,
			ExplosionTexture.get_height()
		)
		var frame = AtlasTexture.new()
		frame.atlas = ExplosionTexture
		frame.region = region
		explosion_frames.add_frame("default", frame)

	# Set animation speed for explosion
	explosion_frames.set_animation_speed("default", 13)  # Frames per second

	# Load the frames for missile
	var MissileTexture = preload("res://assets/effects/rocket_small_spritesheet.png")
	var missile_hframes = 2  # Adjust based on the actual spritesheet

	# Add animation frames for missile
	for i in range(missile_hframes):
		var region = Rect2(
			i * MissileTexture.get_width() / missile_hframes,
			0,
			MissileTexture.get_width() / missile_hframes,
			MissileTexture.get_height()
		)
		var frame = AtlasTexture.new()
		frame.atlas = MissileTexture
		frame.region = region
		missile_frames.add_frame("default", frame)

	# Set animation speed for missile
	missile_frames.set_animation_speed("default", 4)  # Frames per second

	# Do the same for smoke frames
	var SmokeTexture = preload("res://assets/effects/smoke_spritesheet.png")
	var smoke_hframes = 8  # Adjust based on actual spritesheet

	# Add animation frames for smoke
	for i in range(smoke_hframes):
		var region = Rect2(
			i * SmokeTexture.get_width() / smoke_hframes,
			0,
			SmokeTexture.get_width() / smoke_hframes,
			SmokeTexture.get_height()
		)
		var frame = AtlasTexture.new()
		frame.atlas = SmokeTexture
		frame.region = region
		smoke_frames.add_frame("default", frame)

	# Set animation speed for smoke
	smoke_frames.set_animation_speed("default", 8)  # Frames per second

	# Store frames for later use
	self.missile_frames = missile_frames
	self.smoke_frames = smoke_frames
	self.explosion_frames = explosion_frames  # Make sure to store this too

	if missile_collision_shape == null:
		missile_collision_shape = $Area2D/CollisionShape2D

	# Configure difficulty level and set runner chance based on difficulty level
	difficulty_level = Global.difficulty_level
	print("Setting Border Runner System to: ", difficulty_level)

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
	print("BorderRunnerSystem initialized: Chance [", runner_chance, "]")

	# Load gib textures
	for i in range(1, 9):
		var texture = load("res://assets/potato_giblets/giblet_" + str(i) + ".png")
		if texture:
			gib_textures.append(texture)
		else:
			push_error("Failed to load giblet_" + str(i))

	# Initialize smoke particle pool
	for i in range(max_smoke_particles):
		var smoke = AnimatedSprite2D.new()
		smoke.sprite_frames = smoke_frames
		smoke.visible = false
		add_child(smoke)
		smoke_particle_pool.append(smoke)


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
			var roll = randf()  # Random float between 0 and 1
			var threshold = runner_chance * delta

			if roll < threshold:
				attempt_spawn_runner()


# Update all active missiles
func update_missiles(delta):
	var i = active_missiles.size() - 1

	while i >= 0:
		var missile = active_missiles[i]
		if not missile.active:
			active_missiles.remove_at(i)
			i -= 1
			continue

		# Calculate direction and move missile
		var direction = (missile.target - missile.position).normalized()
		var distance_to_move = missile_speed * delta
		missile.position += direction * distance_to_move

		# Update sprite position - this is critical!
		missile.sprite.global_position = missile.position  # Use global_position instead
		missile.sprite.rotation = direction.angle() + PI / 2

		# Smoke trail logic
		missile.smoke_spawn_timer += delta
		if missile.smoke_spawn_timer >= missile.smoke_spawn_interval:
			missile.smoke_spawn_timer = 0
			spawn_smoke_particle(missile.position, direction)

		# Check if missile reached target
		var distance_squared = missile.position.distance_squared_to(missile.target)
		if distance_squared < 100:  # Slightly larger threshold (10 units squared)
			trigger_explosion(missile)
			active_missiles.remove_at(i)
			i -= 1
			continue

		# Check if missile has gone significantly past its target
		# This handles cases where missiles might "miss" their target
		var start_to_target = missile.target - missile.sprite.global_position
		var start_to_current = missile.position - missile.sprite.global_position

		# If the missile has moved 20% further than the target distance, it's gone too far
		if start_to_current.length() > start_to_target.length() * 1.2:
			trigger_explosion(missile)
			active_missiles.remove_at(i)
			i -= 1
			continue

		# Add a boundary check
		var viewport_rect = get_viewport_rect().grow(100)  # Add some margin
		if !viewport_rect.has_point(missile.position):
			missile.sprite.queue_free()
			active_missiles.remove_at(i)
			i -= 1
			continue

		i -= 1


func spawn_smoke_particle(position: Vector2, direction: Vector2):
	# Get a particle from the pool
	var smoke = null
	for particle in smoke_particle_pool:
		if not particle.visible:
			smoke = particle
			break

	# If no particles available, just return
	if not smoke:
		return

	# Configure the particle
	# Randomly vary smoke size
	var size_variation = randf_range(0.03, 0.05)
	smoke.scale = Vector2(size_variation, size_variation)
	smoke.global_position = position - (direction * 20)
	smoke.rotation = randf() * TAU
	smoke.modulate.a = 1.0
	smoke.z_index = 11
	smoke.visible = true
	smoke.play("default")

	# Create a tween for behavior
	var tween = create_tween()
	tween.set_parallel(true)

	# Fade out
	tween.tween_property(smoke, "modulate:a", 0.0, 1.2)

	# Drift
	var drift = direction.rotated(randf_range(-PI / 4, PI / 4)) * -50
	tween.tween_property(smoke, "global_position", smoke.global_position + drift, 1.2)

	# make smoke darker as it ages
	tween.tween_property(smoke, "modulate:r", 0.6, 1.2)
	tween.tween_property(smoke, "modulate:g", 0.6, 1.2)
	tween.tween_property(smoke, "modulate:b", 0.6, 1.2)

	# Scale ups
	tween.tween_property(smoke, "scale", Vector2(0.07, 0.07), 1.2)

	# Add rotation over time - this is the key addition
	var rotation_amount = randf_range(-PI, PI)  # Random rotation between -180° and 180°
	tween.tween_property(smoke, "rotation", smoke.rotation + rotation_amount, 1.2)

	# Return to pool
	tween.chain().tween_callback(
		func():
			smoke.visible = false
			smoke.stop()  # Stop animation
	)


# Update all active runners
func update_runners(delta):
	var i = active_runners.size() - 1

	while i >= 0 and i < active_runners.size():
		if active_runners.size() <= i:  # Additional safety check
			break
		var runner = active_runners[i]

		if runner.current_path_follow:
			runner.follow_path(delta)

		# Check if runner has reached the end of the path
		if runner.current_path_follow and runner.current_path_follow.progress_ratio >= 0.99:
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


# In BorderRunnerSystem.gd
func start_runner(potato: PotatoPerson, is_rejected: bool = false):
	if not is_enabled or is_in_dialogic:
		push_warning("BorderRunnerSystem disabled or in dialogue, no runners allowed.")
		return

	# Ensure the potato is visible
	potato.visible = true
	potato.modulate.a = 1.0
	potato.z_index = 8  # Ensure it's above background elements

	# Set the runner speed directly on the potato
	potato.runner_base_speed = runner_speed  # Add this line

	# Play alarm and show alert
	if alarm_sound and not alarm_sound.playing:
		alarm_sound.play()

	# Add a visual indicator to show this was a rejected potato
	var anger_indicator = Sprite2D.new()
	anger_indicator.texture = preload("res://assets/effects/anger.png")  # Create this small texture
	anger_indicator.position = Vector2(0, -15)  # Position above the potato
	potato.add_child(anger_indicator)

	if is_rejected:
		Global.display_red_alert(
			alert_label, alert_timer, "REJECTED POTATO FLEEING!\nClick to launch missile!"
		)
	else:
		Global.display_red_alert(
			alert_label, alert_timer, "BORDER RUNNER DETECTED!\nClick to launch missile!"
		)

	# Get all available runner paths
	var paths_node = %RunnerPaths
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

	# Attach potato to the path and set its state
	potato.attach_to_path(path)
	potato.set_state(potato.TaterState.RUNNING)

	# Connect to path completion signal
	potato.path_completed.connect(_on_runner_completed.bind(potato))

	# Connect to destroyed signal
	potato.destroyed.connect(_on_runner_destroyed)

	# Add to active runners list
	active_runners.append(potato)


func _on_runner_completed(potato: PotatoPerson):
	# Runner escaped
	handle_runner_escape(potato)

	# Remove from active runners list
	var index = active_runners.find(potato)
	if index >= 0:
		active_runners.remove_at(index)


func _on_runner_destroyed(position: Vector2):
	# Create explosion effects at the position
	spawn_gibs(position)
	# Maybe trigger sound effects or other visual effects
	#trigger_explosion(position)


func handle_runner_escape(_runner: PotatoPerson):
	print("Runner has escaped!")
	# Reset the runner streak
	runner_streak = 0

	# Store original score to check if points were deducted
	var original_score = Global.score
	var points_to_remove = min(escape_penalty, Global.score)  # Only remove what's available

	# Apply score penalty and prevent negative score
	Global.score = max(0, Global.score - points_to_remove)
	if score_label:
		score_label.text = "Score: {total_points}".format({"total_points": Global.score})

	# Update alert to show penalty
	if points_to_remove == 0:
		# No points were deducted
		Global.display_red_alert(alert_label, alert_timer, "RUNNER ESCAPED!\nStrike added!")
	else:
		# Points were deducted, show the penalty
		Global.display_red_alert(
			alert_label,
			alert_timer,
			"RUNNER ESCAPED!\nStrike added!\n-{penalty} points!".format(
				{"penalty": points_to_remove}
			)
		)

	print("Before strike: " + str(Global.strikes))

	# Add one strike to the total strikes stored in the root node of the scene
	Global.strikes += 1

	if strike_label:
		strike_label.text = "Strikes: " + str(Global.strikes) + " / " + str(Global.max_strikes)

	if Global.strikes >= Global.max_strikes:
		print("DEBUG: Maximum strikes reached! Emitting game over signal")
		emit_signal("game_over_triggered")
	else:
		print("DEBUG: After strike: " + str(Global.strikes) + "/" + str(Global.max_strikes))


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
					launch_missile(event.position)
					# Reset cooldown timer
					missile_cooldown_timer = missile_cooldown


func _unhandled_input(_event):
	if not is_enabled or is_in_dialogic:
		return


func launch_missile(target_pos):
	if not is_enabled or is_in_dialogic:
		#print("BorderRunnerSystem disabled or in dialogue, no missiles allowed.")
		return
	print(
		(
			"Launching missile: Max Missiles [%d] / Current Missiles [%d]"
			% [max_missiles, active_missiles.size()]
		)
	)

	if active_missiles.size() >= max_missiles and not unlimited_missiles:
		print("Maximum number of missiles reached. Cannot launch.")
		return

	print("Launching missile at: ", target_pos)

	# More detailed missile creation logging
	var missile = Missile.new(missile_frames)
	if not missile.sprite:
		push_error("Failed to create missile sprite!")
		return

	add_child(missile.sprite)

	var viewport_rect = get_viewport_rect()
	#print("Viewport rect: ", viewport_rect)

	# More explicit missile start position logging
	missile.position = Vector2(-100, -100)
	missile.target = target_pos

	#print("Missile start position: ", missile.position)
	#print("Missile target position: ", missile.target)

	missile.sprite.global_position = missile.position
	missile.sprite.rotation = (target_pos - missile.position).normalized().angle() + PI / 2
	shift_stats.missiles_fired += 1

	# Play activation and launch sound - FIX THIS PART
	if missile_sound and missile_sound.get_instance_id() != 0:
		# Create a dedicated audio player for the missile sound to prevent interruption
		var launch_player = AudioStreamPlayer2D.new()
		launch_player.stream = missile_sound.stream
		launch_player.volume_db = -5.0  # Adjust volume as needed
		launch_player.pitch_scale = randf_range(0.8, 1.2)
		launch_player.bus = "SFX"
		launch_player.autoplay = true
		launch_player.position = missile.position
		add_child(launch_player)

		# Auto-cleanup after playing
		launch_player.finished.connect(launch_player.queue_free)
	else:
		print("ERROR: Missile sound not loaded properly")
	active_missiles.append(missile)

	print("Missile launched: Active Missiles [", active_missiles.size(), "]")


# Handle explosion animation completion
func _on_explosion_animation_finished(explosion: AnimatedSprite2D) -> void:
	explosion.stop()
	explosion.frame = randi_range(23, 25)


# Handle explosion cleanup after timeout
func _on_explosion_cleanup_timeout(explosion: AnimatedSprite2D) -> void:
	if is_instance_valid(explosion):
		explosion.stop()
		explosion.frame = randi_range(23, 25)


# Handle smoke particle animation completion
func _on_smoke_animation_finished(smoke: AnimatedSprite2D) -> void:
	smoke.queue_free()


# Handle smoke z-index adjustment after delay
func _on_smoke_alpha_timeout(smoke: AnimatedSprite2D) -> void:
	if is_instance_valid(smoke):
		smoke.z_index = 13


# Handle smoke cleanup after timeout
func _on_smoke_cleanup_timeout(smoke: AnimatedSprite2D) -> void:
	if is_instance_valid(smoke):
		smoke.queue_free()


func trigger_explosion(missile_or_position):
	#print("Triggering explosion")
	var explosion_position

	# Check if we received a missile object or a position
	if missile_or_position is Vector2:
		explosion_position = missile_or_position
	else:
		var missile = missile_or_position

		# Get the missile sprite's size
		var missile_length = 0

		# For AnimatedSprite2D, we need to access frames differently
		if missile.sprite and missile.sprite.sprite_frames:
			# Get the current animation
			var current_anim = missile.sprite.animation
			# Get the current frame index
			var current_frame = missile.sprite.frame
			# Try to get the texture from the sprite frames
			var texture = missile.sprite.sprite_frames.get_frame_texture(
				current_anim, current_frame
			)
			if texture:
				missile_length = texture.get_height() * 0.5 * missile.sprite.scale.y

		# Calculate tip position using the sprite's rotation
		var angle = missile.sprite.rotation - PI / 2  # Adjust for the initial PI/2 offset
		var tip_offset = Vector2(cos(angle), sin(angle)) * missile_length
		explosion_position = missile.position + tip_offset

	# Trigger screen shake - find the main game node correctly
	# Navigate up the scene tree to find the Root node
	var main_game = self
	while main_game and main_game.get_parent() and main_game.name != "Root":
		main_game = main_game.get_parent()

	if main_game and main_game.has_method("shake_screen"):
		# Medium shake for regular explosions
		main_game.shake_screen(12.0, 0.3)
	else:
		push_error("Could not find main game node with shake_screen method!")
		#print("Current node: ", self.name, ", Parent: ", get_parent().name if get_parent() else "none")

	# Create explosion animation
	var explosion = AnimatedSprite2D.new()
	explosion.sprite_frames = explosion_frames
	explosion.global_position = explosion_position
	explosion.scale = Vector2(explosion_size / 16.0, explosion_size / 16.0) * randf_range(0.5, 2)
	explosion.z_index = 12  # Above missiles
	explosion.play("default")

	# Ensure explosion is removed after animation
	explosion.animation_finished.connect(_on_explosion_animation_finished.bind(explosion))

	# Fallback timer to ensure removal
	var cleanup_timer = get_tree().create_timer(2.0)
	cleanup_timer.timeout.connect(_on_explosion_cleanup_timeout.bind(explosion))

	# Create a tween for scaling and fading
	var exp_tween = create_tween()
	exp_tween.set_parallel(true)

	# Scale up with bounce effect
	(
		exp_tween
		. tween_property(
			explosion,
			"scale",
			Vector2(explosion_size / 32.0, explosion_size / 32.0) * randf_range(0.8, 1.2),
			0.7
		)
		. set_trans(Tween.TRANS_ELASTIC)
		. set_ease(Tween.EASE_OUT)
	)
	# Fade out explosion

	exp_tween.tween_property(explosion, "modulate:a", 0.5 * randf_range(0.8, 1.2), 3).set_delay(0.2)
	add_child(explosion)

	# Brief game pause for impact
	#var previous_pause_state = get_tree().paused
	#get_tree().paused = true

	# Create a timer to unpause after a short duration
	#var unpause_timer = get_tree().create_timer(0.02)  # 20 milliseconds
	#unpause_timer.timeout.connect(func():
	#	get_tree().paused = previous_pause_state
	#)
	# Then, in your trigger_explosion function, replace the current explosion sound code:
	if explosion_sound and explosion_sound.get_instance_id() != 0:
		# Create a dedicated audio player for the explosion sound
		var explosion_player = AudioStreamPlayer2D.new()

		# Pick a random sound from the pool
		var random_sound_index = randi() % explosion_sound_pool.size()
		explosion_player.stream = explosion_sound_pool[random_sound_index]

		# Add volume and position settings
		explosion_player.volume_db = 5.0  # Adjust volume as needed
		explosion_player.position = explosion_position

		# Add pitch variation - wider range for explosions
		var pitch_variance = randf_range(0.8, 1.25)
		explosion_player.pitch_scale = pitch_variance

		# Set the audio bus and play
		explosion_player.bus = "SFX"
		explosion_player.autoplay = true
		add_child(explosion_player)

		# Auto-cleanup after playing
		explosion_player.finished.connect(explosion_player.queue_free)

	# Create smoke animation
	var smoke = AnimatedSprite2D.new()
	smoke.sprite_frames = smoke_frames
	smoke.global_position = explosion_position
	smoke.scale = Vector2(0.05, 0.05)
	smoke.z_index = 13  # Above missiles, below explosion
	smoke.play("default")

	# Create a tween for behavior
	var tween = create_tween()
	tween.set_parallel(true)

	# Fade out
	tween.tween_property(smoke, "modulate:a", 0.0, 1.5)

	# make smoke darker as it ages
	tween.tween_property(smoke, "modulate:r", 0.6, 1.5)
	tween.tween_property(smoke, "modulate:g", 0.6, 1.5)
	tween.tween_property(smoke, "modulate:b", 0.6, 1.5)

	# Scale ups
	tween.tween_property(smoke, "scale", Vector2(0.10, 0.10), 1.5)

	# Ensure smoke is removed after animation
	smoke.animation_finished.connect(func(): smoke.queue_free())

	var smoke_alpha_timer = get_tree().create_timer(0.6)
	smoke_alpha_timer.timeout.connect(
		func():
			if is_instance_valid(smoke):
				smoke.z_index = 13
	)

	var smoke_cleanup_timer = get_tree().create_timer(1.5)
	smoke_cleanup_timer.timeout.connect(
		func():
			if is_instance_valid(smoke):
				smoke.queue_free()
	)

	add_child(smoke)

	# Clean up missile but leave smoke trail to fade out
	if missile_or_position is Vector2:
		# No missile to clean up, just a position
		pass
	else:
		missile_or_position.sprite.queue_free()
		missile_or_position.active = false

	# Play explosion sound
	if explosion_sound and not explosion_sound.playing:
		explosion_sound.play()

	# Check if we hit any runners
	check_runner_hits(explosion_position)


func check_runner_hits(explosion_pos):
	var hit_any = false
	var runners_to_hit = []
	var i = active_runners.size() - 1

	# First, collect all runners to hit
	while i >= 0:
		var runner = active_runners[i]
		var distance = runner.global_position.distance_to(explosion_pos)

		if distance < (explosion_size * 0.65):
			# Store for later processing
			runners_to_hit.append(runner)
			active_runners.remove_at(i)
			hit_any = true

		i -= 1

	# Then process the hits afterward to avoid recursive signal issues
	for runner in runners_to_hit:
		handle_successful_hit(runner, explosion_pos)
		runner.apply_damage()

	if not hit_any:
		print("Missile missed all runners")
		runner_streak = 0


func handle_successful_hit(runner, explosion_pos):
	var root_node = get_tree().current_scene

	# Dictionary of corpse textures by race
	var corpse_textures = {
		"Russet": preload("res://assets/potatoes/bodies/russet_corpse.png"),
		"Yukon Gold": preload("res://assets/potatoes/bodies/yukon_gold_corpse.png"),
		"Sweet Potato": preload("res://assets/potatoes/bodies/sweet_potato_corpse.png"),
		"Purple Majesty": preload("res://assets/potatoes/bodies/purple_majesty_corpse.png")
	}

	# Create a potato corpse sprite
	var corpse = Sprite2D.new()

	# Get the runner's race from potato_info
	var race = "Russet"  # Default fallback race
	if runner.has_method("get_potato_info"):
		var potato_info = runner.get_potato_info()
		if potato_info.has("race"):
			race = potato_info.race

	# Set the appropriate texture based on race
	if corpse_textures.has(race):
		corpse.texture = corpse_textures[race]
	else:
		# Fallback to default
		corpse.texture = corpse_textures["Russet"]

	corpse.global_position = runner.global_position

	corpse.z_index = 3  # Under explosions, above world background. 5 was last visible tested

	# Slightly adjust size randomly
	corpse.scale = Vector2(0.9, 0.9) * randf_range(0.9, 1.1)

	# Add slight random rotation for visual variety
	corpse.rotation = randf_range(-0.4, 0.4)

	# Add the footprint to a group for easier management
	corpse.add_to_group("CorpseGroup")

	# Add to a parent that won't be cleaned up
	root_node.add_child(corpse)

	#var tween = create_tween()
	#tween.tween_property(corpse, "modulate:a", 1.0, 2.0)

	# Store original modulate color
	var original_modulate = runner.modulate

	# Briefly change runner to white
	runner.modulate = Color.WHITE

	# Create a tween to revert the color
	#var color_tween = create_tween()
	#color_tween.tween_property(runner, "modulate", original_modulate, 0.1)

	# Spawn gibs at the runner's position
	# cspawn_gibs(runner.get_position())

	# Update stats with successful hits
	shift_stats.missiles_hit += 1

	runner_streak += 1
	var points_earned = runner_base_points
	var bonus_text = ""

	# Find the main game node correctly
	var main_game = self
	while main_game and main_game.get_parent() and main_game.name != "Root":
		main_game = main_game.get_parent()

	# Calculate bonuses
	var distance = runner.global_position.distance_to(explosion_pos)
	if distance < explosion_size * 0.30:
		# Perfect hit - trigger stronger screen shake
		if main_game and main_game.has_method("shake_screen"):
			main_game.shake_screen(16.0, 0.4)  # Strong shake for perfect hits
		# Update shift stats for perfect hits
		shift_stats.perfect_hits += 1
		# Spawn even more gibs on a perfect hit
		spawn_gibs(runner.global_position)
		points_earned += perfect_hit_bonus
		bonus_text += "PERFECT HIT! +{perfect} accuracy bonus points\n".format(
			{"perfect": perfect_hit_bonus}
		)

	if runner_streak > 1:
		var streak_points = streak_bonus * (runner_streak - 1)
		points_earned += streak_points
		bonus_text += "COMBO x{mult}! +{streak} combo bonus points\n".format(
			{"mult": runner_streak, "streak": streak_points}
		)

	# Add points
	Global.score += points_earned
	if score_label:
		score_label.text = "Score: {total_points}".format({"total_points": Global.score})

	# Remove a strike if any present
	if Global.strikes > 0:
		Global.strikes -= 1
		bonus_text += "Strike removed!\n"

	Global.display_green_alert(
		alert_label,
		alert_timer,
		"{bonus} +{points} points!".format({"bonus": bonus_text, "points": points_earned})
	)

	if strike_label:
		strike_label.text = "Strikes: " + str(Global.strikes) + " / " + str(Global.max_strikes)


func enable():
	is_enabled = true
	if missile_collision_shape:
		missile_collision_shape.disabled = false


func disable():
	is_enabled = false
	if missile_collision_shape:
		missile_collision_shape.disabled = false

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

	# Stop any ongoing tween animations
	var all_tweens = get_tree().get_nodes_in_group("Tween")
	for tween in all_tweens:
		if tween.is_valid():
			tween.kill()

	# Reset timers and state
	time_since_last_run = 0
	missile_cooldown_timer = 0

	# Force all runners to stop their paths
	var all_potatoes = get_tree().get_nodes_in_group("PotatoPerson")
	for potato in all_potatoes:
		if potato.has_method("cleanup"):
			potato.cleanup()


class Gib:
	extends Sprite2D
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

		gib.z_index = 11
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
	# First check if we have valid collision shapes
	var shape1 = $Area2D/CollisionShape2D
	var shape2 = $Area2D/CollisionShape2D2

	if not shape1 and not shape2:
		return Rect2()

	var combined_rect = Rect2()

	# Add first shape to the combined rect if it exists
	if shape1 and shape1.shape is RectangleShape2D:
		var extents1 = shape1.shape.extents
		var pos1 = shape1.global_position
		combined_rect = Rect2(pos1 - extents1, extents1 * 2)

	# Add second shape to the combined rect if it exists
	if shape2 and shape2.shape is RectangleShape2D:
		var extents2 = shape2.shape.extents
		var pos2 = shape2.global_position
		var rect2 = Rect2(pos2 - extents2, extents2 * 2)

		# If the first rect is empty, just use the second rect
		if combined_rect.size == Vector2.ZERO:
			combined_rect = rect2
		else:
			# Otherwise, merge the two rectangles
			combined_rect = combined_rect.merge(rect2)

	return combined_rect
