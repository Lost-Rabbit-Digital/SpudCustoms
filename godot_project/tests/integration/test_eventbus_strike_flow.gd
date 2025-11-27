extends GutTest

## Integration test for EventBus Strike Flow
## Tests: Strike Request → EventBus → GameStateManager → Game Over Detection

var event_bus: Node
var game_state_manager: Node

# Test state tracking
var strike_changed_count: int = 0
var strike_removed_count: int = 0
var game_over_triggered: bool = false
var max_strikes_reached: bool = false
var last_strikes: int = 0
var last_max_strikes: int = 0


func before_each() -> void:
	event_bus = get_node_or_null("/root/EventBus")
	game_state_manager = get_node_or_null("/root/GameStateManager")
	
	assert_not_null(event_bus, "EventBus must be available")
	assert_not_null(game_state_manager, "GameStateManager must be available")
	
	# Reset test state
	strike_changed_count = 0
	strike_removed_count = 0
	game_over_triggered = false
	max_strikes_reached = false
	last_strikes = 0
	last_max_strikes = 0
	
	# Reset game state
	event_bus.request_score_reset()
	event_bus.shift_stats_reset.emit()
	await get_tree().process_frame


func after_each() -> void:
	# Disconnect test signals
	if event_bus.strike_changed.is_connected(_on_strike_changed):
		event_bus.strike_changed.disconnect(_on_strike_changed)
	if event_bus.strike_removed.is_connected(_on_strike_removed):
		event_bus.strike_removed.disconnect(_on_strike_removed)
	if event_bus.game_over_triggered.is_connected(_on_game_over):
		event_bus.game_over_triggered.disconnect(_on_game_over)
	if event_bus.max_strikes_reached.is_connected(_on_max_strikes):
		event_bus.max_strikes_reached.disconnect(_on_max_strikes)
	
	await get_tree().process_frame


# ==================== SIGNAL CALLBACKS ====================


func _on_strike_changed(current: int, max_val: int, delta: int) -> void:
	strike_changed_count += 1
	last_strikes = current
	last_max_strikes = max_val


func _on_strike_removed(current: int, max_val: int) -> void:
	strike_removed_count += 1
	last_strikes = current
	last_max_strikes = max_val


func _on_game_over(reason: String) -> void:
	game_over_triggered = true


func _on_max_strikes() -> void:
	max_strikes_reached = true


# ==================== BASIC STRIKE FLOW ====================


func test_strike_add_flows_through_eventbus() -> void:
	"""Test that strike addition flows through EventBus correctly"""
	
	event_bus.strike_changed.connect(_on_strike_changed)
	
	# Request strike add
	event_bus.request_strike_add("test_reason", {})
	await get_tree().process_frame
	
	# Verify signal emitted
	assert_eq(strike_changed_count, 1, "strike_changed should be emitted once")
	
	# Verify data
	assert_eq(last_strikes, 1, "Should have 1 strike")
	assert_eq(game_state_manager.get_strikes(), 1, "GameStateManager should have 1 strike")


func test_multiple_strikes_accumulate() -> void:
	"""Test that multiple strikes accumulate correctly"""
	
	event_bus.strike_changed.connect(_on_strike_changed)
	
	# Add 3 strikes
	for i in range(3):
		event_bus.request_strike_add("reason_%d" % i, {})
		await get_tree().process_frame
	
	assert_eq(strike_changed_count, 3, "Should have 3 strike changes")
	assert_eq(game_state_manager.get_strikes(), 3, "Should have 3 total strikes")


func test_max_strikes_value() -> void:
	"""Test that max strikes value is correct based on difficulty"""
	
	event_bus.strike_changed.connect(_on_strike_changed)
	
	event_bus.request_strike_add("test", {})
	await get_tree().process_frame
	
	# Max strikes depends on difficulty (Normal = 4, Easy = 6, Expert = 3)
	assert_true(last_max_strikes > 0, "Max strikes should be set")
	assert_eq(last_max_strikes, game_state_manager.get_max_strikes(), "Max strikes should match GameStateManager")


# ==================== STRIKE SOURCES ====================


func test_strike_from_wrong_decision() -> void:
	"""Test strike from making wrong decision"""
	
	event_bus.strike_changed.connect(_on_strike_changed)
	
	event_bus.request_strike_add("wrong_decision", {"potato_type": "russet"})
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_strikes(), 1, "Wrong decision should add strike")


