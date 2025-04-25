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
var cached_leaderboard_entries = [{"name":"nyankind","score":"12500"}, 
									{"name": "MrBright01", "score":"11850"},  
									{"name": "ZombieWhisperer", "score":"9250"},  
									{"name": "FreshwaterFern", "score":"9100"},  
									{"name": "mniEurydice", "score":"8500"},  
									{"name": "HeartCoded", "score":"6400"},  
									{"name": "IceCreamMikey", "score":"6300"},  
									{"name": "BRACUBI", "score":"5000"},  
									{"name": "DamagedPlushie", "score":"4400"},  
									{"name": "TomNook", "score":"250"}]
var last_error_message = ""
var steam_init_success = false
var last_leaderboard_name = ""
var debug_counter = 0

# Steam API Status
var api_call_attempts = {}
var api_call_results = {}
var connected_signals = []
var pending_operations = []

# Signals
signal leaderboard_updated(entries: Array)
signal score_submitted(success: bool)

func _ready():
	# Initialize Steam connection
	if not Steam.isSteamRunning():
		LogManager.write_error("Steam is not running. Steam features will be disabled.")
		return
		
	LogManager.write_info("Configuring Steam connections...")
	steam_init_success = Steam.steamInit()
	LogManager.write_info("Steam init result: " + str(steam_init_success))
	LogManager.write_info("Steam AppID: " + str(Steam.getAppID()))
	LogManager.write_info("Steam User: " + str(Steam.getSteamID()))
	
	# Connect Steam signals
	_connect_signal(Steam.leaderboard_find_result, _on_leaderboard_find_result, "leaderboard_find_result")
	_connect_signal(Steam.leaderboard_score_uploaded, _on_leaderboard_score_uploaded, "leaderboard_score_uploaded")
	_connect_signal(Steam.leaderboard_scores_downloaded, _on_leaderboard_scores_downloaded, "leaderboard_scores_downloaded")
	
	LogManager.write_info("Steam connections configured.")

func _connect_signal(signal_ref, callback, signal_name):
	if signal_ref.is_connected(callback):
		LogManager.write_warning("Signal already connected: " + signal_name)
	else:
		signal_ref.connect(callback)
		connected_signals.append(signal_name)
		LogManager.write_info("Connected signal: " + signal_name)

func _process(_delta: float) -> void:
	# Run Steam callbacks to process Steam events
	if Steam.isSteamRunning():
		Steam.run_callbacks()
		
	# Debug periodic status updates (every 60 frames/~1 second)
	debug_counter += 1
	if debug_counter >= 60:
		debug_counter = 0
		_log_current_state()
		
	# Track pending operations timeout
	for i in range(pending_operations.size() - 1, -1, -1):
		var op = pending_operations[i]
		op.time_elapsed += _delta
		
		# If operation has been pending for more than 10 seconds, log and remove
		if op.time_elapsed > 10.0:
			LogManager.write_warning("Steam operation timed out: " + op.name)
			pending_operations.remove_at(i)

func _log_current_state():
	if is_fetching_leaderboard:
		LogManager.write_steam("Still fetching leaderboard...")
		LogManager.write_steam("Current handle: " + str(current_leaderboard_handle))
		LogManager.write_steam("Last leaderboard: " + last_leaderboard_name)
		LogManager.write_steam("Pending operations: " + str(pending_operations.size()))

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
	
	last_leaderboard_name = base_name
	LogManager.write_steam("Using leaderboard: " + base_name)
	return base_name

# Submit score to the appropriate leaderboard
func submit_score(score: int, difficulty: String = "Normal", shift: int = -1):
	LogManager.write_steam("Submitting score to Steam leaderboard: " + str(score))
	
	if not Steam.isSteamRunning():
		LogManager.write_error("Steam not running, score submission skipped")
		return false
		
	var leaderboard_name = get_leaderboard_name(difficulty, shift)
	LogManager.write_steam("Finding leaderboard: " + leaderboard_name)
	
	# Track API call
	api_call_attempts["findLeaderboard"] = api_call_attempts.get("findLeaderboard", 0) + 1
	
	# Add to pending operations
	pending_operations.append({
		"name": "submit_score_" + leaderboard_name, 
		"score": score,
		"time_elapsed": 0.0
	})
	
	# First find the leaderboard
	Steam.findLeaderboard(leaderboard_name)
	LogManager.write_steam("findLeaderboard call triggered")

