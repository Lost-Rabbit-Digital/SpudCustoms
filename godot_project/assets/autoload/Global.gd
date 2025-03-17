extends Node

var shift: int = 1
var current_story_state: int = 0
var final_score = 0
var build_type = "Full Release" # Can be Full Release or Demo Release
var difficulty_level = "Normal" # Can be "Easy", "Normal", or "Expert"
var strikes = 0
var max_strikes = 4
var current_game_stats: Dictionary = {}
var quota_target = 8  # Required correct decisions
var quota_met = 0   # Number of correct decisions

# Track level progression
var max_level_unlocked = 1  # Start with first level unlocked

# Achievement IDs
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

# Track stats for achievements
var total_shifts_completed = 0
var total_runners_stopped = 0
var perfect_hits = 0

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
	# load_high_scores()
	set_difficulty(difficulty_level)
	# Check for and download cloud saves when game starts
	if Steam.isSteamRunning():
		download_cloud_saves()
	
	
func _init():
	if Steam.isSteamRunning():
		print("Configuring Steam connections...")
		Steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
		Steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
		Steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)
		print("Steam connections configured.")

func _process(_delta: float) -> void:
	Steam.run_callbacks()
	
func store_game_stats(stats: ShiftStats):
	current_game_stats = {
		"shift": shift,
		"time_taken": stats.time_taken,
		"processing_time_left": stats.processing_time_left,
		"score": score,
		"missiles_fired": stats.missiles_fired,
		"missiles_hit": stats.missiles_hit,
		"perfect_hits": stats.perfect_hits,
		"total_stamps": stats.total_stamps,
		"potatoes_approved": stats.potatoes_approved,
		"potatoes_rejected": stats.potatoes_rejected,
		"perfect_bonus": stats.get_missile_bonus(),
		"final_score": final_score
	}
	
# Helper function to get leaderboard name based on difficulty
func get_leaderboard_name(difficulty: String = "") -> String:
	if difficulty.is_empty():
		difficulty = difficulty_level
		
	match difficulty:
		"Easy": return "endless_easy"
		"Normal": return "endless_normal"
		"Expert": return "endless_expert"
		_: return "endless_normal"

func request_leaderboard_entries(difficulty: String = "") -> bool:
	print("GLOBAL: Getting leaderboard entries")
	if difficulty.is_empty():
		difficulty = difficulty_level
	
	# If we don't have a handle for this difficulty, get it
	is_fetching_leaderboard = true
	Steam.findLeaderboard(get_leaderboard_name(difficulty))
	# Return cached entries while we wait
	# return cached_leaderboard_entries
	
	# If we have a handle, fetch the scores
	print("Fetching scores")
	Steam.downloadLeaderboardEntries(1, 12, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL, current_leaderboard_handle)
	Steam.run_callbacks()
	return true

func _on_leaderboard_find_result(handle: int, found: bool) -> void:
	if not found:
		print("Failed to find leaderboard!")
		return
		
	print("Leaderboard found, handle: ", handle)
	current_leaderboard_handle = handle
	
	# Create empty PackedInt32Array for details
	var details = PackedInt32Array()
	
	print("Uploading score to leaderboard")
	Steam.uploadLeaderboardScore(score, true, details, handle)


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
	else:
		print("Failed to upload score to Steam leaderboard")

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
	
func reset_game_state(keep_high_scores=true):
	score = 0
	final_score = 0
	shift = 1
	strikes = 0
	quota_met = 0
	current_game_stats = {}
	
	# Reset all gameplay-related variables
	
	if !keep_high_scores:
		high_scores = {"Easy": 0, "Normal": 0, "Expert": 0}
		
	save_game_state()
	
# Call this function at appropriate times like:
# When exiting to main menu
# When starting a new game mode
# After game over screen

func advance_shift():
	shift += 1
	save_game_state()

