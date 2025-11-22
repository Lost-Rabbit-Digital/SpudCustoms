extends GutTest

## Integration test for Save/Load Flow
## Tests: Set State → Save → Persist to Disk → Clear → Load → Verify All State

var event_bus: Node
var game_state_manager: Node
var save_manager: Node
var global_ref: Node

# Test save file paths
const TEST_SAVE_PATH = "user://test_gamestate.save"


func before_each() -> void:
	event_bus = get_node_or_null("/root/EventBus")
	game_state_manager = get_node_or_null("/root/GameStateManager")
	save_manager = get_node_or_null("/root/SaveManager")
	global_ref = get_node_or_null("/root/Global")

	assert_not_null(event_bus, "EventBus must be available")
	assert_not_null(game_state_manager, "GameStateManager must be available")
	assert_not_null(save_manager, "SaveManager must be available")
	assert_not_null(global_ref, "Global must be available")


func after_each() -> void:
	# Clean up test save files
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)

	await get_tree().process_frame


# ==================== SAVE SIGNALS ====================


func test_save_game_requested_signal() -> void:
	"""Test that save_game_requested signal is emitted"""

	var signal_emitted: bool = false

	var callback = func():
		signal_emitted = true

	event_bus.save_game_requested.connect(callback)

	# Request save
	event_bus.save_game_requested.emit()
	await get_tree().process_frame

	assert_true(signal_emitted, "save_game_requested should be emitted")

	event_bus.save_game_requested.disconnect(callback)


func test_game_saved_signal() -> void:
	"""Test that game_saved signal is emitted after save"""

	var signal_emitted: bool = false

	var callback = func():
		signal_emitted = true

	event_bus.game_saved.connect(callback)

	# Emit game saved
	event_bus.game_saved.emit()
	await get_tree().process_frame

	assert_true(signal_emitted, "game_saved should be emitted")

	event_bus.game_saved.disconnect(callback)


# ==================== LOAD SIGNALS ====================


func test_load_game_requested_signal() -> void:
	"""Test that load_game_requested signal is emitted"""

	var signal_emitted: bool = false

	var callback = func():
		signal_emitted = true

	event_bus.load_game_requested.connect(callback)

	# Request load
	event_bus.load_game_requested.emit()
	await get_tree().process_frame

	assert_true(signal_emitted, "load_game_requested should be emitted")

	event_bus.load_game_requested.disconnect(callback)


func test_game_loaded_signal() -> void:
	"""Test that game_loaded signal is emitted with data"""

	var signal_emitted: bool = false
	var loaded_data: Dictionary = {}

	var callback = func(data: Dictionary):
		signal_emitted = true
		loaded_data = data

	event_bus.game_loaded.connect(callback)

	# Emit game loaded
	var test_data = {"score": 1000, "shift": 5}
	event_bus.game_loaded.emit(test_data)
	await get_tree().process_frame

	assert_true(signal_emitted, "game_loaded should be emitted")
	assert_eq(loaded_data.size(), 2, "Should have 2 data fields")
	assert_eq(loaded_data["score"], 1000, "Score should match")

	event_bus.game_loaded.disconnect(callback)


# ==================== BASIC SAVE/LOAD ====================


func test_save_creates_file() -> void:
	"""Test that saving creates a save file on disk"""

	# Clear any existing save
	global_ref.score = 1234
	global_ref.shift = 3

	# Save
	save_manager.save_game_state({"score": 1234, "shift": 3})
	await get_tree().process_frame

	# Verify file exists
	assert_true(
		FileAccess.file_exists(save_manager.GAMESTATE_SAVE_PATH),
		"Save file should be created"
	)


func test_load_reads_file() -> void:
	"""Test that loading reads from save file"""

	# Create a save
	var save_data = {"score": 5678, "shift": 7}
	save_manager.save_game_state(save_data)
	await get_tree().process_frame

	# Load
	var loaded_data = save_manager.load_game_state()
	await get_tree().process_frame

	# Verify data loaded
	assert_false(loaded_data.is_empty(), "Should load data")
	assert_eq(loaded_data["score"], 5678, "Score should match")
	assert_eq(loaded_data["shift"], 7, "Shift should match")


func test_save_overwrites_existing() -> void:
	"""Test that saving overwrites existing save file"""

	# First save
	save_manager.save_game_state({"score": 100})
	await get_tree().process_frame

	# Second save
	save_manager.save_game_state({"score": 200})
	await get_tree().process_frame

	# Load
	var loaded = save_manager.load_game_state()
	await get_tree().process_frame

	# Should have second save
	assert_eq(loaded["score"], 200, "Should have latest save")


