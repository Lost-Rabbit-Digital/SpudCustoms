extends Control

signal closed
signal continue_to_next_shift
signal return_to_main_menu
signal restart_shift

const GRADE_STAMP_TEXTURE = preload("res://assets/menu/performance_stamp.png")

var stats: Dictionary
var narrative_manager
var steam_status_ok = false
var submission_in_progress = false
var submission_retry_count = 0
var max_submission_retries = 3

@onready var animation_player = $AnimationPlayer


func _init():
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow input to pass through to buttons


func _ready():
	# Connect to Steam manager signals (skip in DEV_MODE)
	if not Global.DEV_MODE and SteamManager:
		if not SteamManager.leaderboard_updated.is_connected(_on_leaderboard_updated):
			SteamManager.leaderboard_updated.connect(_on_leaderboard_updated)
		if not SteamManager.score_submitted.is_connected(_on_score_submitted):
			SteamManager.score_submitted.connect(_on_score_submitted)
		if not SteamManager.steam_status_changed.is_connected(_on_steam_status_changed):
			SteamManager.steam_status_changed.connect(_on_steam_status_changed)

	# Log startup information
	LogManager.write_info("ShiftSummaryScreen initialized")
	LogManager.write_info("Game Stats: " + str(stats))

	# Configure UI
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_STOP  # Block input from passing through
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Try to find narrative manager
	narrative_manager = get_node_or_null("/root/NarrativeManager")
	if not narrative_manager:
		narrative_manager = get_node_or_null("%NarrativeManager")

	# Use stored stats if available, otherwise use test data
	if !Global.current_game_stats.is_empty():
		show_summary(Global.current_game_stats)
		LogManager.write_info("Using actual game stats")
	else:
		show_summary(generate_test_stats())
		LogManager.write_info("Using test stats")

	# Ensure buttons are interactive
	for button in [$ContinueButton, $SubmitScoreButton, $RestartButton, $MainMenuButton]:
		if button:
			button.mouse_filter = Control.MOUSE_FILTER_STOP
			button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# Make sure child elements don't block input for buttons
	if $ScreenBackground:
		$ScreenBackground.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Play entry animation
	play_entry_animation()

	# Check initial Steam status
	_check_steam_status()

	# Request leaderboard data
	update_leaderboard()


func _on_steam_status_changed(connected: bool):
	steam_status_ok = connected
	LogManager.write_info("Steam status changed: " + str(connected))

	if connected:
		$LeaderboardPanel/Entries.text = "Connecting to Steam leaderboards..."
		# Retry leaderboard request if needed
		if $LeaderboardPanel/Entries.text.contains("Could not connect"):
			update_leaderboard()
	else:
		$LeaderboardPanel/Entries.text = "Could not connect to Steam.\nCheck your connection and restart game."

		# Disable submit button if Steam is not connected
		if $SubmitScoreButton:
			$SubmitScoreButton.disabled = !connected
			if !connected:
				$SubmitScoreButton.text = "Steam Offline"


func _check_steam_status():
	# Skip Steam checks in DEV_MODE
	if Global.DEV_MODE:
		steam_status_ok = false
		if $SubmitScoreButton:
			$SubmitScoreButton.disabled = true
			$SubmitScoreButton.text = "Dev Mode"
		if $LeaderboardPanel/Entries:
			$LeaderboardPanel/Entries.text = "DEV_MODE - Steam features disabled"
		return

	# Check if Steam is running and connected
	var steam_running = Steam.isSteamRunning()
	var steam_logged_on = Steam.loggedOn()

	steam_status_ok = steam_running && steam_logged_on

	if !steam_status_ok:
		LogManager.write_warning(
			(
				"Steam not ready - Running: "
				+ str(steam_running)
				+ ", Logged on: "
				+ str(steam_logged_on)
			)
		)
		$LeaderboardPanel/Entries.text = "Could not connect to Steam.\nCheck your connection and restart game."

		# Disable submit button
		if $SubmitScoreButton:
			$SubmitScoreButton.disabled = true
			$SubmitScoreButton.text = "Steam Offline"

	return steam_status_ok


