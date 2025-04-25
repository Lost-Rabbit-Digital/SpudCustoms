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
var cached_leaderboard_entries = []
var last_error_message = ""
var steam_init_success = false
var last_leaderboard_name = ""
var debug_counter = 0
var steam_app_id = 0
var owns_app = false

# Leaderboard state machine
enum LeaderboardState {
	IDLE,
	FINDING,
	UPLOADING,
	DOWNLOADING,
	COMPLETED,
	ERROR
}
var current_leaderboard_state = LeaderboardState.IDLE

# Steam API Status tracking
var api_call_attempts = {}
var api_call_results = {}
var connected_signals = []
var pending_operations = []

# Signals
signal leaderboard_updated(entries: Array)
signal score_submitted(success: bool)
signal steam_status_changed(connected: bool)

func _ready():
	# Initialize Steam connection
	if not Steam.isSteamRunning():
		LogManager.write_error("Steam is not running. Steam features will be disabled.")
		emit_signal("steam_status_changed", false)
		return
		
	LogManager.write_info("Configuring Steam connections...")
	steam_init_success = Steam.steamInit()
	
	if not steam_init_success:
		LogManager.write_error("Steam failed to initialize!")
		emit_signal("steam_status_changed", false)
		return
	
	# Check Steam App ID
	steam_app_id = Steam.getAppID()
	LogManager.write_info("Steam init result: " + str(steam_init_success))
	LogManager.write_info("Steam AppID: " + str(steam_app_id))
	LogManager.write_info("Steam User: " + str(Steam.getSteamID()))
	LogManager.write_info("Steam Logged On: " + str(Steam.loggedOn()))
	
	# Verify app ownership
	_check_app_ownership()
	
	# Connect Steam signals with error handling
	_connect_signal(Steam.leaderboard_find_result, _on_leaderboard_find_result, "leaderboard_find_result")
	_connect_signal(Steam.leaderboard_score_uploaded, _on_leaderboard_score_uploaded, "leaderboard_score_uploaded")
	_connect_signal(Steam.leaderboard_scores_downloaded, _on_leaderboard_scores_downloaded, "leaderboard_scores_downloaded")
	
	LogManager.write_info("Steam connections configured.")
	emit_signal("steam_status_changed", true)
	
	# Setup recurring status check
	_create_status_check_timer()

func _check_app_ownership():
	# Check if the user owns the current app
	owns_app = false
	
	# First check if we're in Steam's official app context
	var is_steam_running = Steam.isSteamRunning()
	if is_steam_running:
		# Get app ownership through Steam API
		owns_app = Steam.isSubscribed()
		LogManager.write_info("Steam app ownership check: " + str(owns_app))
		
		# If we're in a dev environment, report status
		if Steam.isSubscribedFromFreeWeekend():
			LogManager.write_info("User has free weekend access")
		
		if Steam.isDLCInstalled(steam_app_id):
			LogManager.write_info("App is installed as DLC")
			
		if Steam.isSubscribedApp(steam_app_id):
			LogManager.write_info("User is specifically subscribed to this app")
			owns_app = true
	else:
		LogManager.write_warning("Cannot check app ownership - Steam is not running")
	
	# Development fallback - always enable features in dev mode
	if OS.has_feature("editor") || OS.has_feature("debug"):
		LogManager.write_info("Development mode detected - enabling Steam features regardless of ownership")
		owns_app = true
	
	return owns_app

func _connect_signal(signal_ref, callback, signal_name):
	if not signal_ref.is_connected(callback):
		signal_ref.connect(callback)
		connected_signals.append(signal_name)
		LogManager.write_info("Connected signal: " + signal_name)
	else:
		LogManager.write_warning("Signal already connected: " + signal_name)

func _create_status_check_timer():
	var timer = Timer.new()
	timer.wait_time = 5.0  # Check status every 5 seconds
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_check_steam_status)
	add_child(timer)