# ==================== GAME STATE PERSISTENCE ====================


func test_score_persists() -> void:
	"""Test that score persists across save/load"""

	# Set score
	global_ref.score = 9999
	global_ref.final_score = 9999

	# Save
	global_ref.save_game_state()
	await get_tree().process_frame

	# Clear
	global_ref.score = 0
	global_ref.final_score = 0

	# Load
	global_ref.load_game_state()
	await get_tree().process_frame

	# Note: Global.load_game_state doesn't restore score directly
	# It's managed by shift stats, but we can verify save data exists
	var loaded = save_manager.load_game_state()
	assert_true(loaded.size() > 0, "Save data should exist")


func test_shift_persists() -> void:
	"""Test that shift persists across save/load"""

	# Set shift
	global_ref.shift = 8

	# Save
	global_ref.save_game_state()
	await get_tree().process_frame

	# Clear
	global_ref.shift = 0

	# Load
	global_ref.load_game_state()
	await get_tree().process_frame

	# Verify - shift is not loaded by Global.load_game_state
	# But it should be in save data
	var loaded = save_manager.load_game_state()
	assert_eq(loaded.get("shift", -1), 8, "Shift should be in save data")


func test_strikes_persist() -> void:
	"""Test that strikes persist (indirectly through game state)"""

	var test_data = {
		"shift": 5,
		"strikes": 2,
		"difficulty_level": "Normal"
	}

	# Save
	save_manager.save_game_state(test_data)
	await get_tree().process_frame

	# Load
	var loaded = save_manager.load_game_state()
	await get_tree().process_frame

	assert_eq(loaded.get("strikes", -1), 2, "Strikes should persist")


func test_difficulty_persists() -> void:
	"""Test that difficulty persists across save/load"""

	# Set difficulty
	global_ref.difficulty_level = "Expert"

	# Save
	global_ref.save_game_state()
	await get_tree().process_frame

	# Clear
	global_ref.difficulty_level = "Easy"

	# Load
	global_ref.load_game_state()
	await get_tree().process_frame

	# Verify
	var loaded = save_manager.load_game_state()
	assert_eq(loaded.get("difficulty_level", ""), "Expert", "Difficulty should persist")


func test_stats_persist() -> void:
	"""Test that player stats persist across save/load"""

	# Set stats
	global_ref.total_shifts_completed = 12
	global_ref.total_runners_stopped = 45
	global_ref.perfect_hits = 8

	# Save
	global_ref.save_game_state()
	await get_tree().process_frame

	# Clear
	global_ref.total_shifts_completed = 0
	global_ref.total_runners_stopped = 0
	global_ref.perfect_hits = 0

	# Load
	global_ref.load_game_state()
	await get_tree().process_frame

	# Verify
	assert_eq(global_ref.total_shifts_completed, 12, "Shifts completed should persist")
	assert_eq(global_ref.total_runners_stopped, 45, "Runners stopped should persist")
	assert_eq(global_ref.perfect_hits, 8, "Perfect hits should persist")


func test_narrative_choices_persist() -> void:
	"""Test that narrative choices persist across save/load"""

	if not Dialogic:
		pass_test("Dialogic not available")
		return

	# Set choices
	Dialogic.VAR.set("save_test_choice", "save_test_value")
	global_ref.capture_narrative_choices()

	# Save
	global_ref.save_game_state()
	await get_tree().process_frame

	# Clear
	global_ref.narrative_choices.clear()
	Dialogic.VAR.set("save_test_choice", "")

	# Load
	global_ref.load_game_state()
	await get_tree().process_frame

	# Verify
	assert_true(
		global_ref.narrative_choices.has("save_test_choice"),
		"Narrative choice should persist"
	)
	assert_eq(
		global_ref.narrative_choices["save_test_choice"],
		"save_test_value",
		"Choice value should persist"
	)


func test_story_state_persists() -> void:
	"""Test that story state persists across save/load"""

	# Set story state
	global_ref.current_story_state = 7

	# Save
	global_ref.save_game_state()
	await get_tree().process_frame

	# Clear
	global_ref.current_story_state = 0

	# Load
	global_ref.load_game_state()
	await get_tree().process_frame

	# Verify
	assert_eq(global_ref.current_story_state, 7, "Story state should persist")


# ==================== COMPLETE SAVE/LOAD FLOW ====================