func _on_leaderboard_updated(entries: Array):
	LogManager.write_info("Leaderboard updated callback received - entries: " + str(entries.size()))

	# If we're submitting and received an update, we're done submitting
	if submission_in_progress:
		submission_in_progress = false

		if entries.size() > 0:
			# Successfully submitted score and received updated leaderboard
			_show_notification("Score submitted successfully!", Color(0.2, 0.8, 0.2))

			# Update submit button
			if $SubmitScoreButton:
				$SubmitScoreButton.disabled = true
				$SubmitScoreButton.text = "Score Submitted"

	var leaderboard_text = ""

	if entries.is_empty():
		leaderboard_text = "No leaderboard entries available."
		LogManager.write_warning("Received empty leaderboard entries")

		# If this wasn't a result of a submission, try once more
		if !submission_in_progress && submission_retry_count < max_submission_retries:
			submission_retry_count += 1
			LogManager.write_info(
				"Retrying leaderboard request (attempt " + str(submission_retry_count) + ")"
			)

			# Wait a moment before retrying
			var retry_timer = get_tree().create_timer(1.0)
			await retry_timer.timeout
			update_leaderboard()
			return
	else:
		LogManager.write_info("Processing " + str(entries.size()) + " leaderboard entries")
		# Format each entry with proper padding
		for i in range(min(entries.size(), 12)):
			# Use format method for proper formatting to ensure alignment
			leaderboard_text += (
				"%2d    %-15s    %s\n"
				% [i + 1, entries[i].name.substr(0, 15), format_number(int(entries[i].score))]
			)

	# Update the leaderboard text
	if $LeaderboardPanel/Entries:
		$LeaderboardPanel/Entries.text = leaderboard_text

	LogManager.write_info("Leaderboard display updated with " + str(entries.size()) + " entries")


func _on_score_submitted(success: bool):
	LogManager.write_info("Score submission callback received - success: " + str(success))

	# Reset submission state
	submission_in_progress = false

	if success:
		_show_notification("Score submitted successfully!", Color(0.2, 0.8, 0.2))
		LogManager.write_info("Score successfully submitted")

		# Update button state
		if $SubmitScoreButton:
			$SubmitScoreButton.disabled = true
			$SubmitScoreButton.text = "Score Submitted"

		# Request updated leaderboard immediately
		LogManager.write_info("Requesting updated leaderboard data")
		# Reset retry counter since this is a new request
		submission_retry_count = 0
		update_leaderboard()
	else:
		_show_notification("Failed to submit score to leaderboard.", Color(0.8, 0.2, 0.2))
		LogManager.write_error("Score submission failed")

		# Re-enable submit button for retry
		if $SubmitScoreButton:
			$SubmitScoreButton.disabled = false
			$SubmitScoreButton.text = "Retry Submit"


# Helper function to show notifications
func _show_notification(message: String, color: Color = Color(1, 1, 1)):
	# Create notification label
	var notification = Label.new()
	notification.z_index = 100
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification.text = message
	notification.add_theme_color_override("font_color", color)

	# Position near the leaderboard panel
	notification.position = Vector2(
		$LeaderboardPanel.position.x + $LeaderboardPanel.size.x / 2,
		$LeaderboardPanel.position.y + $LeaderboardPanel.size.y - 40
	)

	add_child(notification)

	# Fade out and remove after delay
	var tween = create_tween()
	tween.tween_property(notification, "modulate:a", 0.0, 2.0)
	tween.tween_callback(func(): notification.queue_free())


func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return tr("time_format").format({"minutes": minutes, "seconds": secs})


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


