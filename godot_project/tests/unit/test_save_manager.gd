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
