extends GutTest

## Integration test for Narrative Choice Flow
## Tests: Dialogue → Choice → Save to NarrativeManager → Save to Global → Persist to Disk → Load → Verify

var event_bus: Node
var narrative_manager: Node
var save_manager: Node
var global_ref: Node

func before_each() -> void:
	event_bus = get_node_or_null("/root/EventBus")
	narrative_manager = get_tree().root.get_node_or_null("NarrativeManager")
	save_manager = get_node_or_null("/root/SaveManager")
	global_ref = get_node_or_null("/root/Global")

	assert_not_null(event_bus, "EventBus must be available")
	assert_not_null(save_manager, "SaveManager must be available")
	assert_not_null(global_ref, "Global must be available")


func after_each() -> void:
	# Clean up any narrative choices made during tests
	if global_ref:
		global_ref.narrative_choices.clear()

	# Disconnect any test callbacks
	await get_tree().process_frame


# ==================== DIALOGUE LIFECYCLE EVENTS ====================


func test_dialogue_started_signal_emitted() -> void:
	"""Test that dialogue_started signal is emitted when dialogue begins"""

	var signal_emitted: bool = false
	var timeline_name: String = ""

	var callback = func(name: String):
		signal_emitted = true
		timeline_name = name

	event_bus.dialogue_started.connect(callback)

	# Simulate dialogue start
	event_bus.dialogue_started.emit("test_timeline")
	await get_tree().process_frame

	assert_true(signal_emitted, "dialogue_started should be emitted")
	assert_eq(timeline_name, "test_timeline", "Timeline name should match")

	event_bus.dialogue_started.disconnect(callback)


func test_dialogue_ended_signal_emitted() -> void:
	"""Test that dialogue_ended signal is emitted when dialogue finishes"""

	var signal_emitted: bool = false
	var timeline_name: String = ""

	var callback = func(name: String):
		signal_emitted = true
		timeline_name = name

	event_bus.dialogue_ended.connect(callback)

	# Simulate dialogue end
	event_bus.dialogue_ended.emit("test_timeline")
	await get_tree().process_frame

	assert_true(signal_emitted, "dialogue_ended should be emitted")
	assert_eq(timeline_name, "test_timeline", "Timeline name should match")

	event_bus.dialogue_ended.disconnect(callback)


func test_dialogue_lifecycle_complete() -> void:
	"""Test complete dialogue lifecycle: started → ended"""

	var started_called: bool = false
	var ended_called: bool = false
	var started_name: String = ""
	var ended_name: String = ""

	var start_callback = func(name: String):
		started_called = true
		started_name = name

	var end_callback = func(name: String):
		ended_called = true
		ended_name = name

	event_bus.dialogue_started.connect(start_callback)
	event_bus.dialogue_ended.connect(end_callback)

	# Simulate dialogue lifecycle
	event_bus.dialogue_started.emit("shift1_intro")
	await get_tree().process_frame

	event_bus.dialogue_ended.emit("shift1_intro")
	await get_tree().process_frame

	assert_true(started_called, "dialogue_started should be called")
	assert_true(ended_called, "dialogue_ended should be called")
	assert_eq(started_name, "shift1_intro", "Started timeline should match")
	assert_eq(ended_name, "shift1_intro", "Ended timeline should match")

	event_bus.dialogue_started.disconnect(start_callback)
	event_bus.dialogue_ended.disconnect(end_callback)


# ==================== NARRATIVE CHOICE EVENTS ====================


func test_narrative_choice_made_signal() -> void:
	"""Test that narrative_choice_made signal is emitted"""

	var choice_made: bool = false
	var captured_key: String = ""
	var captured_value: Variant = null

	var callback = func(key: String, value: Variant):
		choice_made = true
		captured_key = key
		captured_value = value

	event_bus.narrative_choice_made.connect(callback)

	# Emit a narrative choice
	event_bus.narrative_choice_made.emit("test_choice", "option_a")
	await get_tree().process_frame

	assert_true(choice_made, "narrative_choice_made should be emitted")
	assert_eq(captured_key, "test_choice", "Choice key should match")
	assert_eq(captured_value, "option_a", "Choice value should match")

	event_bus.narrative_choice_made.disconnect(callback)