func _check_steam_status():
	var is_running = Steam.isSteamRunning()
	var is_logged_on = Steam.loggedOn()
	
	if !is_running || !is_logged_on:
		LogManager.write_warning("Steam status changed - Running: " + str(is_running) + ", Logged on: " + str(is_logged_on))
		emit_signal("steam_status_changed", false)
	
func _process(delta: float) -> void:
	# Run Steam callbacks to process Steam events
	if Steam.isSteamRunning():
		Steam.run_callbacks()
		
	# Debug periodic status updates (every 60 frames/~1 second)
	debug_counter += 1
	if debug_counter >= 60:
		debug_counter = 0
		if is_fetching_leaderboard:
			_log_current_state()
		
	# Track pending operations timeout
	for i in range(pending_operations.size() - 1, -1, -1):
		var op = pending_operations[i]
		op.time_elapsed += delta
		
		# If operation has been pending for more than 10 seconds, log and remove
		if op.time_elapsed > 10.0:
			LogManager.write_warning("Steam operation timed out: " + op.name)
			pending_operations.remove_at(i)
			
			# If this was a leaderboard operation, reset the state
			if op.name.begins_with("leaderboard_") && current_leaderboard_state != LeaderboardState.COMPLETED:
				current_leaderboard_state = LeaderboardState.ERROR
				is_fetching_leaderboard = false
				last_error_message = "Operation timed out: " + op.name
				
				# Notify UI of failure
				if op.name.begins_with("leaderboard_download"):
					emit_signal("leaderboard_updated", [])
				elif op.name.begins_with("leaderboard_upload"):
					emit_signal("score_submitted", false)

func _log_current_state():
	if is_fetching_leaderboard:
		LogManager.write_steam("Leaderboard state: " + LeaderboardState.keys()[current_leaderboard_state])
		LogManager.write_steam("Current leaderboard: " + last_leaderboard_name)
		LogManager.write_steam("Current handle: " + str(current_leaderboard_handle))
		LogManager.write_steam("Pending operations: " + str(pending_operations.size()))
		LogManager.write_steam("Cached entries: " + str(cached_leaderboard_entries.size()))

# Get leaderboard name based on difficulty and shift
func get_leaderboard_name(difficulty: String = "", shift: int = -1) -> String:
	if difficulty.is_empty():
		difficulty = "Normal"
	
	var base_name = ""
	
	# Handle endless mode vs. shift mode - use consistent naming!
	if shift < 0 or shift >= 100:  # Assume very high numbers are endless mode
		# Endless mode leaderboards
		base_name = "endless_" + difficulty.to_lower()
	else:
		# Specific shift leaderboards
		base_name = "shift_" + str(shift) + "_" + difficulty.to_lower()
	
	last_leaderboard_name = base_name
	LogManager.write_steam("Using leaderboard: " + base_name)
	return base_name

# Submit score to the appropriate leaderboard
func submit_score(score: int, difficulty: String = "Normal", shift: int = -1) -> bool:
	LogManager.write_steam("Submitting score to Steam leaderboard: " + str(score))
	
	# Verify Steam is running and user is logged in
	if not _verify_steam_connection():
		LogManager.write_error("Steam not running or user not logged in, score submission skipped")
		emit_signal("score_submitted", false)
		return false
	
	# Don't allow multiple requests at once
	if is_fetching_leaderboard && current_leaderboard_state != LeaderboardState.IDLE:
		LogManager.write_warning("Leaderboard operation already in progress, cannot submit score")
		emit_signal("score_submitted", false)
		return false
		
	# Get leaderboard name
	var leaderboard_name = get_leaderboard_name(difficulty, shift)
	LogManager.write_steam("Finding leaderboard for score submission: " + leaderboard_name)
	
	# Start the leaderboard state machine
	current_leaderboard_state = LeaderboardState.FINDING
	is_fetching_leaderboard = true
	
	# Reset the handle to ensure we get a fresh one
	current_leaderboard_handle = 0
	
	# Track API call
	api_call_attempts["findLeaderboard"] = api_call_attempts.get("findLeaderboard", 0) + 1
	
	# Add to pending operations
	pending_operations.append({
		"name": "leaderboard_upload_" + leaderboard_name, 
		"score": score,
		"time_elapsed": 0.0
	})
	
	# First find the leaderboard - using void call properly
	Steam.findLeaderboard(leaderboard_name)
	LogManager.write_steam("findLeaderboard call triggered")
	
	# Return true to indicate the request was started
	return true

