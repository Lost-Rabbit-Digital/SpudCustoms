extends GutTest

## Unit tests for SaveManager
## Tests game state persistence, high score tracking, and file operations

var save_manager: Node
var test_save_completed_called: bool = false
var test_load_completed_called: bool = false
var last_save_success: bool = false
var last_load_success: bool = false


func before_each() -> void:
	save_manager = get_node("/root/SaveManager")
	test_save_completed_called = false
	test_load_completed_called = false
	last_save_success = false
	last_load_success = false

	# Reset all game data before each test
	save_manager.reset_all_game_data(false)


func after_each() -> void:
	# Disconnect test signals
	if save_manager.save_completed.is_connected(_on_save_completed):
		save_manager.save_completed.disconnect(_on_save_completed)
	if save_manager.load_completed.is_connected(_on_load_completed):
		save_manager.load_completed.disconnect(_on_load_completed)


# ==================== INITIALIZATION TESTS ====================


func test_save_manager_exists() -> void:
	assert_not_null(save_manager, "SaveManager should be available as autoload")


func test_save_paths_are_defined() -> void:
	assert_not_null(save_manager.GAMESTATE_SAVE_PATH, "Gamestate save path should be defined")
	assert_not_null(save_manager.HIGHSCORES_SAVE_PATH, "High scores save path should be defined")


# ==================== GAME STATE SAVE/LOAD TESTS ====================


func test_save_game_state_returns_true_on_success() -> void:
	var test_data = {"test_key": "test_value", "number": 42}
	var result = save_manager.save_game_state(test_data)
	assert_true(result, "save_game_state should return true on success")


func test_save_game_state_emits_signal() -> void:
	save_manager.save_completed.connect(_on_save_completed)

	var test_data = {"test_key": "test_value"}
	save_manager.save_game_state(test_data)
	await get_tree().process_frame

	assert_true(test_save_completed_called, "save_completed signal should be emitted")
	assert_true(last_save_success, "Signal should indicate success")


func test_load_game_state_returns_dictionary() -> void:
	var loaded_data = save_manager.load_game_state()
	assert_typeof(loaded_data, TYPE_DICTIONARY, "load_game_state should return a dictionary")


func test_load_game_state_emits_signal() -> void:
	save_manager.load_completed.connect(_on_load_completed)

	save_manager.load_game_state()
	await get_tree().process_frame

	assert_true(test_load_completed_called, "load_completed signal should be emitted")


func test_save_and_load_game_state_round_trip() -> void:
	var test_data = {
		"shift": 5,
		"score": 1000,
		"test_string": "hello",
		"test_array": [1, 2, 3],
		"test_nested": {"inner": "value"}
	}

	save_manager.save_game_state(test_data)
	var loaded_data = save_manager.load_game_state()

	assert_eq(loaded_data.get("shift"), 5, "Shift should be saved and loaded correctly")
	assert_eq(loaded_data.get("score"), 1000, "Score should be saved and loaded correctly")
	assert_eq(loaded_data.get("test_string"), "hello", "String should be saved and loaded correctly")


# ==================== LEVEL PROGRESS TESTS ====================


func test_save_level_progress_updates_max_level() -> void:
	save_manager.save_level_progress(10, 8, {})

	var max_level = save_manager.get_max_level_reached()
	assert_eq(max_level, 10, "Max level should be updated")


func test_save_level_progress_does_not_decrease_max_level() -> void:
	save_manager.save_level_progress(10, 10, {})
	save_manager.save_level_progress(5, 5, {})

	var max_level = save_manager.get_max_level_reached()
	assert_eq(max_level, 10, "Max level should not decrease")


func test_get_current_level() -> void:
	save_manager.save_level_progress(5, 3, {})

	var current_level = save_manager.get_current_level()
	assert_eq(current_level, 3, "Current level should be saved and retrieved")


func test_get_max_level_reached_default() -> void:
	save_manager.reset_all_game_data(false)
	var max_level = save_manager.get_max_level_reached()
	assert_eq(max_level, 0, "Default max level should be 0")


# ==================== LEVEL HIGH SCORE TESTS ====================


func test_save_level_high_score_saves_new_score() -> void:
	var result = save_manager.save_level_high_score(1, "Normal", 500)
	assert_true(result, "Saving level high score should succeed")

	var retrieved_score = save_manager.get_level_high_score(1, "Normal")
	assert_eq(retrieved_score, 500, "Level high score should be saved correctly")