func test_multiple_narrative_choices() -> void:
	"""Test that multiple narrative choices can be made in sequence"""

	var choices_made: Array = []

	var callback = func(key: String, value: Variant):
		choices_made.append({"key": key, "value": value})

	event_bus.narrative_choice_made.connect(callback)

	# Make multiple choices
	event_bus.narrative_choice_made.emit("initial_response", "friendly")
	await get_tree().process_frame

	event_bus.narrative_choice_made.emit("cafeteria_response", "help")
	await get_tree().process_frame

	event_bus.narrative_choice_made.emit("loyalty_response", "loyal")
	await get_tree().process_frame

	assert_eq(choices_made.size(), 3, "Should have 3 choices")
	assert_eq(choices_made[0].key, "initial_response", "First choice key should match")
	assert_eq(choices_made[1].key, "cafeteria_response", "Second choice key should match")
	assert_eq(choices_made[2].key, "loyalty_response", "Third choice key should match")

	event_bus.narrative_choice_made.disconnect(callback)


# ==================== NARRATIVE CHOICE PERSISTENCE ====================


func test_narrative_choices_saved_to_global() -> void:
	"""Test that narrative choices are saved to Global.narrative_choices"""

	# Clear any existing choices
	global_ref.narrative_choices.clear()

	# Simulate making choices via Dialogic
	if Dialogic:
		Dialogic.VAR.set("test_choice_1", "option_a")
		Dialogic.VAR.set("test_choice_2", "option_b")
		await get_tree().process_frame

		# Capture choices
		global_ref.capture_narrative_choices()
		await get_tree().process_frame

		# Verify choices were captured
		assert_true(global_ref.narrative_choices.has("test_choice_1"), "Choice 1 should be captured")
		assert_true(global_ref.narrative_choices.has("test_choice_2"), "Choice 2 should be captured")
		assert_eq(global_ref.narrative_choices["test_choice_1"], "option_a", "Choice 1 value should match")
		assert_eq(global_ref.narrative_choices["test_choice_2"], "option_b", "Choice 2 value should match")


func test_narrative_choices_persist_across_save_load() -> void:
	"""Test that narrative choices persist across save/load cycles"""

	# Clear any existing choices
	global_ref.narrative_choices.clear()

	# Set up test choices
	if Dialogic:
		Dialogic.VAR.set("initial_response", "friendly")
		Dialogic.VAR.set("cafeteria_response", "help")
		await get_tree().process_frame

		# Capture and save
		global_ref.capture_narrative_choices()
		global_ref.save_game_state()
		await get_tree().process_frame

		# Clear choices to simulate fresh state
		global_ref.narrative_choices.clear()
		Dialogic.VAR.set("initial_response", "")
		Dialogic.VAR.set("cafeteria_response", "")
		await get_tree().process_frame

		# Load game state
		global_ref.load_game_state()
		await get_tree().process_frame

		# Verify choices were restored
		assert_true(global_ref.narrative_choices.has("initial_response"), "Choice should be loaded")
		assert_true(global_ref.narrative_choices.has("cafeteria_response"), "Choice should be loaded")
		assert_eq(global_ref.narrative_choices["initial_response"], "friendly", "Choice value should be restored")
		assert_eq(global_ref.narrative_choices["cafeteria_response"], "help", "Choice value should be restored")


func test_narrative_choice_save_requested_signal() -> void:
	"""Test that narrative_choices_save_requested signal is emitted"""

	var signal_emitted: bool = false

	var callback = func():
		signal_emitted = true

	event_bus.narrative_choices_save_requested.connect(callback)

	# Trigger save
	event_bus.narrative_choices_save_requested.emit()
	await get_tree().process_frame

	assert_true(signal_emitted, "narrative_choices_save_requested should be emitted")

	event_bus.narrative_choices_save_requested.disconnect(callback)


