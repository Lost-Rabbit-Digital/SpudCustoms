extends Node

# Steam Achievement IDs
const ACHIEVEMENTS = {
	"SAVIOR_OF_SPUD": "savior_of_spud",
	"ROOKIE_OFFICER": "rookie_customs_officer",
	"VETERAN_OFFICER": "customs_veteran",
	"MASTER_OFFICER": "master_of_customs",
	"SHARPSHOOTER": "sharpshooter",
	"PERFECT_SHOT": "perfect_shot",
	"BORDER_DEFENDER": "border_defender",
	"HIGH_SCORER": "high_scorer",
	"SCORE_LEGEND": "score_legend",
}

# Leaderboard variables
var is_fetching_leaderboard = false
var current_leaderboard_handle = 0
var cached_leaderboard_entries = [{"name":"HackerMan","score":"1250"}, {"name": "HeartCoded", "score":"800"}]

# Signals
signal leaderboard_updated(entries: Array)
signal score_submitted(success: bool)

func _ready():
	# Initialize Steam connection
	if not Steam.isSteamRunning():
		push_warning("Steam is not running. Steam features will be disabled.")
		return
		
	print("Configuring Steam connections...")
	
	# Connect Steam signals
	Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
	Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
	Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)
	
	print("Steam connections configured.")

func _process(_delta: float) -> void:
	# Run Steam callbacks to process Steam events
	if Steam.isSteamRunning():
		Steam.run_callbacks()

# Get leaderboard name based on difficulty and shift
func get_leaderboard_name(difficulty: String = "", shift: int = -1) -> String:
	var base_name = ""
	
	# Handle endless mode vs. shift mode
	if shift < 0 or shift >= 100:  # Assume very high numbers are endless mode
		# Endless mode leaderboards
		match difficulty:
			"Easy": base_name = "endless_easy"
			"Normal": base_name = "endless_normal"
			"Expert": base_name = "endless_expert"
			_: base_name = "endless_normal"
	else:
		# Specific shift leaderboards - now with proper naming
		base_name = "shift_%d_%s" % [shift, difficulty.to_lower()]
	
	print("Using leaderboard: " + base_name)
	return base_name

# Submit score to the appropriate leaderboard
func submit_score(score: int, difficulty: String = "Normal", shift: int = -1) -> bool:
	print("Submitting score to Steam leaderboard")
	
	if not Steam.isSteamRunning():
		print("Steam not running, score submission skipped")
		return false
		
	var leaderboard_name = get_leaderboard_name(difficulty, shift)
	print("Finding leaderboard: ", leaderboard_name)
	
	# First find the leaderboard
	Steam.findLeaderboard(leaderboard_name)
	return true

# Request leaderboard entries
func request_leaderboard_entries(difficulty: String = "Normal", shift: int = -1) -> bool:
	print("Getting leaderboard entries")
	
	if not Steam.isSteamRunning():
		print("Steam not running, leaderboard request skipped")
		return false
	
	# If we don't have a handle for this leaderboard, get it
	is_fetching_leaderboard = true
	Steam.findLeaderboard(get_leaderboard_name(difficulty, shift))
	
	# Fetch the scores if we have a handle
	print("Fetching scores")
	Steam.downloadLeaderboardEntries(1, 12, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL, current_leaderboard_handle)
	Steam.run_callbacks()
	return true

# Signal handlers for Steam leaderboard operations
func _on_leaderboard_find_result(handle: int, found: bool) -> void:
	if not found:
		push_warning("Failed to find Steam leaderboard!")
		score_submitted.emit(false)
		return
		
	print("Leaderboard found, handle: ", handle)
	current_leaderboard_handle = handle
	
	# Create empty PackedInt32Array for details
	var details = PackedInt32Array()
	
	print("Uploading score to leaderboard")
	Steam.uploadLeaderboardScore(Global.score, true, details, handle)

func _on_leaderboard_score_uploaded(success: int, handle: int, score_details: Dictionary) -> void:
	if success == 1:
		print("Successfully uploaded score to Steam leaderboard!")
		print("Score details: ", score_details)
		print("Requesting updated leaderboard entries...")
		
		# Request updated leaderboard entries
		Steam.downloadLeaderboardEntries(
			1,  # Start rank
			12,  # End rank
			Steam.LEADERBOARD_DATA_REQUEST_GLOBAL,
			handle
		)
		print("Entries requested.")
		score_submitted.emit(true)
	else:
		push_warning("Failed to upload score to Steam leaderboard")
		score_submitted.emit(false)