# Request leaderboard entries
func request_leaderboard_entries(difficulty: String = "Normal", shift: int = -1) -> bool:
	LogManager.write_steam("Getting leaderboard entries for " + difficulty + " shift " + str(shift))
	
	# Verify Steam is running and user is logged in
	if not _verify_steam_connection():
		LogManager.write_error("Steam not running or user not logged in, leaderboard request skipped")
		emit_signal("leaderboard_updated", [])
		return false
	
	# Don't allow multiple requests at once
	if is_fetching_leaderboard && current_leaderboard_state != LeaderboardState.IDLE:
		LogManager.write_warning("Leaderboard operation already in progress, cannot request entries")
		emit_signal("leaderboard_updated", cached_leaderboard_entries) # Return cached entries
		return false
	
	# Get leaderboard name
	var leaderboard_name = get_leaderboard_name(difficulty, shift)
	
	# Start the leaderboard state machine
	current_leaderboard_state = LeaderboardState.FINDING
	is_fetching_leaderboard = true
	
	# Reset the handle to ensure we get a fresh one
	current_leaderboard_handle = 0
	
	# Track API call
	api_call_attempts["findLeaderboard"] = api_call_attempts.get("findLeaderboard", 0) + 1
	
	# Add to pending operations
	pending_operations.append({
		"name": "leaderboard_download_" + leaderboard_name,
		"time_elapsed": 0.0
	})
	
	LogManager.write_steam("Calling findLeaderboard for: " + leaderboard_name)
	# Using void call properly
	Steam.findLeaderboard(leaderboard_name)
	LogManager.write_steam("findLeaderboard call triggered")
	
	# Return true to indicate the request was started
	return true

# Internal function to verify Steam connection
func _verify_steam_connection() -> bool:
	if not Steam.isSteamRunning():
		LogManager.write_error("Steam is not running")
		return false
		
	if not Steam.loggedOn():
		LogManager.write_error("Steam user is not logged in")
		return false
		
	if not steam_init_success:
		LogManager.write_error("Steam was not successfully initialized")
		return false
	
	if not owns_app:
		LogManager.write_warning("User does not own the app")
		# For dev mode, we'll still return true
		if OS.has_feature("editor") || OS.has_feature("debug"):
			return true
		return false
		
	return true

# Internal function to download leaderboard entries
func _download_leaderboard_entries() -> bool:
	if current_leaderboard_state != LeaderboardState.FINDING && current_leaderboard_state != LeaderboardState.UPLOADING:
		LogManager.write_error("Cannot download entries - wrong state: " + str(LeaderboardState.keys()[current_leaderboard_state]))
		return false
		
	# Verify we have a valid handle
	if current_leaderboard_handle <= 0:
		LogManager.write_error("Cannot download leaderboard entries - invalid handle: " + str(current_leaderboard_handle))
		current_leaderboard_state = LeaderboardState.ERROR
		is_fetching_leaderboard = false
		emit_signal("leaderboard_updated", [])
		return false
	
	# Change state to downloading
	current_leaderboard_state = LeaderboardState.DOWNLOADING
	LogManager.write_steam("Downloading entries with handle: " + str(current_leaderboard_handle))
	
	# Track API call
	api_call_attempts["downloadLeaderboardEntries"] = api_call_attempts.get("downloadLeaderboardEntries", 0) + 1
	
	# Request global entries - using void call properly
	Steam.downloadLeaderboardEntries(
		1,  # Start rank
		12,  # End rank
		Steam.LEADERBOARD_DATA_REQUEST_GLOBAL,
		current_leaderboard_handle
	)
	
	LogManager.write_steam("downloadLeaderboardEntries call triggered")
	return true