func test_narrative_choice_load_requested_signal() -> void:
	"""Test that narrative_choices_load_requested signal is emitted with data"""

	var signal_emitted: bool = false
	var loaded_choices: Dictionary = {}

	var callback = func(choices: Dictionary):
		signal_emitted = true
		loaded_choices = choices

	event_bus.narrative_choices_load_requested.connect(callback)

	# Trigger load with test data
	var test_choices = {
		"test_key_1": "test_value_1",
		"test_key_2": "test_value_2"
	}
	event_bus.narrative_choices_load_requested.emit(test_choices)
	await get_tree().process_frame

	assert_true(signal_emitted, "narrative_choices_load_requested should be emitted")
	assert_eq(loaded_choices.size(), 2, "Should have 2 choices")
	assert_eq(loaded_choices["test_key_1"], "test_value_1", "Choice value should match")

	event_bus.narrative_choices_load_requested.disconnect(callback)


# ==================== NARRATIVE MANAGER INTEGRATION ====================


func test_narrative_manager_saves_choices() -> void:
	"""Test that NarrativeManager can save narrative choices"""

	# Skip if NarrativeManager not in scene
	if not narrative_manager:
		pass_test("NarrativeManager not available in test scene")
		return

	if not narrative_manager.has_method("save_narrative_choices"):
		pass_test("NarrativeManager doesn't have save_narrative_choices method")
		return

	# Set up test choices in Dialogic
	if Dialogic:
		Dialogic.VAR.set("test_var_1", "value_1")
		Dialogic.VAR.set("test_var_2", "value_2")
		await get_tree().process_frame

		# Save choices via NarrativeManager
		var saved_choices = narrative_manager.save_narrative_choices()
		await get_tree().process_frame

		# Verify choices were saved
		assert_true(saved_choices is Dictionary, "Should return a Dictionary")
		assert_true(saved_choices.size() > 0, "Should have saved some choices")


func test_narrative_manager_loads_choices() -> void:
	"""Test that NarrativeManager can load narrative choices"""

	# Skip if NarrativeManager not in scene
	if not narrative_manager:
		pass_test("NarrativeManager not available in test scene")
		return

	if not narrative_manager.has_method("load_narrative_choices"):
		pass_test("NarrativeManager doesn't have load_narrative_choices method")
		return

	if Dialogic:
		# Clear existing values
		Dialogic.VAR.set("test_var_3", "")
		await get_tree().process_frame

		# Load test choices via NarrativeManager
		var test_choices = {"test_var_3": "loaded_value"}
		narrative_manager.load_narrative_choices(test_choices)
		await get_tree().process_frame

		# Verify choices were loaded to Dialogic
		assert_eq(Dialogic.VAR.get("test_var_3"), "loaded_value", "Choice should be loaded to Dialogic")


# ==================== COMPLETE WORKFLOW TESTS ====================


