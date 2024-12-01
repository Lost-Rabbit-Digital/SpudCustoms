extends Node

# Existing variables
var shift = 1
var final_score = 0
var build_type = "Demo Release"
var difficulty_level = "Normal" # Can be "Easy", "Normal", or "Expert"
var strikes = 0
var max_strikes = 4
var current_game_stats: Dictionary = {}
var quota_target = 8  # Required correct decisions
var quota_met = 0   # Number of correct decisions


# Add story state enum
enum StoryState {
	NOT_STARTED,
	INTRO_COMPLETE,
	FIRST_SHIFT,
	MIDDLE_GAME,
	FINAL_CONFRONTATION,
	COMPLETED
}

# Add current story state tracking
var current_story_state = StoryState.NOT_STARTED

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
	set_difficulty(difficulty_level)
	
	
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
		"perfect_stamps": stats.perfect_stamps,
		"speed_bonus": stats.get_speed_bonus(),
		"accuracy_bonus": stats.get_accuracy_bonus(),
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

# Update save/load functions
# Update save_game_state
func save_game_state():
	var save_data = {
		"shift": shift,
		"final_score": final_score,
		"quota_met": quota_met,
		"quota_target": quota_target,
		"difficulty_level": difficulty_level,
		"high_scores": high_scores,
		"story_state": current_story_state
	}
	
	var save_file = FileAccess.open("user://gamestate.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_data)

# Update load_game_state
func load_game_state():
	if FileAccess.file_exists("user://gamestate.save"):
		var save_file = FileAccess.open("user://gamestate.save", FileAccess.READ)
		if save_file:
			var data = save_file.get_var()
			shift = data.get("shift", 1)
			final_score = data.get("final_score", 0)
			quota_met = data.get("quota_met", 0)
			quota_target = data.get("quota_target", 8)
			difficulty_level = data.get("difficulty_level", "Expert")
			high_scores = data.get("high_scores", {"Easy": 0, "Normal": 0, "Expert": 0})
			current_story_state = data.get("story_state", StoryState.NOT_STARTED)
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
	

func advance_story_state():
	match current_story_state:
		StoryState.NOT_STARTED:
			current_story_state = StoryState.INTRO_COMPLETE
		StoryState.INTRO_COMPLETE:
			current_story_state = StoryState.FIRST_SHIFT
		StoryState.FIRST_SHIFT:
			current_story_state = StoryState.MIDDLE_GAME
		StoryState.MIDDLE_GAME:
			if shift >= 3: # Or whatever condition triggers final confrontation
				current_story_state = StoryState.FINAL_CONFRONTATION
		StoryState.FINAL_CONFRONTATION:
			current_story_state = StoryState.COMPLETED

func get_story_state() -> int:
	return current_story_state

func set_story_state(new_state: int):
	current_story_state = new_state
	save_game_state() # Add story state to existing save system


### HELPER FUNCTIONS

## Gameover scene transition
func go_to_game_over():
	# Store the score in a global script or autoload
	Global.final_score = Global.score
	print("transition to game over scene")
	#$Gameplay/InteractiveElements/ApprovalStamp.visible = false
	#$Gameplay/InteractiveElements/RejectionStamp.visible = false
	#print("ALERT: go_to_game_over() has been disabled")
	get_tree().change_scene_to_file("res://ShiftSummaryScreen.tscn")
	
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
	# Display the alert
	alert_label.visible = true
	# Update the text
	alert_label.text = text
	# Set desired color
	alert_label.add_theme_color_override("font_color", Color.RED)
	# Hide the alert after a few seconds
	clear_alert_after_delay(alert_label, alert_timer)
	
func display_green_alert(alert_label, alert_timer, text):
	# Display the alert
	alert_label.visible = true
	# Update the text
	alert_label.text = text
	# Set desired color
	alert_label.add_theme_color_override("font_color", Color.GREEN)
	# Hide the alert after a few seconds
	clear_alert_after_delay(alert_label, alert_timer)
