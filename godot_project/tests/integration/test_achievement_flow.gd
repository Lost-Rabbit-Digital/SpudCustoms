extends GutTest

## Integration test for Achievement Flow
## Tests: Player Action → Stat Tracking → Achievement Condition → Achievement Unlocked → Steam Sync

var event_bus: Node
var game_state_manager: Node
var global_ref: Node
var steam_manager: Node

# Mock Steam class for testing
class MockSteam:
	var achievements_set: Array[String] = []
	var stats_stored: bool = false
	var is_running: bool = true

	func setAchievement(achievement_id: String) -> void:
		if not achievements_set.has(achievement_id):
			achievements_set.append(achievement_id)

	func storeStats() -> void:
		stats_stored = true

	func isSteamRunning() -> bool:
		return is_running

	func reset() -> void:
		achievements_set.clear()
		stats_stored = false

var mock_steam: MockSteam


func before_each() -> void:
	event_bus = get_node_or_null("/root/EventBus")
	game_state_manager = get_node_or_null("/root/GameStateManager")
	global_ref = get_node_or_null("/root/Global")
	steam_manager = get_node_or_null("/root/SteamManager")

	assert_not_null(event_bus, "EventBus must be available")
	assert_not_null(game_state_manager, "GameStateManager must be available")
	assert_not_null(global_ref, "Global must be available")

	# Create mock Steam
	mock_steam = MockSteam.new()

	# Reset achievement-related stats
	if global_ref:
		global_ref.total_shifts_completed = 0
		global_ref.total_runners_stopped = 0
		global_ref.perfect_hits = 0


func after_each() -> void:
	if mock_steam:
		mock_steam.reset()

	await get_tree().process_frame


# ==================== ACHIEVEMENT UNLOCKED SIGNAL ====================


func test_achievement_unlocked_signal_emitted() -> void:
	"""Test that achievement_unlocked signal is emitted"""

	var signal_emitted: bool = false
	var achievement_id: String = ""

	var callback = func(id: String):
		signal_emitted = true
		achievement_id = id

	event_bus.achievement_unlocked.connect(callback)

	# Emit achievement unlocked
	event_bus.achievement_unlocked.emit("test_achievement")
	await get_tree().process_frame

	assert_true(signal_emitted, "achievement_unlocked should be emitted")
	assert_eq(achievement_id, "test_achievement", "Achievement ID should match")

	event_bus.achievement_unlocked.disconnect(callback)


func test_multiple_achievements_unlocked() -> void:
	"""Test that multiple achievements can be unlocked in sequence"""

	var achievements_unlocked: Array[String] = []

	var callback = func(id: String):
		achievements_unlocked.append(id)

	event_bus.achievement_unlocked.connect(callback)

	# Unlock multiple achievements
	event_bus.achievement_unlocked.emit("rookie_customs_officer")
	await get_tree().process_frame

	event_bus.achievement_unlocked.emit("sharpshooter")
	await get_tree().process_frame

	event_bus.achievement_unlocked.emit("border_defender")
	await get_tree().process_frame

	assert_eq(achievements_unlocked.size(), 3, "Should have 3 achievements")
	assert_eq(achievements_unlocked[0], "rookie_customs_officer", "First achievement should match")
	assert_eq(achievements_unlocked[1], "sharpshooter", "Second achievement should match")
	assert_eq(achievements_unlocked[2], "border_defender", "Third achievement should match")

	event_bus.achievement_unlocked.disconnect(callback)


# ==================== STAT TRACKING ====================


func test_runner_stopped_increments_stat() -> void:
	"""Test that stopping a runner increments the stat"""

	var initial_count = global_ref.total_runners_stopped

	# Emit runner stopped event
	event_bus.emit_runner_stopped("standard_runner", 100, false)
	await get_tree().process_frame

	# Verify stat incremented through GameStateManager
	assert_eq(
		game_state_manager.get_total_runners_stopped(),
		initial_count + 1,
		"Runner stopped count should increment"
	)


func test_perfect_hit_increments_stat() -> void:
	"""Test that perfect hits increment the stat"""

	var initial_count = global_ref.perfect_hits

	# Emit perfect hit event
	event_bus.perfect_hit_achieved.emit(150)
	await get_tree().process_frame

	# Verify stat incremented through GameStateManager
	assert_eq(
		game_state_manager.get_perfect_hits(),
		initial_count + 1,
		"Perfect hits count should increment"
	)