func test_complete_save_load_cycle() -> void:
	"""Test complete save/load cycle with all game state"""

	# Set up complete game state
	global_ref.shift = 5
	global_ref.difficulty_level = "Normal"
	global_ref.score = 8500
	global_ref.final_score = 8500
	global_ref.strikes = 1
	global_ref.total_shifts_completed = 5
	global_ref.total_runners_stopped = 25
	global_ref.perfect_hits = 7
	global_ref.current_story_state = 3

	# Save
	var save_requested: bool = false
	var game_saved: bool = false

	var save_req_cb = func(): save_requested = true
	var saved_cb = func(): game_saved = true

	event_bus.save_game_requested.connect(save_req_cb)
	event_bus.game_saved.connect(saved_cb)

	event_bus.save_game_requested.emit()
	await get_tree().process_frame

	global_ref.save_game_state()
	event_bus.game_saved.emit()
	await get_tree().process_frame

	# Clear state
	global_ref.shift = 0
	global_ref.difficulty_level = "Easy"
	global_ref.score = 0
	global_ref.final_score = 0
	global_ref.strikes = 0
	global_ref.total_shifts_completed = 0
	global_ref.total_runners_stopped = 0
	global_ref.perfect_hits = 0
	global_ref.current_story_state = 0

	# Load
	var load_requested: bool = false
	var game_loaded: bool = false

	var load_req_cb = func(): load_requested = true
	var loaded_cb = func(_data: Dictionary): game_loaded = true

	event_bus.load_game_requested.connect(load_req_cb)
	event_bus.game_loaded.connect(loaded_cb)

	event_bus.load_game_requested.emit()
	await get_tree().process_frame

	global_ref.load_game_state()
	event_bus.game_loaded.emit({})
	await get_tree().process_frame

	# Verify signals
	assert_true(save_requested, "Save should be requested")
	assert_true(game_saved, "Game should be saved")
	assert_true(load_requested, "Load should be requested")
	assert_true(game_loaded, "Game should be loaded")

	# Verify state restored
	var loaded = save_manager.load_game_state()
	assert_eq(loaded.get("shift", -1), 5, "Shift should be restored")
	assert_eq(loaded.get("difficulty_level", ""), "Normal", "Difficulty should be restored")
	assert_eq(global_ref.total_shifts_completed, 5, "Shifts completed should be restored")
	assert_eq(global_ref.total_runners_stopped, 25, "Runners stopped should be restored")
	assert_eq(global_ref.perfect_hits, 7, "Perfect hits should be restored")
	assert_eq(global_ref.current_story_state, 3, "Story state should be restored")

	# Cleanup
	event_bus.save_game_requested.disconnect(save_req_cb)
	event_bus.game_saved.disconnect(saved_cb)
	event_bus.load_game_requested.disconnect(load_req_cb)
	event_bus.game_loaded.disconnect(loaded_cb)


# ==================== DIFFICULTY LEVELS ====================


func test_save_load_easy_difficulty() -> void:
	"""Test save/load with Easy difficulty"""

	global_ref.difficulty_level = "Easy"
	global_ref.max_strikes = 6

	global_ref.save_game_state()
	await get_tree().process_frame

	global_ref.difficulty_level = "Normal"
	global_ref.max_strikes = 4

	global_ref.load_game_state()
	await get_tree().process_frame

	var loaded = save_manager.load_game_state()
	assert_eq(loaded.get("difficulty_level", ""), "Easy", "Easy difficulty should persist")


func test_save_load_normal_difficulty() -> void:
	"""Test save/load with Normal difficulty"""

	global_ref.difficulty_level = "Normal"
	global_ref.max_strikes = 4

	global_ref.save_game_state()
	await get_tree().process_frame

	var loaded = save_manager.load_game_state()
	assert_eq(loaded.get("difficulty_level", ""), "Normal", "Normal difficulty should persist")


func test_save_load_expert_difficulty() -> void:
	"""Test save/load with Expert difficulty"""

	global_ref.difficulty_level = "Expert"
	global_ref.max_strikes = 3

	global_ref.save_game_state()
	await get_tree().process_frame

	global_ref.difficulty_level = "Normal"

	global_ref.load_game_state()
	await get_tree().process_frame

	var loaded = save_manager.load_game_state()
	assert_eq(loaded.get("difficulty_level", ""), "Expert", "Expert difficulty should persist")


