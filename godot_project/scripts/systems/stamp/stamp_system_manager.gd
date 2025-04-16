extends Node
class_name StampSystemManager

# Main components
var stamp_system: StampSystem
var stamp_factory: StampFactory
var passport_stampable: StampableComponent

# Game references
var main_game: Node
var stats_manager: Node

# Signal to forward from the passport stampable
signal stamp_decision_made(decision: String, perfect: bool)


# Initialize the stamp system
func initialize(game_scene: Node):
	main_game = game_scene

	# Get reference to stats manager
	stats_manager = game_scene.get_node_or_null("SystemManagers/StatsManager")

	# Create the stamp system using our factory
	stamp_system = StampFactory.create_stamp_system(game_scene)

	# Connect stamp system signals
	stamp_system.stamp_applied.connect(_on_stamp_applied)

	# Get a direct reference to the stamp bar controller
	var stamp_bar = game_scene.get_node_or_null("Gameplay/InteractiveElements/StampBarController")

	# Create stampable component for passport
	passport_stampable = StampFactory.create_passport_stampable(game_scene, stamp_system)

	# Connect stamp bar to system by passing the node directly
	if stamp_bar:
		StampFactory.connect_stamp_bar_to_system(stamp_bar, stamp_system)
	else:
		push_error("StampBarController not found in scene")


# Handle stamp application to any document
# In StampSystemManager.gd
func _on_stamp_applied(stamp: StampComponent, document: Node, is_perfect: bool):
	# Update stats for all stamps
	if stats_manager:
		stats_manager.current_stats.total_stamps += 1

	# Additional actions for perfect stamps
	if is_perfect:
		# Update perfect stamp count
		if stats_manager:
			stats_manager.current_stats.perfect_stamps += 1

		# Perfect stamp bonus points
		var perfect_points = 200
		Global.add_score(perfect_points)

		# Find the alert display system - first through main game
		var alert_label = null
		var alert_timer = null

		# Try to find alert references in the scene tree
		var root = get_tree().current_scene
		alert_label = root.get_node_or_null("UI/Labels/MarginContainer/AlertLabel")
		alert_timer = root.get_node_or_null("SystemManagers/Timers/AlertTimer")

		# Display the alert if possible
		if alert_label and alert_timer and Global.has_method("display_green_alert"):
			Global.display_green_alert(
				alert_label,
				alert_timer,
				"PERFECT STAMP! +{points} points!".format({"points": perfect_points})
			)

		# Provide visual feedback with particle effect at stamp position
		# Get the position from either the stamp or the document
		var effect_position = stamp.applied_position
		if effect_position == Vector2.ZERO and document is Node2D:
			effect_position = document.global_position

		# Create the visual effect
		create_perfect_stamp_effect(effect_position)

		# Shake screen if possible
		if root.has_method("shake_screen"):
			root.shake_screen(5.0, 0.2)


func create_perfect_stamp_effect(position: Vector2):
	# Create a particle effect for perfect stamps
	var particles = CPUParticles2D.new()
	particles.position = position
	particles.z_index = 11
	particles.amount = 20
	particles.lifetime = 1.0
	particles.explosiveness = 0.8
	particles.direction = Vector2(0, -1)
	particles.gravity = Vector2(0, 98)
	particles.initial_velocity_min = 50
	particles.initial_velocity_max = 100
	particles.color = Color(1, 0.8, 0, 1)  # Gold particles
	# Add to scene and auto-remove when done
	add_child(particles)
	particles.emitting = true

	# Auto-cleanup
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(
		func():
			particles.queue_free()
			timer.queue_free()
	)


# Handle stamps specifically applied to the passport
func _on_passport_stamped(stamp: StampComponent, is_perfect: bool):
	# Only emit decision signal if we have passport stamps
	var decision = passport_stampable.get_decision()
	if decision != "":
		emit_signal("stamp_decision_made", decision, is_perfect)


# Check for stamps and process a decision
func process_passport_decision():
	if passport_stampable and passport_stampable.has_stamps():
		var decision = passport_stampable.get_decision()

		# Clear the stamps after making decision
		passport_stampable.clear_stamps()

		return decision
	return ""


# Clear all stamps from passport
func clear_passport_stamps():
	if passport_stampable:
		passport_stampable.clear_stamps()
