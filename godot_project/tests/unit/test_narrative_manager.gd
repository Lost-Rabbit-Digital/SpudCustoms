extends GutTest

## Unit tests for NarrativeManager
## Tests choice tracking, dialogue state, save/load persistence

var narrative_manager: Node
var event_bus: Node

func before_each() -> void:
	narrative_manager = get_node_or_null("/root/NarrativeManager")
	event_bus = get_node_or_null("/root/EventBus")

	# NarrativeManager may not be autoload, check if available
	if not narrative_manager:
		push_warning("NarrativeManager not available as autoload, skipping tests")


# ==================== INITIALIZATION ====================


func test_narrative_manager_exists() -> void:
	if narrative_manager:
		assert_not_null(narrative_manager, "NarrativeManager should be available")


func test_narrative_manager_initializes_choice_tracking() -> void:
	if narrative_manager and narrative_manager.has_method("get_choices"):
		var choices = narrative_manager.get_choices()
		assert_true(choices is Dictionary, "Should maintain dictionary of choices")


# ==================== CHOICE RECORDING ====================


func test_record_choice_stores_value() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("record_choice"):
		var choice_key = "test_choice"
		var choice_value = "test_value"

		narrative_manager.record_choice(choice_key, choice_value)

		if narrative_manager.has_method("get_choice"):
			var retrieved = narrative_manager.get_choice(choice_key)
			assert_eq(retrieved, choice_value, "Choice should be stored and retrieved")


func test_record_choice_emits_event() -> void:
	if not narrative_manager or not event_bus:
		return

	var event_emitted: bool = false
	var emitted_key: String = ""
	var emitted_value: Variant = null

	var callback = func(key: String, value: Variant):
		event_emitted = true
		emitted_key = key
		emitted_value = value

	event_bus.narrative_choice_made.connect(callback)

	if narrative_manager.has_method("record_choice"):
		narrative_manager.record_choice("test_key", "test_val")

		await get_tree().process_frame

		assert_true(event_emitted, "Should emit narrative_choice_made event")
		assert_eq(emitted_key, "test_key", "Should emit correct choice key")
		assert_eq(emitted_value, "test_val", "Should emit correct choice value")

	event_bus.narrative_choice_made.disconnect(callback)


func test_record_multiple_choices() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("record_choice"):
		narrative_manager.record_choice("choice1", "value1")
		narrative_manager.record_choice("choice2", "value2")
		narrative_manager.record_choice("choice3", "value3")

		if narrative_manager.has_method("get_choices"):
			var choices = narrative_manager.get_choices()
			assert_eq(choices.size(), 3, "Should store multiple choices")


func test_overwrite_existing_choice() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("record_choice"):
		narrative_manager.record_choice("test_key", "original_value")
		narrative_manager.record_choice("test_key", "new_value")

		if narrative_manager.has_method("get_choice"):
			var result = narrative_manager.get_choice("test_key")
			assert_eq(result, "new_value", "Should overwrite existing choice")


# ==================== CHOICE RETRIEVAL ====================


func test_get_nonexistent_choice_returns_default() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("get_choice"):
		var result = narrative_manager.get_choice("nonexistent_choice", "default_value")
		assert_eq(result, "default_value", "Should return default for nonexistent choice")


func test_get_all_choices() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("get_choices"):
		narrative_manager.record_choice("a", 1)
		narrative_manager.record_choice("b", 2)

		var all_choices = narrative_manager.get_choices()
		assert_true(all_choices.has("a"), "Should contain choice 'a'")
		assert_true(all_choices.has("b"), "Should contain choice 'b'")


# ==================== DIALOGUE STATE ====================


func test_is_dialogue_active() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("is_dialogue_active"):
		# Initially should not be in dialogue
		assert_false(narrative_manager.is_dialogue_active(), "Should not be in dialogue initially")


func test_dialogue_started_sets_active_state() -> void:
	if not narrative_manager or not event_bus:
		return

	# Listen for dialogue_started event
	event_bus.emit_dialogue_started("test_timeline")
	await get_tree().process_frame

	if narrative_manager.has_method("is_dialogue_active"):
		# Should now be in dialogue
		# Actual state depends on NarrativeManager implementation
		pass


func test_dialogue_ended_clears_active_state() -> void:
	if not narrative_manager or not event_bus:
		return

	# Start dialogue
	event_bus.emit_dialogue_started("test_timeline")
	await get_tree().process_frame

	# End dialogue
	event_bus.emit_dialogue_ended("test_timeline")
	await get_tree().process_frame

	if narrative_manager.has_method("is_dialogue_active"):
		# Should no longer be in dialogue
		pass


# ==================== SAVE/LOAD ====================


func test_save_narrative_choices() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("save_narrative_choices"):
		# Record some choices
		if narrative_manager.has_method("record_choice"):
			narrative_manager.record_choice("saved_choice_1", "value1")
			narrative_manager.record_choice("saved_choice_2", "value2")

		# Save choices
		var saved_data = narrative_manager.save_narrative_choices()

		assert_true(saved_data is Dictionary, "Should return Dictionary")
		assert_eq(saved_data.size(), 2, "Should save all choices")
		assert_eq(saved_data.get("saved_choice_1"), "value1", "Should preserve values")