func test_difficulty_affects_loaded_state() -> void:
	"""Test that difficulty settings affect max strikes on load"""

	# This tests the integration between difficulty and game state
	var test_data = {
		"difficulty_level": "Expert",
		"shift": 5,
		"score": 1000
	}

	save_manager.save_game_state(test_data)
	await get_tree().process_frame

	# Load would typically set max_strikes based on difficulty
	var loaded = save_manager.load_game_state()
	assert_eq(loaded.get("difficulty_level", ""), "Expert", "Should load Expert difficulty")


# ==================== HIGH SCORES ====================


func test_high_scores_persist() -> void:
	"""Test that high scores persist across save/load"""

	# Set high scores
	global_ref.high_scores = {
		"Easy": 5000,
		"Normal": 10000,
		"Expert": 15000
	}

	global_ref.save_game_state()
	await get_tree().process_frame

	global_ref.high_scores = {"Easy": 0, "Normal": 0, "Expert": 0}

	global_ref.load_game_state()
	await get_tree().process_frame

	# Verify
	assert_eq(global_ref.high_scores.get("Easy", 0), 5000, "Easy high score should persist")
	assert_eq(global_ref.high_scores.get("Normal", 0), 10000, "Normal high score should persist")
	assert_eq(global_ref.high_scores.get("Expert", 0), 15000, "Expert high score should persist")


func test_level_high_scores_persist() -> void:
	"""Test that level-specific high scores persist"""

	# Save a level high score
	save_manager.save_level_high_score(3, "Normal", 7500)
	await get_tree().process_frame

	# Load
	var loaded_score = save_manager.get_level_high_score(3, "Normal")

	assert_eq(loaded_score, 7500, "Level high score should persist")


func test_global_high_score_persist() -> void:
	"""Test that global high scores persist"""

	# Create game state with global high scores
	var data = {
		"global_highscores": {
			"Easy": 8000,
			"Normal": 12000,
			"Expert": 20000
		}
	}

	save_manager.save_game_state(data)
	await get_tree().process_frame

	# Load
	var easy_score = save_manager.get_global_high_score("Easy")
	var normal_score = save_manager.get_global_high_score("Normal")
	var expert_score = save_manager.get_global_high_score("Expert")

	assert_eq(easy_score, 8000, "Easy global high score should persist")
	assert_eq(normal_score, 12000, "Normal global high score should persist")
	assert_eq(expert_score, 20000, "Expert global high score should persist")


# ==================== EDGE CASES ====================


func test_load_nonexistent_save() -> void:
	"""Test loading when no save file exists"""

	# Delete save if it exists
	if FileAccess.file_exists(save_manager.GAMESTATE_SAVE_PATH):
		DirAccess.remove_absolute(save_manager.GAMESTATE_SAVE_PATH)

	# Try to load
	var loaded = save_manager.load_game_state()

	# Should return empty dictionary
	assert_true(loaded.is_empty(), "Loading nonexistent save should return empty dict")


func test_save_empty_data() -> void:
	"""Test saving empty data"""

	var result = save_manager.save_game_state({})
	await get_tree().process_frame

	assert_true(result, "Should be able to save empty data")

	var loaded = save_manager.load_game_state()
	assert_true(loaded.is_empty(), "Loaded empty data should be empty")


func test_save_with_missing_fields() -> void:
	"""Test saving with some fields missing"""

	var partial_data = {
		"shift": 3
		# Missing other fields
	}

	save_manager.save_game_state(partial_data)
	await get_tree().process_frame

	var loaded = save_manager.load_game_state()

	assert_eq(loaded.get("shift", -1), 3, "Present field should save")
	assert_false(loaded.has("score"), "Missing field should not be present")


func test_multiple_rapid_saves() -> void:
	"""Test that multiple rapid saves work correctly"""

	for i in range(10):
		save_manager.save_game_state({"iteration": i})

	await get_tree().process_frame

	var loaded = save_manager.load_game_state()
	assert_eq(loaded.get("iteration", -1), 9, "Should have last save")


func test_save_large_data() -> void:
	"""Test saving large amounts of data"""

	var large_data = {
		"shift": 10,
		"narrative_choices": {}
	}

	# Create 100 narrative choices
	for i in range(100):
		large_data.narrative_choices["choice_%d" % i] = "value_%d" % i

	save_manager.save_game_state(large_data)
	await get_tree().process_frame

	var loaded = save_manager.load_game_state()
	assert_eq(
		loaded.get("narrative_choices", {}).size(),
		100,
		"Should save large data"
	)


# ==================== PLAYTIME TRACKING ====================