# Request leaderboard entries
func request_leaderboard_entries(difficulty: String = "Normal", shift: int = -1):
	LogManager.write_steam("Getting leaderboard entries for " + difficulty + " shift " + str(shift))
	
	if not Steam.isSteamRunning():
		LogManager.write_error("Steam not running, leaderboard request skipped")
		return false
	
	var leaderboard_name = get_leaderboard_name(difficulty, shift)
	
	# Track that we're fetching
	is_fetching_leaderboard = true
	
	# Track API call
	api_call_attempts["findLeaderboard"] = api_call_attempts.get("findLeaderboard", 0) + 1
	
	# Add to pending operations
	pending_operations.append({
		"name": "request_leaderboard_" + leaderboard_name,
		"time_elapsed": 0.0
	})
	
	LogManager.write_steam("Calling findLeaderboard for: " + leaderboard_name)
	Steam.findLeaderboard(leaderboard_name)
	LogManager.write_steam("findLeaderboard call triggered")
	
	if current_leaderboard_handle != 0:
		LogManager.write_steam("Using existing handle: " + str(current_leaderboard_handle))
		# Fetch scores directly if we already have a handle
		_download_leaderboard_entries()
	

func _download_leaderboard_entries():
	# Try to fetch using current handle
	if current_leaderboard_handle != 0:
		LogManager.write_steam("Downloading entries with handle: " + str(current_leaderboard_handle))
		
		# Track API call
		api_call_attempts["downloadLeaderboardEntries"] = api_call_attempts.get("downloadLeaderboardEntries", 0) + 1
		
		Steam.downloadLeaderboardEntries(
			1,  # Start rank
			12,  # End rank
			Steam.LEADERBOARD_DATA_REQUEST_GLOBAL,
			current_leaderboard_handle
		)
		
		LogManager.write_steam("downloadLeaderboardEntries call triggered")
	else:
		LogManager.write_error("Cannot download leaderboard entries - handle is 0")
		return false

