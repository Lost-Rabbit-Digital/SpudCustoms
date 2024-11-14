extends Node2D

# Runner settings
@export var runner_chance = 0.1  # 10% chance per second for queue potato to run
@export var min_time_between_runs = 15.0 # Reduced to 3 seconds for testing
@export var runner_base_points = 250  # Base points for catching runner
@export var perfect_hit_bonus = 150   # Extra points for perfect hits
@export var streak_bonus = 100        # Bonus for catching multiple runners
@export var debug_mode = true        # Add checkbox in editor for testing
var runner_streak = 0                # Track consecutive successful catches
@export var explosion_size = 48      # Size of explosion in pixels

# Internal state
var time_since_last_run = 0.0
var active_runner = null
var missile_active = false
var missile_position = Vector2.ZERO
var missile_target = Vector2.ZERO
var explosion_active = false
var explosion_position = Vector2.ZERO

# Runner settings
var runner_speed = 0.15  # Reduced from 0.5 for slower movement
@export var missile_speed = 400

# Missile settings
@export var missile_scale = Vector2(0.5, 0.5)  # Adjust missile size
@export var missile_start_height = 600  # Height where missile starts

# Node references
@onready var queue_manager = $"../SystemManagers/QueueManager"
@onready var alarm_sound = $AlarmSound
@onready var explosion_sound = $ExplosionSound
@onready var missile_sound = $MissileSound
@onready var alert_label = $"../UI/Labels/AlertLabel"
@onready var explosion_vfx = $ExplosionVFX
@onready var missile_sprite = $MissileSprite

func _ready():
	# Create missile sprite if it doesn't exist
	if not missile_sprite:
		missile_sprite = Sprite2D.new()
		missile_sprite.texture = preload("res://assets/missiles/missile_sprite.png")  # Make sure path is correct
		missile_sprite.scale = Vector2(0.5, 0.5)
		add_child(missile_sprite)
	missile_sprite.visible = false
	missile_sprite.z_index = 15  # Make sure missile is visible above runners

	if not queue_manager:
		push_error("BorderRunnerSystem: Could not find QueueManager!")
	print("BorderRunnerSystem initialized with chance: ", runner_chance)

func _process(delta):
	if not queue_manager:
		print("No queue manager found!")
		return
		
	if active_runner:
		update_runner(delta)
		return
		
	time_since_last_run += delta
	
	if time_since_last_run >= min_time_between_runs:
		var roll = randf()
		var threshold = runner_chance * delta
		print("Runner check - Time: ", time_since_last_run, " Roll: ", roll, " Threshold: ", threshold)
		
		if roll < threshold:
			print("Runner threshold met, attempting spawn")
			attempt_spawn_runner()
			
		# Debug mode: Force spawn after delay
		if debug_mode and time_since_last_run >= 10.0:
			print("Debug mode forcing runner spawn")
			attempt_spawn_runner()
	
	if missile_active:
		update_missile(delta)

func attempt_spawn_runner():
	print("Attempting to spawn runner...")
	if queue_manager.potatoes.size() > 0:
		print("Found ", queue_manager.potatoes.size(), " potatoes in queue")
		
		# Get a random potato from the queue
		var runner = queue_manager.remove_front_potato()
		if runner:
			print("Selected potato to become runner")
			start_runner(runner)
		else:
			print("Failed to remove potato from queue")
	else:
		print("No potatoes available to become runners")
	
	time_since_last_run = 0.0

func start_runner(potato):
	active_runner = potato
	print("Starting runner")
	
	# Play alarm and show alert
	alarm_sound.play()
	alert_label.text = "BORDER RUNNER DETECTED!\nClick to launch missile!"
	alert_label.visible = true
	
	# Set up path follow
	var path = $"../Gameplay/Paths/RunnerPath"
	if not path:
		push_error("RunnerPath not found!")
		return
		
	var path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	path_follow.progress_ratio = 0.0  # Set progress_ratio on PathFollow2D
	
	# Add the potato to the path_follow
	if potato.get_parent():
		potato.get_parent().remove_child(potato)
	path_follow.add_child(potato)
	potato.position = Vector2.ZERO  # Reset potato position relative to path_follow
	
	print("Runner setup complete on path")