func update_leaderboard():
	LogManager.write_info("Updating leaderboard - current score: " + str(Global.final_score))

	# Update title
	if $LeaderboardTitlePanel/Title:
		$LeaderboardTitlePanel/Title.text = (
			"Global Leaderboard\nEndless - %s" % Global.difficulty_level
		)

	# Check Steam status first
	if !_check_steam_status():
		LogManager.write_error("Steam not available for leaderboard update")
		if $LeaderboardPanel/Entries:
			$LeaderboardPanel/Entries.text = "Could not connect to Steam.\nCheck your connection and restart game."
		return

	# Show loading state and dump debug info
	if $LeaderboardPanel/Entries:
		$LeaderboardPanel/Entries.text = "Loading leaderboard data..."

	LogManager.write_info("Dumping Steam debug info before leaderboard request")
	SteamManager.dump_debug_info()

	# Request leaderboard data
	LogManager.write_info("Requesting leaderboard entries")
	var request_success = Global.request_leaderboard_entries(Global.difficulty_level)
	LogManager.write_info("Request leaderboard result: " + str(request_success))

	if !request_success:
		LogManager.write_error("Failed to request leaderboard entries")
		if $LeaderboardPanel/Entries:
			$LeaderboardPanel/Entries.text = "Could not connect to Steam.\nCheck your connection and restart game."
	else:
		LogManager.write_info("Leaderboard request sent successfully")

		# Set a timeout for leaderboard loading
		var timeout_timer = get_tree().create_timer(5.0)
		timeout_timer.timeout.connect(
			func():
				# Check if we're still showing "Loading..." after 5 seconds
				if (
					$LeaderboardPanel/Entries
					&& $LeaderboardPanel/Entries.text == "Loading leaderboard data..."
				):
					LogManager.write_warning("Leaderboard loading timed out")
					SteamManager.dump_debug_info()

					# Don't reset state - let the callback complete if it arrives
					# Just update the UI to show timeout
					$LeaderboardPanel/Entries.text = "Loading timed out.\nTry again or check Steam connection."
		)


func _on_submit_score_button_pressed() -> void:
	LogManager.write_info("Submit Score button pressed")

	# Check if we're already submitting
	if submission_in_progress:
		LogManager.write_warning("Submission already in progress, ignoring button press")
		return

	# Check Steam status first
	if !_check_steam_status():
		_show_notification("Steam connection unavailable", Color(0.8, 0.2, 0.2))
		return

	# Add visual feedback
	submission_in_progress = true
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
		submission_in_progress = false

		# Show error notification
		_show_notification("Cannot connect to Steam. Check your connection.", Color(0.8, 0.2, 0.2))
		return

	# Set a timeout for submission
	var submission_timer = get_tree().create_timer(10.0)
	submission_timer.timeout.connect(
		func():
			# Check if button is still disabled after 10 seconds
			if submission_in_progress:
				LogManager.write_warning("Score submission timed out")
				SteamManager.dump_debug_info()

				# Reset submission state to allow retry
				submission_in_progress = false
				$SubmitScoreButton.text = "Retry Submit"
				$SubmitScoreButton.disabled = false

				# Don't reset SteamManager state - let callback complete if it arrives
				# Just notify user they can retry
				_show_notification("Submission timed out. Click to retry.", Color(0.8, 0.2, 0.2))
	)