func test_save_level_high_score_updates_higher_score() -> void:
	save_manager.save_level_high_score(1, "Normal", 300)
	save_manager.save_level_high_score(1, "Normal", 500)

	var score = save_manager.get_level_high_score(1, "Normal")
	assert_eq(score, 500, "Higher score should replace lower score")


func test_save_level_high_score_keeps_higher_existing_score() -> void:
	save_manager.save_level_high_score(1, "Normal", 500)
	save_manager.save_level_high_score(1, "Normal", 300)

	var score = save_manager.get_level_high_score(1, "Normal")
	assert_eq(score, 500, "Higher existing score should be kept")


func test_get_level_high_score_returns_zero_for_nonexistent() -> void:
	var score = save_manager.get_level_high_score(999, "Expert")
	assert_eq(score, 0, "Nonexistent level high score should return 0")


func test_save_level_high_score_different_difficulties() -> void:
	save_manager.save_level_high_score(1, "Easy", 100)
	save_manager.save_level_high_score(1, "Normal", 200)
	save_manager.save_level_high_score(1, "Expert", 300)

	assert_eq(save_manager.get_level_high_score(1, "Easy"), 100, "Easy score should be saved")
	assert_eq(save_manager.get_level_high_score(1, "Normal"), 200, "Normal score should be saved")
	assert_eq(save_manager.get_level_high_score(1, "Expert"), 300, "Expert score should be saved")


func test_save_level_high_score_different_levels() -> void:
	save_manager.save_level_high_score(1, "Normal", 100)
	save_manager.save_level_high_score(2, "Normal", 200)
	save_manager.save_level_high_score(3, "Normal", 300)

	assert_eq(save_manager.get_level_high_score(1, "Normal"), 100, "Level 1 score should be saved")
	assert_eq(save_manager.get_level_high_score(2, "Normal"), 200, "Level 2 score should be saved")
	assert_eq(save_manager.get_level_high_score(3, "Normal"), 300, "Level 3 score should be saved")


# ==================== GLOBAL HIGH SCORE TESTS ====================


func test_save_level_high_score_updates_global_high_score() -> void:
	save_manager.save_level_high_score(1, "Normal", 1000)

	var global_score = save_manager.get_global_high_score("Normal")
	assert_eq(global_score, 1000, "Global high score should be updated")


func test_global_high_score_tracks_highest_across_levels() -> void:
	save_manager.save_level_high_score(1, "Normal", 500)
	save_manager.save_level_high_score(2, "Normal", 300)
	save_manager.save_level_high_score(3, "Normal", 800)

	var global_score = save_manager.get_global_high_score("Normal")
	assert_eq(global_score, 800, "Global high score should be the highest score across all levels")


func test_get_global_high_score_returns_zero_for_nonexistent() -> void:
	save_manager.reset_all_game_data(false)
	var score = save_manager.get_global_high_score("Expert")
	assert_eq(score, 0, "Nonexistent global high score should return 0")


# ==================== HIGH SCORES SAVE/LOAD TESTS ====================


func test_save_high_scores_returns_true_on_success() -> void:
	var high_scores = {"Easy": 100, "Normal": 200, "Expert": 300}
	var result = save_manager.save_high_scores(high_scores)
	assert_true(result, "save_high_scores should return true on success")


func test_load_high_scores_returns_dictionary() -> void:
	var high_scores = save_manager.load_high_scores()
	assert_typeof(high_scores, TYPE_DICTIONARY, "load_high_scores should return a dictionary")


func test_save_and_load_high_scores_round_trip() -> void:
	var test_scores = {"Easy": 500, "Normal": 750, "Expert": 1000}

	save_manager.save_high_scores(test_scores)
	var loaded_scores = save_manager.load_high_scores()

	assert_eq(loaded_scores.get("Easy"), 500, "Easy score should round-trip correctly")
	assert_eq(loaded_scores.get("Normal"), 750, "Normal score should round-trip correctly")
	assert_eq(loaded_scores.get("Expert"), 1000, "Expert score should round-trip correctly")


# ==================== RESET TESTS ====================


func test_reset_all_game_data_without_keeping_scores() -> void:
	# Save some data
	save_manager.save_level_high_score(1, "Normal", 1000)
	save_manager.save_level_progress(5, 5, {})

	# Reset without keeping scores
	save_manager.reset_all_game_data(false)

	# Verify data is reset
	assert_eq(save_manager.get_max_level_reached(), 0, "Max level should be reset to 0")
	assert_eq(save_manager.get_level_high_score(1, "Normal"), 0, "High scores should be reset")


