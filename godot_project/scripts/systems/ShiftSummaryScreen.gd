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
	if not SteamManager.leaderboard_updated.is_connected(_on_leaderboard_updated):
		SteamManager.leaderboard_updated.connect(_on_leaderboard_updated)
	if not SteamManager.score_submitted.is_connected(_on_score_submitted):
		SteamManager.score_submitted.connect(_on_score_submitted)
	
	# Log startup information
	LogManager.write_info("ShiftSummaryScreen initialized")
	LogManager.write_info("Game Stats: " + str(stats))
	
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_STOP  # Block input from passing through
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

	var narrative_manager = %NarrativeManager

	# Use stored stats if available, otherwise use test data
	if !Global.current_game_stats.is_empty():
		show_summary(Global.current_game_stats)
		LogManager.write_info("Using actual game stats")
	else:
		show_summary(generate_test_stats())
		LogManager.write_info("Using test stats")

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

func _on_leaderboard_updated(entries: Array):
	LogManager.write_info("Leaderboard updated callback received - entries: " + str(entries.size()))
	var leaderboard_text = ""
	
	if entries.is_empty():
		leaderboard_text = "No leaderboard entries available."
		LogManager.write_warning("Received empty leaderboard entries")
	else:
		LogManager.write_info("Processing " + str(entries.size()) + " leaderboard entries")
		for i in range(min(entries.size(), 12)):
			# Format each entry with proper padding
			leaderboard_text += "%2d  %-15s  %s\n" % [
				i + 1, 
				entries[i].name.substr(0, 15), 
				format_number(int(entries[i].score))
			]
	
	$LeaderboardPanel/Entries.text = leaderboard_text
	LogManager.write_info("Leaderboard display updated")

func _on_score_submitted(success: bool):
	LogManager.write_info("Score submission callback received - success: " + str(success))
	
	# Create visual feedback
	var notification = Label.new()
	notification.z_index = 100
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	if success:
		notification.text = "Score submitted successfully!"
		notification.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
		LogManager.write_info("Score successfully submitted")
		
		# Request updated leaderboard immediately
		LogManager.write_info("Requesting updated leaderboard data")
		Global.request_leaderboard_entries(Global.difficulty_level)
	else:
		notification.text = "Failed to submit score to leaderboard."
		notification.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
		LogManager.write_error("Score submission failed")
		
		# Re-enable submit button
		$SubmitScoreButton.disabled = false
		$SubmitScoreButton.text = "Retry Submit"
	
	# Position the notification at the center bottom of the screen
	notification.position = Vector2(
		$LeaderboardPanel.position.x + $LeaderboardPanel.size.x / 2,
		$LeaderboardPanel.position.y + $LeaderboardPanel.size.y - 40
	)
	
	add_child(notification)
	
	# Remove notification after a delay
	var tween = create_tween()
	tween.tween_property(notification, "modulate:a", 0.0, 2.0)
	tween.tween_callback(func(): notification.queue_free())

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return tr("time_format").format({"minutes": minutes, "seconds": secs})


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
		$LeftPanel/ShiftComplete.text = tr("shift_complete_success").format({"shift": shift_number})
		$LeftPanel/ShiftComplete.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	else:
		var failure_reason = tr("strike_limit_reached") if strikes_failed else tr("quota_not_met")
		$LeftPanel/ShiftComplete.text = tr("shift_complete_failure").format({
			"shift": shift_number, 
			"failure": failure_reason
		})
		$LeftPanel/ShiftComplete.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))

	#Get rid of continue button if lost
	if global_strikes_failed:
		$ContinueButton.queue_free()

	populate_stats()


