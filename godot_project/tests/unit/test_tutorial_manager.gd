extends GutTest

## Unit tests for TutorialManager
## Tests tutorial system initialization, progression, completion, and persistence

var tutorial_manager: Node
var test_tutorial_started_called: bool = false
var test_tutorial_completed_called: bool = false
var test_tutorial_skipped_called: bool = false
var test_step_completed_called: bool = false
var last_tutorial_id: String = ""
var last_step_index: int = -1


func before_each() -> void:
	tutorial_manager = get_node("/root/TutorialManager")
	test_tutorial_started_called = false
	test_tutorial_completed_called = false
	test_tutorial_skipped_called = false
	test_step_completed_called = false
	last_tutorial_id = ""
	last_step_index = -1

	# Reset tutorial manager state
	tutorial_manager.reset_all_tutorials()
	tutorial_manager.set_tutorials_enabled(true)
	tutorial_manager.can_skip_tutorials = false


func after_each() -> void:
	# Clean up any active overlays
	if tutorial_manager.tutorial_overlay:
		tutorial_manager.tutorial_overlay.queue_free()
		tutorial_manager.tutorial_overlay = null

	# Disconnect test signals
	if tutorial_manager.tutorial_started.is_connected(_on_tutorial_started):
		tutorial_manager.tutorial_started.disconnect(_on_tutorial_started)
	if tutorial_manager.tutorial_completed.is_connected(_on_tutorial_completed):
		tutorial_manager.tutorial_completed.disconnect(_on_tutorial_completed)
	if tutorial_manager.tutorial_skipped.is_connected(_on_tutorial_skipped):
		tutorial_manager.tutorial_skipped.disconnect(_on_tutorial_skipped)
	if tutorial_manager.tutorial_step_completed.is_connected(_on_step_completed):
		tutorial_manager.tutorial_step_completed.disconnect(_on_step_completed)


# ==================== INITIALIZATION TESTS ====================


func test_tutorial_manager_exists() -> void:
	assert_not_null(tutorial_manager, "TutorialManager should be available as autoload")


func test_initial_state() -> void:
	assert_eq(tutorial_manager.current_tutorial, "", "Current tutorial should be empty initially")
	assert_eq(tutorial_manager.current_step, 0, "Current step should be 0 initially")
	assert_true(tutorial_manager.tutorial_enabled, "Tutorials should be enabled by default")


func test_tutorials_dictionary_exists() -> void:
	assert_true(tutorial_manager.TUTORIALS.size() > 0, "TUTORIALS dictionary should have entries")


func test_all_tutorials_have_required_fields() -> void:
	for tutorial_id in tutorial_manager.TUTORIALS:
		var tutorial = tutorial_manager.TUTORIALS[tutorial_id]
		assert_true(tutorial.has("name"), "Tutorial %s should have name" % tutorial_id)
		assert_true(tutorial.has("steps"), "Tutorial %s should have steps" % tutorial_id)
		assert_true(tutorial["steps"].size() > 0, "Tutorial %s should have at least one step" % tutorial_id)


# ==================== TUTORIAL STARTING TESTS ====================


func test_start_tutorial_emits_signal() -> void:
	tutorial_manager.tutorial_started.connect(_on_tutorial_started)

	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	assert_true(test_tutorial_started_called, "tutorial_started signal should be emitted")
	assert_eq(last_tutorial_id, "gate_control", "Signal should include correct tutorial ID")


func test_start_tutorial_sets_current_tutorial() -> void:
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	assert_eq(tutorial_manager.current_tutorial, "gate_control", "Current tutorial should be set")
	assert_eq(tutorial_manager.current_step, 0, "Current step should be 0")


func test_start_invalid_tutorial_fails_gracefully() -> void:
	tutorial_manager.start_tutorial("invalid_tutorial_id")
	await get_tree().process_frame

	assert_eq(tutorial_manager.current_tutorial, "", "Current tutorial should remain empty for invalid ID")


func test_start_completed_tutorial_does_nothing() -> void:
	tutorial_manager.mark_tutorial_completed("gate_control")
	tutorial_manager.tutorial_started.connect(_on_tutorial_started)

	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	assert_false(test_tutorial_started_called, "Completed tutorial should not start again")


# ==================== TUTORIAL STEP TESTS ====================


func test_advance_tutorial_step_increments_step() -> void:
	tutorial_manager.start_tutorial("rules_checking")  # Has 2 steps
	await get_tree().process_frame

	var initial_step = tutorial_manager.current_step
	tutorial_manager.advance_tutorial_step()
	await get_tree().process_frame

	assert_eq(tutorial_manager.current_step, initial_step + 1, "Step should increment")