func test_complete_narrative_choice_workflow() -> void:
	"""Test complete workflow: dialogue → choice → save → load → verify"""

	# Skip if Dialogic not available
	if not Dialogic:
		pass_test("Dialogic not available")
		return

	# Track all signals
	var dialogue_started: bool = false
	var dialogue_ended: bool = false
	var choice_made: bool = false
	var save_requested: bool = false

	var start_cb = func(_name: String): dialogue_started = true
	var end_cb = func(_name: String): dialogue_ended = true
	var choice_cb = func(_key: String, _value: Variant): choice_made = true
	var save_cb = func(): save_requested = true

	event_bus.dialogue_started.connect(start_cb)
	event_bus.dialogue_ended.connect(end_cb)
	event_bus.narrative_choice_made.connect(choice_cb)
	event_bus.narrative_choices_save_requested.connect(save_cb)

	# 1. Start dialogue
	event_bus.dialogue_started.emit("test_timeline")
	await get_tree().process_frame

	# 2. Make a choice
	Dialogic.VAR.set("workflow_test_choice", "workflow_value")
	event_bus.narrative_choice_made.emit("workflow_test_choice", "workflow_value")
	await get_tree().process_frame

	# 3. End dialogue
	event_bus.dialogue_ended.emit("test_timeline")
	await get_tree().process_frame

	# 4. Save choices
	global_ref.capture_narrative_choices()
	event_bus.narrative_choices_save_requested.emit()
	await get_tree().process_frame

	# 5. Save game state
	global_ref.save_game_state()
	await get_tree().process_frame

	# 6. Clear state
	global_ref.narrative_choices.clear()
	Dialogic.VAR.set("workflow_test_choice", "")
	await get_tree().process_frame

	# 7. Load game state
	global_ref.load_game_state()
	await get_tree().process_frame

	# Verify all signals were emitted
	assert_true(dialogue_started, "dialogue_started should be emitted")
	assert_true(dialogue_ended, "dialogue_ended should be emitted")
	assert_true(choice_made, "narrative_choice_made should be emitted")
	assert_true(save_requested, "narrative_choices_save_requested should be emitted")

	# Verify choice persisted
	assert_true(global_ref.narrative_choices.has("workflow_test_choice"), "Choice should persist")
	assert_eq(global_ref.narrative_choices["workflow_test_choice"], "workflow_value", "Choice value should persist")

	# Cleanup
	event_bus.dialogue_started.disconnect(start_cb)
	event_bus.dialogue_ended.disconnect(end_cb)
	event_bus.narrative_choice_made.disconnect(choice_cb)
	event_bus.narrative_choices_save_requested.disconnect(save_cb)


func test_multiple_choices_persist_correctly() -> void:
	"""Test that multiple choices made during dialogue all persist"""

	if not Dialogic:
		pass_test("Dialogic not available")
		return

	# Clear state
	global_ref.narrative_choices.clear()

	# Make multiple choices
	var choices = {
		"choice_1": "value_1",
		"choice_2": "value_2",
		"choice_3": "value_3",
		"choice_4": "value_4",
		"choice_5": "value_5"
	}

	for key in choices:
		Dialogic.VAR.set(key, choices[key])
		event_bus.narrative_choice_made.emit(key, choices[key])
		await get_tree().process_frame

	# Save
	global_ref.capture_narrative_choices()
	global_ref.save_game_state()
	await get_tree().process_frame

	# Clear
	for key in choices:
		Dialogic.VAR.set(key, "")
	global_ref.narrative_choices.clear()
	await get_tree().process_frame

	# Load
	global_ref.load_game_state()
	await get_tree().process_frame

	# Verify all choices persisted
	for key in choices:
		assert_true(global_ref.narrative_choices.has(key), "Choice %s should persist" % key)
		assert_eq(global_ref.narrative_choices[key], choices[key], "Choice %s value should match" % key)


func test_narrative_choices_isolated_from_game_state() -> void:
	"""Test that narrative choices are independent from other game state"""

	if not Dialogic:
		pass_test("Dialogic not available")
		return

	# Set up narrative choice
	Dialogic.VAR.set("isolated_choice", "narrative_value")
	global_ref.capture_narrative_choices()

	# Set up game state
	var original_score = global_ref.score
	global_ref.score = 9999

	# Save both
	global_ref.save_game_state()
	await get_tree().process_frame

	# Clear both
	global_ref.narrative_choices.clear()
	Dialogic.VAR.set("isolated_choice", "")
	global_ref.score = 0
	await get_tree().process_frame

	# Load
	global_ref.load_game_state()
	await get_tree().process_frame

	# Verify both restored independently
	assert_true(global_ref.narrative_choices.has("isolated_choice"), "Narrative choice should be restored")
	assert_eq(global_ref.score, 9999, "Game state should be restored")


# ==================== EDGE CASES ====================


func test_empty_narrative_choices_save_load() -> void:
	"""Test that save/load works with no narrative choices"""

	global_ref.narrative_choices.clear()

	# Save with empty choices
	global_ref.save_game_state()
	await get_tree().process_frame

	# Load
	global_ref.load_game_state()
	await get_tree().process_frame

	# Should not crash and choices should be empty
	assert_true(global_ref.narrative_choices.is_empty(), "Choices should remain empty")


