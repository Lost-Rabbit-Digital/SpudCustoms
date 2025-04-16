extends Control

signal closed
signal continue_to_next_shift
signal return_to_main_menu
signal restart_shift

const GRADE_STAMP_TEXTURE = preload("res://assets/menu/performance_stamp.png")

var stats: Dictionary
# First try using the unique node name identifier
var narrative_manager

@onready var animation_player = $AnimationPlayer


func _init():
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow input to pass through to buttons


func _ready():
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_STOP  # Block input from passing through
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

	var narrative_manager = %NarrativeManager

	# Use stored stats if available, otherwise use test data
	if !Global.current_game_stats.is_empty():
		show_summary(Global.current_game_stats)
	else:
		show_summary(generate_test_stats())

	# Ensure buttons are interactive
	for button in [$ContinueButton, $SubmitScoreButton, $RestartButton, $MainMenuButton]:
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# Make sure child elements don't block input for buttons
	$ScreenBackground.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Connect button signals
	#$ContinueButton.connect("pressed", Callable(self, "_on_continue_button_pressed"))
	#$SubmitScoreButton.connect("pressed", Callable(self, "_on_submit_score_button_pressed"))
	#$RestartButton.connect("pressed", Callable(self, "_on_restart_button_pressed"))
	#$MainMenuButton.connect("pressed", Callable(self, "_on_main_menu_button_pressed"))

	# Call animation
	play_entry_animation()


# Add to ShiftSummaryScreen.gd
func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%sm %ss" % [minutes, secs]


func show_summary(stats_data: Dictionary):
	stats = stats_data
	show()

	# First update the shift number regardless of win/loss status
	var shift_number = stats.get("shift", 1)

	# Determine if player won or lost
	var win_condition = stats.get("quota_met", 0) >= stats.get("quota_target", 5)
	print("Win Condition ", win_condition)
	var strikes_failed = stats.get("strikes", 0) >= stats.get("max_strikes", 6)
	print("Strikes failed: ", strikes_failed)
	var global_strikes_failed = Global.strikes >= Global.max_strikes
	print("Global Strikes failed: ", global_strikes_failed)

	# Update UI based on result
	if win_condition:
		$LeftPanel/ShiftComplete.text = (
			"""SHIFT {shift} COMPLETE
		SUCCESS!
		"""
			. format({"shift": shift_number})
		)
		$LeftPanel/ShiftComplete.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	else:
		var failure_reason = "STRIKE LIMIT REACHED!" if strikes_failed else "QUOTA NOT MET!"
		$LeftPanel/ShiftComplete.text = (
			"""SHIFT {shift} COMPLETE
		{failure}
		"""
			. format({"shift": shift_number, "failure": failure_reason})
		)
		$LeftPanel/ShiftComplete.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))

	#Get rid of continue button if lost
	if global_strikes_failed:
		$ContinueButton.queue_free()

	populate_stats()