func test_reset_all_game_data_creates_fresh_state() -> void:
	save_manager.reset_all_game_data(false)

	var game_state = save_manager.load_game_state()

	assert_true(game_state.has("shift"), "Fresh state should have shift key")
	assert_true(game_state.has("current_level"), "Fresh state should have current_level key")
	assert_true(game_state.has("max_level_reached"), "Fresh state should have max_level_reached key")
	assert_true(game_state.has("level_highscores"), "Fresh state should have level_highscores key")


func test_reset_all_game_data_returns_true() -> void:
	var result = save_manager.reset_all_game_data(false)
	assert_true(result, "reset_all_game_data should return true")


# ==================== STRING KEY CONVERSION TESTS ====================


func test_level_keys_are_converted_to_strings() -> void:
	# Save with integer level
	save_manager.save_level_high_score(5, "Normal", 100)

	# Load and check the key is a string
	var game_state = save_manager.load_game_state()
	var level_highscores = game_state.get("level_highscores", {})

	assert_true(level_highscores.has("5"), "Level key should be converted to string '5'")
	assert_false(level_highscores.has(5), "Integer key 5 should not exist")


# ==================== TEST SIGNAL HANDLERS ====================


func _on_save_completed(success: bool) -> void:
	test_save_completed_called = true
	last_save_success = success


func _on_load_completed(success: bool) -> void:
	test_load_completed_called = true
	last_load_success = success


# ==================== SAVE_LEVEL_PROGRESS WITH HIGHSCORES TESTS ====================


func test_save_level_progress_with_empty_highscores() -> void:
	var result = save_manager.save_level_progress(5, 3, {})
	assert_true(result, "Should succeed with empty highscores dictionary")

	var max_level = save_manager.get_max_level_reached()
	assert_eq(max_level, 5, "Max level should be saved")


func test_save_level_progress_with_level_highscores() -> void:
	var level_scores = {1: {"Easy": 100, "Normal": 200}}
	var result = save_manager.save_level_progress(5, 3, level_scores)
	assert_true(result, "Should succeed with level highscores")

	# Verify the data was saved
	var game_state = save_manager.load_game_state()
	assert_true(game_state.has("level_highscores"), "Should have level_highscores key")


func test_save_level_progress_converts_integer_keys_to_strings() -> void:
	var level_scores = {1: {"Normal": 300}, 2: {"Expert": 400}}
	save_manager.save_level_progress(5, 3, level_scores)

	var game_state = save_manager.load_game_state()
	var level_highscores = game_state.get("level_highscores", {})

	assert_true(level_highscores.has("1"), "Should convert integer key 1 to string '1'")
	assert_true(level_highscores.has("2"), "Should convert integer key 2 to string '2'")
	assert_false(level_highscores.has(1), "Should not have integer key 1")
	assert_false(level_highscores.has(2), "Should not have integer key 2")


func test_save_level_progress_merges_with_existing_highscores() -> void:
	# Save initial highscores
	save_manager.save_level_high_score(1, "Easy", 100)

	# Save level progress with additional highscores
	var level_scores = {2: {"Normal": 200}}
	save_manager.save_level_progress(5, 3, level_scores)

	# Both should exist
	assert_eq(save_manager.get_level_high_score(1, "Easy"), 100, "Original highscore should be preserved")
	var game_state = save_manager.load_game_state()
	assert_true(game_state["level_highscores"].has("2"), "New level highscore should be added")


func test_save_level_progress_updates_current_level() -> void:
	save_manager.save_level_progress(10, 7, {})
	var current = save_manager.get_current_level()
	assert_eq(current, 7, "Current level should be updated correctly")

	save_manager.save_level_progress(10, 9, {})
	current = save_manager.get_current_level()
	assert_eq(current, 9, "Current level should be updated to new value")


# ==================== RESET WITH KEEP_HIGH_SCORES TESTS ====================


func test_reset_all_game_data_keeps_high_scores_when_true() -> void:
	# Save some high scores
	var high_scores = {"Easy": 500, "Normal": 750, "Expert": 1000}
	save_manager.save_high_scores(high_scores)

	# Reset with keep_high_scores = true
	save_manager.reset_all_game_data(true)

	# Load and verify high scores are preserved in the game state
	var game_state = save_manager.load_game_state()
	var preserved_scores = game_state.get("high_scores", {})

	assert_eq(preserved_scores.get("Easy"), 500, "Easy high score should be kept")
	assert_eq(preserved_scores.get("Normal"), 750, "Normal high score should be kept")
	assert_eq(preserved_scores.get("Expert"), 1000, "Expert high score should be kept")