# Save/load functions
func save_game_state():
	var current_story_state = GameState.get_max_level_reached()
	var save_data = {
		"shift": shift,
		"final_score": final_score,
		"quota_met": quota_met,
		"quota_target": quota_target,
		"difficulty_level": difficulty_level,
		"high_scores": high_scores,
		"story_state": current_story_state,
		"current_game_stats": current_game_stats
	}
	
	var save_file = FileAccess.open("user://gamestate.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_data)
		
		if Steam.isSteamRunning():
			Steam.fileWrite("user://gamestate.save", FileAccess.get_file_as_bytes("user://gamestate.save"))
			Steam.fileWrite("user://highscores.save", FileAccess.get_file_as_bytes("user://highscores.save"))

# Update load_game_state
func load_game_state():
	var data = {}
	
	# Try loading from cloud first if Steam is running
	if Steam.isSteamRunning() and Steam.fileExists("gamestate.save"):
		var file_size = Steam.getFileSize("gamestate.save")
		var file_content = Steam.fileRead("gamestate.save", file_size)
		
		var temp_file = FileAccess.open("user://temp_gamestate.save", FileAccess.WRITE)
		if temp_file:
			temp_file.store_buffer(file_content)
			temp_file = FileAccess.open("user://temp_gamestate.save", FileAccess.READ)
			data = temp_file.get_var()
	# Fall back to local save if cloud save fails or Steam isn't running
	elif FileAccess.file_exists("user://gamestate.save"):
		var save_file = FileAccess.open("user://gamestate.save", FileAccess.READ)
		if save_file:
			data = save_file.get_var()
			
	# Load the data if we got any
	if not data.is_empty():
		shift = data.get("shift", 1)
		final_score = data.get("final_score", 0)
		quota_met = data.get("quota_met", 0)
		quota_target = data.get("quota_target", 8)
		difficulty_level = data.get("difficulty_level", "Expert")
		high_scores = data.get("high_scores", {"Easy": 0, "Normal": 0, "Expert": 0})
		current_story_state = data.get("story_state", 0)
		current_game_stats = data.get("current_game_stats", {})
		score = final_score
		score_updated.emit(score)

# Modify save_high_scores()
func save_high_scores():
	var save_file = FileAccess.open("user://highscores.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(high_scores)
		
		if Steam.isSteamRunning():
			Steam.fileWrite("highscores.save", FileAccess.get_file_as_bytes("user://highscores.save"))

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
		match difficulty_level:
			"Easy":
				quota_target = 5
			"Normal":
				quota_target = 8
			"Expert":
				quota_target = 10
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
	
func unlock_level(level_id: int):
	if level_id > max_level_unlocked:
		max_level_unlocked = level_id
	
	# Save progress to disk
	save_game_state()

func is_level_unlocked(level_id: int) -> bool:
	return level_id <= max_level_unlocked

func advance_story_state():
	# Also unlock the next level when story progresses
	unlock_level(shift + 1)

func get_story_state() -> int:
	return current_story_state

func set_story_state(new_state: int):
	current_story_state = new_state
	save_game_state() # Add story state to existing save system

## Gameover scene transition
func go_to_game_over():
	# Store the score in a global script or autoload
	Global.final_score = Global.score
	print("transition to game over scene")
	get_tree().change_scene_to_file("res://scripts/systems/ShiftSummaryScreen.tscn")
	
func clear_alert_after_delay(alert_label, alert_timer):
	alert_timer.start()
	# Delay is the "wait_time" property on the $SystemManagers/Timers/AlertTimer
	await alert_timer.timeout
	# Hide the alert
	alert_label.visible = false
	# Set to placeholder text for debugging
	alert_label.text = "PLACEHOLDER ALERT TEXT"
	# Set to a noticable color for debugging
	alert_label.add_theme_color_override("font_color", Color.BLUE)

func display_red_alert(alert_label, alert_timer, text):
	# Load and play the audio file
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = load("res://assets/audio/ui_feedback/decline_red_alert.wav")
	audio_player.volume_db = -5
	audio_player.bus = "SFX"
	add_child(audio_player)
	audio_player.play()
	# Display the alert
	alert_label.visible = true
	# Update the text
	alert_label.text = text
	# Set desired color
	alert_label.add_theme_color_override("font_color", Color.RED)
	# Hide the alert after a few seconds
	clear_alert_after_delay(alert_label, alert_timer)
	
func display_green_alert(alert_label, alert_timer, text):
	# Load and play the audio file
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = load("res://assets/audio/ui_feedback/accept_green_alert.wav")
	audio_player.volume_db = -5
	audio_player.bus = "SFX"
	add_child(audio_player)
	audio_player.play()
	# Display the alert
	alert_label.visible = true
	# Update the text
	alert_label.text = text
	# Set desired color
	alert_label.add_theme_color_override("font_color", Color.GREEN)
	# Hide the alert after a few seconds
	clear_alert_after_delay(alert_label, alert_timer)

func download_cloud_saves():
	if not Steam.isSteamRunning():
		return
		
	if Steam.fileExists("gamestate.save"):
		var file_size = Steam.getFileSize("gamestate.save")
		var file_content = Steam.fileRead("gamestate.save", file_size)
		
		var local_file = FileAccess.open("user://gamestate.save", FileAccess.WRITE)
		if local_file:
			local_file.store_buffer(file_content)
			
	if Steam.fileExists("highscores.save"):
		var scores_size = Steam.getFileSize("highscores.save")
		var scores_content = Steam.fileRead("highscores.save", scores_size)
		
		var local_scores = FileAccess.open("user://highscores.save", FileAccess.WRITE)
		if local_scores:
			local_scores.store_buffer(scores_content)
			
	load_game_state()
	# load_high_scores()

func check_achievements():
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
	if current_story_state >= 13:
		Steam.setAchievement(ACHIEVEMENTS.SAVIOR_OF_SPUD)

# Call this after each shift or when stats change
func update_steam_stats():
	if not Steam.isSteamRunning():
		return
		
	Steam.setStatInt("total_shifts", total_shifts_completed)
	Steam.setStatInt("runners_stopped", total_runners_stopped)
	Steam.setStatInt("perfect_hits", perfect_hits)
	Steam.setStatInt("high_score", score)
	Steam.storeStats() # Important: Actually saves stats to Steam