func update_runner(delta):
	if not active_runner:
		return
		
	var path_follow = active_runner.get_parent()
	if not path_follow or not path_follow is PathFollow2D:
		push_error("Runner's parent is not a PathFollow2D!")
		return
		
	path_follow.progress_ratio += delta * runner_speed
	print("Runner progress: ", path_follow.progress_ratio)
	
	# Check if runner reached the end
	if path_follow.progress_ratio >= 1.0:
		runner_escaped()
		return  # Add this return to prevent further updates
		
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if active_runner and not missile_active:
				launch_missile(event.position)

func launch_missile(target_pos):
	print("Launching missile at: ", target_pos)
	missile_active = true
	
	# Start from bottom center of screen
	var viewport_rect = get_viewport_rect()
	missile_position = Vector2(viewport_rect.size.x / 2, viewport_rect.size.y - 100)
	missile_target = target_pos
	
	# Ensure missile is visible and at the correct position
	missile_sprite.visible = true
	missile_sprite.position = missile_position
	missile_sprite.modulate.a = 1.0  # Ensure fully visible
	
	# Calculate initial rotation to point at target
	var direction = (missile_target - missile_position).normalized()
	missile_sprite.rotation = direction.angle() - PI/2
	
	missile_sound.play()
	print("Missile launched from: ", missile_position)

func update_missile(delta):
	if not missile_active:
		return
		
	var direction = (missile_target - missile_position).normalized()
	var movement = direction * missile_speed * delta
	missile_position += movement
	missile_sprite.position = missile_position
	missile_sprite.rotation = direction.angle() - PI/2
	
	print("Missile pos: ", missile_position, " Target: ", missile_target)
	
	# Check if missile reached target
	if missile_position.distance_to(missile_target) < 5:
		print("Missile reached target!")
		trigger_explosion()

func trigger_explosion():
	print("Triggering explosion at: ", missile_position)
	explosion_active = true
	explosion_vfx.position = missile_position
	explosion_vfx.visible = true
	explosion_vfx.start_explosion()
	missile_active = false
	missile_sprite.visible = false
	
	if explosion_sound:
		explosion_sound.play()
	else:
		push_error("Explosion sound not found!")
	
	check_runner_hit()

func check_runner_hit():
	if not active_runner:
		print("No active runner to check for hit")
		return
		
	var distance = active_runner.global_position.distance_to(explosion_vfx.position)
	print("Distance to runner: ", distance)
	
	if distance < explosion_size:
		runner_streak += 1
		var points_earned = runner_base_points
		var bonus_text = ""
		
		# Perfect hit bonus
		if distance < explosion_size / 3:
			points_earned += perfect_hit_bonus
			bonus_text += "PERFECT HIT! +{perfect} bonus\n".format({"perfect": perfect_hit_bonus})
			print("Perfect hit scored!")
		
		# Streak bonus
		if runner_streak > 1:
			var streak_points = streak_bonus * (runner_streak - 1)
			points_earned += streak_points
			bonus_text += "STREAK x{mult}! +{streak} bonus\n".format({
				"mult": runner_streak,
				"streak": streak_points
			})
		
		# Remove a strike if any present
		if get_parent().strikes > 0:
			get_parent().strikes -= 1
			bonus_text += "Strike removed!\n"
		
		# Add points to main game score
		get_parent().score += points_earned
		
		# Update display
		alert_label.text = "{bonus}Total: +{points} points!".format({
			"bonus": bonus_text,
			"points": points_earned
		})
		alert_label.modulate = Color.GREEN
		
		var timer = get_tree().create_timer(2.0)
		timer.connect("timeout", Callable(self, "clear_alert"))
		
		clean_up_runner()
	else:
		print("Missile missed the runner")
		# Reset streak on miss
		runner_streak = 0

func runner_escaped():
	runner_streak = 0  # Reset streak on escape
	get_parent().strikes += 1
	alert_label.text = "Runner escaped! Strike added!"
	alert_label.modulate = Color.RED
	
	var timer = get_tree().create_timer(2.0)
	timer.connect("timeout", Callable(self, "clear_alert"))
	
	clean_up_runner()

func clean_up_runner():
	if active_runner:
		var path_follow = active_runner.get_parent()
		if path_follow:
			path_follow.queue_free()
		active_runner.queue_free()
		active_runner = null
	time_since_last_run = 0

func clear_alert():
	alert_label.visible = false
	alert_label.modulate = Color.WHITE