func test_reset_all_game_data_clears_level_progress_but_keeps_scores() -> void:
	# Save level progress and scores
	save_manager.save_level_progress(10, 8, {})
	save_manager.save_high_scores({"Easy": 300})

	# Reset with keep_high_scores = true
	save_manager.reset_all_game_data(true)

	# Level progress should be reset
	assert_eq(save_manager.get_max_level_reached(), 0, "Max level should be reset")
	assert_eq(save_manager.get_current_level(), 0, "Current level should be reset")

	# High scores should be kept
	var game_state = save_manager.load_game_state()
	var scores = game_state.get("high_scores", {})
	assert_eq(scores.get("Easy"), 300, "High scores should be preserved")


func test_reset_all_game_data_initializes_all_fields() -> void:
	save_manager.reset_all_game_data(false)
	var game_state = save_manager.load_game_state()

	# Verify all expected fields exist with correct defaults
	assert_eq(game_state.get("shift"), 0, "Shift should be 0")
	assert_eq(game_state.get("current_level"), 0, "Current level should be 0")
	assert_eq(game_state.get("max_level_reached"), 0, "Max level reached should be 0")
	assert_eq(game_state.get("final_score"), 0, "Final score should be 0")
	assert_eq(game_state.get("quota_met"), 0, "Quota met should be 0")
	assert_eq(game_state.get("quota_target"), 8, "Quota target should be 8")
	assert_eq(game_state.get("difficulty_level"), "Normal", "Difficulty should be Normal")
	assert_eq(game_state.get("story_state"), 0, "Story state should be 0")
	assert_eq(game_state.get("total_shifts_completed"), 0, "Total shifts should be 0")
	assert_eq(game_state.get("total_runners_stopped"), 0, "Total runners should be 0")
	assert_eq(game_state.get("perfect_hits"), 0, "Perfect hits should be 0")

	# Verify dictionaries are initialized
	assert_not_null(game_state.get("level_highscores"), "Level highscores should exist")
	assert_not_null(game_state.get("current_game_stats"), "Current game stats should exist")
	assert_not_null(game_state.get("narrative_choices"), "Narrative choices should exist")


# ==================== DATA PERSISTENCE TESTS ====================


func test_multiple_saves_persist_latest_data() -> void:
	save_manager.save_game_state({"value": 1})
	save_manager.save_game_state({"value": 2})
	save_manager.save_game_state({"value": 3})

	var loaded = save_manager.load_game_state()
	assert_eq(loaded.get("value"), 3, "Latest save should be persisted")


func test_complex_nested_data_persists() -> void:
	var complex_data = {
		"level": 5,
		"stats": {"health": 100, "mana": 50},
		"inventory": [{"id": 1, "name": "sword"}, {"id": 2, "name": "shield"}],
		"flags": {"tutorial_complete": true, "boss_defeated": false}
	}

	save_manager.save_game_state(complex_data)
	var loaded = save_manager.load_game_state()

	assert_eq(loaded.get("level"), 5, "Level should be preserved")
	assert_eq(loaded["stats"]["health"], 100, "Nested stats should be preserved")
	assert_eq(loaded["inventory"][0]["name"], "sword", "Array items should be preserved")
	assert_eq(loaded["flags"]["tutorial_complete"], true, "Boolean flags should be preserved")


func test_empty_dictionary_can_be_saved_and_loaded() -> void:
	save_manager.save_game_state({})
	var loaded = save_manager.load_game_state()
	assert_typeof(loaded, TYPE_DICTIONARY, "Empty dictionary should load as dictionary")


func test_large_dictionary_persists() -> void:
	var large_data = {}
	for i in range(100):
		large_data["key_" + str(i)] = "value_" + str(i)

	save_manager.save_game_state(large_data)
	var loaded = save_manager.load_game_state()

	assert_eq(loaded.size(), 100, "All 100 keys should be preserved")
	assert_eq(loaded.get("key_50"), "value_50", "Random key should have correct value")


# ==================== EDGE CASES AND ERROR HANDLING TESTS ====================


func test_get_level_high_score_with_string_level_key() -> void:
	# Manually save with string key to test string handling
	var game_state = save_manager.load_game_state()
	game_state["level_highscores"] = {"5": {"Normal": 250}}
	save_manager.save_game_state(game_state)

	# Should work with integer level parameter
	var score = save_manager.get_level_high_score(5, "Normal")
	assert_eq(score, 250, "Should retrieve score with integer level when key is string")