func populate_stats():
	# Add performance comparison
	var difficulty_rating = "Normal"
	var expected_score = 2000  # Base expected score

	# Adjust expectations based on difficulty
	match Global.difficulty_level:
		"Easy":
			expected_score = 1000
			difficulty_rating = tr("options_difficulty_easy")
		"Normal":
			expected_score = 2000
			difficulty_rating = tr("options_difficulty_normal")
		"Expert":
			expected_score = 3000
			difficulty_rating = tr("options_difficulty_expert")
	
	# Update shift info
	$HeaderPanel/Title.text = tr("shift_summary_title_with_difficulty").format({"difficulty": difficulty_rating})

	# Update missile stats with calculated hit rate
	$LeftPanel/MissileStats.text = tr("runner_stats_template").format({
		"runner_attempts": format_number(stats.get("runner_attempts", 0)),
		"fired": format_number(stats.get("missiles_fired", 0)),
		"hit": format_number(stats.get("missiles_hit", 0)),
		"perfect": format_number(stats.get("perfect_hits", 0)),
		"rate": floor(stats.get("hit_rate", 0.0))
	})

	# Update document stats
	$LeftPanel/DocumentStats.text = tr("document_stats_template").format({
		"stamped": format_number(stats.get("total_stamps", 0)),
		"approved": format_number(stats.get("potatoes_approved", 0)),
		"rejected": format_number(stats.get("potatoes_rejected", 0)),
		"perfect_stamps": format_number(stats.get("perfect_stamps", 0))
	})

	# Update bonus stats without speed bonus
	$RightPanel/BonusStats.text = tr("bonus_stats_template").format({
		"processing_speed_bonus": format_number(stats.get("processing_speed_bonus", 0)),
		"accuracy": format_number(stats.get("accuracy_bonus", 0)),
		"perfect_hit_bonus": format_number(stats.get("perfect_hit_bonus", 0)),
		"total_score_bonus": format_number(
			(
				stats.get("processing_speed_bonus", 0)
				+ stats.get("accuracy_bonus", 0)
				+ stats.get("perfect_hit_bonus", 0)
			)
		)
	})
	
	# Update leaderboard
	update_leaderboard()

	# Calculate performance percentage
	var performance = float(stats.get("score", 0)) / float(expected_score) * 100
	var performance_text = tr("performance_good")
	var performance_color = Color(1.0, 0.8, 0)  # Default yellow

	if performance >= 150:
		performance_text = tr("performance_exceptional")
		performance_color = Color(1.0, 0.4, 0.8)  # Pink
		$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
		$"RightPanel/GradeStamp-2".texture = GRADE_STAMP_TEXTURE
		$"RightPanel/GradeStamp-3".texture = GRADE_STAMP_TEXTURE
	elif performance >= 120:
		performance_text = tr("performance_excellent")
		performance_color = Color(0.2, 0.8, 0.2)  # Green
		$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
		$"RightPanel/GradeStamp-2".texture = GRADE_STAMP_TEXTURE
	elif performance >= 90:
		performance_text = tr("performance_good")
		performance_color = Color(0.4, 0.7, 0.1)  # Light green
		$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
	elif performance < 70:
		performance_text = tr("performance_needs_improvement")
		performance_color = Color(0.8, 0.4, 0.1)  # Orange
	elif performance < 50:
		performance_text = tr("performance_poor")
		performance_color = Color(0.8, 0.2, 0.2)  # Red


	# Add performance rating to display
	$RightPanel/PerformanceStats.text = tr("performance_stats_template").format({
		"time_taken": format_time(stats.get("time_taken", 0)),
		"expected_score": format_number(int(expected_score)),
		"score": format_number(stats.get("score", 0)),
		"percent": floor(performance),
		"rating": performance_text
	})

	$RightPanel/PerformanceStats.add_theme_color_override("font_color", performance_color)

	# Update the performance stats with high score information
	var level_id = stats.get("shift", 1)
	var high_score = GameState.get_high_score(level_id)
	var is_new_high_score = stats.get("score", 0) > high_score && high_score > 0

	if is_new_high_score:
		$RightPanel/PerformanceStats.text += "\n" + tr("new_high_score")
		$RightPanel/PerformanceStats.add_theme_color_override(
			"font_color", Color(1.0, 0.8, 0.2, 1.0)
		)
	elif high_score > 0:
		$RightPanel/PerformanceStats.text += "\n" + tr("high_score_display").format({"score": str(high_score)})


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

	var expected_score
	# Adjust expectations based on difficulty
	match Global.difficulty_level:
		"Easy":
			expected_score = 1000
		"Normal":
			expected_score = 2000
		"Expert":
			expected_score = 3000

	# Calculate performance percentage
	var performance = float(stats.get("score", 0)) / float(expected_score) * 100
	var performance_text = tr("performance_good")
	var performance_color = Color(1.0, 0.8, 0)  # Default yellow

	if performance >= 150:
		performance_text = tr("performance_exceptional")
		performance_color = Color(1.0, 0.4, 0.8)  # Pink
		$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
		$"RightPanel/GradeStamp-2".texture = GRADE_STAMP_TEXTURE
		$"RightPanel/GradeStamp-3".texture = GRADE_STAMP_TEXTURE
	elif performance >= 120:
		performance_text = tr("performance_excellent")
		performance_color = Color(0.2, 0.8, 0.2)  # Green
		$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
		$"RightPanel/GradeStamp-2".texture = GRADE_STAMP_TEXTURE
	elif performance >= 90:
		performance_text = tr("performance_good")
		performance_color = Color(0.4, 0.7, 0.1)  # Light green
		$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
	elif performance < 70:
		performance_text = tr("performance_needs_improvement")
		performance_color = Color(0.8, 0.4, 0.1)  # Orange
	elif performance < 50:
		performance_text = tr("performance_poor")
		performance_color = Color(0.8, 0.2, 0.2)  # Red

	# Animate stamps based on performance
	animate_grade_stamps(performance)

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
	LogManager.write_info("Updating leaderboard - current score: " + str(Global.final_score))
	$LeaderboardTitlePanel/Title.text = "Global Leaderboard\nEndless - %s" % Global.difficulty_level
	
	# Show loading state and dumping debug info
	$LeaderboardPanel/Entries.text = "Loading leaderboard data..."
	LogManager.write_info("Dumping Steam debug info before leaderboard request")
	SteamManager.dump_debug_info()
	
	# Request leaderboard data
	LogManager.write_info("Requesting leaderboard entries")
	var request_success = Global.request_leaderboard_entries(Global.difficulty_level)
	LogManager.write_info("Request leaderboard result: " + str(request_success))
	
	if !request_success:
		LogManager.write_error("Failed to request leaderboard entries")
		$LeaderboardPanel/Entries.text = "Could not connect to Steam.\nCheck your connection and restart game."
	else:
		LogManager.write_info("Leaderboard request sent successfully")
		
		# Set a timeout for leaderboard loading
		get_tree().create_timer(5.0).timeout.connect(func():
			# Check if we're still showing "Loading..." after 5 seconds
			if $LeaderboardPanel/Entries.text == "Loading leaderboard data...":
				LogManager.write_warning("Leaderboard loading timed out")
				SteamManager.dump_debug_info()
				$LeaderboardPanel/Entries.text = "Loading timed out.\nTry submitting score again."
		)



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
	LogManager.write_info("Submit Score button pressed")
	
	# Add visual feedback
	$SubmitScoreButton.text = "Submitting..."
	$SubmitScoreButton.disabled = true
	
	# Log debug info before submission
	LogManager.write_info("Dumping Steam debug info before score submission")
	SteamManager.dump_debug_info()
	
	# Submit the score
	LogManager.write_info("Submitting score: " + str(Global.final_score))
	var submission_success = Global.submit_score(Global.final_score)
	LogManager.write_info("Submit score API call result: " + str(submission_success))
	
	if !submission_success:
		LogManager.write_error("Failed to submit score API call")
		$SubmitScoreButton.text = "Retry Submit"
		$SubmitScoreButton.disabled = false
		
		# Create temporary notification label
		var notification = Label.new()
		notification.text = "Cannot connect to Steam. Check your connection."
		notification.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
		notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		notification.z_index = 100
		
		notification.position = Vector2(
			$LeaderboardPanel.position.x + $LeaderboardPanel.size.x / 2,
			$LeaderboardPanel.position.y + $LeaderboardPanel.size.y - 40
		)
		
		add_child(notification)
		
		# Remove notification after a delay
		var tween = create_tween()
		tween.tween_property(notification, "modulate:a", 0.0, 2.0)
		tween.tween_callback(func(): notification.queue_free())
		
		return
	
	# Set a timeout for submission
	var submission_timer = get_tree().create_timer(10.0)
	submission_timer.timeout.connect(func():
		# Check if button is still disabled after 10 seconds
		if $SubmitScoreButton.disabled:
			LogManager.write_warning("Score submission timed out")
			SteamManager.dump_debug_info()
			$SubmitScoreButton.text = "Retry Submit"
			$SubmitScoreButton.disabled = false
			
			var timeout_notification = Label.new()
			timeout_notification.text = "Submission timed out. Try again."
			timeout_notification.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
			timeout_notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			timeout_notification.z_index = 100
			
			timeout_notification.position = Vector2(
				$LeaderboardPanel.position.x + $LeaderboardPanel.size.x / 2,
				$LeaderboardPanel.position.y + $LeaderboardPanel.size.y - 40
			)
			
			add_child(timeout_notification)
			
			# Remove notification after a delay
			var tween = create_tween()
			tween.tween_property(timeout_notification, "modulate:a", 0.0, 2.0)
			tween.tween_callback(func(): timeout_notification.queue_free())
	)