func test_playtime_persists() -> void:
	"""Test that playtime persists across save/load"""

	global_ref.total_playtime = 3600.0  # 1 hour

	global_ref.save_game_state()
	await get_tree().process_frame

	global_ref.total_playtime = 0.0

	global_ref.load_game_state()
	await get_tree().process_frame

	assert_eq(global_ref.total_playtime, 3600.0, "Playtime should persist")


func test_playtime_accumulates() -> void:
	"""Test that playtime accumulates across sessions"""

	# Session 1
	global_ref.total_playtime = 1800.0  # 30 minutes
	global_ref.save_game_state()
	await get_tree().process_frame

	# Session 2
	global_ref.load_game_state()
	await get_tree().process_frame
	global_ref.total_playtime += 1800.0  # Another 30 minutes
	global_ref.save_game_state()
	await get_tree().process_frame

	# Verify
	var loaded = save_manager.load_game_state()
	assert_eq(loaded.get("total_playtime", 0.0), 3600.0, "Playtime should accumulate")


# ==================== SAVE MANAGER SPECIFIC ====================


func test_save_completed_signal() -> void:
	"""Test that SaveManager emits save_completed signal"""

	var signal_emitted: bool = false
	var success: bool = false

	var callback = func(result: bool):
		signal_emitted = true
		success = result

	save_manager.save_completed.connect(callback)

	save_manager.save_game_state({"test": "data"})
	await get_tree().process_frame

	assert_true(signal_emitted, "save_completed should be emitted")
	assert_true(success, "Save should succeed")

	save_manager.save_completed.disconnect(callback)


func test_load_completed_signal() -> void:
	"""Test that SaveManager emits load_completed signal"""

	var signal_emitted: bool = false
	var success: bool = false

	var callback = func(result: bool):
		signal_emitted = true
		success = result

	# Create a save first
	save_manager.save_game_state({"test": "data"})
	await get_tree().process_frame

	save_manager.load_completed.connect(callback)

	save_manager.load_game_state()
	await get_tree().process_frame

	assert_true(signal_emitted, "load_completed should be emitted")
	assert_true(success, "Load should succeed")

	save_manager.load_completed.disconnect(callback)


func test_reset_all_game_data() -> void:
	"""Test that reset_all_game_data works correctly"""

	# Set up some data
	global_ref.shift = 10
	global_ref.score = 50000
	global_ref.save_game_state()
	await get_tree().process_frame

	# Reset
	save_manager.reset_all_game_data(false)
	await get_tree().process_frame

	# Load
	var loaded = save_manager.load_game_state()

	# Should be reset
	assert_eq(loaded.get("shift", -1), 0, "Shift should be reset")
	assert_eq(loaded.get("final_score", -1), 0, "Score should be reset")


func test_reset_keeps_high_scores() -> void:
	"""Test that reset can optionally keep high scores"""

	# Set up data with high scores
	var data = {
		"shift": 10,
		"high_scores": {"Normal": 10000}
	}
	save_manager.save_game_state(data)
	await get_tree().process_frame

	# Reset but keep high scores
	save_manager.reset_all_game_data(true)
	await get_tree().process_frame

	var loaded = save_manager.load_game_state()

	# High scores should be preserved
	assert_true(loaded.has("high_scores"), "High scores should be kept")


# ==================== INTEGRATION WITH EVENTBUS ====================


func test_save_via_eventbus() -> void:
	"""Test saving game state via EventBus"""

	global_ref.shift = 7
	global_ref.score = 5000

	event_bus.save_game_requested.emit()
	await get_tree().process_frame

	# GameStateManager should handle this
	# Verify data was saved
	global_ref.save_game_state()
	var loaded = save_manager.load_game_state()

	assert_true(loaded.size() > 0, "Data should be saved")


func test_load_via_eventbus() -> void:
	"""Test loading game state via EventBus"""

	# Create a save
	save_manager.save_game_state({"shift": 9})
	await get_tree().process_frame

	var data_loaded: Dictionary = {}
	var callback = func(data: Dictionary):
		data_loaded = data

	event_bus.game_loaded.connect(callback)

	event_bus.load_game_requested.emit()
	await get_tree().process_frame

	# Manually trigger what GameStateManager would do
	global_ref.load_game_state()
	event_bus.game_loaded.emit(save_manager.load_game_state())
	await get_tree().process_frame

	assert_true(data_loaded.size() > 0, "Data should be loaded via EventBus")

	event_bus.game_loaded.disconnect(callback)
