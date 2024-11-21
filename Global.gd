extends Node

# Existing variables
var shift = 1
var final_score = 0
var quota_met = 0
var build_type = "Full Release"
var difficulty_level = "Expert" # Can be "Easy", "Normal", or "Expert"

# New scoring system variables
var score: int = 0
var high_scores: Dictionary = {
	"Easy": 0,
	"Normal": 0,
	"Expert": 0
}

var is_fetching_leaderboard = false
var current_leaderboard_handle = 0
var cached_leaderboard_entries = []

# Signals
signal score_updated(new_score: int)
signal high_score_achieved(difficulty: String, score: int)

func _ready():
	# Initialize score to final_score if it exists
	Steam.steamInit()
	score = final_score
	load_high_scores()
	
	
func _init():
	if Steam.isSteamRunning():
		print("Configuring Steam connections...")
		Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
		Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
		Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)
		print("Steam connections configured.")

# Helper function to get leaderboard name based on difficulty
func get_leaderboard_name(difficulty: String = "") -> String:
	if difficulty.is_empty():
		difficulty = difficulty_level
		
	match difficulty:
		"Easy": return "endless_easy"
		"Normal": return "endless_normal"
		"Expert": return "endless_expert"
		_: return "endless_normal"

func get_leaderboard_entries(difficulty: String = "") -> Array:
	print("GLOBAL: Getting leaderboard entries")
	if difficulty.is_empty():
		difficulty = difficulty_level
	
	if not Steam.isSteamRunning():
		print("Loading dummy data")
		# Return dummy data for testing when Steam isn't available
		return [
			{"name": "BroHeartTTV", "score": 15750},
			{"name": "LRDStudio", "score": 8600},
			{"name": "Maaack", "score": 7200},
			{"name": "IrishJohn", "score": 6980},
			{"name": "FreshWaterFern", "score": 6540},
			{"name": "AtegonDev", "score": 5300},
			{"name": "OtterMakesGames", "score": 5200},
			{"name": "nan0dev", "score": 4700},
			{"name": "imlergan", "score": 4440},
			{"name": "KittyKatsuVT", "score": 4300},
			{"name": "nhancodes", "score": 4150},
			{"name": "2NerdyNerds", "score": 4100}
		]
	
	# If we don't have a handle for this difficulty, get it
	is_fetching_leaderboard = true
	Steam.findLeaderboard(get_leaderboard_name(difficulty))
	# Return cached entries while we wait
	# return cached_leaderboard_entries
	
	# If we have a handle, fetch the scores
	print("Fetching scores")
	Steam.downloadLeaderboardEntries(Steam.LEADERBOARD_DATA_REQUEST_GLOBAL,
		1,
		12  # Get top 12 entries
	)
	
	return cached_leaderboard_entries

func _on_leaderboard_find_result(handle: int, found: bool) -> void:
	if not found:
		print("Failed to find leaderboard!")
		return
		
	print("Leaderboard found, handle: ", handle)
	current_leaderboard_handle = handle
	
	# Create empty PackedInt32Array for details
	var details = PackedInt32Array()
	
	print("Uploading score to leaderboard")
	Steam.uploadLeaderboardScore(
		handle,  # Leaderboard handle
		score,   # Current score
		details  # Empty details array
	)

func _on_leaderboard_score_uploaded(success: int, handle: int, score_details: Dictionary) -> void:
	if success == 1:
		print("Successfully uploaded score to Steam leaderboard!")
		print("Score details: ", score_details)
		
		# Request updated leaderboard entries
		Steam.downloadLeaderboardEntries(
			handle,
			Steam.LEADERBOARD_DATA_REQUEST_GLOBAL,
			1,  # Start rank
			12  # End rank
		)
	else:
		print("Failed to upload score to Steam leaderboard")

func _on_leaderboard_scores_downloaded(handle: int, entries: Array) -> void:
	print("Leaderboard scores downloaded")
	is_fetching_leaderboard = false
	cached_leaderboard_entries.clear()
	
	for entry in entries:
		# Get the player name from Steam
		var player_name = Steam.getFriendPersonaName(entry.steam_id_user)
		cached_leaderboard_entries.append({
			"name": player_name,
			"score": entry.score
		})
	print("Updated cached leaderboard entries: ", cached_leaderboard_entries)

func submit_score(score: int):
	print("Submitting score to Steam leaderboard")
	if not Steam.isSteamRunning():
		print("Steam not running, score submission skipped")
		return false
		
	var leaderboard_name = get_leaderboard_name(difficulty_level)
	print("Finding leaderboard: ", leaderboard_name)
	
	# First find the leaderboard
	Steam.findLeaderboard(leaderboard_name)
	return true

# Update your add_score function to also update Steam leaderboards
func add_score(points: int):
	score += points
	final_score = score
	score_updated.emit(score)
	
	# Check for high score
	if score > high_scores[difficulty_level]:
		high_scores[difficulty_level] = score
		high_score_achieved.emit(difficulty_level, score)
		save_high_scores()


func reset_score():
	score = 0
	final_score = 0
	score_updated.emit(score)

func reset_shift():
	shift = 1
	quota_met = 0

func advance_shift():
	shift += 1
	save_game_state()

func save_game_state():
	var save_data = {
		"shift": shift,
		"final_score": final_score,
		"quota_met": quota_met,
		"difficulty_level": difficulty_level,
		"high_scores": high_scores
	}
	
	var save_file = FileAccess.open("user://gamestate.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_data)

func load_game_state():
	if FileAccess.file_exists("user://gamestate.save"):
		var save_file = FileAccess.open("user://gamestate.save", FileAccess.READ)
		if save_file:
			var data = save_file.get_var()
			shift = data.get("shift", 1)
			final_score = data.get("final_score", 0)
			quota_met = data.get("quota_met", 0)
			difficulty_level = data.get("difficulty_level", "Expert")
			high_scores = data.get("high_scores", {"Easy": 0, "Normal": 0, "Expert": 0})
			score = final_score
			score_updated.emit(score)

func save_high_scores():
	var save_file = FileAccess.open("user://highscores.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(high_scores)

func load_high_scores():
	if FileAccess.file_exists("user://highscores.save"):
		var save_file = FileAccess.open("user://highscores.save", FileAccess.READ)
		if save_file:
			high_scores = save_file.get_var()

func get_high_score(difficulty: String = "") -> int:
	if difficulty.is_empty():
		difficulty = difficulty_level
	return high_scores.get(difficulty, 0)

func set_difficulty(new_difficulty: String):
	if new_difficulty in ["Easy", "Normal", "Expert"]:
		difficulty_level = new_difficulty
		save_game_state()

# Helper function to format score with commas
func format_score(value: int) -> String:
	var formatted = ""
	var str_value = str(value)
	var count = 0
	
	for i in range(str_value.length() - 1, -1, -1):
		if count == 3:
			formatted = "," + formatted
			count = 0
		formatted = str_value[i] + formatted
		count += 1
	
	return formatted

# Debug function to reset everything
func reset_all():
	score = 0
	final_score = 0
	shift = 1
	quota_met = 0
	high_scores = {"Easy": 0, "Normal": 0, "Expert": 0}
	save_game_state()
	save_high_scores()