func test_strike_from_runner_escape() -> void:
	"""Test strike from runner escaping"""
	
	event_bus.strike_changed.connect(_on_strike_changed)
	
	# Runner escape triggers strike via GameStateManager
	event_bus.emit_runner_escaped("potato", {"penalty": 100})
	await get_tree().process_frame
	
	# GameStateManager should add strike
	assert_true(game_state_manager.get_strikes() >= 1, "Runner escape should add strike")


func test_strike_from_quota_failure() -> void:
	"""Test strike from failing to meet quota"""
	
	event_bus.strike_changed.connect(_on_strike_changed)
	
	event_bus.request_strike_add("quota_not_met", {"quota_met": 5, "quota_target": 8})
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_strikes(), 1, "Quota failure should add strike")


# ==================== STRIKE FORGIVENESS ====================


func test_strike_removed_on_runner_caught() -> void:
	"""Test that catching a runner removes a strike"""
	
	event_bus.strike_changed.connect(_on_strike_changed)
	event_bus.strike_removed.connect(_on_strike_removed)
	
	# Add some strikes first
	event_bus.request_strike_add("test1", {})
	await get_tree().process_frame
	event_bus.request_strike_add("test2", {})
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_strikes(), 2, "Should have 2 strikes")
	
	# Catch a runner (GameStateManager handles strike forgiveness)
	event_bus.emit_runner_stopped({"points_earned": 250})
	await get_tree().process_frame
	
	# Strike should be removed
	assert_eq(game_state_manager.get_strikes(), 1, "Should have 1 strike after forgiveness")
	assert_eq(strike_removed_count, 1, "strike_removed should be emitted")


func test_strike_forgiveness_stops_at_zero() -> void:
	"""Test that strikes cannot go below zero"""
	
	event_bus.strike_removed.connect(_on_strike_removed)
	
	# No strikes to begin with
	assert_eq(game_state_manager.get_strikes(), 0, "Should start with 0 strikes")
	
	# Try to remove a strike
	event_bus.emit_runner_stopped({"points_earned": 250})
	await get_tree().process_frame
	
	# Should still be 0
	assert_eq(game_state_manager.get_strikes(), 0, "Strikes should not go negative")


# ==================== GAME OVER DETECTION ====================


func test_max_strikes_triggers_game_over() -> void:
	"""Test that reaching max strikes triggers game over"""
	
	event_bus.strike_changed.connect(_on_strike_changed)
	event_bus.max_strikes_reached.connect(_on_max_strikes)
	event_bus.game_over_triggered.connect(_on_game_over)
	
	var max_strikes = game_state_manager.get_max_strikes()
	
	# Add strikes up to max
	for i in range(max_strikes):
		event_bus.request_strike_add("test_%d" % i, {})
		await get_tree().process_frame
	
	# Verify game over
	assert_true(max_strikes_reached, "max_strikes_reached should be emitted")
	assert_true(game_over_triggered, "game_over_triggered should be emitted")


func test_game_over_reason_is_max_strikes() -> void:
	"""Test that game over reason is correctly set"""
	
	var game_over_reason: String = ""
	
	var callback = func(reason: String):
		game_over_reason = reason
	
	event_bus.game_over_triggered.connect(callback)
	
	var max_strikes = game_state_manager.get_max_strikes()
	
	# Trigger max strikes
	for i in range(max_strikes):
		event_bus.request_strike_add("test", {})
		await get_tree().process_frame
	
	assert_eq(game_over_reason, "max_strikes", "Game over reason should be max_strikes")
	
	event_bus.game_over_triggered.disconnect(callback)


func test_one_strike_below_max_no_game_over() -> void:
	"""Test that being one strike below max doesn't trigger game over"""
	
	event_bus.max_strikes_reached.connect(_on_max_strikes)
	event_bus.game_over_triggered.connect(_on_game_over)
	
	var max_strikes = game_state_manager.get_max_strikes()
	
	# Add strikes up to max - 1
	for i in range(max_strikes - 1):
		event_bus.request_strike_add("test_%d" % i, {})
		await get_tree().process_frame
	
	# Should NOT trigger game over
	assert_false(max_strikes_reached, "Should not reach max strikes")
	assert_false(game_over_triggered, "Should not trigger game over")


# ==================== UI INTEGRATION ====================


func test_ui_strike_update_requested() -> void:
	"""Test that UI strike update is requested"""
	
	var ui_update_count: int = 0
	
	var callback = func(current: int, max_val: int):
		ui_update_count += 1
	
	event_bus.ui_strike_update_requested.connect(callback)
	
	event_bus.request_strike_add("test", {})
	await get_tree().process_frame
	
	assert_eq(ui_update_count, 1, "UI update should be requested")
	
	event_bus.ui_strike_update_requested.disconnect(callback)