func populate_stats():
	# Update shift info
	$HeaderPanel/Title.text = "SHIFT SUMMARY\n %s" % Global.difficulty_level

	# Update missile stats with calculated hit rate
	$LeftPanel/MissileStats.text = (
		"""RUNNER STATS
Runner Attempts: {runner_attempts}
Missiles Fired: {fired}
Runners Hit: {hit}
Perfect Hits: {perfect}
Hit Rate: {rate}%
"""
		. format(
			{
				"runner_attempts": format_number(stats.get("runner_attempts", 0)),
				"fired": format_number(stats.get("missiles_fired", 0)),
				"hit": format_number(stats.get("missiles_hit", 0)),
				"perfect": format_number(stats.get("perfect_hits", 0)),
				"rate": floor(stats.get("hit_rate", 0.0))
			}
		)
	)

	# Update document stats
	$LeftPanel/DocumentStats.text = (
		"""DOCUMENT STATS
Documents Stamped: {stamped}
Potatoes Approved: {approved}
Potatoes Rejected: {rejected}
Perfect Stamps: {perfect_stamps}
"""
		. format(
			{
				"stamped": format_number(stats.get("total_stamps", 0)),
				"approved": format_number(stats.get("potatoes_approved", 0)),
				"rejected": format_number(stats.get("potatoes_rejected", 0)),
				"perfect_stamps": format_number(stats.get("perfect_stamps", 0))
			}
		)
	)

	# Update bonus stats without speed bonus
	$RightPanel/BonusStats.text = (
		"""BONUSES
Processing Speed Bonus: {processing_speed_bonus}
Stamp Accuracy Bonus: {accuracy}
Perfect Hits Bonus: {perfect_hit_bonus}
Total Score Bonus: {total_score_bonus}
"""
		. format(
			{
				"processing_speed_bonus": format_number(stats.get("processing_speed_bonus", 0)),
				"accuracy": format_number(stats.get("accuracy_bonus", 0)),
				"perfect_hit_bonus": format_number(stats.get("perfect_hit_bonus", 0)),
				"total_score_bonus":
				format_number(
					(
						stats.get("processing_speed_bonus", 0)
						+ stats.get("accuracy_bonus", 0)
						+ stats.get("perfect_hit_bonus", 0)
					)
				)
			}
		)
	)

	# Update leaderboard
	update_leaderboard()

	# Add performance comparison
	var difficulty_rating = "Normal"
	var expected_score = 2000  # Base expected score

	# Adjust expectations based on difficulty
	match Global.difficulty_level:
		"Easy":
			expected_score = 1000
			difficulty_rating = "Easy"
		"Normal":
			expected_score = 2000
			difficulty_rating = "Normal"
		"Expert":
			expected_score = 3000
			difficulty_rating = "Expert"

	# Calculate performance percentage
	var performance = float(stats.get("score", 0)) / float(expected_score) * 100
	var performance_text = "Average"
	var performance_color = Color(1.0, 0.8, 0)  # Default yellow

	if performance >= 150:
		performance_text = "Exceptional!"
		performance_color = Color(1.0, 0.4, 0.8)  # Pink
		$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
		$"RightPanel/GradeStamp-2".texture = GRADE_STAMP_TEXTURE
		$"RightPanel/GradeStamp-3".texture = GRADE_STAMP_TEXTURE
	elif performance >= 120:
		performance_text = "Excellent!"
		performance_color = Color(0.2, 0.8, 0.2)  # Green
		$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
		$"RightPanel/GradeStamp-2".texture = GRADE_STAMP_TEXTURE
	elif performance >= 90:
		performance_text = "Good"
		performance_color = Color(0.4, 0.7, 0.1)  # Light green
		$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
	elif performance < 70:
		performance_text = "Needs Improvement"
		performance_color = Color(0.8, 0.4, 0.1)  # Orange
	elif performance < 50:
		performance_text = "Poor"
		performance_color = Color(0.8, 0.2, 0.2)  # Red

	# Add performance rating to display
	$RightPanel/PerformanceStats.text = (
		"""PERFORMANCE
Time Taken: {time_taken}
Expected Score: {expected_score}
Total Score: {score}
Over-Score Percentage: {percent}%
Performance Rating:
{rating}
	"""
		. format(
			{
				"time_taken": format_time(stats.get("time_taken", 0)),
				"expected_score": format_number(int(expected_score)),
				"score": format_number(stats.get("score", 0)),
				"percent": floor(performance),
				"rating": performance_text
			}
		)
	)

	$RightPanel/PerformanceStats.add_theme_color_override("font_color", performance_color)

	# Update the performance stats with high score information
	var level_id = stats.get("shift", 1)
	var high_score = GameState.get_high_score(level_id)
	var is_new_high_score = stats.get("score", 0) > high_score && high_score > 0

	if is_new_high_score:
		$RightPanel/PerformanceStats.text += "\nNEW HIGH SCORE!"
		$RightPanel/PerformanceStats.add_theme_color_override(
			"font_color", Color(1.0, 0.8, 0.2, 1.0)
		)
	elif high_score > 0:
		$RightPanel/PerformanceStats.text += "\nHigh Score: " + str(high_score)


