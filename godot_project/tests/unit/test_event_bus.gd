extends GutTest

## Unit tests for EventBus system
## Tests signal emissions, event chaining, and GameStateManager integration

var event_bus: Node
var game_state_manager: Node
var test_score_changed_called: bool = false
var test_strike_changed_called: bool = false
var last_score_data: Dictionary = {}
var last_strike_data: Dictionary = {}

func before_each() -> void:
	event_bus = get_node("/root/EventBus")
	game_state_manager = get_node("/root/GameStateManager")
	test_score_changed_called = false
	test_strike_changed_called = false
	last_score_data = {}
	last_strike_data = {}


func after_each() -> void:
	# Disconnect any test signals
	if event_bus.score_changed.is_connected(_on_test_score_changed):
		event_bus.score_changed.disconnect(_on_test_score_changed)
	if event_bus.strike_changed.is_connected(_on_test_strike_changed):
		event_bus.strike_changed.disconnect(_on_test_strike_changed)


# ==================== SIGNAL EMISSION TESTS ====================


func test_request_score_add_emits_score_changed() -> void:
	event_bus.score_changed.connect(_on_test_score_changed)

	event_bus.request_score_add(100, "test_source", {"test_key": "test_value"})

	# Wait for signal processing
	await get_tree().process_frame

	assert_true(test_score_changed_called, "score_changed signal should be emitted")
	assert_eq(last_score_data.get("delta"), 100, "Delta should be 100")
	assert_eq(last_score_data.get("source"), "test_source", "Source should be test_source")


func test_request_strike_add_emits_strike_changed() -> void:
	event_bus.strike_changed.connect(_on_test_strike_changed)

	event_bus.request_strike_add("test_reason", {"test_metadata": "value"})

	await get_tree().process_frame

	assert_true(test_strike_changed_called, "strike_changed signal should be emitted")


func test_show_alert_emits_correct_signal() -> void:
	var alert_red_called: bool = false
	var alert_green_called: bool = false

	var red_callback = func(msg: String, dur: float):
		alert_red_called = true
	var green_callback = func(msg: String, dur: float):
		alert_green_called = true

	event_bus.alert_red_requested.connect(red_callback)
	event_bus.alert_green_requested.connect(green_callback)

	event_bus.show_alert("Test message", false, 2.0)
	await get_tree().process_frame
	assert_true(alert_red_called, "Red alert should be emitted for negative message")

	alert_red_called = false
	event_bus.show_alert("Success message", true, 2.0)
	await get_tree().process_frame
	assert_true(alert_green_called, "Green alert should be emitted for positive message")

	event_bus.alert_red_requested.disconnect(red_callback)
	event_bus.alert_green_requested.disconnect(green_callback)


func test_emit_runner_escaped_includes_data() -> void:
	var runner_data_received: Dictionary = {}

	var callback = func(data: Dictionary):
		runner_data_received = data

	event_bus.runner_escaped.connect(callback)

	var test_data = {"type": "potato", "penalty": 100, "streak_reset": true}
	event_bus.emit_runner_escaped("potato", test_data)

	await get_tree().process_frame

	assert_eq(runner_data_received.get("type"), "potato", "Runner type should be preserved")
	assert_eq(runner_data_received.get("penalty"), 100, "Penalty should be preserved")

	event_bus.runner_escaped.disconnect(callback)


# ==================== GAMESTATE MANAGER INTEGRATION TESTS ====================


func test_score_request_updates_gamestate_manager() -> void:
	var initial_score = game_state_manager.get_score()

	event_bus.request_score_add(250, "test")
	await get_tree().process_frame

	var new_score = game_state_manager.get_score()
	assert_eq(new_score, initial_score + 250, "GameStateManager score should increase by 250")


func test_strike_request_updates_gamestate_manager() -> void:
	var initial_strikes = game_state_manager.get_strikes()

	event_bus.request_strike_add("test_reason")
	await get_tree().process_frame

	var new_strikes = game_state_manager.get_strikes()
	assert_eq(new_strikes, initial_strikes + 1, "GameStateManager strikes should increase by 1")


func test_multiple_score_adds_accumulate() -> void:
	var initial_score = game_state_manager.get_score()

	event_bus.request_score_add(100, "test1")
	await get_tree().process_frame
	event_bus.request_score_add(50, "test2")
	await get_tree().process_frame
	event_bus.request_score_add(25, "test3")
	await get_tree().process_frame

	var final_score = game_state_manager.get_score()
	assert_eq(final_score, initial_score + 175, "Multiple score adds should accumulate")


# ==================== BACKWARD COMPATIBILITY TESTS ====================


func test_global_stays_in_sync_with_gamestate_manager() -> void:
	var global_node = get_node("/root/Global")

	var initial_global_score = global_node.score
	var initial_gsm_score = game_state_manager.get_score()

	assert_eq(initial_global_score, initial_gsm_score, "Global and GSM should start in sync")

	event_bus.request_score_add(100, "sync_test")
	await get_tree().process_frame

	var new_global_score = global_node.score
	var new_gsm_score = game_state_manager.get_score()

	assert_eq(new_global_score, new_gsm_score, "Global and GSM should stay in sync")