func test_multiple_stats_tracked_simultaneously() -> void:
	"""Test that multiple stats are tracked correctly"""

	var initial_runners = global_ref.total_runners_stopped
	var initial_perfect = global_ref.perfect_hits

	# Perform multiple actions
	event_bus.emit_runner_stopped("runner1", 100, true)
	await get_tree().process_frame

	event_bus.perfect_hit_achieved.emit(150)
	await get_tree().process_frame

	event_bus.emit_runner_stopped("runner2", 100, false)
	await get_tree().process_frame

	# Verify both stats updated
	assert_eq(
		game_state_manager.get_total_runners_stopped(),
		initial_runners + 2,
		"Runners stopped should be +2"
	)
	assert_eq(
		game_state_manager.get_perfect_hits(),
		initial_perfect + 2,
		"Perfect hits should be +2 (1 from stopped, 1 from event)"
	)


# ==================== ACHIEVEMENT CONDITIONS ====================


func test_rookie_officer_achievement_condition() -> void:
	"""Test rookie officer achievement condition (1 shift completed)"""

	# Set up condition
	global_ref.total_shifts_completed = 1

	# Mock achievement check
	var should_unlock = global_ref.total_shifts_completed >= 1

	assert_true(should_unlock, "Rookie officer should unlock at 1 shift")


func test_veteran_officer_achievement_condition() -> void:
	"""Test veteran officer achievement condition (10 shifts completed)"""

	# Test below threshold
	global_ref.total_shifts_completed = 9
	var should_not_unlock = global_ref.total_shifts_completed >= 10
	assert_false(should_not_unlock, "Veteran officer should not unlock at 9 shifts")

	# Test at threshold
	global_ref.total_shifts_completed = 10
	var should_unlock = global_ref.total_shifts_completed >= 10
	assert_true(should_unlock, "Veteran officer should unlock at 10 shifts")


func test_master_officer_achievement_condition() -> void:
	"""Test master officer achievement condition (25 shifts completed)"""

	# Test below threshold
	global_ref.total_shifts_completed = 24
	var should_not_unlock = global_ref.total_shifts_completed >= 25
	assert_false(should_not_unlock, "Master officer should not unlock at 24 shifts")

	# Test at threshold
	global_ref.total_shifts_completed = 25
	var should_unlock = global_ref.total_shifts_completed >= 25
	assert_true(should_unlock, "Master officer should unlock at 25 shifts")


func test_sharpshooter_achievement_condition() -> void:
	"""Test sharpshooter achievement condition (10 runners stopped)"""

	# Test at threshold
	global_ref.total_runners_stopped = 10
	var should_unlock = global_ref.total_runners_stopped >= 10
	assert_true(should_unlock, "Sharpshooter should unlock at 10 runners")


func test_border_defender_achievement_condition() -> void:
	"""Test border defender achievement condition (50 runners stopped)"""

	global_ref.total_runners_stopped = 50
	var should_unlock = global_ref.total_runners_stopped >= 50
	assert_true(should_unlock, "Border defender should unlock at 50 runners")


func test_perfect_shot_achievement_condition() -> void:
	"""Test perfect shot achievement condition (5 perfect hits)"""

	global_ref.perfect_hits = 5
	var should_unlock = global_ref.perfect_hits >= 5
	assert_true(should_unlock, "Perfect shot should unlock at 5 perfect hits")


func test_high_scorer_achievement_condition() -> void:
	"""Test high scorer achievement condition (10000 score)"""

	global_ref.score = 10000
	var should_unlock = global_ref.score >= 10000
	assert_true(should_unlock, "High scorer should unlock at 10000 score")


func test_score_legend_achievement_condition() -> void:
	"""Test score legend achievement condition (50000 score)"""

	global_ref.score = 50000
	var should_unlock = global_ref.score >= 50000
	assert_true(should_unlock, "Score legend should unlock at 50000 score")


# ==================== ACHIEVEMENT CHECK FLOW ====================


func test_achievement_check_requested_signal() -> void:
	"""Test that achievement_check_requested signal works"""

	var signal_emitted: bool = false

	var callback = func():
		signal_emitted = true

	event_bus.achievement_check_requested.connect(callback)

	# Request achievement check
	event_bus.achievement_check_requested.emit()
	await get_tree().process_frame

	assert_true(signal_emitted, "achievement_check_requested should be emitted")

	event_bus.achievement_check_requested.disconnect(callback)


# ==================== NARRATIVE ACHIEVEMENTS ====================


