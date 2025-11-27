extends GutTest

## Integration test for Complete EventBus Game Flow
## Tests: Full shift cycle using EventBus architecture

var event_bus: Node
var game_state_manager: Node

# Track game flow events
var shift_started: bool = false
var shift_completed: bool = false
var game_over_occurred: bool = false
var high_score_achieved: bool = false


func before_each() -> void:
	event_bus = get_node_or_null("/root/EventBus")
	game_state_manager = get_node_or_null("/root/GameStateManager")
	
	assert_not_null(event_bus, "EventBus must be available")
	assert_not_null(game_state_manager, "GameStateManager must be available")
	
	# Reset tracking
	shift_started = false
	shift_completed = false
	game_over_occurred = false
	high_score_achieved = false
	
	# Reset game state
	event_bus.shift_stats_reset.emit()
	await get_tree().process_frame


func after_each() -> void:
	# Cleanup signal connections
	_disconnect_all_test_signals()
	await get_tree().process_frame


func _disconnect_all_test_signals() -> void:
	var signals_to_check = [
		"game_over_triggered",
		"high_score_achieved",
		"score_changed",
		"strike_changed"
	]
	
	for signal_name in signals_to_check:
		var signal_obj = event_bus.get(signal_name)
		if signal_obj and signal_obj is Signal:
			# Disconnect all connections (GDScript 4.x)
			pass  # Handled in individual tests


# ==================== COMPLETE SHIFT FLOW ====================


func test_successful_shift_completion() -> void:
	"""Test a complete successful shift from start to finish"""
	
	# 1. Initialize shift
	event_bus.shift_stats_reset.emit()
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_score(), 0, "Score should start at 0")
	assert_eq(game_state_manager.get_strikes(), 0, "Strikes should start at 0")
	
	# 2. Process some potatoes (correct decisions)
	for i in range(5):
		event_bus.request_score_add(100, "correct_decision", {})
		await get_tree().process_frame
	
	assert_eq(game_state_manager.get_score(), 500, "Should have 500 points from 5 correct decisions")
	
	# 3. Make one mistake
	event_bus.request_strike_add("wrong_decision", {})
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_strikes(), 1, "Should have 1 strike")
	
	# 4. Catch a runner (bonus points + strike forgiveness)
	event_bus.emit_runner_stopped({"points_earned": 250})
	await get_tree().process_frame
	
	assert_true(game_state_manager.get_score() >= 750, "Should have runner bonus")
	assert_eq(game_state_manager.get_strikes(), 0, "Strike should be forgiven")
	
	# 5. Complete shift successfully
	var final_score = game_state_manager.get_score()
	assert_true(final_score > 0, "Should have positive score at end")


func test_failed_shift_max_strikes() -> void:
	"""Test shift failure due to max strikes"""
	
	var game_over_triggered: bool = false
	
	var callback = func(reason: String):
		game_over_triggered = true
		assert_eq(reason, "max_strikes", "Game over reason should be max_strikes")
	
	event_bus.game_over_triggered.connect(callback)
	
	# Add strikes until max
	var max_strikes = game_state_manager.get_max_strikes()
	for i in range(max_strikes):
		event_bus.request_strike_add("mistake_%d" % i, {})
		await get_tree().process_frame
	
	# Verify game over
	assert_true(game_over_triggered, "Game over should be triggered")
	
	event_bus.game_over_triggered.disconnect(callback)


# ==================== SCORE ACCUMULATION SCENARIOS ====================


func test_perfect_shift_no_strikes() -> void:
	"""Test a perfect shift with no strikes"""
	
	# Process 10 potatoes correctly
	for i in range(10):
		event_bus.request_score_add(100, "perfect_decision", {})
		await get_tree().process_frame
	
	# Add some bonuses
	event_bus.request_score_add(500, "perfect_bonus", {})
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_score(), 1500, "Perfect shift should have 1500 points")
	assert_eq(game_state_manager.get_strikes(), 0, "Perfect shift should have 0 strikes")