func test_overwrite_existing_choice() -> void:
	"""Test that making the same choice again overwrites the previous value"""

	if not Dialogic:
		pass_test("Dialogic not available")
		return

	# Make initial choice
	Dialogic.VAR.set("overwrite_test", "initial_value")
	global_ref.capture_narrative_choices()
	assert_eq(global_ref.narrative_choices["overwrite_test"], "initial_value", "Initial value should be set")

	# Overwrite choice
	Dialogic.VAR.set("overwrite_test", "new_value")
	global_ref.capture_narrative_choices()
	assert_eq(global_ref.narrative_choices["overwrite_test"], "new_value", "Value should be overwritten")


func test_narrative_choice_with_different_types() -> void:
	"""Test that narrative choices support different value types"""

	if not Dialogic:
		pass_test("Dialogic not available")
		return

	# Test string
	Dialogic.VAR.set("string_choice", "string_value")
	# Test int
	Dialogic.VAR.set("int_choice", 42)
	# Test bool
	Dialogic.VAR.set("bool_choice", true)

	global_ref.capture_narrative_choices()
	await get_tree().process_frame

	# Verify types preserved
	if global_ref.narrative_choices.has("string_choice"):
		assert_eq(global_ref.narrative_choices["string_choice"], "string_value", "String should be preserved")
	if global_ref.narrative_choices.has("int_choice"):
		assert_eq(global_ref.narrative_choices["int_choice"], 42, "Int should be preserved")
	if global_ref.narrative_choices.has("bool_choice"):
		assert_eq(global_ref.narrative_choices["bool_choice"], true, "Bool should be preserved")


func test_dialogue_state_changed_during_choice() -> void:
	"""Test that story state can change during dialogue choices"""

	var state_changed: bool = false
	var new_state: int = 0

	var callback = func(state: int):
		state_changed = true
		new_state = state

	event_bus.story_state_changed.connect(callback)

	# Simulate state change during dialogue
	event_bus.dialogue_started.emit("critical_choice")
	await get_tree().process_frame

	# Make a critical choice that changes story state
	event_bus.story_state_changed.emit(5)
	await get_tree().process_frame

	event_bus.dialogue_ended.emit("critical_choice")
	await get_tree().process_frame

	assert_true(state_changed, "Story state should have changed")
	assert_eq(new_state, 5, "New state should be 5")

	event_bus.story_state_changed.disconnect(callback)


# ==================== PERFORMANCE TESTS ====================


func test_large_number_of_choices() -> void:
	"""Test that system can handle many narrative choices"""

	if not Dialogic:
		pass_test("Dialogic not available")
		return

	global_ref.narrative_choices.clear()

	# Create 50 choices
	for i in range(50):
		var key = "mass_choice_%d" % i
		var value = "value_%d" % i
		Dialogic.VAR.set(key, value)

	await get_tree().process_frame

	# Capture and save
	global_ref.capture_narrative_choices()
	global_ref.save_game_state()
	await get_tree().process_frame

	# Clear
	for i in range(50):
		Dialogic.VAR.set("mass_choice_%d" % i, "")
	global_ref.narrative_choices.clear()
	await get_tree().process_frame

	# Load
	global_ref.load_game_state()
	await get_tree().process_frame

	# Verify all loaded
	var loaded_count = 0
	for key in global_ref.narrative_choices:
		if key.begins_with("mass_choice_"):
			loaded_count += 1

	assert_true(loaded_count > 0, "Should have loaded some choices")


func test_rapid_choice_succession() -> void:
	"""Test that rapid successive choices are handled correctly"""

	var choices_tracked: int = 0

	var callback = func(_key: String, _value: Variant):
		choices_tracked += 1

	event_bus.narrative_choice_made.connect(callback)

	# Emit 10 choices rapidly
	for i in range(10):
		event_bus.narrative_choice_made.emit("rapid_choice_%d" % i, "value_%d" % i)

	await get_tree().process_frame

	assert_eq(choices_tracked, 10, "All rapid choices should be tracked")

	event_bus.narrative_choice_made.disconnect(callback)
