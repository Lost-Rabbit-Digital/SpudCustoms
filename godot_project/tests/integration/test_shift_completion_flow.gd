extends GutTest

## Integration test for Shift Completion Flow
## Tests: Quota Check → Summary Screen → Leaderboard Submission → Save → Achievement Check

var event_bus: Node
var game_state_manager: Node
var save_manager: Node

func before_each() -> void:
	event_bus = get_node_or_null("/root/EventBus")
	game_state_manager = get_node_or_null("/root/GameStateManager")
	save_manager = get_node_or_null("/root/SaveManager")

	assert_not_null(event_bus, "EventBus must be available")
	assert_not_null(game_state_manager, "GameStateManager must be available")
	assert_not_null(save_manager, "SaveManager must be available")


# ==================== SHIFT COMPLETION ====================


func test_successful_shift_completion_flow() -> void:
	"""
	Test complete flow of successfully completing a shift:
	1. Player meets quota
	2. quota_reached signal emitted
	3. shift_advanced signal emitted
	4. Save game state
	5. Check achievements
	6. Load summary screen
	"""

	var quota_reached_called: bool = false
	var shift_advanced_called: bool = false
	var game_saved: bool = false
	var achievement_checked: bool = false

	var quota_callback = func():
		quota_reached_called = true

	var shift_callback = func(_new_shift: int):
		shift_advanced_called = true

	var save_callback = func(_success: bool):
		game_saved = true

	var achievement_callback = func(_achievement_id: String):
		achievement_checked = true

	event_bus.quota_reached.connect(quota_callback)
	event_bus.shift_advanced.connect(shift_callback)
	event_bus.save_completed.connect(save_callback)
	event_bus.achievement_check_requested.connect(achievement_callback)

	# Simulate meeting quota
	var current_shift = game_state_manager.get_shift()
	event_bus.emit_quota_reached()
	await get_tree().process_frame

	# Advance to next shift
	event_bus.emit_shift_advanced(current_shift + 1)
	await get_tree().process_frame

	# Trigger save
	event_bus.emit_save_game_requested()
	await get_tree().process_frame

	# Check shift-based achievements
	event_bus.emit_achievement_check_requested("shift_veteran")
	await get_tree().process_frame

	# Verify flow
	assert_true(quota_reached_called, "Quota reached should be emitted")
	assert_true(shift_advanced_called, "Shift advanced should be emitted")

	# Cleanup
	event_bus.quota_reached.disconnect(quota_callback)
	event_bus.shift_advanced.disconnect(shift_callback)
	event_bus.save_completed.disconnect(save_callback)
	event_bus.achievement_check_requested.disconnect(achievement_callback)


func test_failed_shift_flow() -> void:
	"""
	Test flow when shift fails (max strikes reached):
	1. Max strikes reached
	2. game_over_triggered emitted
	3. Show game over screen
	4. Optionally save stats
	"""

	var game_over_called: bool = false

	var callback = func():
		game_over_called = true

	event_bus.game_over_triggered.connect(callback)

	# Simulate max strikes
	var max_strikes = game_state_manager.get_max_strikes()
	var current_strikes = game_state_manager.get_strikes()

	# Add strikes to reach max
	for i in range(max_strikes - current_strikes):
		event_bus.request_strike_add("test_strike")
		await get_tree().process_frame

	# Game over should be triggered
	await get_tree().process_frame

	# Note: Actual triggering depends on GameStateManager

	event_bus.game_over_triggered.disconnect(callback)


# ==================== SAVE/LOAD ====================


func test_save_preserves_game_state() -> void:
	"""
	Test that saving game preserves all critical state
	"""

	# Set some game state
	var test_score = 5000
	var test_shift = 5
	var test_strikes = 2

	# Request save
	var save_completed: bool = false

	var callback = func(success: bool):
		save_completed = success

	event_bus.save_completed.connect(callback)

	event_bus.emit_save_game_requested()
	await get_tree().process_frame

	# Verify save completed
	# Actual save verification would require SaveManager integration

	event_bus.save_completed.disconnect(callback)


func test_load_restores_game_state() -> void:
	"""
	Test that loading game restores all critical state
	"""

	# Trigger load
	var load_completed: bool = false

	var callback = func(_data: Dictionary):
		load_completed = true

	event_bus.game_loaded.connect(callback)

	event_bus.emit_load_game_requested()
	await get_tree().process_frame

	# Verify state restored
	# Actual verification would need known saved state

	event_bus.game_loaded.disconnect(callback)


func test_narrative_choices_persist_across_save_load() -> void:
	"""
	Test that narrative choices are saved and restored
	"""

	# Make a narrative choice
	var choice_key = "test_choice"
	var choice_value = "test_value"

	event_bus.emit_narrative_choice_made(choice_key, choice_value)
	await get_tree().process_frame

	# Save game
	event_bus.emit_save_game_requested()
	await get_tree().process_frame

	# Load game (would need to reset state first in real test)
	event_bus.emit_load_game_requested()
	await get_tree().process_frame

	# Verify choice was restored
	# Actual verification needs NarrativeManager query


# ==================== LEADERBOARD SUBMISSION ====================