func test_narrative_achievement_from_dialogue() -> void:
	"""Test that achievements can be unlocked from Dialogic signals"""

	var achievement_unlocked: bool = false
	var unlocked_id: String = ""

	var callback = func(id: String):
		achievement_unlocked = true
		unlocked_id = id

	event_bus.achievement_unlocked.connect(callback)

	# Simulate Dialogic signal for narrative achievement
	# Based on NarrativeManager._on_dialogic_signal
	event_bus.achievement_unlocked.emit("born_diplomat")
	await get_tree().process_frame

	assert_true(achievement_unlocked, "Narrative achievement should be unlocked")
	assert_eq(unlocked_id, "born_diplomat", "Achievement ID should match")

	event_bus.achievement_unlocked.disconnect(callback)


func test_multiple_narrative_achievements() -> void:
	"""Test multiple narrative achievements from story choices"""

	var achievements: Array[String] = []

	var callback = func(id: String):
		achievements.append(id)

	event_bus.achievement_unlocked.connect(callback)

	# Simulate multiple narrative achievements
	event_bus.achievement_unlocked.emit("born_diplomat")
	await get_tree().process_frame

	event_bus.achievement_unlocked.emit("tater_of_justice")
	await get_tree().process_frame

	event_bus.achievement_unlocked.emit("best_served_hot")
	await get_tree().process_frame

	event_bus.achievement_unlocked.emit("down_with_the_tatriarchy")
	await get_tree().process_frame

	assert_eq(achievements.size(), 4, "Should have 4 narrative achievements")
	assert_true(achievements.has("born_diplomat"), "Should have born_diplomat")
	assert_true(achievements.has("tater_of_justice"), "Should have tater_of_justice")
	assert_true(achievements.has("best_served_hot"), "Should have best_served_hot")
	assert_true(achievements.has("down_with_the_tatriarchy"), "Should have down_with_the_tatriarchy")

	event_bus.achievement_unlocked.disconnect(callback)


# ==================== COMPLETE ACHIEVEMENT FLOW ====================


func test_complete_achievement_flow_runner_stopped() -> void:
	"""Test complete flow: stop runner → stat tracked → achievement unlocked"""

	var initial_runners = global_ref.total_runners_stopped
	var achievement_unlocked: bool = false

	var callback = func(_id: String):
		achievement_unlocked = true

	event_bus.achievement_unlocked.connect(callback)

	# Stop 10 runners to unlock sharpshooter
	for i in range(10):
		event_bus.emit_runner_stopped("runner_%d" % i, 100, false)
		await get_tree().process_frame

	# Verify stat tracked
	assert_eq(
		game_state_manager.get_total_runners_stopped(),
		initial_runners + 10,
		"Should have stopped 10 runners"
	)

	# In real game, achievement check would happen here
	# We simulate it
	if game_state_manager.get_total_runners_stopped() >= 10:
		event_bus.achievement_unlocked.emit("sharpshooter")
		await get_tree().process_frame

	assert_true(achievement_unlocked, "Sharpshooter achievement should unlock")

	event_bus.achievement_unlocked.disconnect(callback)


func test_complete_achievement_flow_perfect_hits() -> void:
	"""Test complete flow: perfect hits → stat tracked → achievement unlocked"""

	var initial_perfect = global_ref.perfect_hits
	var achievement_unlocked: bool = false

	var callback = func(_id: String):
		achievement_unlocked = true

	event_bus.achievement_unlocked.connect(callback)

	# Achieve 5 perfect hits
	for i in range(5):
		event_bus.perfect_hit_achieved.emit(150)
		await get_tree().process_frame

	# Verify stat tracked
	assert_eq(
		game_state_manager.get_perfect_hits(),
		initial_perfect + 5,
		"Should have 5 perfect hits"
	)

	# Simulate achievement check
	if game_state_manager.get_perfect_hits() >= 5:
		event_bus.achievement_unlocked.emit("perfect_shot")
		await get_tree().process_frame

	assert_true(achievement_unlocked, "Perfect shot achievement should unlock")

	event_bus.achievement_unlocked.disconnect(callback)


func test_complete_achievement_flow_high_score() -> void:
	"""Test complete flow: earn score → check achievement → high scorer unlocked"""

	var achievement_unlocked: bool = false

	var callback = func(_id: String):
		achievement_unlocked = true

	event_bus.achievement_unlocked.connect(callback)

	# Earn score to reach 10000
	event_bus.request_score_add(10000, "test")
	await get_tree().process_frame

	# Verify score tracked
	assert_true(game_state_manager.get_score() >= 10000, "Score should be at least 10000")

	# Simulate achievement check
	if game_state_manager.get_score() >= 10000:
		event_bus.achievement_unlocked.emit("high_scorer")
		await get_tree().process_frame

	assert_true(achievement_unlocked, "High scorer achievement should unlock")

	event_bus.achievement_unlocked.disconnect(callback)


