extends Node

# Persistent variables
var current_story_state: int = 0
var difficulty_level = "Normal" # Can be "Easy", "Normal", or "Expert"
var build_type = "Full Release" # Can be Full Release or Demo Release
var base_quota_target = 8 # Quota scaling variable
var game_mode = "score_attack"
# Transient variables
var shift: int = 0
var final_score = 0
var strikes = 0
var max_strikes = 4
var current_game_stats: Dictionary = {}
var quota_target = 8  # Required correct decisions
var quota_met = 0   # Number of correct decisions

# Track stats for achievements
var total_shifts_completed = 0
var total_runners_stopped = 0
var perfect_hits = 0

# New scoring system variables
var score: int = 0
var high_scores: Dictionary = {
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

# Signals
signal score_updated(new_score: int)
signal high_score_achieved(difficulty: String, score: int)

func _ready():
	# Load difficulty from Config instead of saved game state
	difficulty_level = Config.get_config("GameSettings", "Difficulty", "Normal")
	# Initialize settings based on difficulty
	set_difficulty(difficulty_level)
	
	# Load score from saved game state
	score = final_score
	
	# Check for and download cloud saves when game starts
	if Steam.isSteamRunning():
		SteamManager.download_cloud_saves()
		
	# Load saved game state
	load_game_state()
	
	# Sync SaveManager and game state
	sync_level_unlock_data()
	

func _process(_delta: float) -> void:
	pass # No need for Steam callbacks here anymore

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
	
	# Save the game stats
	save_game_state()

func add_score(points: int):
	score += points
	final_score = score
	score_updated.emit(score)
	
	# Save high score for the current level
	var high_score = SaveManager.get_level_high_score(shift, difficulty_level)
	
	# Check if this is a new high score for this level and difficulty
	if score > high_score:
		SaveManager.save_level_high_score(shift, difficulty_level, score)
		high_score_achieved.emit(difficulty_level, score)

# Add a function to get high score for the current level
func get_current_level_high_score() -> int:
	return SaveManager.get_level_high_score(shift, difficulty_level)

func get_level_high_score(level_id: int, difficulty: String = "") -> int:
	if not difficulty:
		difficulty = difficulty_level
		
	return SaveManager.get_level_high_score(level_id, difficulty)

func reset_score():
	score = 0
	final_score = 0
	score_updated.emit(score)

func reset_shift():
	shift = 0
	quota_met = 0
	
func reset_game_state(keep_high_scores=true):
	score = 0
	final_score = 0
	shift = 0
	strikes = 0
	quota_met = 0
	current_game_stats = {}
	
	# Reset all gameplay-related variables
	if !keep_high_scores:
		high_scores = {"Easy": 0, "Normal": 0, "Expert": 0}
		
	save_game_state()

func advance_shift():
	shift += 1
	GameState.set_current_level(shift)
	GameState.level_reached(shift)
	# reset per-shift stats
	reset_shift_stats()
	var scaling_factor:float 
	# Update quota target for new shift
	# This assumes quota target increases with each shift
	match Global.difficulty_level:
		"Easy": 
			# TODO: 0.8 normally
			scaling_factor = 0.1
		"Normal":
			scaling_factor = 1
		"Expert":
			scaling_factor = 1.2
		
		
	quota_target = int(floor((base_quota_target + (shift - 1 )) * scaling_factor))
	save_game_state()

func switch_game_mode(mode: String):
	# Reset core gameplay variables
	reset_shift_stats()
	
	if mode == "story":
		game_mode = "story"
		# Load story progress from GameState
		shift = GameState.get_current_level()
		# Set quota based on current level
		quota_target = floor(base_quota_target + (shift - 1))
		
	elif mode == "score_attack":
		# For score attack, reset to level 1 but keep difficulty
		shift = 1
		# Use standard quota based on difficulty
		quota_target = 9999
		game_mode = "score_attack"
		
	# Make sure UI gets updated on next scene load
	save_game_state()

func synchronize_with_game_state():
	# Make sure shift is synchronized with GameState
	shift = GameState.get_current_level()
	
	# Reset gameplay variables for new shift
	score = 0
	quota_met = 0
	strikes = 0
	
func sync_level_unlock_data() -> int:
	# Get the max level from both systems
	var save_manager_max = 0
	var game_state_max = GameState.get_max_level_reached()
	
	# Get SaveManager max if available
	if SaveManager.has_method("get_max_level_reached"):
		save_manager_max = SaveManager.get_max_level_reached()
	
	# Use the highest value
	var true_max_level = max(save_manager_max, game_state_max)
	
	# Update systems if needed
	if true_max_level > game_state_max:
		GameState.level_reached(true_max_level)
	
	if SaveManager.has_method("save_level_progress") and true_max_level > save_manager_max:
		# Create high scores dictionary
		var high_scores = {}
		for level in range(1, true_max_level + 1):
			var level_key = str(level)
			high_scores[level_key] = {}
			
			# Add scores for each difficulty
			for difficulty in ["Easy", "Normal", "Expert"]:
				high_scores[level_key][difficulty] = GameState.get_high_score(level, difficulty)
		
		SaveManager.save_level_progress(true_max_level, Global.shift, high_scores)
	
	return true_max_level

func reset_shift_stats():
	score = 0
	final_score = 0  # Make sure this is explicitly reset
	quota_met = 0
	strikes = 0
	current_game_stats = {}
	GlobalState.save()

# Save and Load Handling - Now using SaveManager
func save_game_state():
	var data = {
		"shift": shift,
		"difficulty_level": difficulty_level,
		"high_scores": high_scores,
		"story_state": current_story_state,
	}
	
	SaveManager.save_game_state(data)

func load_game_state():
	var data = SaveManager.load_game_state()
	
	# Load the data if we got any
	if not data.is_empty():
		high_scores = data.get("high_scores", {"Easy": 0, "Normal": 0, "Expert": 0})
		current_story_state = data.get("story_state", 0)


# Modify get_high_score to be more flexible
func get_high_score(level: int = -1, difficulty: String = "") -> int:
	if difficulty.is_empty():
		difficulty = difficulty_level
		
	if level < 0:
		# Get global high score for the difficulty
		return SaveManager.get_global_high_score(difficulty)
	else:
		# Get level-specific high score
		return SaveManager.get_level_high_score(level, difficulty)

func set_difficulty(new_difficulty: String):
	if new_difficulty in ["Easy", "Normal", "Expert"]:
		difficulty_level = new_difficulty
		
		# Save the difficulty to Config
		Config.set_config("GameSettings", "Difficulty", difficulty_level)
		var scaling_factor:float
		# Update game parameters based on difficulty
		match difficulty_level:
			"Easy":
				# TODO: 0.8 normally
				scaling_factor = 0.1
				max_strikes = 6
			"Normal":
				scaling_factor = 1
				max_strikes = 4
			"Expert":
				scaling_factor = 1.2
				max_strikes = 3
		quota_target = int(floor(base_quota_target * scaling_factor))

# Update variables used for unlocking levels in level select
func unlock_level(level_id: int):
	if level_id > SaveManager.get_max_level_reached():
		SaveManager.save_level_progress(level_id, shift, {Global.difficulty_level: Global.score})
	
	# Save progress to disk
	save_game_state()

func is_level_unlocked(level_id: int) -> bool:
	return level_id <= SaveManager.get_max_level_reached()

func advance_story_state():
	# Also unlock the next level when story progresses
	unlock_level(shift + 1)

func get_story_state() -> int:
	return current_story_state

func set_story_state(new_state: int):
	current_story_state = new_state
	save_game_state() # Add story state to existing save system

# Steam interface methods - Using SteamManager
func check_achievements():
	SteamManager.check_achievements(
		total_shifts_completed,
		total_runners_stopped,
		perfect_hits,
		score,
		current_story_state
	)

func update_steam_stats():
	SteamManager.update_steam_stats(
		total_shifts_completed,
		total_runners_stopped,
		perfect_hits,
		score
	)

func submit_score(score: int):
	return SteamManager.submit_score(score, difficulty_level, shift)

func request_leaderboard_entries(difficulty: String = ""):
	return SteamManager.request_leaderboard_entries(
		difficulty if difficulty != "" else difficulty_level,
		shift
	)

# UI Helper methods - Using UIManager
func display_red_alert(alert_label, alert_timer, text):
	UIManager.display_red_alert(alert_label, alert_timer, text)

func display_green_alert(alert_label, alert_timer, text):
	UIManager.display_green_alert(alert_label, alert_timer, text)

func shake_screen(intensity: float = 10.0, duration: float = 0.3):
	UIManager.shake_screen(intensity, duration)

func format_score(value: int) -> String:
	return UIManager.format_score(value)

# Debug function to reset all data, persistent and non-persistent
func reset_all():
	SaveManager.reset_all_game_data(false)
	reset_game_state(false)