func debug_steam_status():
	LogManager.write_info("=== MANUAL STEAM DEBUG REQUESTED ===")
	SteamManager.dump_debug_info()
	
	# Attempt a direct leaderboard re-fetch
	var success = SteamManager._download_leaderboard_entries()
	LogManager.write_info("Manual leaderboard download attempt: " + str(success))
	
	# Create a debug display
	var debug_panel = PanelContainer.new()
	debug_panel.z_index = 200
	debug_panel.size = Vector2(600, 500)
	debug_panel.position = Vector2(
		(get_viewport_rect().size.x - debug_panel.size.x) / 2,
		(get_viewport_rect().size.y - debug_panel.size.y) / 2
	)
	
	var debug_label = RichTextLabel.new()
	debug_label.bbcode_enabled = true
	debug_label.size = Vector2(580, 460)
	debug_label.position = Vector2(10, 10)
	
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.position = Vector2(debug_panel.size.x/2 - 40, debug_panel.size.y - 40)
	close_button.size = Vector2(80, 30)
	
	var debug_text = "[b]Steam Debug Info[/b]\n\n"
	debug_text += "Steam running: " + str(Steam.isSteamRunning()) + "\n"
	debug_text += "Current leaderboard: " + str(SteamManager.last_leaderboard_name) + "\n"
	debug_text += "Current handle: " + str(SteamManager.current_leaderboard_handle) + "\n"
	debug_text += "Is fetching: " + str(SteamManager.is_fetching_leaderboard) + "\n"
	debug_text += "Last error: " + str(SteamManager.last_error_message) + "\n\n"
	
	debug_text += "[b]API Calls:[/b]\n"
	for key in SteamManager.api_call_attempts:
		debug_text += key + ": " + str(SteamManager.api_call_attempts[key]) + "\n"
	
	debug_text += "\n[b]Cached Entries:[/b]\n"
	for entry in SteamManager.cached_leaderboard_entries:
		debug_text += str(entry.get("rank", "?")) + ": " + str(entry.get("name", "Unknown")) + " - " + str(entry.get("score", 0)) + "\n"
	
	debug_label.text = debug_text
	
	debug_panel.add_child(debug_label)
	debug_panel.add_child(close_button)
	add_child(debug_panel)
	
	close_button.pressed.connect(func(): debug_panel.queue_free())


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

	# Get narrative manager reference
	var narrative_manager = get_node_or_null("/root/NarrativeManager")
	if narrative_manager:
		# Show the day transition
		narrative_manager.show_day_transition(Global.shift, Global.shift + 1)

		# Connect to the dialogue_finished signal
		if not narrative_manager.dialogue_finished.is_connected(_on_day_transition_complete):
			narrative_manager.dialogue_finished.connect(
				_on_day_transition_complete, CONNECT_ONE_SHOT
			)
	else:
		# Fallback if narrative manager isn't found
		_on_day_transition_complete()

	# Emit signal and free this screen
	emit_signal("continue_to_next_shift")
	queue_free()