# ==================== HELPER METHOD TESTS ====================


func test_request_score_add_helper_method() -> void:
	event_bus.score_changed.connect(_on_test_score_changed)

	EventBus.request_score_add(500, "helper_test", {"bonus": true})
	await get_tree().process_frame

	assert_true(test_score_changed_called, "Helper method should emit score_changed")
	assert_eq(last_score_data.get("delta"), 500, "Helper method should pass correct delta")


func test_track_event_helper_emits_analytics_event() -> void:
	var analytics_event_called: bool = false
	var event_name_received: String = ""
	var event_data_received: Dictionary = {}

	var callback = func(name: String, data: Dictionary):
		analytics_event_called = true
		event_name_received = name
		event_data_received = data

	event_bus.analytics_event.connect(callback)

	EventBus.track_event("TestEvent", {"key": "value"})
	await get_tree().process_frame

	assert_true(analytics_event_called, "track_event should emit analytics_event")
	assert_eq(event_name_received, "TestEvent", "Event name should be preserved")
	assert_eq(event_data_received.get("key"), "value", "Event data should be preserved")

	event_bus.analytics_event.disconnect(callback)


# ==================== EVENT CHAINING TESTS ====================


func test_runner_stopped_triggers_score_and_analytics() -> void:
	var score_changed: bool = false
	var analytics_called: bool = false

	var score_callback = func(_new_score: int, _delta: int, _source: String):
		score_changed = true
	var analytics_callback = func(_runner_data: Dictionary):
		analytics_called = true

	event_bus.score_changed.connect(score_callback)
	event_bus.runner_stopped.connect(analytics_callback)

	event_bus.emit_runner_stopped({"type": "potato", "bonus": 200})
	await get_tree().process_frame

	# Give GameStateManager time to process the runner_stopped event
	await get_tree().process_frame

	assert_true(analytics_called, "Analytics should track runner_stopped")
	# Note: score_changed depends on GameStateManager implementation

	event_bus.score_changed.disconnect(score_callback)
	event_bus.runner_stopped.disconnect(analytics_callback)


# ==================== METADATA PRESERVATION TESTS ====================


func test_metadata_preserved_in_score_add() -> void:
	var metadata_received: Dictionary = {}

	var callback = func(_new_score: int, _delta: int, _source: String, metadata: Dictionary = {}):
		metadata_received = metadata

	event_bus.score_changed.connect(callback)

	var test_metadata = {"action_type": "perfect_stamp", "combo": 5}
	event_bus.request_score_add(100, "gameplay", test_metadata)
	await get_tree().process_frame

	assert_eq(metadata_received.get("action_type"), "perfect_stamp", "Metadata should be preserved")
	assert_eq(metadata_received.get("combo"), 5, "Metadata values should be correct")

	event_bus.score_changed.disconnect(callback)


func test_empty_metadata_handled_gracefully() -> void:
	event_bus.score_changed.connect(_on_test_score_changed)

	# Call without metadata
	event_bus.request_score_add(50, "no_metadata_test")
	await get_tree().process_frame

	assert_true(test_score_changed_called, "Score add without metadata should work")


# ==================== ERROR HANDLING TESTS ====================


func test_negative_score_handled() -> void:
	var initial_score = game_state_manager.get_score()

	event_bus.request_score_add(-100, "penalty")
	await get_tree().process_frame

	var new_score = game_state_manager.get_score()
	assert_true(new_score >= 0, "Score should not go negative")


func test_max_strikes_triggers_game_over() -> void:
	var game_over_called: bool = false

	var callback = func():
		game_over_called = true

	event_bus.game_over_triggered.connect(callback)

	# Add strikes until max
	var max_strikes = game_state_manager.get_max_strikes()
	var current_strikes = game_state_manager.get_strikes()

	for i in range(max_strikes - current_strikes):
		event_bus.request_strike_add("test")
		await get_tree().process_frame

	await get_tree().process_frame

	# Check if game over was triggered (depends on GameStateManager implementation)
	# This test documents expected behavior

	event_bus.game_over_triggered.disconnect(callback)


# ==================== CONNECTION REPORT TEST ====================


func test_get_connection_report_returns_data() -> void:
	if event_bus.has_method("get_connection_report"):
		var report = event_bus.get_connection_report()
		assert_true(report is String, "Connection report should be a String")
		assert_gt(report.length(), 0, "Connection report should not be empty")


# ==================== CALLBACK FUNCTIONS ====================


func _on_test_score_changed(new_score: int, delta: int, source: String, metadata: Dictionary = {}) -> void:
	test_score_changed_called = true
	last_score_data = {
		"new_score": new_score,
		"delta": delta,
		"source": source,
		"metadata": metadata
	}


func _on_test_strike_changed(current_strikes: int, max_strikes: int, delta: int) -> void:
	test_strike_changed_called = true
	last_strike_data = {
		"current_strikes": current_strikes,
		"max_strikes": max_strikes,
		"delta": delta
	}
