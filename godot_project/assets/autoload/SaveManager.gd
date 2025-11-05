extends Node

var high_scores = {
	"level_highscores": {
		"1": {  # Level ID as string
			"Easy": 100,
			"Normal": 200,
			"Expert": 300
		},
		"2": {
			"Easy": 150,
			"Normal": 250,
			"Expert": 350
		}
	},
	"global_highscores": {
		"Easy": 500,
		"Normal": 750,
		"Expert": 1000
	}
}


# Save file paths
const GAMESTATE_SAVE_PATH = "user://gamestate.save"
const HIGHSCORES_SAVE_PATH = "user://highscores.save"

# Signals
signal save_completed(success: bool)
signal load_completed(success: bool)

# Save the current game state
func save_game_state(data: Dictionary) -> bool:
	# Remove difficulty_level if it's in the data
	var save_file = FileAccess.open(GAMESTATE_SAVE_PATH, FileAccess.WRITE)
	if save_file:
		save_file.store_var(data)
		
		# Upload to Steam Cloud if available
		if Steam.isSteamRunning():
			# SteamManager.upload_cloud_saves()
			LogManager.write_info("todo: upload steam cloud saves")
			pass
		
		save_completed.emit(true)
		return true
	else:
		push_error("Failed to save game state!")
		save_completed.emit(false)
		return false

# Load the game state
func load_game_state() -> Dictionary:
	var data = {}
	var success = false
	
	# Try loading from cloud first if Steam is running
	if Steam.isSteamRunning() and Steam.fileExists("gamestate.save"):
		var file_size = Steam.getFileSize("gamestate.save")
		var file_content = Steam.fileRead("gamestate.save", file_size)
		
		var temp_file = FileAccess.open("user://temp_gamestate.save", FileAccess.WRITE)
		if temp_file:
			temp_file.store_buffer(file_content)
			temp_file = FileAccess.open("user://temp_gamestate.save", FileAccess.READ)
			data = temp_file.get_var()
			success = true
	
	# Fall back to local save if cloud save fails or Steam isn't running
	elif FileAccess.file_exists(GAMESTATE_SAVE_PATH):
		var save_file = FileAccess.open(GAMESTATE_SAVE_PATH, FileAccess.READ)
		if save_file:
			data = save_file.get_var()
			success = true
			
	load_completed.emit(success)
	return data

# Save high scores
func save_high_scores(high_scores: Dictionary) -> bool:
	var save_file = FileAccess.open(HIGHSCORES_SAVE_PATH, FileAccess.WRITE)
	if save_file:
		save_file.store_var(high_scores)
		
		# Upload to Steam Cloud if available
		if Steam.isSteamRunning():
			SteamManager.upload_cloud_saves()
			
		return true
	
	return false

# Load high scores
func load_high_scores() -> Dictionary:
	var high_scores = {"Easy": 0, "Normal": 0, "Expert": 0}
	
	if FileAccess.file_exists(HIGHSCORES_SAVE_PATH):
		var save_file = FileAccess.open(HIGHSCORES_SAVE_PATH, FileAccess.READ)
		if save_file:
			high_scores = save_file.get_var()
	
	return high_scores

# Level progress functions
# When creating dictionaries, consistently use string keys
func save_level_progress(max_level: int, current_level: int, level_highscores: Dictionary = {}) -> bool:
	var game_state = load_game_state()
	
	# Always convert integer keys to strings
	game_state["max_level_reached"] = max(game_state.get("max_level_reached", 0), max_level)
	game_state["current_level"] = current_level
	
	# Convert all integer keys to strings consistently
	var string_keyed_highscores = {}
	for level_id in level_highscores:
		string_keyed_highscores[str(level_id)] = level_highscores[level_id]
	
	# Now use the string-keyed dictionary
	if not string_keyed_highscores.is_empty():
		# Initialize if needed
		if not game_state.has("level_highscores"):
			game_state["level_highscores"] = {}
			
		# Merge with existing
		for level_key in string_keyed_highscores:
			if not game_state["level_highscores"].has(level_key):
				game_state["level_highscores"][level_key] = {}
				
			for difficulty in string_keyed_highscores[level_key]:
				# Update only if new score is higher
				var current = 0 # game_state["level_highscores"][level_key].get(difficulty, 0)
				var new_score = 0 # string_keyed_highscores[level_key][difficulty]
				if new_score > current:
					game_state["level_highscores"][level_key][difficulty] = new_score
	
	return save_game_state(game_state)

# Get the highest level the player has reached
func get_max_level_reached() -> int:
	var game_state = load_game_state()
	return game_state.get("max_level_reached", 0)

# Get the current level the player is on
func get_current_level() -> int:
	var game_state = load_game_state()
	return game_state.get("current_level", 0)

# Save high score for a specific level and difficulty
func save_level_high_score(level: int, difficulty: String, score: int) -> bool:
	var game_state = load_game_state()
	
	# Initialize the level high scores dictionary if it doesn't exist
	if not game_state.has("level_highscores"):
		game_state["level_highscores"] = {}
		
	# Initialize the level entry if it doesn't exist
	var level_key = str(level)  # Convert level to string
	if not game_state["level_highscores"].has(level_key):
		game_state["level_highscores"][level_key] = {}
		
	# Only update if new score is higher
	var current_high_score = get_level_high_score(level, difficulty)
	if score > current_high_score:
		game_state["level_highscores"][level_key][difficulty] = score
		
		# Also update global high score if needed
		if not game_state.has("global_highscores"):
			game_state["global_highscores"] = {}
			
		if not game_state["global_highscores"].has(difficulty) or score > game_state["global_highscores"][difficulty]:
			game_state["global_highscores"][difficulty] = score
			
		return save_game_state(game_state)
		
	return true  # No need to save, existing score is higher

# Get high score for a specific level and difficulty
func get_level_high_score(level: int, difficulty: String) -> int:
	var game_state = load_game_state()
	
	# Get the level high scores
	var level_highscores = game_state.get("level_highscores", {})
	var level_key = str(level)  # Convert level to string
	
	# Check if this level has high scores
	if level_highscores.has(level_key):
		# Get the high score for this difficulty, or 0 if it doesn't exist
		return level_highscores[level_key].get(difficulty, 0)
		
	return 0

## Get global high score for a difficulty
func get_global_high_score(difficulty: String) -> int:
	var game_state = load_game_state()
	var global_highscores = game_state.get("global_highscores", {})
	return global_highscores.get(difficulty, 0)

# Reset all game state data
func reset_all_game_data(keep_high_scores: bool = true) -> bool:
	var high_scores = {}

	# Keep high scores if requested
	if keep_high_scores:
		high_scores = load_high_scores()

	# Create a fresh game state
	var game_state = {
		"shift": 0,
		"current_level": 0,
		"max_level_reached": 0,
		"final_score": 0,
		"quota_met": 0,
		"quota_target": 8,
		"difficulty_level": "Normal",
		"high_scores": high_scores,
		"story_state": 0,
		"level_highscores": {},
		"current_game_stats": {},
		"narrative_choices": {},
		"total_shifts_completed": 0,
		"total_runners_stopped": 0,
		"perfect_hits": 0
	}

	return save_game_state(game_state)