func _on_day_transition_complete():
	# Saving current game state
	GlobalState.save()

	# Reload the game scene
	if SceneLoader:
		SceneLoader.reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scenes/game_scene/mainGame.tscn")


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


# TODO: Utility re-use
static func find_viewports_in_tree(node: Node) -> Array:
	var viewports = []

	if node is SubViewport or node is SubViewportContainer:
		viewports.append(node)

	for child in node.get_children():
		var child_viewports = find_viewports_in_tree(child)
		viewports.append_array(child_viewports)

	return viewports


func animate_grade_stamps(performance: float):
	# Get references to the grade stamps
	var stamps = []
	var num_stamps = 0

	if performance >= 150:
		stamps = [
			$"RightPanel/GradeStamp-1", $"RightPanel/GradeStamp-2", $"RightPanel/GradeStamp-3"
		]
		num_stamps = 3
	elif performance >= 120:
		stamps = [$"RightPanel/GradeStamp-1", $"RightPanel/GradeStamp-2"]
		num_stamps = 2
	elif performance >= 90:
		stamps = [$"RightPanel/GradeStamp-1"]
		num_stamps = 1

	# Reset all stamps first
	for i in range(1, 4):
		var stamp = get_node_or_null("RightPanel/GradeStamp-" + str(i))
		if stamp:
			stamp.modulate.a = 0
			stamp.scale = Vector2(0.1, 0.1)
			stamp.rotation_degrees = -45

	# Animate each stamp with a delay between them
	for i in range(num_stamps):
		var stamp = stamps[i]

		# Create stamp animation with delay
		var tween = create_tween().set_parallel(false)
		tween.tween_interval(i * 0.5)  # Stagger the stamps

		# Play stamp sound
		tween.tween_callback(
			func():
				var audio_player = AudioStreamPlayer.new()
				audio_player.stream = preload("res://assets/audio/mechanical/stamp_sound_1.mp3")
				audio_player.volume_db = -5
				audio_player.bus = "SFX"
				add_child(audio_player)
				audio_player.play()
				audio_player.finished.connect(func(): audio_player.queue_free())
		)

		# Slam animation
		tween.tween_property(stamp, "scale", Vector2(4.0, 4.0), 0.15)
		tween.tween_property(stamp, "rotation_degrees", 0, 0.15)
		tween.tween_property(stamp, "modulate:a", 1.0, 0.15)

		# Bounce back
		tween.tween_property(stamp, "scale", Vector2(2.8, 2.8), 0.1)

		# Final settle
		tween.tween_property(stamp, "scale", Vector2(3.0, 3.0), 0.1)

	# Replace the textures with final colored versions after animations
	if num_stamps > 0:
		var final_texture = GRADE_STAMP_TEXTURE
		for i in range(num_stamps):
			stamps[i].texture = final_texture

func _unhandled_key_input(event):
	# Check for F12 key press for debug info
	if event is InputEventKey and event.keycode == KEY_F12 and event.pressed and not event.echo:
		debug_steam_status()