func test_save_level_high_score_with_zero_score() -> void:
	# First save a positive score
	save_manager.save_level_high_score(1, "Easy", 100)

	# Try to save zero score (should not update)
	save_manager.save_level_high_score(1, "Easy", 0)

	var score = save_manager.get_level_high_score(1, "Easy")
	assert_eq(score, 100, "Zero score should not replace positive score")


func test_save_level_high_score_with_negative_score() -> void:
	save_manager.save_level_high_score(1, "Normal", 100)
	save_manager.save_level_high_score(1, "Normal", -50)

	var score = save_manager.get_level_high_score(1, "Normal")
	assert_eq(score, 100, "Negative score should not replace positive score")


func test_load_game_state_with_no_existing_file() -> void:
	# Reset first to clear any existing data
	save_manager.reset_all_game_data(false)

	# Delete the save file
	if FileAccess.file_exists(save_manager.GAMESTATE_SAVE_PATH):
		DirAccess.remove_absolute(save_manager.GAMESTATE_SAVE_PATH)

	var loaded = save_manager.load_game_state()
	assert_typeof(loaded, TYPE_DICTIONARY, "Should return dictionary even with no file")
	assert_eq(loaded.size(), 0, "Should return empty dictionary when no file exists")


func test_load_high_scores_with_no_existing_file() -> void:
	# Delete the high scores file if it exists
	if FileAccess.file_exists(save_manager.HIGHSCORES_SAVE_PATH):
		DirAccess.remove_absolute(save_manager.HIGHSCORES_SAVE_PATH)

	var scores = save_manager.load_high_scores()
	assert_typeof(scores, TYPE_DICTIONARY, "Should return dictionary")
	assert_eq(scores.get("Easy"), 0, "Default Easy score should be 0")
	assert_eq(scores.get("Normal"), 0, "Default Normal score should be 0")
	assert_eq(scores.get("Expert"), 0, "Default Expert score should be 0")


func test_save_level_high_score_initializes_missing_structures() -> void:
	# Start with fresh state
	save_manager.reset_all_game_data(false)

	# Manually remove level_highscores
	var game_state = save_manager.load_game_state()
	game_state.erase("level_highscores")
	game_state.erase("global_highscores")
	save_manager.save_game_state(game_state)

	# Should still work and initialize structures
	var result = save_manager.save_level_high_score(1, "Normal", 500)
	assert_true(result, "Should succeed even with missing structures")

	var score = save_manager.get_level_high_score(1, "Normal")
	assert_eq(score, 500, "Score should be saved after initialization")


# ==================== SIGNAL EMISSION TESTS ====================


func test_load_completed_signal_emits_true_on_success() -> void:
	# Save some data first
	save_manager.save_game_state({"test": "data"})

	save_manager.load_completed.connect(_on_load_completed)
	save_manager.load_game_state()
	await get_tree().process_frame

	assert_true(test_load_completed_called, "load_completed signal should be emitted")
	assert_true(last_load_success, "Signal should indicate success when file exists")


func test_load_completed_signal_emits_false_on_no_file() -> void:
	# Delete save file
	if FileAccess.file_exists(save_manager.GAMESTATE_SAVE_PATH):
		DirAccess.remove_absolute(save_manager.GAMESTATE_SAVE_PATH)

	save_manager.load_completed.connect(_on_load_completed)
	save_manager.load_game_state()
	await get_tree().process_frame

	assert_true(test_load_completed_called, "load_completed signal should be emitted")
	assert_false(last_load_success, "Signal should indicate failure when file doesn't exist")


# ==================== MULTIPLE DIFFICULTY LEVELS TESTS ====================


func test_all_difficulty_levels_independent() -> void:
	var difficulties = ["Easy", "Normal", "Expert"]
	var scores = [100, 200, 300]

	for i in range(difficulties.size()):
		save_manager.save_level_high_score(1, difficulties[i], scores[i])

	for i in range(difficulties.size()):
		var score = save_manager.get_level_high_score(1, difficulties[i])
		assert_eq(score, scores[i], "Each difficulty should maintain independent scores")


func test_global_high_scores_per_difficulty() -> void:
	save_manager.save_level_high_score(1, "Easy", 500)
	save_manager.save_level_high_score(2, "Normal", 750)
	save_manager.save_level_high_score(3, "Expert", 1000)

	assert_eq(save_manager.get_global_high_score("Easy"), 500, "Easy global score")
	assert_eq(save_manager.get_global_high_score("Normal"), 750, "Normal global score")
	assert_eq(save_manager.get_global_high_score("Expert"), 1000, "Expert global score")


