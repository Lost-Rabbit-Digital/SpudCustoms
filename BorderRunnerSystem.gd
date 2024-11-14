extends Node2D

# Runner settings
@export var runner_chance = 0.2  # 20% chance per second for queue potato to run
@export var min_time_between_runs = 3.0  # Reduced to 3 seconds for testing
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
var missile_speed = 400
var explosion_active = false
var explosion_position = Vector2.ZERO

# Node references
@onready var queue_manager = $"../SystemManagers/QueueManager"
@onready var alarm_sound = $AlarmSound
@onready var explosion_sound = $ExplosionSound
@onready var missile_sound = $MissileSound
@onready var alert_label = $"../UI/Labels/AlertLabel"
@onready var explosion_vfx = $ExplosionVFX
@onready var missile_sprite = $MissileSprite

func _ready():
	missile_sprite.visible = false
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
	var potatoes = queue_manager.get_queue_potatoes()
	print("Found ", potatoes.size(), " potatoes in queue")
	
	if potatoes.size() > 0:
		var runner_index = randi() % potatoes.size()
		var runner = potatoes[runner_index]
		print("Selected potato at index ", runner_index, " to become runner")
		
		# Remove from queue and start running
		queue_manager.remove_potato(runner_index)
		start_runner(runner)
	else:
		print("No potatoes available to become runners")
	
	time_since_last_run = 0.0

func start_runner(potato):
	active_runner = potato
	active_runner.position = Vector2(1200, 150)  # Start position
	print("Starting runner at position: ", active_runner.position)
	
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
	path_follow.add_child(active_runner)
	active_runner.progress_ratio = 0.0
	print("Runner setup complete on path")

func update_runner(delta):
	if not active_runner:
		return
		
	var path_follow = active_runner.get_parent()
	path_follow.progress_ratio += delta * 0.5  # Adjust speed as needed
	
	if path_follow.progress_ratio >= 1.0:
		runner_escaped()



func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if active_runner and not missile_active:
				launch_missile(event.position)

func launch_missile(target_pos):
	missile_active = true
	missile_position = Vector2(640, 720)  # Bottom center of screen
	missile_target = target_pos
	missile_sprite.visible = true
	missile_sound.play()

func update_missile(delta):
	var direction = (missile_target - missile_position).normalized()
	missile_position += direction * missile_speed * delta
	missile_sprite.position = missile_position
	missile_sprite.rotation = direction.angle() - PI/2  # Point missile in direction of travel
	
	# Check if missile reached target
	if missile_position.distance_to(missile_target) < 5:
		trigger_explosion()

func trigger_explosion():
	explosion_active = true
	explosion_vfx.position = missile_position
	explosion_vfx.start_explosion()
	missile_active = false
	missile_sprite.visible = false
	explosion_sound.play()
	
	check_runner_hit()

func check_runner_hit():
	if not active_runner:
		return
		
	var distance = active_runner.position.distance_to(explosion_vfx.position)
	
	if distance < explosion_size:
		runner_streak += 1
		var points_earned = runner_base_points
		var bonus_text = ""
		
		# Perfect hit bonus
		if distance < explosion_size / 3:
			points_earned += perfect_hit_bonus
			bonus_text += "PERFECT HIT! +{perfect} bonus\n".format({"perfect": perfect_hit_bonus})
		
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
		path_follow.queue_free()
		active_runner = null
	time_since_last_run = 0

func clear_alert():
	alert_label.visible = false
	alert_label.modulate = Color.WHITE