func play_entry_animation():
	# Set initial states for text elements
	$LeftPanel.modulate.a = 0
	$RightPanel.modulate.a = 0
	$HeaderPanel.modulate.a = 0
	$LeaderboardPanel.modulate.a = 0
	$LeaderboardTitlePanel.modulate.a = 0

	# Store original positions
	var stats_bg_original_pos = $StatsJournalBackground.position
	var leaderboard_bg_original_pos = $LeaderboardBackground.position

	# Set initial positions (off-screen at the top)
	$StatsJournalBackground.position.y = -$StatsJournalBackground.texture.get_height() - 400
	$LeaderboardBackground.position.y = -$LeaderboardBackground.texture.get_height() - 400

	# Create animation sequence
	var tween = create_tween()
	tween.set_parallel(false)  # Sequential animations

	# 1. First, slide in StatsJournalBackground with bounce
	(
		tween
		. tween_property($StatsJournalBackground, "position:y", stats_bg_original_pos.y - 30, 0.75)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)

	# Add bounce
	(
		tween
		. tween_property($StatsJournalBackground, "position:y", stats_bg_original_pos.y + 15, 0.3)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_IN_OUT)
	)

	# Final settle
	(
		tween
		. tween_property($StatsJournalBackground, "position:y", stats_bg_original_pos.y, 0.2)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)

	# 2. Then, slide in LeaderboardBackground with bounce
	(
		tween
		. tween_property(
			$LeaderboardBackground, "position:y", leaderboard_bg_original_pos.y - 30, 0.7
		)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)

	# Add bounce
	(
		tween
		. tween_property(
			$LeaderboardBackground, "position:y", leaderboard_bg_original_pos.y + 15, 0.3
		)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_IN_OUT)
	)

	# Final settle
	(
		tween
		. tween_property($LeaderboardBackground, "position:y", leaderboard_bg_original_pos.y, 0.2)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)

	# 3. Now start the text animations with slow fade-in

	# Header fades in first (slow)
	tween.tween_property($HeaderPanel, "modulate:a", 1.0, 1.0)

	# Then the panels fade in (slow)
	tween.tween_property($LeftPanel, "modulate:a", 1.0, 0.9)
	tween.tween_property($RightPanel, "modulate:a", 1.0, 0.9)

	# Finally the leaderboard (slow)
	tween.tween_property($LeaderboardTitlePanel, "modulate:a", 1.0, 0.7)
	tween.tween_property($LeaderboardPanel, "modulate:a", 1.0, 0.7)


# Helper function to format numbers with commas
func format_number(number: int) -> String:
	var str_num = str(number)
	var formatted = ""
	var count = 0

	# Add commas every 3 digits from the right
	for i in range(str_num.length() - 1, -1, -1):
		if count == 3:
			formatted = "," + formatted
			count = 0
		formatted = str_num[i] + formatted
		count += 1

	return formatted


func calculate_hit_rate() -> String:
	if stats.get("missiles_fired", 0) > 0:
		return "%d" % ((float(stats.get("missiles_hit", 0)) / stats.get("missiles_fired", 0)) * 100)
	return "0"


func update_leaderboard():
	print("Submitting score of: ")
	print(Global.final_score)
	Global.submit_score(Global.final_score)
	print("Updating leaderboard...")
	$LeaderboardTitlePanel/Title.text = "Global Leaderboard\nEndless - %s" % Global.difficulty_level
	# Format leaderboard entries
	var request_success = Global.request_leaderboard_entries(Global.difficulty_level)
	var leaderboard_text = ""

	if request_success:
		leaderboard_text = "Getting leaderboard scores..."
		$LeaderboardPanel/Entries.text = leaderboard_text

	await get_tree().create_timer(1.0).timeout

	leaderboard_text = ""
	$LeaderboardPanel/Entries.text = ""

	await get_tree().create_timer(1.0).timeout

	var entries = [{"name": "Score?", "score": "404"}]
	if SteamManager.cached_leaderboard_entries:
		entries = SteamManager.cached_leaderboard_entries
	else:
		push_warning("No cached leaderboard entries")
	for i in range(min(entries.size(), 12)):
		leaderboard_text += (
			"%2d  %-15s  %s\n" % [i + 1, entries[i].name, format_number(int(entries[i].score))]
		)

	$LeaderboardPanel/Entries.text = leaderboard_text
	print("Leaderboard updated.")