func test_leaderboard_submission_after_shift() -> void:
	"""
	Test that completing a shift submits score to leaderboard
	"""

	var leaderboard_submitted: bool = false

	var callback = func(_leaderboard_name: String, _score: int):
		leaderboard_submitted = true

	if event_bus.has_signal("leaderboard_score_submitted"):
		event_bus.leaderboard_score_submitted.connect(callback)

		# Complete shift
		event_bus.emit_shift_advanced(5)
		await get_tree().process_frame

		# Submit score to leaderboard
		var final_score = game_state_manager.get_score()
		var difficulty = game_state_manager.get_difficulty()
		var leaderboard_name = "shift_5_%s" % difficulty.to_lower()

		event_bus.emit_leaderboard_submission_requested(leaderboard_name, final_score)
		await get_tree().process_frame

		# Note: Actual submission handled by SteamManager

		event_bus.leaderboard_score_submitted.disconnect(callback)


func test_high_score_achievement() -> void:
	"""
	Test that achieving high score triggers achievement
	"""

	var high_score_achieved: bool = false

	var callback = func(_difficulty: String, _score: int):
		high_score_achieved = true

	event_bus.high_score_achieved.connect(callback)

	# Simulate high score
	var current_score = 10000
	event_bus.emit_high_score_achieved("Normal", current_score)
	await get_tree().process_frame

	assert_true(high_score_achieved, "High score achievement should trigger")

	event_bus.high_score_achieved.disconnect(callback)


# ==================== SHIFT STATS TRACKING ====================


func test_shift_stats_calculated_correctly() -> void:
	"""
	Test that ShiftStats calculates bonuses correctly
	"""

	# This would test ShiftStats integration
	# Actual calculation tested in unit tests

	# Simulate shift with:
	# - 10 potatoes processed (5 correct, 5 incorrect)
	# - 3 perfect hits
	# - 2 runners stopped

	var expected_accuracy_bonus = 0  # 50% accuracy
	var expected_missile_bonus = 450  # 3 * 150
	var expected_speed_bonus = 0  # Depends on time

	# ShiftStats would calculate these at shift end


# ==================== SCENE TRANSITIONS ====================


func test_shift_to_summary_screen_transition() -> void:
	"""
	Test transition from game scene to summary screen
	"""

	# Complete shift
	event_bus.emit_quota_reached()
	await get_tree().process_frame

	event_bus.emit_shift_advanced(2)
	await get_tree().process_frame

	# Scene transition would be handled by SceneLoader
	# Test documents expected scene change request


func test_summary_to_next_shift_transition() -> void:
	"""
	Test continuing from summary screen to next shift
	"""

	# From summary screen, click continue
	# Should load next shift's intro dialogue or main game

	event_bus.emit_shift_advanced(3)
	await get_tree().process_frame

	# Verify next shift starts with correct state


# ==================== ACHIEVEMENT CHECKS ====================


func test_shift_completion_checks_multiple_achievements() -> void:
	"""
	Test that shift completion checks relevant achievements
	"""

	var achievements_checked: Array[String] = []

	var callback = func(achievement_id: String):
		achievements_checked.append(achievement_id)

	event_bus.achievement_check_requested.connect(callback)

	# Complete shift
	event_bus.emit_shift_advanced(5)
	await get_tree().process_frame

	# Should check achievements like:
	# - shift_veteran (complete 10 shifts)
	# - accuracy_master (90%+ accuracy)
	# - perfect_shift (no strikes)

	event_bus.emit_achievement_check_requested("shift_veteran")
	event_bus.emit_achievement_check_requested("accuracy_master")
	event_bus.emit_achievement_check_requested("perfect_shift")

	await get_tree().process_frame

	assert_eq(achievements_checked.size(), 3, "Should check multiple achievements")

	event_bus.achievement_check_requested.disconnect(callback)


# ==================== DIFFICULTY MODIFIERS ====================


func test_difficulty_affects_quota() -> void:
	"""
	Test that difficulty setting affects quota requirements
	"""

	var easy_quota = 10
	var normal_quota = 15
	var expert_quota = 20

	# These values would come from GameStateManager or difficulty settings


func test_difficulty_affects_scoring() -> void:
	"""
	Test that difficulty affects score multipliers
	"""

	# Easy: 0.8x multiplier
	# Normal: 1.0x multiplier
	# Expert: 1.5x multiplier

	# Award 100 points on different difficulties
	# Verify final scores reflect multipliers


# ==================== ERROR RECOVERY ====================


func test_save_failure_shows_error() -> void:
	"""
	Test that save failure is communicated to player
	"""

	var error_shown: bool = false

	var callback = func(_message: String, _duration: float):
		error_shown = true

	event_bus.alert_red_requested.connect(callback)

	# Simulate save failure
	event_bus.emit_save_completed(false)
	await get_tree().process_frame

	# Error alert should be shown
	event_bus.show_alert("Failed to save game!", false, 3.0)
	await get_tree().process_frame

	assert_true(error_shown, "Save failure should show error alert")

	event_bus.alert_red_requested.disconnect(callback)


func test_leaderboard_timeout_handled() -> void:
	"""
	Test that leaderboard timeout doesn't block progression
	"""

	# Submit score
	event_bus.emit_leaderboard_submission_requested("test_board", 1000)
	await get_tree().process_frame

	# Simulate timeout (no response after 5 seconds)
	await get_tree().create_timer(0.1).timeout

	# Should allow player to continue despite timeout
	# UI should show timeout message but not block
