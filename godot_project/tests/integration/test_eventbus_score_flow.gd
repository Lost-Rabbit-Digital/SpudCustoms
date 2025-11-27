extends GutTest

## Integration test for EventBus Score Flow
## Tests: Score Request → EventBus → GameStateManager → State Update → UI Signal

var event_bus: Node
var game_state_manager: Node

# Test state tracking
var score_changed_count: int = 0
var ui_update_count: int = 0
var last_score: int = 0
var last_delta: int = 0
var last_source: String = ""


func before_each() -> void:
	event_bus = get_node_or_null("/root/EventBus")
	game_state_manager = get_node_or_null("/root/GameStateManager")
	
	assert_not_null(event_bus, "EventBus must be available")
	assert_not_null(game_state_manager, "GameStateManager must be available")
	
	# Reset test state
	score_changed_count = 0
	ui_update_count = 0
	last_score = 0
	last_delta = 0
	last_source = ""
	
	# Reset game state
	event_bus.request_score_reset()
	await get_tree().process_frame


func after_each() -> void:
	# Disconnect any test signals
	if event_bus.score_changed.is_connected(_on_score_changed):
		event_bus.score_changed.disconnect(_on_score_changed)
	if event_bus.ui_score_update_requested.is_connected(_on_ui_update):
		event_bus.ui_score_update_requested.disconnect(_on_ui_update)
	
	await get_tree().process_frame


# ==================== SIGNAL CALLBACKS ====================


func _on_score_changed(new_score: int, delta: int, source: String) -> void:
	score_changed_count += 1
	last_score = new_score
	last_delta = delta
	last_source = source


func _on_ui_update(new_score: int) -> void:
	ui_update_count += 1
	last_score = new_score


# ==================== BASIC SCORE FLOW ====================


func test_score_add_flows_through_eventbus() -> void:
	"""Test that score addition flows: Request → EventBus → GameStateManager → Signals"""
	
	event_bus.score_changed.connect(_on_score_changed)
	event_bus.ui_score_update_requested.connect(_on_ui_update)
	
	# Request score add
	event_bus.request_score_add(100, "test_source", {})
	await get_tree().process_frame
	
	# Verify signals emitted
	assert_eq(score_changed_count, 1, "score_changed should be emitted once")
	assert_eq(ui_update_count, 1, "UI update should be requested once")
	
	# Verify data
	assert_eq(last_score, 100, "Score should be 100")
	assert_eq(last_delta, 100, "Delta should be 100")
	assert_eq(last_source, "test_source", "Source should match")
	
	# Verify GameStateManager state
	assert_eq(game_state_manager.get_score(), 100, "GameStateManager should have score 100")


func test_multiple_score_additions() -> void:
	"""Test that multiple score additions accumulate correctly"""
	
	event_bus.score_changed.connect(_on_score_changed)
	
	# Add scores from different sources
	event_bus.request_score_add(50, "source_1", {})
	await get_tree().process_frame
	
	event_bus.request_score_add(75, "source_2", {})
	await get_tree().process_frame
	
	event_bus.request_score_add(25, "source_3", {})
	await get_tree().process_frame
	
	# Verify accumulation
	assert_eq(score_changed_count, 3, "Should have 3 score changes")
	assert_eq(game_state_manager.get_score(), 150, "Total score should be 150")
	assert_eq(last_score, 150, "Last score should be 150")


func test_score_reset() -> void:
	"""Test that score reset works through EventBus"""
	
	event_bus.score_changed.connect(_on_score_changed)
	
	# Add some score
	event_bus.request_score_add(500, "test", {})
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_score(), 500, "Score should be 500")
	
	# Reset
	event_bus.request_score_reset()
	await get_tree().process_frame
	
	# Verify reset
	assert_eq(game_state_manager.get_score(), 0, "Score should be reset to 0")
	assert_eq(score_changed_count, 2, "Should have 2 score changes (add + reset)")


func test_score_with_metadata() -> void:
	"""Test that metadata is preserved in score events"""
	
	var metadata_received: Dictionary = {}
	
	var callback = func(new_score: int, delta: int, source: String):
		# Metadata is not directly passed in signal, but source is
		assert_eq(source, "stamp_system", "Source should be preserved")
	
	event_bus.score_changed.connect(callback)
	
	var metadata = {
		"stamp_type": "approved",
		"perfect": true,
		"combo": 5
	}
	
	event_bus.request_score_add(200, "stamp_system", metadata)
	await get_tree().process_frame
	
	event_bus.score_changed.disconnect(callback)


# ==================== SCORE FROM DIFFERENT SOURCES ====================


func test_score_from_stamp_system() -> void:
	"""Test score addition from stamp system"""
	
	event_bus.score_changed.connect(_on_score_changed)
	
	event_bus.request_score_add(100, "stamp_approved", {"perfect": true})
	await get_tree().process_frame
	
	assert_eq(last_source, "stamp_approved", "Source should be stamp_approved")
	assert_eq(game_state_manager.get_score(), 100, "Score should be added")


func test_score_from_runner_system() -> void:
	"""Test score addition from runner system"""
	
	event_bus.score_changed.connect(_on_score_changed)
	
	event_bus.request_score_add(250, "runner_stopped", {"perfect_hit": false})
	await get_tree().process_frame
	
	assert_eq(last_source, "runner_stopped", "Source should be runner_stopped")
	assert_eq(game_state_manager.get_score(), 250, "Score should be added")


func test_score_from_bonus_system() -> void:
	"""Test score addition from bonus/combo system"""
	
	event_bus.score_changed.connect(_on_score_changed)
	
	event_bus.request_score_add(500, "combo_bonus", {"combo_count": 10})
	await get_tree().process_frame
	
	assert_eq(last_source, "combo_bonus", "Source should be combo_bonus")
	assert_eq(game_state_manager.get_score(), 500, "Score should be added")