func generate_test_stats() -> Dictionary:
	return {
		"shift": 1337,  # Current shift number
		"time_taken": 1337.0,  # Time taken in seconds
		"score": 1337,  # Base score
		"missiles_fired": 1337,
		"missiles_hit": 1337,
		"perfect_hits": 1337,
		"total_stamps": 1337,
		"potatoes_approved": 1337,
		"potatoes_rejected": 1337,
		"accuracy_bonus": 1337,
		"final_score": 1337
	}


func _on_submit_score_button_pressed() -> void:
	print("Submit Score Button Clicked, submitting score and updating leaderboard")
	update_leaderboard()


# Handle scene transition after fade out
func _handle_scene_transition(scene_path: String) -> void:
	# Create a small delay to ensure the screen is fully black
	var timer = get_tree().create_timer(0.1)

	# Check if SceneLoader exists in the scene tree (it should be autoloaded)
	if Engine.has_singleton("SceneLoader") or get_node_or_null("/root/SceneLoader"):
		# Use SceneLoader if available
		var loader = get_node("/root/SceneLoader")
		if loader and loader.has_method("load_scene"):
			loader.load_scene(scene_path)
		else:
			get_tree().change_scene_to_file(scene_path)
	else:
		# Direct scene transition fallback
		get_tree().change_scene_to_file(scene_path)


func transition_to_scene(scene_path: String):
	# Create a canvas layer to ensure the fade rectangle covers everything
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 128  # Very high layer to be above everything
	add_child(canvas_layer)

	# Create a properly sized fade rectangle
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport_rect().size
	canvas_layer.add_child(fade_rect)

	# Make sure the rect covers the whole screen regardless of viewport size
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_bottom = 1.0

	# Fade out animation
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.5)

	# Use a callback to handle the scene transition after fade completes
	tween.tween_callback(_handle_scene_transition.bind(scene_path))


func _on_continue_button_pressed() -> void:
	Global.reset_shift_stats()
	print("Continue button pressed")

	# Saving current game state
	GlobalState.save()

	# Emit signal
	emit_signal("continue_to_next_shift")
	queue_free()


func _on_restart_button_pressed() -> void:
	Global.reset_shift_stats()
	print("Restart button pressed")
	emit_signal("restart_shift")
	queue_free()


func _on_main_menu_button_pressed() -> void:
	Global.reset_shift_stats()
	print("Main menu button pressed, emitting signal")
	emit_signal("return_to_main_menu")
	queue_free()


func transition_to_scene_in_viewport(scene_path: String):
	# Create a canvas layer to ensure the fade rectangle covers everything
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 128  # Very high layer to be above everything
	add_child(canvas_layer)

	# Create a properly sized fade rectangle
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport_rect().size
	canvas_layer.add_child(fade_rect)

	# Ensure the rect covers the whole viewport
	if fade_rect is Control:
		fade_rect.anchor_right = 1.0
		fade_rect.anchor_bottom = 1.0
		fade_rect.grow_horizontal = Control.GROW_DIRECTION_BOTH
		fade_rect.grow_vertical = Control.GROW_DIRECTION_BOTH

	# Fade out animation
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.5)

	# Use a timer to ensure the tween completes before changing scenes
	await tween.finished

	# Find the parent ViewportContainer or SubViewport
	var viewport_container = find_parent_viewport()
	if viewport_container:
		# Clear existing content
		for child in viewport_container.get_children():
			child.queue_free()

		# Load and add new scene
		var new_scene = load(scene_path).instantiate()
		viewport_container.add_child(new_scene)
		print("Scene transitioned within viewport: " + scene_path)
	else:
		# Fallback to direct scene transition if can't find viewport
		push_warning("Could not find parent viewport, using direct scene transition")
		get_tree().change_scene_to_file(scene_path)

	# Signal completion
	emit_signal("closed")
	queue_free()


# Helper function to find the parent viewport
func find_parent_viewport():
	var parent = get_parent()
	while parent:
		# Check if this is a SubViewport or ViewportContainer
		if parent is SubViewport or parent is SubViewportContainer:
			return parent

		# Move up the scene tree
		parent = parent.get_parent()

	# If we didn't find a viewport container
	return null


