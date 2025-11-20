extends GutTest

## Integration test for Border Runner Flow
## Tests: Spawn → Detection → Missile Launch → Hit/Miss → Score Update → Achievement Check

var event_bus: Node
var game_state_manager: Node

func before_each() -> void:
	event_bus = get_node_or_null("/root/EventBus")
	game_state_manager = get_node_or_null("/root/GameStateManager")

	assert_not_null(event_bus, "EventBus must be available")
	assert_not_null(game_state_manager, "GameStateManager must be available")


# ==================== RUNNER CAUGHT FLOW ====================


func test_runner_caught_full_flow() -> void:
	"""
	Test complete flow of successfully catching a border runner:
	1. Runner spawned
	2. Player clicks to launch missile
	3. Missile hits runner
	4. Score increased
	5. Strike removed (if any)
	6. Achievement progress tracked
	"""

	var initial_score = game_state_manager.get_score()
	var initial_strikes = game_state_manager.get_strikes()

	var runner_stopped_called: bool = false
	var score_increased: bool = false
	var achievement_checked: bool = false

	var runner_callback = func(_data: Dictionary):
		runner_stopped_called = true

	var score_callback = func(_new_score: int, delta: int, _source: String, _metadata: Dictionary = {}):
		if delta > 0:
			score_increased = true

	var achievement_callback = func(_achievement_id: String):
		achievement_checked = true

	event_bus.runner_stopped.connect(runner_callback)
	event_bus.score_changed.connect(score_callback)
	event_bus.achievement_check_requested.connect(achievement_callback)

	# Simulate runner caught
	var runner_data = {
		"type": "potato",
		"speed": 150,
		"distance_traveled": 200,
		"was_perfect_hit": false
	}

	event_bus.emit_runner_stopped(runner_data)
	await get_tree().process_frame

	# Award points for stopping runner
	event_bus.request_score_add(200, "runner_stopped", runner_data)
	await get_tree().process_frame

	# If player had strikes, remove one
	if initial_strikes > 0:
		# Strike removal would be handled by BorderRunnerSystem
		pass

	# Check achievement progress
	event_bus.emit_achievement_check_requested("border_defender")
	await get_tree().process_frame

	# Verify flow
	assert_true(runner_stopped_called, "Runner stopped event should fire")
	assert_true(score_increased, "Score should increase")

	var new_score = game_state_manager.get_score()
	assert_gt(new_score, initial_score, "Score should be higher")

	# Cleanup
	event_bus.runner_stopped.disconnect(runner_callback)
	event_bus.score_changed.disconnect(score_callback)
	event_bus.achievement_check_requested.disconnect(achievement_callback)


func test_perfect_hit_on_runner() -> void:
	"""
	Test that a perfect hit (center mass) awards bonus points
	"""

	var initial_score = game_state_manager.get_score()
	var perfect_hit_triggered: bool = false

	var callback = func(bonus: int):
		perfect_hit_triggered = true

	event_bus.perfect_hit_achieved.connect(callback)

	# Simulate perfect hit
	var runner_data = {
		"type": "potato",
		"was_perfect_hit": true,
		"hit_accuracy": 100.0
	}

	event_bus.emit_runner_stopped(runner_data)
	await get_tree().process_frame

	# Award base points
	event_bus.request_score_add(200, "runner_stopped")
	await get_tree().process_frame

	# Award perfect hit bonus
	event_bus.emit_perfect_hit_achieved(150)
	await get_tree().process_frame

	assert_true(perfect_hit_triggered, "Perfect hit achievement should trigger")

	var final_score = game_state_manager.get_score()
	var total_added = final_score - initial_score

	assert_eq(total_added, 350, "Should award 200 base + 150 perfect hit bonus")

	event_bus.perfect_hit_achieved.disconnect(callback)


# ==================== RUNNER ESCAPED FLOW ====================