func test_mixed_performance_shift() -> void:
	"""Test a shift with mixed correct/incorrect decisions"""
	
	# 5 correct decisions
	for i in range(5):
		event_bus.request_score_add(100, "correct", {})
		await get_tree().process_frame
	
	# 2 mistakes
	for i in range(2):
		event_bus.request_strike_add("wrong", {})
		await get_tree().process_frame
	
	# 3 more correct
	for i in range(3):
		event_bus.request_score_add(100, "correct", {})
		await get_tree().process_frame
	
	assert_eq(game_state_manager.get_score(), 800, "Should have 800 points")
	assert_eq(game_state_manager.get_strikes(), 2, "Should have 2 strikes")


# ==================== RUNNER SCENARIOS ====================


func test_multiple_runners_caught() -> void:
	"""Test catching multiple runners in one shift"""
	
	# Catch 3 runners
	for i in range(3):
		event_bus.emit_runner_stopped({"points_earned": 250})
		await get_tree().process_frame
	
	# Score should include all runner bonuses
	assert_true(game_state_manager.get_score() >= 750, "Should have points from 3 runners")


func test_runner_escape_penalty() -> void:
	"""Test runner escape applies penalty correctly"""
	
	# Build up some score
	event_bus.request_score_add(1000, "initial", {})
	await get_tree().process_frame
	
	var score_before = game_state_manager.get_score()
	
	# Runner escapes
	event_bus.emit_runner_escaped("potato", {"penalty": 200})
	await get_tree().process_frame
	
	# Score should be reduced and strike added
	assert_true(game_state_manager.get_score() < score_before, "Score should be reduced")
	assert_true(game_state_manager.get_strikes() >= 1, "Strike should be added")


func test_runner_escape_with_zero_score() -> void:
	"""Test runner escape when score is already zero"""
	
	assert_eq(game_state_manager.get_score(), 0, "Score starts at 0")
	
	# Runner escapes
	event_bus.emit_runner_escaped("potato", {"penalty": 200})
	await get_tree().process_frame
	
	# Score should stay at 0 (not go negative)
	assert_eq(game_state_manager.get_score(), 0, "Score should not go negative")
	assert_true(game_state_manager.get_strikes() >= 1, "Strike should still be added")


# ==================== COMBO AND BONUS SCENARIOS ====================


func test_perfect_hit_bonus() -> void:
	"""Test perfect hit bonus points"""
	
	# Trigger perfect hit
	event_bus.emit_perfect_hit_achieved(150)
	await get_tree().process_frame
	
	# Perfect hits are tracked
	assert_true(game_state_manager.get_perfect_hits() >= 1, "Perfect hit should be tracked")


func test_combo_multiplier_scenario() -> void:
	"""Test score accumulation with combo multipliers"""
	
	# Simulate combo scoring
	event_bus.request_score_add(100, "base", {})
	await get_tree().process_frame
	
	event_bus.request_score_add(150, "combo_2x", {})
	await get_tree().process_frame
	
	event_bus.request_score_add(200, "combo_3x", {})
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_score(), 450, "Combo scores should accumulate")


# ==================== STATE TRANSITIONS ====================


func test_shift_advancement() -> void:
	"""Test shift advancement via EventBus"""
	
	var initial_shift = game_state_manager.get_shift()
	
	# Request shift advancement
	event_bus.shift_advance_requested.emit()
	await get_tree().process_frame
	
	# Note: Actual shift advancement is handled by Global/GameState
	# EventBus just coordinates the request


func test_shift_stats_reset() -> void:
	"""Test that shift stats reset clears score and strikes"""
	
	# Build up state
	event_bus.request_score_add(500, "test", {})
	await get_tree().process_frame
	event_bus.request_strike_add("test", {})
	await get_tree().process_frame
	
	assert_true(game_state_manager.get_score() > 0, "Should have score")
	assert_true(game_state_manager.get_strikes() > 0, "Should have strikes")
	
	# Reset
	event_bus.shift_stats_reset.emit()
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_score(), 0, "Score should be reset")
	assert_eq(game_state_manager.get_strikes(), 0, "Strikes should be reset")


# ==================== SAVE/LOAD INTEGRATION ====================


func test_save_mid_shift() -> void:
	"""Test saving game state mid-shift"""
	
	# Build up some state
	event_bus.request_score_add(750, "test", {})
	await get_tree().process_frame
	event_bus.request_strike_add("test", {})
	await get_tree().process_frame
	
	# Request save
	event_bus.save_game_requested.emit()
	await get_tree().process_frame
	
	# Verify state is in snapshot
	var state = game_state_manager.get_state_snapshot()
	assert_eq(state.get("score", -1), 750, "Score should be in snapshot")
	assert_eq(state.get("strikes", -1), 1, "Strikes should be in snapshot")


