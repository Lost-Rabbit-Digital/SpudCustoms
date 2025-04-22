class_name StampSystemManager
extends Node

# Signal to forward from the passport stampable
signal stamp_decision_made(decision: String, perfect: bool)

@export var alert_label: Label
@export var alert_timer: Timer

# Main components
var stamp_system: StampSystem
var stamp_factory: StampFactory
var passport_stampable: StampableComponent

# Game references
var main_game: Node
var stats_manager: Node

# Initialize the stamp system
func initialize(game_scene: Node):
	main_game = game_scene

	# Get reference to stats manager
	stats_manager = game_scene.get_node_or_null("SystemManagers/StatsManager")

	# Get UI references
	alert_label = game_scene.get_node_or_null("UI/Labels/MarginContainer/AlertLabel")
	alert_timer = game_scene.get_node_or_null("SystemManagers/Timers/AlertTimer")
	
	# Log whether we found the references
	if alert_label:
		print("Alert label found successfully")
	else:
		push_warning("Alert label not found in scene tree")
		
	if alert_timer:
		print("Alert timer found successfully")
	else:
		push_warning("Alert timer not found in scene tree")

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
	print("Stamp", stamp)
	print("Document", document)
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
		
		# Try to find alert references in the scene tree
		var root = get_tree().current_scene

		# Display the alert if possible
		Global.display_green_alert(
			alert_label,
			alert_timer,
			tr("alert_perfect_hit").format({"perfect": str(perfect_points)})
		)

		# Provide visual feedback with particle effect at stamp position
		# Get the position from either the stamp or the document
		var effect_position = Vector2(385, 350)

		# Create the visual effect
		create_perfect_stamp_effect(effect_position)
	
		# Shake screen
		Global.shake_screen(3, 0.5)


func create_perfect_stamp_effect(position: Vector2):
	# Create a particle effect for perfect stamps
	var particles = CPUParticles2D.new()
	
	# Make sure we're using global position
	particles.global_position = position 
	#+ Vector2(randi_range(-200,200),randi_range(-25,25))
	
	# Set to very high z_index to ensure visibility
	particles.z_index = 25
	
	# Increase amount and lifetime for better visibility
	particles.amount = 100
	particles.lifetime = 4
	particles.explosiveness = 0.9
	
	# Add some spread
	particles.spread = 70.0
	
	# Set direction upward with some randomness
	particles.direction = Vector2(0, -1)
	particles.gravity = Vector2(0, 150)
	
	# Increase velocity for better visibility
	particles.initial_velocity_min = 75
	particles.initial_velocity_max = 250
	
	particles.scale_amount_min = 0.6 # Minimum size
	particles.scale_amount_max = 6.0  # Maximum size
	
	# Use a bright, noticeable color
	particles.color = Color(1, 0.8, 0, 1)  # Gold particles
	
	# Add a second color for variation (optional)
	particles.color_ramp = Gradient.new()
	particles.color_ramp.add_point(0.0, Color(1, 0.8, 0, 1))  # Gold
	particles.color_ramp.add_point(1.0, Color(1, 0.5, 0, 0.1))  # Fading orange
	
	# Add to scene root rather than StampSystemManager
	get_tree().current_scene.add_child(particles)
	
	# Start emitting
	particles.emitting = true
	
	# Auto-cleanup
	var timer = Timer.new()
	timer.wait_time = 4
	timer.one_shot = true
	get_tree().current_scene.add_child(timer)
	timer.start()
	timer.timeout.connect(
		func():
			particles.queue_free()
			timer.queue_free()
	)
	
	# Debug information
	print("Created particle effect at position: ", position)

# Handle stamps specifically applied to the passport
func _on_passport_stamped(_stamp: StampComponent, is_perfect: bool):
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