func _on_shift_summary_continue():
	print("Continuing to next shift")

	# Save the current shift number before advancing
	var completed_shift = Global.shift

	# Save high score for the current level
	GameState.set_high_score(completed_shift, Global.difficulty_level, Global.score)

	# Advance the shift and story state
	Global.advance_shift()
	Global.advance_story_state()

	# Make sure GameState is updated with our progress
	GameState.level_reached(completed_shift + 1)

	# Check if there's an end dialogue for this shift
	if completed_shift in narrative_manager.LEVEL_END_DIALOGUES:
		# Play the ending dialogue for the completed shift
		narrative_manager.start_level_end_dialogue(completed_shift)

		# Wait for dialogue to finish before proceeding
		await narrative_manager.end_dialogue_finished

	# Check if we've reached the end of the game
	if completed_shift >= 13:
		# Final shift completed, show credits
		transition_to_scene("res://scenes/end_credits/end_credits.tscn")
		return

	# Show day transition
	print("showing day transition")
	narrative_manager.show_day_transition(completed_shift, completed_shift + 1)

	SceneLoader.reload_current_scene()
	# Ensure a clean transition for the viewport
	#transition_within_viewport("res://scenes/game_scene/mainGame.tscn")


func _on_shift_summary_restart():
	# Keep the same shift but reset the stats
	Global.reset_shift_stats()
	Global.reset_game_state()
	GlobalState.save()

	# Transition within the viewport
	transition_within_viewport("res://scenes/game_scene/mainGame.tscn")


func _on_shift_summary_main_menu():
	# Save state before transitioning to main menu
	Global.reset_shift_stats()
	GlobalState.save()

	# This one might be different - if main menu is outside viewport
	var main_menu_path = "res://scenes/menus/main_menu/main_menu_with_animations.tscn"

	# Check if we need to exit the subviewport entirely
	if should_exit_viewport_for_main_menu():
		get_tree().change_scene_to_file(main_menu_path)
	else:
		transition_within_viewport(main_menu_path)


# Helper function to determine if we should exit viewport for main menu
func should_exit_viewport_for_main_menu() -> bool:
	# Check the structure of your scene tree
	# This depends on how your project is organized

	# Simple implementation - check if main menu is a different root
	var current_scene_path = get_tree().current_scene.scene_file_path
	var is_within_game_scene = current_scene_path.contains("game_scene")

	# If we're in a game scene, we probably need to exit the viewport
	return is_within_game_scene


# General utility function for transitions within viewport
func transition_within_viewport(scene_path: String):
	# Find the parent viewport container
	var viewport_container = find_parent_viewport_container()

	if viewport_container:
		# Create fade effect
		var fade_rect = ColorRect.new()
		fade_rect.color = Color(0, 0, 0, 0)
		fade_rect.size = get_viewport_rect().size
		fade_rect.z_index = 100
		add_child(fade_rect)

		# Fade to black
		var tween = create_tween()
		tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.5)

		# Remove all current children from the viewport
		for child in viewport_container.get_children():
			child.free()

		# Instantiate the new scene
		var new_scene = load(scene_path).instantiate()
		viewport_container.add_child(new_scene)

		print("Transitioned within viewport to: " + scene_path)

		# Clean up fade rect
		fade_rect.queue_free()
	else:
		# Fallback to direct scene change
		push_warning("Could not find viewport container, using direct scene transition")
		get_tree().change_scene_to_file(scene_path)


func find_parent_viewport_container():
	var parent = get_parent()
	while parent:
		if parent is SubViewportContainer or parent is SubViewport:
			return parent
		parent = parent.get_parent()
	return null


# You might want to add this to a utility script for reuse across your project
static func find_viewports_in_tree(node: Node) -> Array:
	var viewports = []

	if node is SubViewport or node is SubViewportContainer:
		viewports.append(node)

	for child in node.get_children():
		var child_viewports = find_viewports_in_tree(child)
		viewports.append_array(child_viewports)

	return viewports