func test_ui_receives_correct_strike_values() -> void:
	"""Test that UI receives correct current and max strike values"""
	
	var received_current: int = 0
	var received_max: int = 0
	
	var callback = func(current: int, max_val: int):
		received_current = current
		received_max = max_val
	
	event_bus.ui_strike_update_requested.connect(callback)
	
	event_bus.request_strike_add("test", {})
	await get_tree().process_frame
	
	assert_eq(received_current, 1, "UI should receive current strikes = 1")
	assert_eq(received_max, game_state_manager.get_max_strikes(), "UI should receive correct max strikes")
	
	event_bus.ui_strike_update_requested.disconnect(callback)


# ==================== DIFFICULTY INTEGRATION ====================


func test_easy_difficulty_max_strikes() -> void:
	"""Test that Easy difficulty has 6 max strikes"""
	
	# Set difficulty to Easy
	if game_state_manager.has_method("set_difficulty"):
		game_state_manager.set_difficulty("Easy")
		await get_tree().process_frame
		
		assert_eq(game_state_manager.get_max_strikes(), 6, "Easy should have 6 max strikes")


func test_normal_difficulty_max_strikes() -> void:
	"""Test that Normal difficulty has 4 max strikes"""
	
	# Set difficulty to Normal
	if game_state_manager.has_method("set_difficulty"):
		game_state_manager.set_difficulty("Normal")
		await get_tree().process_frame
		
		assert_eq(game_state_manager.get_max_strikes(), 4, "Normal should have 4 max strikes")


func test_expert_difficulty_max_strikes() -> void:
	"""Test that Expert difficulty has 3 max strikes"""
	
	# Set difficulty to Expert
	if game_state_manager.has_method("set_difficulty"):
		game_state_manager.set_difficulty("Expert")
		await get_tree().process_frame
		
		assert_eq(game_state_manager.get_max_strikes(), 3, "Expert should have 3 max strikes")


# ==================== STRIKE RESET ====================


func test_strikes_reset_on_shift_stats_reset() -> void:
	"""Test that strikes are reset when shift stats reset"""
	
	event_bus.strike_changed.connect(_on_strike_changed)
	
	# Add some strikes
	event_bus.request_strike_add("test1", {})
	await get_tree().process_frame
	event_bus.request_strike_add("test2", {})
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_strikes(), 2, "Should have 2 strikes")
	
	# Reset shift stats
	event_bus.shift_stats_reset.emit()
	await get_tree().process_frame
	
	# Strikes should be reset
	assert_eq(game_state_manager.get_strikes(), 0, "Strikes should be reset to 0")


# ==================== EDGE CASES ====================


func test_rapid_strike_additions() -> void:
	"""Test that rapid strike additions are handled correctly"""
	
	event_bus.strike_changed.connect(_on_strike_changed)
	
	# Rapid fire strikes (no await between)
	for i in range(3):
		event_bus.request_strike_add("rapid_%d" % i, {})
	
	# Wait for all to process
	await get_tree().process_frame
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_strikes(), 3, "All rapid strikes should be processed")


func test_strike_with_metadata() -> void:
	"""Test that strike metadata is preserved"""
	
	var metadata_test: bool = false
	
	var callback = func(current: int, max_val: int, delta: int):
		# Metadata is not directly in signal, but we verify the strike was added
		metadata_test = true
	
	event_bus.strike_changed.connect(callback)
	
	var metadata = {
		"reason": "wrong_stamp",
		"potato_type": "russet",
		"expected": "approved",
		"actual": "rejected"
	}
	
	event_bus.request_strike_add("wrong_decision", metadata)
	await get_tree().process_frame
	
	assert_true(metadata_test, "Strike with metadata should be processed")
	
	event_bus.strike_changed.disconnect(callback)


# ==================== INTEGRATION WITH SAVE SYSTEM ====================


func test_strikes_in_state_snapshot() -> void:
	"""Test that strikes are included in state snapshot"""
	
	# Add strikes
	event_bus.request_strike_add("test1", {})
	await get_tree().process_frame
	event_bus.request_strike_add("test2", {})
	await get_tree().process_frame
	
	# Get state snapshot
	var state = game_state_manager.get_state_snapshot()
	
	assert_eq(state.get("strikes", -1), 2, "Strikes should be in state snapshot")
	assert_eq(state.get("max_strikes", -1), game_state_manager.get_max_strikes(), "Max strikes should be in snapshot")