func _on_leaderboard_scores_downloaded(message: String, this_leaderboard_handle: int, result: Array) -> void:
	print("Scores downloaded message: %s" % message)
	print("Leaderboard scores downloaded")
	is_fetching_leaderboard = false
	cached_leaderboard_entries.clear()
	print("Entries include:") 
	print(result)
	
	for entry in result:
		print(entry)
		# Get the player name from Steam
		var player_name = Steam.getFriendPersonaName(entry.steam_id)
		cached_leaderboard_entries.append({
			"rank": entry.global_rank,
			"name": player_name,
			"score": entry.score
		})
	
	print("Updated cached leaderboard entries: ", cached_leaderboard_entries)
	leaderboard_updated.emit(cached_leaderboard_entries)

# Achievement handling
func check_achievements(total_shifts_completed: int, total_runners_stopped: int, perfect_hits: int, score: int, current_story_state: int):
	if not Steam.isSteamRunning():
		return
		
	# First shift completion
	if total_shifts_completed == 1:
		Steam.setAchievement(ACHIEVEMENTS.ROOKIE_OFFICER)
		
	# Shift milestones
	if total_shifts_completed >= 10:
		Steam.setAchievement(ACHIEVEMENTS.VETERAN_OFFICER)
	if total_shifts_completed >= 25:
		Steam.setAchievement(ACHIEVEMENTS.MASTER_OFFICER)
		
	# Runner achievements
	if total_runners_stopped >= 10:
		Steam.setAchievement(ACHIEVEMENTS.SHARPSHOOTER)
	if total_runners_stopped >= 50:
		Steam.setAchievement(ACHIEVEMENTS.BORDER_DEFENDER)
	if perfect_hits >= 5:
		Steam.setAchievement(ACHIEVEMENTS.PERFECT_SHOT)
		
	# Score achievements
	if score >= 10000:
		Steam.setAchievement(ACHIEVEMENTS.HIGH_SCORER)
	if score >= 50000:
		Steam.setAchievement(ACHIEVEMENTS.SCORE_LEGEND)
		
	# Story completion
	if current_story_state >= 11:
		Steam.setAchievement(ACHIEVEMENTS.SAVIOR_OF_SPUD)

# Update Steam stats
func update_steam_stats(total_shifts_completed: int, total_runners_stopped: int, perfect_hits: int, score: int):
	if not Steam.isSteamRunning():
		return
		
	Steam.setStatInt("total_shifts", total_shifts_completed)
	Steam.setStatInt("runners_stopped", total_runners_stopped)
	Steam.setStatInt("perfect_hits", perfect_hits)
	Steam.setStatInt("high_score", score)
	Steam.storeStats() # Important: Actually saves stats to Steam

# Cloud save operations
func download_cloud_saves():
	if not Steam.isSteamRunning():
		return false
	var success = true
	
	if Steam.fileExists("gamestate.save"):
		var file_size = Steam.getFileSize("gamestate.save")
		var file_content = Steam.fileRead("gamestate.save", file_size)
		
		var local_file = FileAccess.open("user://gamestate.save", FileAccess.WRITE)
		if local_file:
			local_file.store_buffer(file_content)
		else:
			success = false
			
	if Steam.fileExists("highscores.save"):
		var scores_size = Steam.getFileSize("highscores.save")
		var scores_content = Steam.fileRead("highscores.save", scores_size)
		
		var local_scores = FileAccess.open("user://highscores.save", FileAccess.WRITE)
		if local_scores:
			local_scores.store_buffer(scores_content)
		else:
			success = false
			
	return success

# Upload save files to Steam Cloud
func upload_cloud_saves():
	if not Steam.isSteamRunning():
		return false
		
	var success = true
	
	if FileAccess.file_exists("user://gamestate.save"):
		success = success and Steam.fileWrite("gamestate.save", FileAccess.get_file_as_bytes("user://gamestate.save"))
		
	if FileAccess.file_exists("user://highscores.save"):
		success = success and Steam.fileWrite("highscores.save", FileAccess.get_file_as_bytes("user://highscores.save"))
		
	return success
