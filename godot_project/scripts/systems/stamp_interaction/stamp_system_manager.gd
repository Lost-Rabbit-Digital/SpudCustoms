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
func _on_stamp_applied(stamp: StampComponent, document: Node, is_perfect: bool):
	# Update stats
	if stats_manager:
		stats_manager.current_stats.total_stamps += 1
		
		if is_perfect:
			stats_manager.current_stats.perfect_stamps += 1
			# Add bonus for perfect stamp
			Global.add_score(100)

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