func test_tutorial_step_completed_emits_signal() -> void:
	tutorial_manager.tutorial_step_completed.connect(_on_step_completed)
	tutorial_manager.start_tutorial("rules_checking")
	await get_tree().process_frame

	test_step_completed_called = false
	tutorial_manager.advance_tutorial_step()
	await get_tree().process_frame

	assert_true(test_step_completed_called, "tutorial_step_completed signal should be emitted")
	assert_eq(last_step_index, 0, "First step index should be 0")


func test_trigger_tutorial_action_advances_step() -> void:
	tutorial_manager.start_tutorial("gate_control")  # Has "lever_pulled" action
	await get_tree().process_frame

	var initial_step = tutorial_manager.current_step
	tutorial_manager.trigger_tutorial_action("lever_pulled")
	await get_tree().process_frame

	assert_eq(tutorial_manager.current_step, initial_step + 1, "Action should advance step")


func test_trigger_wrong_action_does_nothing() -> void:
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	var initial_step = tutorial_manager.current_step
	tutorial_manager.trigger_tutorial_action("wrong_action")
	await get_tree().process_frame

	assert_eq(tutorial_manager.current_step, initial_step, "Wrong action should not advance step")


# ==================== TUTORIAL COMPLETION TESTS ====================


func test_complete_tutorial_emits_signal() -> void:
	tutorial_manager.tutorial_completed.connect(_on_tutorial_completed)
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	tutorial_manager.complete_tutorial()
	await get_tree().process_frame

	assert_true(test_tutorial_completed_called, "tutorial_completed signal should be emitted")
	assert_eq(last_tutorial_id, "gate_control", "Completed tutorial ID should match")


func test_complete_tutorial_marks_as_completed() -> void:
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	tutorial_manager.complete_tutorial()
	await get_tree().process_frame

	assert_true(
		tutorial_manager.is_tutorial_completed("gate_control"),
		"Tutorial should be marked as completed"
	)


func test_complete_tutorial_resets_current_tutorial() -> void:
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	tutorial_manager.complete_tutorial()
	await get_tree().process_frame

	assert_eq(tutorial_manager.current_tutorial, "", "Current tutorial should be reset")
	assert_eq(tutorial_manager.current_step, 0, "Current step should be reset")


func test_complete_tutorial_cleans_up_overlay() -> void:
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	# Overlay should exist
	assert_not_null(tutorial_manager.tutorial_overlay, "Overlay should exist during tutorial")

	tutorial_manager.complete_tutorial()
	await get_tree().process_frame

	assert_null(tutorial_manager.tutorial_overlay, "Overlay should be cleaned up after completion")


# ==================== TUTORIAL SKIPPING TESTS ====================


func test_skip_tutorial_emits_signal() -> void:
	tutorial_manager.can_skip_tutorials = true
	tutorial_manager.tutorial_skipped.connect(_on_tutorial_skipped)
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	tutorial_manager.skip_current_tutorial()
	await get_tree().process_frame

	assert_true(test_tutorial_skipped_called, "tutorial_skipped signal should be emitted")
	assert_eq(last_tutorial_id, "gate_control", "Skipped tutorial ID should match")


func test_skip_tutorial_does_not_mark_completed() -> void:
	tutorial_manager.can_skip_tutorials = true
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	tutorial_manager.skip_current_tutorial()
	await get_tree().process_frame

	assert_false(
		tutorial_manager.is_tutorial_completed("gate_control"),
		"Skipped tutorial should not be marked as completed"
	)


func test_skip_tutorial_resets_state() -> void:
	tutorial_manager.can_skip_tutorials = true
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	tutorial_manager.skip_current_tutorial()
	await get_tree().process_frame

	assert_eq(tutorial_manager.current_tutorial, "", "Current tutorial should be reset after skip")
	assert_eq(tutorial_manager.current_step, 0, "Current step should be reset after skip")


# ==================== SHIFT TRIGGER TESTS ====================


func test_check_shift_tutorials_triggers_appropriate_tutorial() -> void:
	tutorial_manager.tutorial_started.connect(_on_tutorial_started)

	# Gate control has shift_trigger = 1
	tutorial_manager.check_shift_tutorials(1)
	await get_tree().process_frame

	assert_true(test_tutorial_started_called, "Tutorial should start for matching shift")
	# Should be one of the shift 1 tutorials
	assert_true(
		last_tutorial_id in ["gate_control", "megaphone_call", "document_inspection", "stamp_usage", "border_runners"],
		"Should start a shift 1 tutorial"
	)


func test_check_shift_tutorials_does_not_trigger_for_wrong_shift() -> void:
	tutorial_manager.tutorial_started.connect(_on_tutorial_started)

	# No tutorials for shift 10
	tutorial_manager.check_shift_tutorials(10)
	await get_tree().process_frame

	assert_false(test_tutorial_started_called, "Tutorial should not start for shift without tutorials")