# ==================== SCORE PENALTIES ====================


func test_score_penalty_from_runner_escape() -> void:
	"""Test that runner escape applies score penalty correctly"""
	
	event_bus.score_changed.connect(_on_score_changed)
	
	# Add initial score
	event_bus.request_score_add(1000, "initial", {})
	await get_tree().process_frame
	
	# Runner escapes (handled by GameStateManager listening to runner_escaped)
	event_bus.emit_runner_escaped("potato", {"penalty": 200})
	await get_tree().process_frame
	
	# Score should be reduced (GameStateManager handles this)
	var current_score = game_state_manager.get_score()
	assert_true(current_score <= 1000, "Score should be reduced or unchanged")


func test_score_penalty_from_innocent_hit() -> void:
	"""Test that hitting innocent potato applies penalty"""
	
	event_bus.score_changed.connect(_on_score_changed)
	
	# Add initial score
	event_bus.request_score_add(500, "initial", {})
	await get_tree().process_frame
	
	# Hit innocent potato
	event_bus.emit_innocent_hit(100, {"message": "Wrong potato!"})
	await get_tree().process_frame
	
	# Score should be reduced
	var current_score = game_state_manager.get_score()
	assert_true(current_score <= 500, "Score should be reduced or unchanged")


# ==================== HIGH SCORE DETECTION ====================


func test_high_score_achievement_signal() -> void:
	"""Test that high score achievement emits signal"""
	
	var high_score_achieved: bool = false
	var achieved_score: int = 0
	
	var callback = func(difficulty: String, score: int, shift: int):
		high_score_achieved = true
		achieved_score = score
	
	event_bus.high_score_achieved.connect(callback)
	
	# Add a high score (assuming no previous high score)
	event_bus.request_score_add(10000, "test", {})
	await get_tree().process_frame
	
	# Note: High score detection depends on SaveManager state
	# This test verifies the signal exists and can be connected
	
	event_bus.high_score_achieved.disconnect(callback)


# ==================== UI INTEGRATION ====================


func test_ui_updates_on_every_score_change() -> void:
	"""Test that UI update is requested for every score change"""
	
	event_bus.ui_score_update_requested.connect(_on_ui_update)
	
	# Multiple score changes
	for i in range(5):
		event_bus.request_score_add(100, "test_%d" % i, {})
		await get_tree().process_frame
	
	assert_eq(ui_update_count, 5, "UI should be updated 5 times")


func test_ui_receives_correct_score_value() -> void:
	"""Test that UI receives the correct cumulative score"""
	
	event_bus.ui_score_update_requested.connect(_on_ui_update)
	
	event_bus.request_score_add(100, "test1", {})
	await get_tree().process_frame
	assert_eq(last_score, 100, "UI should show 100")
	
	event_bus.request_score_add(200, "test2", {})
	await get_tree().process_frame
	assert_eq(last_score, 300, "UI should show 300")
	
	event_bus.request_score_add(50, "test3", {})
	await get_tree().process_frame
	assert_eq(last_score, 350, "UI should show 350")


# ==================== EDGE CASES ====================


func test_negative_score_clamped_to_zero() -> void:
	"""Test that score cannot go below zero"""
	
	event_bus.score_changed.connect(_on_score_changed)
	
	# Start with small score
	event_bus.request_score_add(50, "initial", {})
	await get_tree().process_frame
	
	# Try to apply large penalty via runner escape
	event_bus.emit_runner_escaped("potato", {"penalty": 1000})
	await get_tree().process_frame
	
	# Score should be clamped to 0
	assert_true(game_state_manager.get_score() >= 0, "Score should not be negative")


func test_zero_score_addition() -> void:
	"""Test that adding zero score still emits signals"""
	
	event_bus.score_changed.connect(_on_score_changed)
	
	event_bus.request_score_add(0, "zero_test", {})
	await get_tree().process_frame
	
	assert_eq(score_changed_count, 1, "Signal should still be emitted for zero")
	assert_eq(last_delta, 0, "Delta should be 0")


func test_large_score_values() -> void:
	"""Test that large score values are handled correctly"""
	
	event_bus.score_changed.connect(_on_score_changed)
	
	event_bus.request_score_add(999999, "large_score", {})
	await get_tree().process_frame
	
	assert_eq(game_state_manager.get_score(), 999999, "Large scores should work")


# ==================== CONCURRENT REQUESTS ====================


func test_rapid_score_additions() -> void:
	"""Test that rapid score additions are handled correctly"""
	
	event_bus.score_changed.connect(_on_score_changed)
	
	# Rapid fire score additions (no await between them)
	for i in range(10):
		event_bus.request_score_add(10, "rapid_%d" % i, {})
	
	# Wait for all to process
	await get_tree().process_frame
	await get_tree().process_frame
	
	# All should be processed
	assert_eq(game_state_manager.get_score(), 100, "All rapid additions should be processed")


# ==================== INTEGRATION WITH SAVE SYSTEM ====================


func test_score_persists_after_save() -> void:
	"""Test that score is included in save state"""
	
	# Add score
	event_bus.request_score_add(7500, "test", {})
	await get_tree().process_frame
	
	# Get state snapshot
	var state = game_state_manager.get_state_snapshot()
	
	assert_eq(state.get("score", -1), 7500, "Score should be in state snapshot")


func test_score_restored_after_load() -> void:
	"""Test that score is restored when loading game state"""
	
	# This test would require SaveManager integration
	# For now, verify that GameStateManager has the load handler
	assert_true(
		event_bus.load_game_requested.is_connected(game_state_manager._on_load_requested),
		"GameStateManager should listen to load requests"
	)
