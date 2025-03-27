extends Control

@onready var animation_player = $AnimationPlayer
@onready var background = $Background
signal closed

var stats: Dictionary
const BACKGROUND_TEXTURE = preload("res://assets/menu/shift_summary_end_screen.png")
const GRADE_STAMP_TEXTURE = preload("res://assets/menu/performance_stamp.png")

signal continue_to_next_shift
signal return_to_main_menu
signal restart_shift

func _init():
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow input to pass through to buttons

func _ready():
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_STOP  # Block input from passing through
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

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
	$Background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$ScreenBackground.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Connect button signals
	$ContinueButton.connect("pressed", Callable(self, "_on_continue_button_pressed"))
	$SubmitScoreButton.connect("pressed", Callable(self, "_on_submit_score_button_pressed"))
	$RestartButton.connect("pressed", Callable(self, "_on_restart_button_pressed"))
	$MainMenuButton.connect("pressed", Callable(self, "_on_main_menu_button_pressed"))
	
	setup_background()
	
	var original_bg_pos = $Background.position
	
	# Call animation
	play_entry_animation()

func setup_background():
	if background and BACKGROUND_TEXTURE:
		background.texture = BACKGROUND_TEXTURE
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

# Add to ShiftSummaryScreen.gd
func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%sm %ss" % [minutes, secs]

func show_summary(stats_data: Dictionary):
	stats = stats_data
	show()
	 # Determine if player won or lost
	var win_condition = stats.get("quota_met", 0) >= stats.get("quota_target", 0)
	var strikes_failed = stats.get("strikes", 0) >= stats.get("max_strikes", 0)
	
	# Update UI based on result
	if win_condition:
		$LeftPanel/ShiftComplete.text = """SHIFT {shift} COMPLETE
		SUCCESS!
		""".format({
			"shift": stats.get("shift", 1)
		})
		$LeftPanel/ShiftComplete.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	else:
		var failure_reason = "STRIKE LIMIT REACHED!" if strikes_failed else "QUOTA NOT MET!"
		$LeftPanel/ShiftComplete.text = """SHIFT {shift} COMPLETE
		{failure}
		""".format({
			"shift": stats.get("shift", 1),
			"failure": failure_reason
		})
		$LeftPanel/ShiftComplete.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	populate_stats()