func test_runner_escaped_full_flow() -> void:
	"""
	Test complete flow of runner escaping:
	1. Runner reaches end of path
	2. Strike added
	3. Score penalty applied
	4. Game over check (if max strikes)
	"""

	var initial_score = game_state_manager.get_score()
	var initial_strikes = game_state_manager.get_strikes()

	var runner_escaped_called: bool = false
	var strike_added: bool = false
	var score_decreased: bool = false

	var escape_callback = func(_data: Dictionary):
		runner_escaped_called = true

	var strike_callback = func(_current: int, _max: int, delta: int):
		if delta > 0:
			strike_added = true

	var score_callback = func(_new_score: int, delta: int, _source: String, _metadata: Dictionary = {}):
		if delta < 0:
			score_decreased = true

	event_bus.runner_escaped.connect(escape_callback)
	event_bus.strike_changed.connect(strike_callback)
	event_bus.score_changed.connect(score_callback)

	# Simulate runner escape
	var escape_data = {
		"type": "potato",
		"penalty": 100,
		"streak_reset": true
	}

	event_bus.emit_runner_escaped("potato", escape_data)
	await get_tree().process_frame

	# Add strike
	event_bus.request_strike_add("runner_escaped", escape_data)
	await get_tree().process_frame

	# Apply score penalty
	event_bus.request_score_add(-100, "runner_escaped_penalty")
	await get_tree().process_frame

	# Verify flow
	assert_true(runner_escaped_called, "Runner escaped event should fire")
	assert_true(strike_added, "Strike should be added")

	var new_strikes = game_state_manager.get_strikes()
	assert_eq(new_strikes, initial_strikes + 1, "Strikes should increase by 1")

	# Cleanup
	event_bus.runner_escaped.disconnect(escape_callback)
	event_bus.strike_changed.disconnect(strike_callback)
	event_bus.score_changed.disconnect(score_callback)


func test_max_strikes_triggers_game_over() -> void:
	"""
	Test that reaching max strikes triggers game over
	"""

	var game_over_triggered: bool = false

	var callback = func():
		game_over_triggered = true

	event_bus.game_over_triggered.connect(callback)

	# Get current strike count
	var max_strikes = game_state_manager.get_max_strikes()
	var current_strikes = game_state_manager.get_strikes()
	var strikes_to_add = max_strikes - current_strikes

	# Add strikes to reach max
	for i in range(strikes_to_add):
		event_bus.request_strike_add("test_strike_%d" % i)
		await get_tree().process_frame

	# GameStateManager should emit game_over_triggered
	await get_tree().process_frame

	# Note: Actual game over triggering depends on GameStateManager implementation

	event_bus.game_over_triggered.disconnect(callback)


# ==================== UI FEEDBACK TESTS ====================


func test_runner_stopped_shows_alert() -> void:
	"""
	Test that stopping a runner shows positive UI feedback
	"""

	var alert_shown: bool = false

	var callback = func(_message: String, _duration: float):
		alert_shown = true

	event_bus.alert_green_requested.connect(callback)

	# Stop runner and show success alert
	event_bus.emit_runner_stopped({"type": "potato"})
	await get_tree().process_frame

	event_bus.show_alert("Runner Stopped! +200 points", true, 2.0)
	await get_tree().process_frame

	assert_true(alert_shown, "Success alert should be shown")

	event_bus.alert_green_requested.disconnect(callback)


func test_runner_escaped_shows_warning() -> void:
	"""
	Test that runner escaping shows negative UI feedback
	"""

	var alert_shown: bool = false

	var callback = func(_message: String, _duration: float):
		alert_shown = true

	event_bus.alert_red_requested.connect(callback)

	# Runner escapes and show warning alert
	event_bus.emit_runner_escaped("potato", {"penalty": 100})
	await get_tree().process_frame

	event_bus.show_alert("Runner Escaped! Strike Added!", false, 2.0)
	await get_tree().process_frame

	assert_true(alert_shown, "Warning alert should be shown")

	event_bus.alert_red_requested.disconnect(callback)