# Signal handlers for Steam leaderboard operations
func _on_leaderboard_find_result(handle: int, found: bool) -> void:
	LogManager.write_steam("Leaderboard find result - Handle: " + str(handle) + ", Found: " + str(found))
	
	# Track API result
	api_call_results["findLeaderboard"] = {
		"handle": handle,
		"found": found,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	if not found:
		last_error_message = "Failed to find Steam leaderboard!"
		LogManager.write_error(last_error_message)
		score_submitted.emit(false)
		is_fetching_leaderboard = false
		return
		
	LogManager.write_steam("Leaderboard found, handle: " + str(handle))
	current_leaderboard_handle = handle
	
	# Check if we're in score submission or just fetching
	var submitting_score = false
	for op in pending_operations:
		if op.name.begins_with("submit_score_"):
			submitting_score = true
			LogManager.write_steam("Processing pending score submission: " + str(op.score))
			
			# Create empty PackedInt32Array for details
			var details = PackedInt32Array()
			
			# Track API call
			api_call_attempts["uploadLeaderboardScore"] = api_call_attempts.get("uploadLeaderboardScore", 0) + 1
			
			LogManager.write_steam("Uploading score " + str(op.score) + " to leaderboard")
			Steam.uploadLeaderboardScore(op.score, true, details, handle)
			LogManager.write_steam("uploadLeaderboardScore call triggered")
			break
	
	# If not submitting score, just download entries
	if not submitting_score:
		LogManager.write_steam("Not submitting score, just downloading entries")
		_download_leaderboard_entries()

func _on_leaderboard_score_uploaded(success: int, handle: int, score_details: Dictionary) -> void:
	LogManager.write_steam("Score upload result - Success: " + str(success) + ", Handle: " + str(handle))
	LogManager.write_steam("Score details: " + str(score_details))
	
	# Track API result
	api_call_results["uploadLeaderboardScore"] = {
		"success": success,
		"handle": handle,
		"details": score_details,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Remove pending submission operation
	for i in range(pending_operations.size() - 1, -1, -1):
		var op = pending_operations[i]
		if op.name.begins_with("submit_score_"):
			pending_operations.remove_at(i)
	
	if success == 1:
		LogManager.write_steam("Successfully uploaded score to Steam leaderboard!")
		LogManager.write_steam("Requesting updated leaderboard entries...")
		
		# Request updated leaderboard entries
		_download_leaderboard_entries()
		
		LogManager.write_steam("Entries requested.")
		score_submitted.emit(true)
	else:
		last_error_message = "Failed to upload score to Steam leaderboard"
		LogManager.write_error(last_error_message)
		score_submitted.emit(false)
		is_fetching_leaderboard = false

func _on_leaderboard_scores_downloaded(message: String, this_leaderboard_handle: int, result: Array) -> void:
	LogManager.write_steam("Scores downloaded message: " + message)
	LogManager.write_steam("Leaderboard handle: " + str(this_leaderboard_handle) + ", Entries: " + str(result.size()))
	
	# Track API result
	api_call_results["downloadLeaderboardEntries"] = {
		"message": message,
		"handle": this_leaderboard_handle,
		"count": result.size(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	is_fetching_leaderboard = false
	cached_leaderboard_entries.clear()
	
	# Remove pending download operation
	for i in range(pending_operations.size() - 1, -1, -1):
		var op = pending_operations[i]
		if op.name.begins_with("request_leaderboard_"):
			pending_operations.remove_at(i)
	
	if result.is_empty():
		LogManager.write_warning("No leaderboard entries returned")
		leaderboard_updated.emit(cached_leaderboard_entries)
		return
	
	LogManager.write_steam("Processing " + str(result.size()) + " leaderboard entries")
	
	for entry in result:
		LogManager.write_steam("Entry: " + str(entry))
		
		# Get the player name from Steam
		var steam_id = entry.get("steam_id", 0)
		var player_name = "Unknown"
		
		if steam_id != 0:
			player_name = Steam.getFriendPersonaName(steam_id)
			if player_name.is_empty():
				player_name = "Player " + str(entry.get("global_rank", 0))
		
		cached_leaderboard_entries.append({
			"rank": entry.get("global_rank", 0),
			"name": player_name,
			"score": entry.get("score", 0)
		})
	
	LogManager.write_steam("Updated cached leaderboard entries: " + str(cached_leaderboard_entries.size()))
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

# Debug function to log current state
func dump_debug_info() -> String:
	var debug_info = "=== STEAM MANAGER DEBUG INFO ===\n"
	debug_info += "Steam running: " + str(Steam.isSteamRunning()) + "\n"
	debug_info += "Steam initialized: " + str(steam_init_success) + "\n"
	debug_info += "Steam AppID: " + str(Steam.getAppID()) + "\n"
	debug_info += "Steam UserID: " + str(Steam.getSteamID()) + "\n"
	debug_info += "Current leaderboard: " + last_leaderboard_name + "\n"
	debug_info += "Current handle: " + str(current_leaderboard_handle) + "\n"
	debug_info += "Is fetching: " + str(is_fetching_leaderboard) + "\n"
	debug_info += "Last error: " + last_error_message + "\n"
	debug_info += "Cached entries: " + str(cached_leaderboard_entries.size()) + "\n"
	debug_info += "Connected signals: " + str(connected_signals) + "\n"
	debug_info += "Pending operations: " + str(pending_operations.size()) + "\n"
	debug_info += "API calls attempted: " + str(api_call_attempts) + "\n"
	debug_info += "API call results: " + str(api_call_results) + "\n"
	
	LogManager.write_info(debug_info)
	return debug_info