func show_summary(stats_data: Dictionary):
	stats = stats_data
	show()

	# First update the shift number regardless of win/loss status
	var shift_number = stats.get("shift", 1)

	# Determine if player won or lost
	var win_condition = stats.get("quota_met", 0) >= stats.get("quota_target", 5)
	var strikes_failed = stats.get("strikes", 0) >= stats.get("max_strikes", 6)
	var global_strikes_failed = Global.strikes >= Global.max_strikes

	# Update UI based on result
	if $LeftPanel/ShiftComplete:
		if win_condition:
			$LeftPanel/ShiftComplete.text = tr("shift_complete_success").format(
				{"shift": shift_number}
			)
			$LeftPanel/ShiftComplete.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
		else:
			var failure_reason = (
				tr("strike_limit_reached") if strikes_failed else tr("quota_not_met")
			)
			$LeftPanel/ShiftComplete.text = tr("shift_complete_failure").format(
				{"shift": shift_number, "failure": failure_reason}
			)
			$LeftPanel/ShiftComplete.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))

	# Hide continue button if lost due to strikes
	if global_strikes_failed && $ContinueButton:
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
	if $HeaderPanel/Title:
		$HeaderPanel/Title.text = tr("shift_summary_title_with_difficulty").format(
			{"difficulty": difficulty_rating}
		)

	# Update missile stats with calculated hit rate
	if $LeftPanel/MissileStats:
		$LeftPanel/MissileStats.text = tr("runner_stats_template").format(
			{
				"runner_attempts": format_number(stats.get("runner_attempts", 0)),
				"fired": format_number(stats.get("missiles_fired", 0)),
				"hit": format_number(stats.get("missiles_hit", 0)),
				"perfect": format_number(stats.get("perfect_hits", 0)),
				"rate": floor(stats.get("hit_rate", 0.0))
			}
		)

	# Update document stats
	if $LeftPanel/DocumentStats:
		$LeftPanel/DocumentStats.text = tr("document_stats_template").format(
			{
				"stamped": format_number(stats.get("total_stamps", 0)),
				"approved": format_number(stats.get("potatoes_approved", 0)),
				"rejected": format_number(stats.get("potatoes_rejected", 0)),
				"perfect_stamps": format_number(stats.get("perfect_stamps", 0))
			}
		)

	# Update bonus stats without speed bonus
	if $RightPanel/BonusStats:
		$RightPanel/BonusStats.text = tr("bonus_stats_template").format(
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

	# Update leaderboard
	update_leaderboard()

	# Calculate performance percentage
	var performance = float(stats.get("score", 0)) / float(expected_score) * 100
	var performance_text = tr("performance_good")
	var performance_color = Color(1.0, 0.8, 0)  # Default yellow

	if performance >= 150:
		performance_text = tr("performance_exceptional")
		performance_color = Color(1.0, 0.4, 0.8)  # Pink
		if has_node("RightPanel/GradeStamp-1"):
			$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
		if has_node("RightPanel/GradeStamp-2"):
			$"RightPanel/GradeStamp-2".texture = GRADE_STAMP_TEXTURE
		if has_node("RightPanel/GradeStamp-3"):
			$"RightPanel/GradeStamp-3".texture = GRADE_STAMP_TEXTURE
	elif performance >= 120:
		performance_text = tr("performance_excellent")
		performance_color = Color(0.2, 0.8, 0.2)  # Green
		if has_node("RightPanel/GradeStamp-1"):
			$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
		if has_node("RightPanel/GradeStamp-2"):
			$"RightPanel/GradeStamp-2".texture = GRADE_STAMP_TEXTURE
	elif performance >= 90:
		performance_text = tr("performance_good")
		performance_color = Color(0.4, 0.7, 0.1)  # Light green
		if has_node("RightPanel/GradeStamp-1"):
			$"RightPanel/GradeStamp-1".texture = GRADE_STAMP_TEXTURE
	elif performance < 70:
		performance_text = tr("performance_needs_improvement")
		performance_color = Color(0.8, 0.4, 0.1)  # Orange
	elif performance < 50:
		performance_text = tr("performance_poor")
		performance_color = Color(0.8, 0.2, 0.2)  # Red

	# Add performance rating to display
	if $RightPanel/PerformanceStats:
		$RightPanel/PerformanceStats.text = tr("performance_stats_template").format(
			{
				"time_taken": format_time(stats.get("time_taken", 0)),
				"expected_score": format_number(int(expected_score)),
				"score": format_number(stats.get("score", 0)),
				"percent": floor(performance),
				"rating": performance_text
			}
		)

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
			$RightPanel/PerformanceStats.text += (
				"\n" + tr("high_score_display").format({"score": str(high_score)})
			)

	# Animate stamps based on performance
	animate_grade_stamps(performance)


func play_entry_animation():
	# Set initial states for text elements
	if $LeftPanel:
		$LeftPanel.modulate.a = 0
	if $RightPanel:
		$RightPanel.modulate.a = 0
	if $HeaderPanel:
		$HeaderPanel.modulate.a = 0
	if $LeaderboardPanel:
		$LeaderboardPanel.modulate.a = 0
	if $LeaderboardTitlePanel:
		$LeaderboardTitlePanel.modulate.a = 0

	# Store original positions
	var stats_bg_original_pos = (
		$StatsJournalBackground.position if has_node("StatsJournalBackground") else Vector2.ZERO
	)
	var leaderboard_bg_original_pos = (
		$LeaderboardBackground.position if has_node("LeaderboardBackground") else Vector2.ZERO
	)

	# Set initial positions (off-screen at the top)
	if has_node("StatsJournalBackground"):
		$StatsJournalBackground.position.y = -$StatsJournalBackground.texture.get_height() - 400
	if has_node("LeaderboardBackground"):
		$LeaderboardBackground.position.y = -$LeaderboardBackground.texture.get_height() - 400

	# Create animation sequence
	var tween = create_tween()
	tween.set_parallel(false)  # Sequential animations

	# 1. First, slide in StatsJournalBackground with bounce
	if has_node("StatsJournalBackground"):
		(
			tween
			. tween_property(
				$StatsJournalBackground, "position:y", stats_bg_original_pos.y - 30, 0.75
			)
			. set_trans(Tween.TRANS_BACK)
			. set_ease(Tween.EASE_OUT)
		)

		# Add bounce
		(
			tween
			. tween_property(
				$StatsJournalBackground, "position:y", stats_bg_original_pos.y + 15, 0.3
			)
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
	if has_node("LeaderboardBackground"):
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
			. tween_property(
				$LeaderboardBackground, "position:y", leaderboard_bg_original_pos.y, 0.2
			)
			. set_trans(Tween.TRANS_SINE)
			. set_ease(Tween.EASE_OUT)
		)

	# 3. Now start the text animations with slow fade-in
	if $HeaderPanel:
		tween.tween_property($HeaderPanel, "modulate:a", 1.0, 1.0)

	# Then the panels fade in (slow)
	if $LeftPanel:
		tween.tween_property($LeftPanel, "modulate:a", 1.0, 0.9)
	if $RightPanel:
		tween.tween_property($RightPanel, "modulate:a", 1.0, 0.9)

	# Finally the leaderboard (slow)
	if $LeaderboardTitlePanel:
		tween.tween_property($LeaderboardTitlePanel, "modulate:a", 1.0, 0.7)
	if $LeaderboardPanel:
		tween.tween_property($LeaderboardPanel, "modulate:a", 1.0, 0.7)


func animate_grade_stamps(performance: float):
	# Get references to the grade stamps
	var stamps = []
	var num_stamps = 0

	if performance >= 150:
		stamps = [
			get_node_or_null("RightPanel/GradeStamp-1"),
			get_node_or_null("RightPanel/GradeStamp-2"),
			get_node_or_null("RightPanel/GradeStamp-3")
		]
		stamps = stamps.filter(func(s): return s != null)
		num_stamps = stamps.size()
	elif performance >= 120:
		stamps = [
			get_node_or_null("RightPanel/GradeStamp-1"), get_node_or_null("RightPanel/GradeStamp-2")
		]
		stamps = stamps.filter(func(s): return s != null)
		num_stamps = stamps.size()
	elif performance >= 90:
		stamps = [get_node_or_null("RightPanel/GradeStamp-1")]
		stamps = stamps.filter(func(s): return s != null)
		num_stamps = stamps.size()

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
		if not stamp:
			continue

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
			if stamps[i]:
				stamps[i].texture = final_texture


func generate_test_stats() -> Dictionary:
	return {
		"shift": 1,
		"time_taken": 360.0,
		"score": 2000,
		"missiles_fired": 25,
		"missiles_hit": 15,
		"perfect_hits": 5,
		"total_stamps": 30,
		"potatoes_approved": 15,
		"potatoes_rejected": 15,
		"perfect_stamps": 10,
		"accuracy_bonus": 1000,
		"processing_speed_bonus": 500,
		"perfect_hit_bonus": 750,
		"hit_rate": 60.0,
		"runner_attempts": 12,
		"final_score": 4250
	}


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
	# Check for demo limit before proceeding
	if check_demo_limit():
		# Show demo limit message after a short delay
		await get_tree().create_timer(0.5).timeout
		show_demo_limit_dialog()
		return

	# Saving current game state
	GlobalState.save()

	# Reload the game scene
	if SceneLoader:
		SceneLoader.reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scenes/game_scene/mainGame.tscn")


func check_demo_limit() -> bool:
	# Check if this is a demo build and if the player has reached the limit
	if Global.build_type == "Demo Release" and Global.shift >= 3:
		return true
	return false


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


# Handle scene transition after fade out
func _handle_scene_transition(scene_path: String) -> void:
	# Create a small delay to ensure the screen is fully black
	var timer = get_tree().create_timer(0.1)
	await timer.timeout

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
		await tween.finished

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


func _unhandled_key_input(event):
	# Check for F12 key press for debug info
	#if event is InputEventKey and event.keycode == KEY_F12 and event.pressed and not event.echo:
	#	debug_steam_status()
	pass


func show_demo_limit_dialog():
	# Create a panel to display the message
	var demo_panel = PanelContainer.new()
	demo_panel.z_index = 100

	var vbox = VBoxContainer.new()
	vbox.set_custom_minimum_size(Vector2(500, 300))
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var title = Label.new()
	title.text = "Demo Version Limit Reached"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)

	var message = RichTextLabel.new()
	message.bbcode_enabled = true
	message.text = """
	[center]Thank you for playing the demo version of Potato Customs!

	You've reached the limit of the demo version.
	
	To continue your journey as a customs officer and experience the full story, please purchase the full game.
	
	And please consider leaving an honest review, we're very responsive to feedback!
	[url=https://store.steampowered.com/app/3291880/]Buy Potato Customs on Steam[/url][/center]
	"""
	message.fit_content = true
	message.custom_minimum_size = Vector2(450, 200)
	message.meta_clicked.connect(func(meta): OS.shell_open(meta))

	var button = Button.new()
	button.text = "Return to Main Menu"
	button.custom_minimum_size = Vector2(200, 50)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	vbox.add_child(title)
	vbox.add_child(message)
	vbox.add_child(button)

	demo_panel.add_child(vbox)
	add_child(demo_panel)

	# Center the panel
	demo_panel.position = (get_viewport_rect().size - demo_panel.size) / 2

	# Connect button to return to main menu
	button.pressed.connect(
		func():
			# Return to main menu
			get_tree().change_scene_to_file(
				"res://scenes/menus/main_menu/main_menu_with_animations.tscn"
			)
			# Remove the panel
			demo_panel.queue_free()
	)

	# Add a nice animation
	demo_panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(demo_panel, "modulate:a", 1.0, 0.5)