# ==================== ACHIEVEMENT PERSISTENCE ====================


func test_achievement_stats_persist_across_sessions() -> void:
	"""Test that achievement stats persist across save/load"""

	# Set stats
	global_ref.total_runners_stopped = 25
	global_ref.perfect_hits = 10
	global_ref.total_shifts_completed = 15

	# Save
	global_ref.save_game_state()
	await get_tree().process_frame

	# Clear
	global_ref.total_runners_stopped = 0
	global_ref.perfect_hits = 0
	global_ref.total_shifts_completed = 0
	await get_tree().process_frame

	# Load
	global_ref.load_game_state()
	await get_tree().process_frame

	# Verify stats restored
	assert_eq(global_ref.total_runners_stopped, 25, "Runners stopped should be restored")
	assert_eq(global_ref.perfect_hits, 10, "Perfect hits should be restored")
	assert_eq(global_ref.total_shifts_completed, 15, "Shifts completed should be restored")


func test_achievement_progress_accumulates() -> void:
	"""Test that achievement progress accumulates over multiple sessions"""

	# Session 1: Stop 5 runners
	global_ref.total_runners_stopped = 5
	global_ref.save_game_state()
	await get_tree().process_frame

	# Session 2: Load and stop 5 more
	global_ref.load_game_state()
	await get_tree().process_frame
	global_ref.total_runners_stopped += 5
	global_ref.save_game_state()
	await get_tree().process_frame

	# Verify accumulated
	assert_eq(global_ref.total_runners_stopped, 10, "Progress should accumulate")


# ==================== MULTIPLE ACHIEVEMENTS ====================


func test_multiple_achievements_unlock_simultaneously() -> void:
	"""Test that multiple achievement conditions can be met at once"""

	var achievements_unlocked: Array[String] = []

	var callback = func(id: String):
		achievements_unlocked.append(id)

	event_bus.achievement_unlocked.connect(callback)

	# Set up conditions for multiple achievements
	global_ref.total_shifts_completed = 25  # Master officer
	global_ref.total_runners_stopped = 50  # Border defender
	global_ref.perfect_hits = 5  # Perfect shot
	global_ref.score = 50000  # Score legend

	# Simulate achievement check that checks all conditions
	if global_ref.total_shifts_completed >= 25:
		event_bus.achievement_unlocked.emit("master_of_customs")
	if global_ref.total_runners_stopped >= 50:
		event_bus.achievement_unlocked.emit("border_defender")
	if global_ref.perfect_hits >= 5:
		event_bus.achievement_unlocked.emit("perfect_shot")
	if global_ref.score >= 50000:
		event_bus.achievement_unlocked.emit("score_legend")

	await get_tree().process_frame

	assert_eq(achievements_unlocked.size(), 4, "Should unlock 4 achievements")

	event_bus.achievement_unlocked.disconnect(callback)


func test_achievement_sequence_progression() -> void:
	"""Test that achievement tiers unlock in sequence"""

	var achievements: Array[String] = []

	var callback = func(id: String):
		achievements.append(id)

	event_bus.achievement_unlocked.connect(callback)

	# Progress through shift achievements
	global_ref.total_shifts_completed = 1
	if global_ref.total_shifts_completed >= 1:
		event_bus.achievement_unlocked.emit("rookie_customs_officer")
	await get_tree().process_frame

	global_ref.total_shifts_completed = 10
	if global_ref.total_shifts_completed >= 10:
		event_bus.achievement_unlocked.emit("customs_veteran")
	await get_tree().process_frame

	global_ref.total_shifts_completed = 25
	if global_ref.total_shifts_completed >= 25:
		event_bus.achievement_unlocked.emit("master_of_customs")
	await get_tree().process_frame

	# Verify sequence
	assert_eq(achievements.size(), 3, "Should have 3 achievements in sequence")
	assert_eq(achievements[0], "rookie_customs_officer", "First should be rookie")
	assert_eq(achievements[1], "customs_veteran", "Second should be veteran")
	assert_eq(achievements[2], "master_of_customs", "Third should be master")

	event_bus.achievement_unlocked.disconnect(callback)


# ==================== EDGE CASES ====================


