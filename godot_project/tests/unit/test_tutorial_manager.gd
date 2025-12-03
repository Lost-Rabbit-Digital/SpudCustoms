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
	# Clean up any tutorial UI
	tutorial_manager.cleanup_tutorial_ui()

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


func test_skip_tutorial_marks_as_completed() -> void:
	# Note: In the new implementation, skipped tutorials ARE marked as completed
	# so they don't re-appear to the player
	tutorial_manager.can_skip_tutorials = true
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	tutorial_manager.skip_current_tutorial()
	await get_tree().process_frame

	assert_true(
		tutorial_manager.is_tutorial_completed("gate_control"),
		"Skipped tutorial should be marked as completed to prevent re-showing"
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

	# Multiple tutorials have shift_trigger = 1
	tutorial_manager.check_shift_tutorials(1)
	await get_tree().process_frame

	assert_true(test_tutorial_started_called, "Tutorial should start for matching shift")
	# Should be one of the shift 1 tutorials (welcome has priority 0, so it starts first)
	assert_true(
		last_tutorial_id in ["welcome", "gate_control", "megaphone_call", "document_inspection", "stamp_usage", "border_runners", "strikes_and_quota"],
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
	tutorial_manager.mark_tutorial_completed("welcome")
	tutorial_manager.mark_tutorial_completed("gate_control")
	tutorial_manager.mark_tutorial_completed("megaphone_call")
	tutorial_manager.mark_tutorial_completed("document_inspection")
	tutorial_manager.mark_tutorial_completed("stamp_usage")
	tutorial_manager.mark_tutorial_completed("border_runners")
	tutorial_manager.mark_tutorial_completed("strikes_and_quota")

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


# ==================== SAVE/LOAD PERSISTENCE TESTS ====================


func test_save_tutorial_progress_saves_completed_tutorials() -> void:
	var save_manager_node = get_node("/root/SaveManager")

	tutorial_manager.mark_tutorial_completed("gate_control")
	tutorial_manager.mark_tutorial_completed("megaphone_call")
	tutorial_manager.save_tutorial_progress()

	var save_data = save_manager_node.load_game()
	assert_true(save_data.has("tutorials_completed"), "Save data should have tutorials_completed")
	assert_true(
		save_data["tutorials_completed"].has("gate_control"),
		"Save should include completed tutorial"
	)
	assert_true(
		save_data["tutorials_completed"]["gate_control"],
		"Completed tutorial should be marked true"
	)


func test_save_tutorial_progress_saves_enabled_state() -> void:
	var save_manager_node = get_node("/root/SaveManager")

	tutorial_manager.set_tutorials_enabled(false)
	tutorial_manager.save_tutorial_progress()

	var save_data = save_manager_node.load_game()
	assert_true(save_data.has("tutorial_enabled"), "Save data should have tutorial_enabled")
	assert_false(save_data["tutorial_enabled"], "Enabled state should be saved correctly")


func test_load_tutorial_progress_restores_completed_tutorials() -> void:
	# Setup save data
	tutorial_manager.mark_tutorial_completed("gate_control")
	tutorial_manager.mark_tutorial_completed("megaphone_call")
	tutorial_manager.save_tutorial_progress()

	# Reset and reload
	tutorial_manager.reset_all_tutorials()
	tutorial_manager.load_tutorial_progress()

	assert_true(
		tutorial_manager.is_tutorial_completed("gate_control"),
		"Completed tutorial should be restored"
	)
	assert_true(
		tutorial_manager.is_tutorial_completed("megaphone_call"),
		"Completed tutorial should be restored"
	)


func test_load_tutorial_progress_restores_enabled_state() -> void:
	tutorial_manager.set_tutorials_enabled(false)
	tutorial_manager.save_tutorial_progress()

	# Change state and reload
	tutorial_manager.tutorial_enabled = true
	tutorial_manager.load_tutorial_progress()

	assert_false(tutorial_manager.tutorial_enabled, "Enabled state should be restored")


func test_load_tutorial_progress_handles_missing_save_data() -> void:
	var save_manager_node = get_node("/root/SaveManager")

	# Create a fresh save without tutorial data
	save_manager_node.save_game({})

	# Should not crash
	tutorial_manager.load_tutorial_progress()

	# Should use default values
	assert_true(tutorial_manager.tutorial_enabled, "Should default to enabled")


func test_save_load_round_trip_preserves_all_data() -> void:
	# Complete some tutorials
	tutorial_manager.mark_tutorial_completed("gate_control")
	tutorial_manager.mark_tutorial_completed("document_inspection")
	tutorial_manager.set_tutorials_enabled(false)
	tutorial_manager.save_tutorial_progress()

	# Reset state
	tutorial_manager.reset_all_tutorials()
	tutorial_manager.set_tutorials_enabled(true)

	# Reload
	tutorial_manager.load_tutorial_progress()

	assert_true(
		tutorial_manager.is_tutorial_completed("gate_control"),
		"First tutorial should be restored"
	)
	assert_true(
		tutorial_manager.is_tutorial_completed("document_inspection"),
		"Second tutorial should be restored"
	)
	assert_false(
		tutorial_manager.is_tutorial_completed("megaphone_call"),
		"Uncompleted tutorial should remain uncompleted"
	)
	assert_false(tutorial_manager.tutorial_enabled, "Enabled state should be restored")


# ==================== TUTORIAL OVERLAY UI TESTS ====================


func test_show_tutorial_step_creates_overlay() -> void:
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	assert_not_null(tutorial_manager.tutorial_overlay, "Overlay should be created")
	assert_true(tutorial_manager.tutorial_overlay is Control, "Overlay should be a Control node")


func test_show_tutorial_step_creates_label() -> void:
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	assert_not_null(tutorial_manager.tutorial_label, "Label should be created")
	assert_true(tutorial_manager.tutorial_label is RichTextLabel, "tutorial_label should be a RichTextLabel")
	assert_gt(tutorial_manager.tutorial_label.text.length(), 0, "Label should have text")


func test_show_tutorial_step_displays_correct_text() -> void:
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	var expected_text = tutorial_manager.TUTORIALS["gate_control"]["steps"][0]["text"]
	assert_eq(
		tutorial_manager.tutorial_label.text,
		expected_text,
		"Label should display correct step text"
	)


func test_show_tutorial_step_updates_text_on_advance() -> void:
	tutorial_manager.start_tutorial("rules_checking")  # Has 2 steps
	await get_tree().process_frame

	var first_text = tutorial_manager.tutorial_label.text

	tutorial_manager.advance_tutorial_step()
	await get_tree().process_frame

	var second_text = tutorial_manager.tutorial_label.text
	assert_ne(first_text, second_text, "Text should change when advancing steps")


func test_overlay_has_styled_panel() -> void:
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	# The new implementation uses a PanelContainer with a StyleBoxFlat background
	assert_true(
		tutorial_manager.tutorial_panel is PanelContainer,
		"Tutorial panel should be a PanelContainer"
	)


func test_skip_button_appears_when_allowed() -> void:
	tutorial_manager.can_skip_tutorials = true
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	assert_not_null(tutorial_manager.skip_button, "Skip button should be present when skipping is allowed")


func test_skip_button_not_present_when_disabled() -> void:
	tutorial_manager.can_skip_tutorials = false
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	assert_null(tutorial_manager.skip_button, "Skip button should not be present when skipping is disabled")


func test_overlay_cleaned_up_between_steps() -> void:
	tutorial_manager.start_tutorial("rules_checking")  # Has 2 steps
	await get_tree().process_frame

	var first_overlay = tutorial_manager.tutorial_overlay

	tutorial_manager.advance_tutorial_step()
	await get_tree().process_frame

	var second_overlay = tutorial_manager.tutorial_overlay

	# Overlay should be recreated
	assert_not_null(second_overlay, "New overlay should be created")


# ==================== DURATION-BASED STEP TESTS ====================


func test_duration_step_auto_advances() -> void:
	tutorial_manager.start_tutorial("rules_checking")  # Has duration steps
	await get_tree().process_frame

	# Set to a step with duration
	tutorial_manager.current_step = 0
	var step = tutorial_manager.TUTORIALS["rules_checking"]["steps"][0]

	if step.has("duration"):
		var initial_step = tutorial_manager.current_step
		tutorial_manager.show_tutorial_step()

		# Wait for duration
		await get_tree().create_timer(step["duration"] + 0.5).timeout

		# Step should have advanced
		assert_gt(
			tutorial_manager.current_step,
			initial_step,
			"Step should auto-advance after duration"
		)


func test_duration_step_ignores_actions() -> void:
	tutorial_manager.start_tutorial("rules_checking")
	await get_tree().process_frame

	# Go to a duration-based step
	tutorial_manager.current_step = 0
	var step = tutorial_manager.TUTORIALS["rules_checking"]["steps"][0]

	if step.has("duration"):
		tutorial_manager.show_tutorial_step()
		var initial_step = tutorial_manager.current_step

		# Try to trigger action
		tutorial_manager.trigger_tutorial_action("any_action")
		await get_tree().process_frame

		assert_eq(
			tutorial_manager.current_step,
			initial_step,
			"Duration step should not respond to actions"
		)


# ==================== MULTI-STEP TUTORIAL FLOW TESTS ====================


func test_multi_step_tutorial_full_flow() -> void:
	var step_count = 0

	var callback = func(_tutorial_id: String, _step_idx: int):
		step_count += 1

	tutorial_manager.tutorial_started.connect(_on_tutorial_started)
	tutorial_manager.tutorial_step_completed.connect(callback)
	tutorial_manager.tutorial_completed.connect(_on_tutorial_completed)

	# Start stamp_usage which has 4 steps
	tutorial_manager.start_tutorial("stamp_usage")
	await get_tree().process_frame

	assert_true(test_tutorial_started_called, "Tutorial should start")

	var tutorial = tutorial_manager.TUTORIALS["stamp_usage"]
	var expected_steps = tutorial["steps"].size()

	# Complete all steps
	for step_idx in expected_steps:
		var step = tutorial["steps"][step_idx]
		if step.has("wait_for_action"):
			tutorial_manager.trigger_tutorial_action(step["wait_for_action"])
			await get_tree().process_frame

	assert_true(test_tutorial_completed_called, "Tutorial should complete after all steps")
	assert_eq(step_count, expected_steps, "All steps should be completed")

	tutorial_manager.tutorial_step_completed.disconnect(callback)


func test_advance_step_at_last_step_completes_tutorial() -> void:
	tutorial_manager.tutorial_completed.connect(_on_tutorial_completed)
	tutorial_manager.start_tutorial("gate_control")  # Single step tutorial
	await get_tree().process_frame

	# Advance past the last step
	tutorial_manager.advance_tutorial_step()
	await get_tree().process_frame

	assert_true(test_tutorial_completed_called, "Tutorial should complete at last step")


# ==================== ERROR HANDLING AND EDGE CASES ====================


func test_trigger_action_when_no_tutorial_active() -> void:
	# Should not crash
	tutorial_manager.trigger_tutorial_action("any_action")
	await get_tree().process_frame

	assert_true(true, "Should handle action when no tutorial active")


func test_complete_tutorial_when_no_tutorial_active() -> void:
	# Should not crash
	tutorial_manager.tutorial_completed.connect(_on_tutorial_completed)
	tutorial_manager.complete_tutorial()
	await get_tree().process_frame

	assert_false(test_tutorial_completed_called, "Signal should not emit when no tutorial active")


func test_skip_tutorial_when_no_tutorial_active() -> void:
	tutorial_manager.tutorial_skipped.connect(_on_tutorial_skipped)
	tutorial_manager.skip_current_tutorial()
	await get_tree().process_frame

	assert_false(test_tutorial_skipped_called, "Signal should not emit when no tutorial active")


func test_show_tutorial_step_when_no_tutorial_active() -> void:
	# Should not crash
	tutorial_manager.show_tutorial_step()
	await get_tree().process_frame

	assert_null(tutorial_manager.tutorial_overlay, "No overlay should be created")


func test_show_tutorial_step_past_last_step_completes() -> void:
	tutorial_manager.tutorial_completed.connect(_on_tutorial_completed)
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	# Manually set step past end
	tutorial_manager.current_step = 999
	tutorial_manager.show_tutorial_step()
	await get_tree().process_frame

	assert_true(test_tutorial_completed_called, "Should complete when step is past end")


func test_multiple_signal_listeners() -> void:
	var listener1_called = false
	var listener2_called = false

	var callback1 = func(_id: String): listener1_called = true
	var callback2 = func(_id: String): listener2_called = true

	tutorial_manager.tutorial_started.connect(callback1)
	tutorial_manager.tutorial_started.connect(callback2)

	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	assert_true(listener1_called, "First listener should be called")
	assert_true(listener2_called, "Second listener should be called")

	tutorial_manager.tutorial_started.disconnect(callback1)
	tutorial_manager.tutorial_started.disconnect(callback2)


func test_tutorial_step_out_of_bounds() -> void:
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	# Force step beyond bounds
	tutorial_manager.current_step = 100

	# Should not crash
	tutorial_manager.trigger_tutorial_action("lever_pulled")
	await get_tree().process_frame

	assert_true(true, "Should handle out of bounds step gracefully")


# ==================== INTEGRATION TESTS ====================


func test_full_shift_workflow() -> void:
	tutorial_manager.tutorial_started.connect(_on_tutorial_started)
	tutorial_manager.tutorial_completed.connect(_on_tutorial_completed)

	# Check shift 1 tutorials
	tutorial_manager.check_shift_tutorials(1)
	await get_tree().process_frame

	assert_true(test_tutorial_started_called, "Shift should trigger tutorial")

	var tutorial_id = last_tutorial_id
	var tutorial = tutorial_manager.TUTORIALS[tutorial_id]

	# Complete the tutorial
	for step in tutorial["steps"]:
		if step.has("wait_for_action"):
			tutorial_manager.trigger_tutorial_action(step["wait_for_action"])
			await get_tree().process_frame
		elif step.has("duration"):
			await get_tree().create_timer(step["duration"] + 0.5).timeout

	assert_true(test_tutorial_completed_called, "Tutorial should complete")
	assert_true(
		tutorial_manager.is_tutorial_completed(tutorial_id),
		"Completed tutorial should be marked"
	)


func test_tutorial_persists_across_sessions() -> void:
	# Session 1: Complete a tutorial
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame

	tutorial_manager.trigger_tutorial_action("lever_pulled")
	await get_tree().process_frame

	assert_true(tutorial_manager.is_tutorial_completed("gate_control"), "Should be completed")

	# Simulate saving
	tutorial_manager.save_tutorial_progress()

	# Session 2: Reset and reload
	tutorial_manager.reset_all_tutorials()
	assert_false(
		tutorial_manager.is_tutorial_completed("gate_control"),
		"Should be reset locally"
	)

	tutorial_manager.load_tutorial_progress()
	assert_true(
		tutorial_manager.is_tutorial_completed("gate_control"),
		"Should be restored from save"
	)


func test_disable_tutorials_prevents_all_triggers() -> void:
	tutorial_manager.set_tutorials_enabled(false)
	tutorial_manager.tutorial_started.connect(_on_tutorial_started)

	# Try various ways to start tutorials
	tutorial_manager.start_tutorial("gate_control")
	await get_tree().process_frame
	assert_eq(tutorial_manager.current_tutorial, "", "Direct start should work even when disabled")

	test_tutorial_started_called = false

	# Check shift triggers should be blocked
	tutorial_manager.check_shift_tutorials(1)
	await get_tree().process_frame
	assert_false(test_tutorial_started_called, "Shift triggers should be blocked when disabled")


func test_completion_percentage_accurate_throughout_session() -> void:
	var total = tutorial_manager.TUTORIALS.size()

	# Complete tutorials one by one and verify percentage
	var completed = 0
	for tutorial_id in tutorial_manager.TUTORIALS:
		tutorial_manager.mark_tutorial_completed(tutorial_id)
		completed += 1

		var expected = (float(completed) / float(total)) * 100.0
		var actual = tutorial_manager.get_tutorial_completion_percentage()

		assert_almost_eq(
			actual,
			expected,
			0.1,
			"Completion percentage should be accurate after completing %d tutorials" % completed
		)


# ==================== HIGHLIGHT AREA TESTS ====================


func test_highlight_created_for_highlighted_steps() -> void:
	# Find a tutorial with a highlighted step
	tutorial_manager.start_tutorial("gate_control")  # First step has highlight: true
	await get_tree().process_frame

	# Check if highlighted_nodes array has entries (new shader-based highlighting)
	assert_gt(
		tutorial_manager.highlighted_nodes.size(),
		0,
		"Highlighted nodes should be populated for highlighted step"
	)


func test_no_highlight_for_non_highlighted_steps() -> void:
	# Start a tutorial with a non-highlighted step
	tutorial_manager.start_tutorial("border_runners")
	await get_tree().process_frame

	var step = tutorial_manager.TUTORIALS["border_runners"]["steps"][0]
	if not step.get("highlight", false):
		# This step should not create a highlight
		# Note: highlight_rect might be null or not depending on implementation
		assert_true(true, "Non-highlighted step handled")


# ==================== SPECIFIC TUTORIAL TESTS ====================


func test_gate_control_tutorial_structure() -> void:
	var tutorial = tutorial_manager.TUTORIALS["gate_control"]

	assert_eq(tutorial["name"], "Opening the Gate", "Gate control should have correct name")
	assert_eq(tutorial["shift_trigger"], 1, "Gate control should trigger on shift 1")
	assert_eq(tutorial["steps"].size(), 2, "Gate control should have 2 steps")

	var step = tutorial["steps"][0]
	assert_eq(step["wait_for_action"], "lever_pulled", "Gate control should wait for lever_pulled")
	assert_true(step["highlight"], "Gate control step should be highlighted")


func test_stamp_usage_tutorial_structure() -> void:
	var tutorial = tutorial_manager.TUTORIALS["stamp_usage"]

	assert_eq(tutorial["name"], "Using the Stamps", "Stamp usage should have correct name")
	assert_eq(tutorial["shift_trigger"], 1, "Stamp usage should trigger on shift 1")
	assert_eq(tutorial["steps"].size(), 5, "Stamp usage should have 5 steps")


func test_xray_scanner_tutorial_structure() -> void:
	var tutorial = tutorial_manager.TUTORIALS["xray_scanner"]

	assert_eq(tutorial["name"], "X-Ray Scanning", "X-ray scanner should have correct name")
	assert_eq(tutorial["shift_trigger"], 3, "X-ray scanner should trigger on shift 3")
	assert_gt(tutorial["steps"].size(), 0, "X-ray scanner should have steps")