func debug_steam_status():
	LogManager.write_info("=== MANUAL STEAM DEBUG REQUESTED ===")
	SteamManager.dump_debug_info()

	# Show a debug panel with information
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
	close_button.position = Vector2(debug_panel.size.x / 2 - 40, debug_panel.size.y - 40)
	close_button.size = Vector2(80, 30)

	var debug_text = "[b]Steam Debug Info[/b]\n\n"
	debug_text += "Steam running: " + str(Steam.isSteamRunning()) + "\n"
	debug_text += "Steam logged on: " + str(Steam.loggedOn()) + "\n"
	debug_text += "Current leaderboard: " + str(SteamManager.last_leaderboard_name) + "\n"
	debug_text += "Current handle: " + str(SteamManager.current_leaderboard_handle) + "\n"
	debug_text += (
		"Leaderboard state: "
		+ str(SteamManager.LeaderboardState.keys()[SteamManager.current_leaderboard_state])
		+ "\n"
	)
	debug_text += "Is fetching: " + str(SteamManager.is_fetching_leaderboard) + "\n"
	debug_text += "Last error: " + str(SteamManager.last_error_message) + "\n\n"

	debug_text += "[b]API Calls:[/b]\n"
	for key in SteamManager.api_call_attempts:
		debug_text += key + ": " + str(SteamManager.api_call_attempts[key]) + "\n"

	debug_text += "\n[b]Cached Entries:[/b]\n"
	for entry in SteamManager.cached_leaderboard_entries:
		debug_text += (
			str(entry.get("rank", "?"))
			+ ": "
			+ str(entry.get("name", "Unknown"))
			+ " - "
			+ str(entry.get("score", 0))
			+ "\n"
		)

	debug_label.text = debug_text

	debug_panel.add_child(debug_label)
	debug_panel.add_child(close_button)
	add_child(debug_panel)

	close_button.pressed.connect(func(): debug_panel.queue_free())

	# Try to force a leaderboard reset and refresh
	var reset_button = Button.new()
	reset_button.text = "Reset & Refresh"
	reset_button.position = Vector2(debug_panel.size.x / 2 - 60, debug_panel.size.y - 80)
	reset_button.size = Vector2(120, 30)
	debug_panel.add_child(reset_button)

	reset_button.pressed.connect(
		func():
			SteamManager.reset_leaderboard_state()
			update_leaderboard()
			debug_panel.queue_free()
			# Show new debug panel after a short delay
			await get_tree().create_timer(2.0).timeout
			debug_steam_status()
	)
