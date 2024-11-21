extends Node

# Existing variables
var shift = 1
var final_score = 0
var quota_met = 0
var build_type = "Demo Release"
var difficulty_level = "Expert" # Can be "Easy", "Normal", or "Expert"

# New scoring system variables
var score: int = 0
var high_scores: Dictionary = {
	"Easy": 0,
	"Normal": 0,
	"Expert": 0
}

var is_fetching_leaderboard = false
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
	print("Running global init")
	if Steam.isSteamRunning():
		Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
		Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
		Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)
		print("All steam connections configured.")
		Steam.findLeaderboard("endless_expert")
		submit_score(10000)


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
		push_error("Failed to find leaderboard!")
		return
	
	# Immediately request scores
	Steam.downloadLeaderboardEntries(
		handle,
		Steam.LEADERBOARD_DATA_REQUEST_GLOBAL,
		1,
		12
	)

func _on_leaderboard_scores_downloaded(handle: int, entries: Array) -> void:
	print("leaderboard scores downloaded...")
	is_fetching_leaderboard = false
	cached_leaderboard_entries.clear()
	
	for entry in entries:
		cached_leaderboard_entries.append({
			"name": entry.steam_id_user,  # You might want to get actual Steam names
			"score": entry.score
		})
	print(cached_leaderboard_entries)

func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> void:
	if success == 1:
		print("Successfully uploaded scores!")
		# Add additional logic to use other variables passed back
	else:
		print("Failed to upload scores!")

func submit_score(score: int):
	# Update Steam leaderboard if available
	print("Submitting score, checking if Steam running")
	var details = ""
	if Steam.isSteamRunning():
		print("Steam running, fetching handle")
		var handle = get_leaderboard_name(difficulty_level)
		Steam.findLeaderboard("endless_expert")
		print("Submitting score")
		Steam.uploadLeaderboardScore(score, true, var_to_bytes(details).to_int32_array())

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