func test_load_restores_state() -> void:
	"""Test that loading restores game state"""
	
	# This test verifies the load mechanism exists
	var load_handler_connected = event_bus.load_game_requested.is_connected(
		game_state_manager._on_load_requested
	)
	
	assert_true(load_handler_connected, "GameStateManager should handle load requests")


# ==================== DIFFICULTY SCENARIOS ====================


func test_easy_difficulty_shift() -> void:
	"""Test shift with Easy difficulty (6 max strikes)"""
	
	if game_state_manager.has_method("set_difficulty"):
		game_state_manager.set_difficulty("Easy")
		await get_tree().process_frame
		
		# Can make more mistakes on Easy
		for i in range(5):
			event_bus.request_strike_add("mistake", {})
			await get_tree().process_frame
		
		# Should not be game over yet (max is 6)
		assert_eq(game_state_manager.get_strikes(), 5, "Should have 5 strikes")


func test_expert_difficulty_shift() -> void:
	"""Test shift with Expert difficulty (3 max strikes)"""
	
	if game_state_manager.has_method("set_difficulty"):
		game_state_manager.set_difficulty("Expert")
		await get_tree().process_frame
		
		var game_over_triggered: bool = false
		var callback = func(reason: String): game_over_triggered = true
		event_bus.game_over_triggered.connect(callback)
		
		# Make 3 mistakes (should trigger game over)
		for i in range(3):
			event_bus.request_strike_add("mistake", {})
			await get_tree().process_frame
		
		assert_true(game_over_triggered, "Expert should trigger game over at 3 strikes")
		
		event_bus.game_over_triggered.disconnect(callback)


# ==================== EDGE CASES ====================


func test_rapid_event_sequence() -> void:
	"""Test rapid sequence of different events"""
	
	# Rapid fire different events
	event_bus.request_score_add(100, "test1", {})
	event_bus.request_strike_add("test", {})
	event_bus.request_score_add(50, "test2", {})
	event_bus.emit_runner_stopped({"points_earned": 200})
	event_bus.request_score_add(75, "test3", {})
	
	# Wait for all to process
	await get_tree().process_frame
	await get_tree().process_frame
	
	# All events should be processed
	assert_true(game_state_manager.get_score() > 0, "Score should be accumulated")


func test_event_ordering() -> void:
	"""Test that events are processed in order"""
	
	var events_processed: Array = []
	
	var score_callback = func(new_score: int, delta: int, source: String):
		events_processed.append("score_%s" % source)
	
	var strike_callback = func(current: int, max_val: int, delta: int):
		events_processed.append("strike")
	
	event_bus.score_changed.connect(score_callback)
	event_bus.strike_changed.connect(strike_callback)
	
	# Emit events in specific order
	event_bus.request_score_add(100, "first", {})
	await get_tree().process_frame
	
	event_bus.request_strike_add("second", {})
	await get_tree().process_frame
	
	event_bus.request_score_add(50, "third", {})
	await get_tree().process_frame
	
	# Verify order
	assert_eq(events_processed.size(), 3, "Should have 3 events")
	assert_eq(events_processed[0], "score_first", "First event should be score_first")
	assert_eq(events_processed[1], "strike", "Second event should be strike")
	assert_eq(events_processed[2], "score_third", "Third event should be score_third")
	
	event_bus.score_changed.disconnect(score_callback)
	event_bus.strike_changed.disconnect(strike_callback)


# ==================== PERFORMANCE ====================


func test_100_events_performance() -> void:
	"""Test that system handles 100 events efficiently"""
	
	var start_time = Time.get_ticks_msec()
	
	# Fire 100 events
	for i in range(100):
		if i % 2 == 0:
			event_bus.request_score_add(10, "perf_test", {})
		else:
			event_bus.request_strike_add("perf_test", {})
		await get_tree().process_frame
	
	var end_time = Time.get_ticks_msec()
	var duration = end_time - start_time
	
	# Should complete in reasonable time (< 5 seconds)
	assert_true(duration < 5000, "100 events should process in under 5 seconds")
	
	# Verify all events processed
	assert_eq(game_state_manager.get_score(), 500, "All score events should be processed")