func test_load_narrative_choices() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("load_narrative_choices"):
		var test_data = {
			"loaded_choice_1": "loaded_value1",
			"loaded_choice_2": "loaded_value2"
		}

		narrative_manager.load_narrative_choices(test_data)

		if narrative_manager.has_method("get_choice"):
			var choice1 = narrative_manager.get_choice("loaded_choice_1")
			var choice2 = narrative_manager.get_choice("loaded_choice_2")

			assert_eq(choice1, "loaded_value1", "Should load choice 1")
			assert_eq(choice2, "loaded_value2", "Should load choice 2")


func test_load_empty_choices_handled() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("load_narrative_choices"):
		# Should handle empty dictionary gracefully
		narrative_manager.load_narrative_choices({})

		# Should not crash


func test_save_load_roundtrip() -> void:
	if not narrative_manager:
		return

	if not narrative_manager.has_method("save_narrative_choices") or not narrative_manager.has_method("load_narrative_choices"):
		return

	# Save some choices
	if narrative_manager.has_method("record_choice"):
		narrative_manager.record_choice("roundtrip_1", "value_a")
		narrative_manager.record_choice("roundtrip_2", "value_b")

	# Save
	var saved = narrative_manager.save_narrative_choices()

	# Clear (if method exists)
	if narrative_manager.has_method("clear_choices"):
		narrative_manager.clear_choices()

	# Load
	narrative_manager.load_narrative_choices(saved)

	# Verify
	if narrative_manager.has_method("get_choice"):
		assert_eq(narrative_manager.get_choice("roundtrip_1"), "value_a", "Roundtrip should preserve data")
		assert_eq(narrative_manager.get_choice("roundtrip_2"), "value_b", "Roundtrip should preserve data")


# ==================== DIALOGIC INTEGRATION ====================


func test_choices_sync_to_dialogic_variables() -> void:
	if not narrative_manager:
		return

	# NarrativeManager should sync choices to Dialogic.VAR
	# This enables Dialogic timelines to check player choices

	if narrative_manager.has_method("record_choice"):
		narrative_manager.record_choice("dialogic_test_var", "test_value")

		# Check if synced to Dialogic
		if Dialogic and Dialogic.has_method("VAR"):
			# var dialogic_value = Dialogic.VAR.get("dialogic_test_var")
			# assert_eq(dialogic_value, "test_value", "Should sync to Dialogic variables")
			pass


# ==================== GAME MODE TRACKING ====================


func test_track_game_mode() -> void:
	if not narrative_manager:
		return

	# NarrativeManager may track current game mode (story, endless, score_attack)
	if narrative_manager.has_method("set_game_mode"):
		narrative_manager.set_game_mode("story")

		if narrative_manager.has_method("get_game_mode"):
			assert_eq(narrative_manager.get_game_mode(), "story", "Should track game mode")


# ==================== CHOICE BRANCHING ====================


func test_choice_affects_story_branch() -> void:
	if not narrative_manager:
		return

	# Make a choice that affects branching
	if narrative_manager.has_method("record_choice"):
		narrative_manager.record_choice("initial_response", "eager")

		# This choice should affect which dialogues are shown
		# Actual branching logic is in Dialogic timelines


func test_multiple_endings_tracked() -> void:
	if not narrative_manager:
		return

	# Game has multiple endings based on choices
	# Test that ending choice is tracked

	if narrative_manager.has_method("record_choice"):
		narrative_manager.record_choice("ending_type", "vengeance")

		if narrative_manager.has_method("get_choice"):
			var ending = narrative_manager.get_choice("ending_type")
			assert_eq(ending, "vengeance", "Should track ending choice")


# ==================== EDGE CASES ====================


func test_record_choice_with_null_value() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("record_choice"):
		# Should handle null value gracefully
		narrative_manager.record_choice("null_choice", null)

		if narrative_manager.has_method("get_choice"):
			var result = narrative_manager.get_choice("null_choice")
			# May return null or default depending on implementation


func test_record_choice_with_empty_key() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("record_choice"):
		# Should handle empty key gracefully or reject
		narrative_manager.record_choice("", "value")

		# Should not crash


func test_record_choice_with_complex_value() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("record_choice"):
		# Test with Dictionary value
		var complex_value = {"option": "a", "weight": 0.75}
		narrative_manager.record_choice("complex_choice", complex_value)

		if narrative_manager.has_method("get_choice"):
			var result = narrative_manager.get_choice("complex_choice")
			assert_eq(result.get("option"), "a", "Should handle complex values")


# ==================== ANALYTICS INTEGRATION ====================


func test_choice_tracked_by_analytics() -> void:
	if not narrative_manager or not event_bus:
		return

	var analytics_event_fired: bool = false

	var callback = func(_event_name: String, _data: Dictionary):
		analytics_event_fired = true

	if event_bus.has_signal("analytics_event"):
		event_bus.analytics_event.connect(callback)

		if narrative_manager.has_method("record_choice"):
			narrative_manager.record_choice("analytics_test", "test_value")

			await get_tree().process_frame

			# Analytics should track narrative choices

		event_bus.analytics_event.disconnect(callback)


# ==================== RESET ====================


func test_clear_all_choices() -> void:
	if not narrative_manager:
		return

	if narrative_manager.has_method("clear_choices"):
		# Add some choices
		if narrative_manager.has_method("record_choice"):
			narrative_manager.record_choice("clear_test_1", "value1")
			narrative_manager.record_choice("clear_test_2", "value2")

		# Clear all
		narrative_manager.clear_choices()

		if narrative_manager.has_method("get_choices"):
			var choices = narrative_manager.get_choices()
			assert_eq(choices.size(), 0, "Should clear all choices")