# Signal handlers for Steam leaderboard operations
func _on_leaderboard_find_result(handle: int, found: bool) -> void:
	LogManager.write_steam("Leaderboard find result - Handle: " + str(handle) + ", Found: " + str(found))
	
	# Track API result
	api_call_results["findLeaderboard"] = {
		"handle": handle,
		"found": found,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Verify current state
	if current_leaderboard_state != LeaderboardState.FINDING:
		LogManager.write_warning("Unexpected leaderboard_find_result callback in state: " + 
							  LeaderboardState.keys()[current_leaderboard_state])
		return
	
	# Handle failure
	if handle == 0 || !found:
		last_error_message = "Failed to find Steam leaderboard!"
		LogManager.write_error(last_error_message)
		
		# Update state
		current_leaderboard_state = LeaderboardState.ERROR
		is_fetching_leaderboard = false
		
		# Remove pending operations for this request
		_clear_pending_leaderboard_operations()
		
		# Notify UI of failure
		emit_signal("score_submitted", false)
		emit_signal("leaderboard_updated", [])
		return
		
	LogManager.write_steam("Leaderboard found, handle: " + str(handle))
	current_leaderboard_handle = handle
	
	# Check if we're in score submission or just fetching
	var submitting_score = false
	for op in pending_operations:
		if op.name.begins_with("leaderboard_upload_"):
			submitting_score = true
			LogManager.write_steam("Processing pending score submission: " + str(op.score))
			
			# Update state
			current_leaderboard_state = LeaderboardState.UPLOADING
			
			# Create empty PackedInt32Array for details
			var details = PackedInt32Array()
			
			# Track API call
			api_call_attempts["uploadLeaderboardScore"] = api_call_attempts.get("uploadLeaderboardScore", 0) + 1
			
			LogManager.write_steam("Uploading score " + str(op.score) + " to leaderboard")
			# Using void call properly
			Steam.uploadLeaderboardScore(op.score, true, details, handle)
			LogManager.write_steam("uploadLeaderboardScore call triggered")
			return
	
	# If not submitting score, just download entries
	LogManager.write_steam("Not submitting score, downloading entries")
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
	
	# Verify current state
	if current_leaderboard_state != LeaderboardState.UPLOADING:
		LogManager.write_warning("Unexpected leaderboard_score_uploaded callback in state: " + 
							  LeaderboardState.keys()[current_leaderboard_state])
		return
	
	# Remove pending upload operation
	_clear_pending_leaderboard_operations("leaderboard_upload_")
	
	if success == 1:
		LogManager.write_steam("Successfully uploaded score to Steam leaderboard!")
		LogManager.write_steam("Requesting updated leaderboard entries...")
		
		# Request updated leaderboard entries
		_download_leaderboard_entries()
		
		# Notify UI of success
		emit_signal("score_submitted", true)
	else:
		last_error_message = "Failed to upload score to Steam leaderboard"
		LogManager.write_error(last_error_message)
		
		# Update state
		current_leaderboard_state = LeaderboardState.ERROR
		is_fetching_leaderboard = false
		
		# Notify UI of failure
		emit_signal("score_submitted", false)

func _on_leaderboard_scores_downloaded(message: String, this_leaderboard_handle: int, result: Array) -> void:
	LogManager.write_steam("Scores downloaded message: " + message)
	LogManager.write_steam("Leaderboard handle: " + str(this_leaderboard_handle) + 
						", Entries: " + str(result.size()))
	
	# Track API result
	api_call_results["downloadLeaderboardEntries"] = {
		"message": message,
		"handle": this_leaderboard_handle,
		"count": result.size(),
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Verify current state
	if current_leaderboard_state != LeaderboardState.DOWNLOADING:
		LogManager.write_warning("Unexpected leaderboard_scores_downloaded callback in state: " + 
							  LeaderboardState.keys()[current_leaderboard_state])
	
	# Update state
	current_leaderboard_state = LeaderboardState.COMPLETED
	is_fetching_leaderboard = false
	
	# Remove pending operations
	_clear_pending_leaderboard_operations()
	
	# Process results
	cached_leaderboard_entries.clear()
	
	if result.is_empty():
		LogManager.write_warning("No leaderboard entries returned")
		emit_signal("leaderboard_updated", cached_leaderboard_entries)
		return
	
	LogManager.write_steam("Processing " + str(result.size()) + " leaderboard entries")
	
	for entry in result:
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
	emit_signal("leaderboard_updated", cached_leaderboard_entries)

# Helper function to clear pending operations
func _clear_pending_leaderboard_operations(prefix: String = "leaderboard_"):
	for i in range(pending_operations.size() - 1, -1, -1):
		var op = pending_operations[i]
		if op.name.begins_with(prefix):
			pending_operations.remove_at(i)

# Achievement handling
func check_achievements(total_shifts_completed: int, total_runners_stopped: int, perfect_hits: int, score: int, current_story_state: int):
	if not _verify_steam_connection():
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
	
	# After setting achievements, store them
	Steam.storeStats()

# Update Steam stats
func update_steam_stats(total_shifts_completed: int, total_runners_stopped: int, perfect_hits: int, score: int):
	if not _verify_steam_connection():
		return
		
	Steam.setStatInt("total_shifts", total_shifts_completed)
	Steam.setStatInt("runners_stopped", total_runners_stopped)
	Steam.setStatInt("perfect_hits", perfect_hits)
	Steam.setStatInt("high_score", score)
	Steam.storeStats() # Important: Actually saves stats to Steam

# Upload cloud saves
func upload_cloud_saves():
	if not _verify_steam_connection():
		return false
		
	LogManager.write_info("Uploading cloud saves")
	# This would be implemented based on your specific save system
	return true

# Debug function to log current state
func dump_debug_info() -> String:
	var debug_info = "=== STEAM MANAGER DEBUG INFO ===\n"
	debug_info += "Steam running: " + str(Steam.isSteamRunning()) + "\n"
	debug_info += "Steam logged on: " + str(Steam.loggedOn()) + "\n"
	debug_info += "Steam initialized: " + str(steam_init_success) + "\n"
	debug_info += "Steam AppID: " + str(steam_app_id) + "\n"
	debug_info += "Owns App: " + str(owns_app) + "\n"
	debug_info += "Steam UserID: " + str(Steam.getSteamID()) + "\n"
	debug_info += "Leaderboard state: " + LeaderboardState.keys()[current_leaderboard_state] + "\n"
	debug_info += "Current leaderboard: " + last_leaderboard_name + "\n"
	debug_info += "Current handle: " + str(current_leaderboard_handle) + "\n"
	debug_info += "Is fetching: " + str(is_fetching_leaderboard) + "\n"
	debug_info += "Last error: " + last_error_message + "\n"
	debug_info += "Cached entries: " + str(cached_leaderboard_entries.size()) + "\n"
	debug_info += "Connected signals: " + str(connected_signals) + "\n"
	debug_info += "Pending operations: " + str(pending_operations.size()) + "\n"
	debug_info += "API calls attempted: " + str(api_call_attempts.size()) + "\n"
	debug_info += "API call results: " + str(api_call_results.size()) + "\n"
	
	LogManager.write_info(debug_info)
	return debug_info

# Force reset the leaderboard state - useful for recovering from stuck states
func reset_leaderboard_state():
	LogManager.write_warning("Manually resetting leaderboard state")
	current_leaderboard_state = LeaderboardState.IDLE
	is_fetching_leaderboard = false
	_clear_pending_leaderboard_operations()
	
	# Wait a frame and try again
	await get_tree().process_frame
	return true