func test_check_shift_tutorials_skips_completed_tutorials() -> void:
	# Mark all shift 1 tutorials as completed
	tutorial_manager.mark_tutorial_completed("gate_control")
	tutorial_manager.mark_tutorial_completed("megaphone_call")
	tutorial_manager.mark_tutorial_completed("document_inspection")
	tutorial_manager.mark_tutorial_completed("stamp_usage")
	tutorial_manager.mark_tutorial_completed("border_runners")

	tutorial_manager.tutorial_started.connect(_on_tutorial_started)
	tutorial_manager.check_shift_tutorials(1)
	await get_tree().process_frame

	assert_false(test_tutorial_started_called, "No tutorial should start if all are completed")


func test_check_shift_tutorials_respects_enabled_flag() -> void:
	tutorial_manager.set_tutorials_enabled(false)
	tutorial_manager.tutorial_started.connect(_on_tutorial_started)

	tutorial_manager.check_shift_tutorials(1)
	await get_tree().process_frame

	assert_false(test_tutorial_started_called, "Tutorials should not start when disabled")


# ==================== ENABLE/DISABLE TESTS ====================


func test_set_tutorials_enabled() -> void:
	tutorial_manager.set_tutorials_enabled(false)
	assert_false(tutorial_manager.tutorial_enabled, "Tutorials should be disabled")

	tutorial_manager.set_tutorials_enabled(true)
	assert_true(tutorial_manager.tutorial_enabled, "Tutorials should be enabled")


# ==================== COMPLETION TRACKING TESTS ====================


func test_is_tutorial_completed_returns_false_initially() -> void:
	assert_false(
		tutorial_manager.is_tutorial_completed("gate_control"),
		"Tutorial should not be completed initially"
	)


func test_mark_tutorial_completed() -> void:
	tutorial_manager.mark_tutorial_completed("gate_control")
	assert_true(
		tutorial_manager.is_tutorial_completed("gate_control"),
		"Tutorial should be marked as completed"
	)


func test_reset_all_tutorials_clears_progress() -> void:
	tutorial_manager.mark_tutorial_completed("gate_control")
	tutorial_manager.mark_tutorial_completed("megaphone_call")

	tutorial_manager.reset_all_tutorials()

	assert_false(
		tutorial_manager.is_tutorial_completed("gate_control"),
		"All tutorials should be unmarked after reset"
	)
	assert_false(
		tutorial_manager.is_tutorial_completed("megaphone_call"),
		"All tutorials should be unmarked after reset"
	)


func test_get_tutorial_completion_percentage_zero_initially() -> void:
	var percentage = tutorial_manager.get_tutorial_completion_percentage()
	assert_eq(percentage, 0.0, "Completion percentage should be 0% initially")


func test_get_tutorial_completion_percentage_calculates_correctly() -> void:
	var total_tutorials = tutorial_manager.TUTORIALS.size()

	# Complete half the tutorials (rounded down)
	var tutorials_to_complete = int(total_tutorials / 2)
	var completed = 0
	for tutorial_id in tutorial_manager.TUTORIALS:
		if completed >= tutorials_to_complete:
			break
		tutorial_manager.mark_tutorial_completed(tutorial_id)
		completed += 1

	var expected_percentage = (float(tutorials_to_complete) / float(total_tutorials)) * 100.0
	var actual_percentage = tutorial_manager.get_tutorial_completion_percentage()

	assert_almost_eq(
		actual_percentage,
		expected_percentage,
		0.1,
		"Completion percentage should match completed tutorials"
	)


func test_get_tutorial_completion_percentage_one_hundred_when_all_complete() -> void:
	# Complete all tutorials
	for tutorial_id in tutorial_manager.TUTORIALS:
		tutorial_manager.mark_tutorial_completed(tutorial_id)

	var percentage = tutorial_manager.get_tutorial_completion_percentage()
	assert_eq(percentage, 100.0, "Completion percentage should be 100% when all complete")


# ==================== TEST SIGNAL HANDLERS ====================


func _on_tutorial_started(tutorial_id: String) -> void:
	test_tutorial_started_called = true
	last_tutorial_id = tutorial_id


func _on_tutorial_completed(tutorial_id: String) -> void:
	test_tutorial_completed_called = true
	last_tutorial_id = tutorial_id


func _on_tutorial_skipped(tutorial_id: String) -> void:
	test_tutorial_skipped_called = true
	last_tutorial_id = tutorial_id


func _on_step_completed(tutorial_id: String, step_index: int) -> void:
	test_step_completed_called = true
	last_tutorial_id = tutorial_id
	last_step_index = step_index