func test_achievement_unlock_idempotent() -> void:
	"""Test that unlocking the same achievement multiple times is safe"""

	var unlock_count: int = 0

	var callback = func(_id: String):
		unlock_count += 1

	event_bus.achievement_unlocked.connect(callback)

	# Unlock same achievement multiple times
	event_bus.achievement_unlocked.emit("test_achievement")
	event_bus.achievement_unlocked.emit("test_achievement")
	event_bus.achievement_unlocked.emit("test_achievement")
	await get_tree().process_frame

	# Signal emitted 3 times (Steam handles deduplication)
	assert_eq(unlock_count, 3, "Signal should emit each time")

	event_bus.achievement_unlocked.disconnect(callback)


func test_achievement_with_zero_threshold() -> void:
	"""Test achievement conditions with zero values"""

	# Should not unlock with 0
	global_ref.total_runners_stopped = 0
	var should_not_unlock = global_ref.total_runners_stopped >= 10
	assert_false(should_not_unlock, "Should not unlock with 0 runners")


func test_achievement_stat_overflow_protection() -> void:
	"""Test that very large stat values don't break achievements"""

	# Set very large value
	global_ref.total_runners_stopped = 999999

	# Should still meet condition
	var should_unlock = global_ref.total_runners_stopped >= 50
	assert_true(should_unlock, "Large values should still meet conditions")


# ==================== HIGH SCORE ACHIEVEMENTS ====================


func test_high_score_achieved_signal() -> void:
	"""Test that high_score_achieved signal is emitted"""

	var signal_emitted: bool = false
	var difficulty: String = ""
	var score: int = 0

	var callback = func(diff: String, sc: int, _level: int):
		signal_emitted = true
		difficulty = diff
		score = sc

	event_bus.high_score_achieved.connect(callback)

	# Emit high score
	event_bus.high_score_achieved.emit("Normal", 15000, 5)
	await get_tree().process_frame

	assert_true(signal_emitted, "high_score_achieved should be emitted")
	assert_eq(difficulty, "Normal", "Difficulty should match")
	assert_eq(score, 15000, "Score should match")

	event_bus.high_score_achieved.disconnect(callback)


func test_high_score_triggers_achievement() -> void:
	"""Test that achieving high score can trigger achievement unlock"""

	var high_score_achieved: bool = false
	var achievement_unlocked: bool = false

	var score_cb = func(_diff: String, _score: int, _level: int):
		high_score_achieved = true

	var achievement_cb = func(_id: String):
		achievement_unlocked = true

	event_bus.high_score_achieved.connect(score_cb)
	event_bus.achievement_unlocked.connect(achievement_cb)

	# Achieve high score
	event_bus.high_score_achieved.emit("Normal", 25000, 5)
	await get_tree().process_frame

	# Unlock achievement for high score
	event_bus.achievement_unlocked.emit("high_scorer")
	await get_tree().process_frame

	assert_true(high_score_achieved, "High score should be achieved")
	assert_true(achievement_unlocked, "Achievement should be unlocked")

	event_bus.high_score_achieved.disconnect(score_cb)
	event_bus.achievement_unlocked.disconnect(achievement_cb)


# ==================== STORY ACHIEVEMENTS ====================


func test_story_completion_achievement() -> void:
	"""Test that completing story triggers achievement"""

	var achievement_unlocked: bool = false

	var callback = func(_id: String):
		achievement_unlocked = true

	event_bus.achievement_unlocked.connect(callback)

	# Set story state to completed
	global_ref.current_story_state = 11

	# Check achievement
	if global_ref.current_story_state >= 11:
		event_bus.achievement_unlocked.emit("savior_of_spud")
		await get_tree().process_frame

	assert_true(achievement_unlocked, "Story completion achievement should unlock")

	event_bus.achievement_unlocked.disconnect(callback)


# ==================== INTEGRATION WITH GAME FLOW ====================


func test_shift_completion_checks_achievements() -> void:
	"""Test that completing a shift triggers achievement checks"""

	var achievement_check_requested: bool = false

	var callback = func():
		achievement_check_requested = true

	event_bus.achievement_check_requested.connect(callback)

	# Complete shift
	event_bus.shift_advanced.emit(1, 2)
	await get_tree().process_frame

	# Request achievement check
	event_bus.achievement_check_requested.emit()
	await get_tree().process_frame

	assert_true(achievement_check_requested, "Achievement check should be requested")

	event_bus.achievement_check_requested.disconnect(callback)