func populate_stats():
	
	# Update shift info
	$HeaderPanel/Title.text = "SHIFT SUMMARY\n %s" % Global.difficulty_level
	
	# Update missile stats with calculated hit rate
	$LeftPanel/MissileStats.text = """RUNNER STATS
Runner Attempts: {runner_attempts}
Missiles Fired: {fired}
Runners Hit: {hit}
Perfect Hits: {perfect}
Hit Rate: {rate}%
""".format({
		"runner_attempts": format_number(stats.get("runner_attempts", 0)),
		"fired": format_number(stats.get("missiles_fired", 0)),
		"hit": format_number(stats.get("missiles_hit", 0)),
		"perfect": format_number(stats.get("perfect_hits", 0)),
		"rate": floor(stats.get("hit_rate", 0.0))
	})
	
	# Update document stats
	$LeftPanel/DocumentStats.text = """DOCUMENT STATS
Documents Stamped: {stamped}
Potatoes Approved: {approved}
Potatoes Rejected: {rejected}
Perfect Stamps: {perfect_stamps}
""".format({
		"stamped": format_number(stats.get("total_stamps", 0)),
		"approved": format_number(stats.get("potatoes_approved", 0)),
		"rejected": format_number(stats.get("potatoes_rejected", 0)),
		"perfect_stamps": format_number(stats.get("perfect_stamps", 0))
	})
	
	# Update bonus stats without speed bonus
	$RightPanel/BonusStats.text = """BONUSES
Processing Speed Bonus: {processing_speed_bonus}
Stamp Accuracy Bonus: {accuracy}
Perfect Hits Bonus: {perfect_hit_bonus}
Total Score Bonus: {total_score_bonus}
""".format({
		"processing_speed_bonus": format_number(stats.get("processing_speed_bonus", 0)),
		"accuracy": format_number(stats.get("accuracy_bonus", 0)),
		"perfect_hit_bonus": format_number(stats.get("perfect_hit_bonus", 0)),
		"total_score_bonus": format_number(stats.get("processing_speed_bonus", 0) + stats.get("accuracy_bonus", 0) + stats.get("perfect_hit_bonus", 0))
	})
	
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
	$RightPanel/PerformanceStats.text = """PERFORMANCE
Time Taken: {time_taken}
Expected Score: {expected_score}
Total Score: {score}
Over-Score Percentage: {percent}%
Performance Rating: 
{rating}
	""".format({
		"time_taken": format_time(stats.get("time_taken", 0)),
		"expected_score": format_number(int(expected_score)),
		"score": format_number(stats.get("score", 0)),
		"percent": floor(performance),
		"rating": performance_text
	})
	
	$RightPanel/PerformanceStats.add_theme_color_override("font_color", performance_color)

	var high_score = GameState.get_high_score(stats.get("shift", 1))
	var is_new_high_score = stats.get("score", 0) > high_score
	
	if is_new_high_score && high_score > 0:
		$RightPanel/PerformanceStats.text += "\nNEW HIGH SCORE!"
		$RightPanel/PerformanceStats.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))
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
	tween.tween_property($StatsJournalBackground, "position:y", stats_bg_original_pos.y - 30, 0.75)\
		 .set_trans(Tween.TRANS_BACK)\
		 .set_ease(Tween.EASE_OUT)
	
	# Add bounce
	tween.tween_property($StatsJournalBackground, "position:y", stats_bg_original_pos.y + 15, 0.3)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
		 
	# Final settle
	tween.tween_property($StatsJournalBackground, "position:y", stats_bg_original_pos.y, 0.2)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)
	
	# 2. Then, slide in LeaderboardBackground with bounce
	tween.tween_property($LeaderboardBackground, "position:y", leaderboard_bg_original_pos.y - 30, 0.7)\
		 .set_trans(Tween.TRANS_BACK)\
		 .set_ease(Tween.EASE_OUT)
	
	# Add bounce
	tween.tween_property($LeaderboardBackground, "position:y", leaderboard_bg_original_pos.y + 15, 0.3)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_IN_OUT)
		 
	# Final settle
	tween.tween_property($LeaderboardBackground, "position:y", leaderboard_bg_original_pos.y, 0.2)\
		 .set_trans(Tween.TRANS_SINE)\
		 .set_ease(Tween.EASE_OUT)
	
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
	
	var entries = [{"name":"Score?","score":"404"}]
	entries = Global.cached_leaderboard_entries
	for i in range(min(entries.size(), 12)):
		leaderboard_text += "%2d  %-15s  %s\n" % [
			i + 1,
			entries[i].name,
			format_number(entries[i].score)
		]
	
	$LeaderboardPanel/Entries.text = leaderboard_text
	print("Leaderboard updated.")

func generate_test_stats() -> Dictionary:
	return {
		"shift": 1337,                    # Current shift number
		"time_taken": 1337.0,           # Time taken in seconds
		"score": 1337,                 # Base score
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
	
func transition_to_scene(scene_path: String):
	# Create a tween for a cleaner fade transition
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = get_viewport_rect().size
	fade_rect.z_index = 100  # Ensure it's above everything
	add_child(fade_rect)
	
	# Fade out animation
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.5)
	
	# Load scene after animation completes
	tween.tween_callback(func():
		# Access SceneLoader directly
		#if SceneLoader:
		#	SceneLoader.load_scene(scene_path)
		#else:
		push_error("SceneLoader not found, falling back to change_scene_to_file")
		get_tree().change_scene_to_file(scene_path)
		# Clean up the fade rectangle
		fade_rect.queue_free()
	)

func _on_continue_button_pressed() -> void: 
	print("Continue button pressed")
	emit_signal("continue_to_next_shift")
	queue_free()

func _on_restart_button_pressed() -> void:
	print("Restart button pressed")
	emit_signal("restart_shift")
	queue_free()

func _on_main_menu_button_pressed() -> void:
	print("Main menu button pressed")
	emit_signal("return_to_main_menu")
	queue_free()