# ==================== BOUNDARY VALUE TESTS ====================


func test_save_level_progress_with_max_level_zero() -> void:
	var result = save_manager.save_level_progress(0, 0, {})
	assert_true(result, "Should handle zero max level")
	assert_eq(save_manager.get_max_level_reached(), 0, "Zero max level should be valid")


func test_save_level_high_score_very_large_score() -> void:
	var large_score = 999999999
	save_manager.save_level_high_score(1, "Normal", large_score)
	var retrieved = save_manager.get_level_high_score(1, "Normal")
	assert_eq(retrieved, large_score, "Should handle very large scores")


func test_many_levels_high_scores() -> void:
	# Test with many levels
	for level in range(1, 51):
		save_manager.save_level_high_score(level, "Normal", level * 100)

	# Verify a few random ones
	assert_eq(save_manager.get_level_high_score(1, "Normal"), 100, "Level 1 score")
	assert_eq(save_manager.get_level_high_score(25, "Normal"), 2500, "Level 25 score")
	assert_eq(save_manager.get_level_high_score(50, "Normal"), 5000, "Level 50 score")


# ==================== CONCURRENT OPERATIONS TESTS ====================


func test_rapid_save_operations() -> void:
	# Simulate rapid saves
	for i in range(10):
		save_manager.save_game_state({"iteration": i})

	var loaded = save_manager.load_game_state()
	assert_eq(loaded.get("iteration"), 9, "Last save should win in rapid operations")


func test_interleaved_save_and_load() -> void:
	save_manager.save_game_state({"value": 1})
	var loaded1 = save_manager.load_game_state()

	save_manager.save_game_state({"value": 2})
	var loaded2 = save_manager.load_game_state()

	save_manager.save_game_state({"value": 3})
	var loaded3 = save_manager.load_game_state()

	assert_eq(loaded1.get("value"), 1, "First load should get first value")
	assert_eq(loaded2.get("value"), 2, "Second load should get second value")
	assert_eq(loaded3.get("value"), 3, "Third load should get third value")


# ==================== DATA INTEGRITY TESTS ====================


func test_save_does_not_modify_original_dictionary() -> void:
	var original = {"key": "value", "number": 42}
	var original_size = original.size()

	save_manager.save_game_state(original)

	assert_eq(original.size(), original_size, "Original dictionary should not be modified")
	assert_eq(original.get("key"), "value", "Original values should be unchanged")


func test_level_high_score_does_not_update_on_equal_score() -> void:
	save_manager.save_level_high_score(1, "Normal", 500)
	var result = save_manager.save_level_high_score(1, "Normal", 500)

	# Should return true but not actually update
	assert_true(result, "Should return true when score is equal")
	var score = save_manager.get_level_high_score(1, "Normal")
	assert_eq(score, 500, "Score should remain the same")


func test_global_high_score_only_updates_when_higher() -> void:
	save_manager.save_level_high_score(1, "Normal", 500)
	save_manager.save_level_high_score(2, "Normal", 300)

	var global_score = save_manager.get_global_high_score("Normal")
	assert_eq(global_score, 500, "Global score should be the highest, not the latest")


# ==================== SPECIAL CHARACTERS AND STRINGS TESTS ====================


func test_save_game_state_with_special_characters() -> void:
	var special_data = {
		"unicode": "Hello 世界 🎮",
		"quotes": "She said \"Hello\"",
		"newlines": "Line1\nLine2\nLine3",
		"symbols": "!@#$%^&*()"
	}

	save_manager.save_game_state(special_data)
	var loaded = save_manager.load_game_state()

	assert_eq(loaded.get("unicode"), "Hello 世界 🎮", "Unicode should be preserved")
	assert_eq(loaded.get("quotes"), "She said \"Hello\"", "Quotes should be preserved")
	assert_eq(loaded.get("symbols"), "!@#$%^&*()", "Symbols should be preserved")


func test_difficulty_names_case_sensitive() -> void:
	save_manager.save_level_high_score(1, "Normal", 100)
	save_manager.save_level_high_score(1, "normal", 200)  # lowercase

	var normal_score = save_manager.get_level_high_score(1, "Normal")
	var lowercase_score = save_manager.get_level_high_score(1, "normal")

	assert_eq(normal_score, 100, "Normal should have its own score")
	assert_eq(lowercase_score, 200, "normal should have separate score (case sensitive)")
