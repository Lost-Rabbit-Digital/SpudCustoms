extends Node

# Development mode - Set to true to disable Steam functionality
const DEV_MODE = true  # Set to true to skip all Steam features

# Difficulty scaling factors for quota calculations
const DIFFICULTY_SCALING_EASY: float = 0.8
const DIFFICULTY_SCALING_NORMAL: float = 1.0
const DIFFICULTY_SCALING_EXPERT: float = 1.2

# Persistent variables
var current_story_state: int = 0
var difficulty_level = "Normal"  # Can be "Easy", "Normal", or "Expert"
var build_type = "Full"  # Can be "Full" or "Demo"
var base_quota_target = 8  # Quota scaling variable
var game_mode = "score_attack"
var narrative_choices: Dictionary = {}  # Track player's narrative choices
# Transient variables
var shift: int = 0
var final_score = 0
var strikes = 0
var max_strikes = 4
var current_game_stats: Dictionary = {}
var quota_target = 8  # Required correct decisions
var quota_met = 0  # Number of correct decisions

# Track stats for achievements
var total_shifts_completed = 0
var total_runners_stopped = 0
var perfect_hits = 0

# Playtime tracking
var total_playtime: float = 0.0  # Total playtime in seconds
var session_start_time: float = 0.0

# New scoring system variables
var score: int = 0
var high_scores: Dictionary = {
	"level_highscores":
	{
		"1": {"Easy": 100, "Normal": 200, "Expert": 300},  # Level ID as string
		"2": {"Easy": 150, "Normal": 250, "Expert": 350}
	},
	"global_highscores": {"Easy": 500, "Normal": 750, "Expert": 1000}
}

# Signals
signal score_updated(new_score: int)
signal high_score_achieved(difficulty: String, score: int)


func _ready():
	# Connect to EventBus signals
	if EventBus:
		EventBus.shift_advance_requested.connect(_on_shift_advance_requested)
		EventBus.story_state_advance_requested.connect(_on_story_state_advance_requested)
		EventBus.level_unlock_requested.connect(_on_level_unlock_requested)

	# Load difficulty from Config instead of saved game state
	difficulty_level = Config.get_config("GameSettings", "Difficulty", "Normal")
	# Initialize settings based on difficulty
	set_difficulty(difficulty_level)

	# Load score from saved game state
	score = final_score

	# Check for and download cloud saves when game starts
	if not DEV_MODE and Steam.isSteamRunning():
		#SteamManager.download_cloud_saves()
		LogManager.write_info("Steam is running.")
		pass
	elif DEV_MODE:
		LogManager.write_info("DEV_MODE enabled - Steam features disabled.")

	# Load saved game state (but defer narrative choice restoration)
	load_game_state()

	# Sync SaveManager and game state
	sync_level_unlock_data()

	# Defer narrative choice restoration to next frame when Dialogic is ready
	call_deferred("_restore_narrative_choices_deferred")

	# Start playtime tracking
	session_start_time = Time.get_ticks_msec() / 1000.0


func _on_shift_advance_requested() -> void:
	"""Handle shift advancement via EventBus"""
	advance_shift()


func _on_story_state_advance_requested() -> void:
	"""Handle story state advancement via EventBus"""
	advance_story_state()
  
func _on_level_unlock_requested(level_id: int) -> void:
	"""Handle level unlock request via EventBus"""
	unlock_level(level_id)


func _process(delta: float) -> void:
	# Update playtime tracking
	if session_start_time > 0:
		total_playtime += delta


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


func reset_game_state(keep_high_scores = true):
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

	# Disable tutorial mode when advancing past shift 0
	if shift > 0 and GameStateManager:
		GameStateManager.set_tutorial_mode(false)
		GameStateManager.set_shift(shift)

	var scaling_factor: float
	# Update quota target for new shift based on difficulty
	match Global.difficulty_level:
		"Easy":
			scaling_factor = DIFFICULTY_SCALING_EASY
		"Normal":
			scaling_factor = DIFFICULTY_SCALING_NORMAL
		"Expert":
			scaling_factor = DIFFICULTY_SCALING_EXPERT

	quota_target = int(floor((base_quota_target + (shift - 1)) * scaling_factor))
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
		"narrative_choices": {},
		"total_shifts_completed": total_shifts_completed,
		"total_runners_stopped": total_runners_stopped,
		"perfect_hits": perfect_hits,
		"total_playtime": total_playtime,
	}

	# REFACTORED: Use EventBus for narrative choices
	# Capture narrative choices using Global's built-in method
	# NarrativeManager (if present in scene) can override these via EventBus
	capture_narrative_choices()
	data["narrative_choices"] = narrative_choices

	# Emit EventBus event for any scene-based narrative managers to update choices
	if EventBus:
		EventBus.narrative_choices_save_requested.emit()

	SaveManager.save_game_state(data)


func load_game_state():
	var data = SaveManager.load_game_state()

	# Load the data if we got any
	if not data.is_empty():
		# Restore shift value - CRITICAL for game progression
		shift = data.get("shift", 0)
		# Also sync with GameStateManager
		if GameStateManager:
			GameStateManager.set_shift(shift)

		high_scores = data.get("high_scores", {"Easy": 0, "Normal": 0, "Expert": 0})
		current_story_state = data.get("story_state", 0)
		narrative_choices = data.get("narrative_choices", {})
		# Note: Narrative choice restoration is deferred to _restore_narrative_choices_deferred()
		# to ensure Dialogic is fully initialized

		# Restore narrative choices to Dialogic
		restore_narrative_choices()
		total_shifts_completed = data.get("total_shifts_completed", 0)
		total_runners_stopped = data.get("total_runners_stopped", 0)
		perfect_hits = data.get("perfect_hits", 0)
		total_playtime = data.get("total_playtime", 0.0)

		# REFACTORED: Emit event for narrative choices loading
		# NarrativeManager (if present in scene) will respond to this event
		if EventBus and data.has("narrative_choices"):
			EventBus.narrative_choices_load_requested.emit(data.get("narrative_choices", {}))


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
		var scaling_factor: float
		# Update game parameters based on difficulty
		match difficulty_level:
			"Easy":
				scaling_factor = DIFFICULTY_SCALING_EASY
				max_strikes = 6
			"Normal":
				scaling_factor = DIFFICULTY_SCALING_NORMAL
				max_strikes = 4
			"Expert":
				scaling_factor = DIFFICULTY_SCALING_EXPERT
				max_strikes = 3
		quota_target = int(floor(base_quota_target * scaling_factor))


# Update variables used for unlocking levels in level select
func unlock_level(level_id: int):
	if level_id > SaveManager.get_max_level_reached():
		SaveManager.save_level_progress(level_id, shift, {Global.difficulty_level: Global.score})
		# Emit level unlocked signal via EventBus
		EventBus.level_unlocked.emit(level_id)
		LogManager.write_info("Level %d unlocked" % level_id)

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
	save_game_state()  # Add story state to existing save system


# Steam interface methods - Using SteamManager
func check_achievements():
	SteamManager.check_achievements(
		total_shifts_completed, total_runners_stopped, perfect_hits, score, current_story_state
	)


func update_steam_stats():
	SteamManager.update_steam_stats(
		total_shifts_completed, total_runners_stopped, perfect_hits, score
	)


func submit_score(score: int):
	return SteamManager.submit_score(score, difficulty_level, shift)


func request_leaderboard_entries(difficulty: String = ""):
	return SteamManager.request_leaderboard_entries(
		difficulty if difficulty != "" else difficulty_level, shift
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


# Narrative Choice Persistence Functions
func capture_narrative_choices():
	"""Capture current Dialogic variables and store them for persistence"""
	if not Dialogic:
		return

	# Check if Dialogic VAR subsystem is available (may not be ready during early startup)
	if not Dialogic.has_subsystem("VAR"):
		print("Dialogic VAR subsystem not ready yet, skipping narrative choice capture")
		return

	# Get all Dialogic variables related to story choices
	# IMPORTANT: This list MUST match NarrativeManager.choice_variables exactly!
	# Updated to include all new variables from enhanced narrative
	var important_vars = [
		# Shift 1 - Introduction
		"initial_response",          # eager, questioning
		"note_reaction",             # investigate, destroy, report
		"kept_note",                 # yes, no
		"reported_note",             # yes

		# Shift 2 - Meeting Sasha & Murphy
		"murphy_trust",              # open, guarded
		"eat_reserve",               # ate, refused

		# Shift 3 - Missing Wife
		"scanner_response",          # loyal, questioning
		"family_response",           # refuse, help
		"has_wife_photo",            # yes, no
		"wife_name",                 # "Maris Piper"
		"reveal_reaction",           # shocked, cautious

		# Shift 4 - Root Reserve Trucks
		"cafeteria_response",        # serious, avoid
		"murphy_alliance",           # ally, cautious, skeptical
		"sasha_trust_level",         # committed, cautious

		# Shift 5 - Loyalty Screening & Heist
		"sasha_investigation",       # committed, hesitant
		"loyalty_response",          # patriotic, idealistic
		"hide_choice",               # desk, window
		"evidence_choice",           # hand_over, keep, lie, chaos
		"viktor_wife_discovery",     # yes (discovered Viktor's wife on manifest)

		# Shift 6 - RealityScan
		"fellow_officer_response",   # cautious, sympathetic, loyal
		"interrogation_response",    # lie, legal
		"viktor_conversation",       # curious, direct
		"scanner_choice",            # help, scan, viktor
		"helped_operative",          # yes, no
		"viktor_allied",             # yes
		"betrayed_resistance",       # yes
		"sasha_plan_response",       # committed, nervous

		# Shift 7 - Resistance Meeting
		"resistance_mission",        # committed, hesitant, cautious
		"final_decision",            # help, passive, undecided
		"yellow_badge_response",     # help, betray

		# Shift 8 - Sasha's Capture
		"sasha_response",            # cautious, concerned
		"interrogation_choice",      # deny, betray
		"sasha_arrest_reaction",     # intervene, hide, promise
		"player_wanted",             # yes
		"player_captured",           # yes
		"has_keycard",               # yes
		"murphy_final_alliance",     # committed, hesitant

		# Shift 9 - The Attack
		"critical_choice",           # help, betray
		"stay_or_go",                # stay, go - CRITICAL ending choice!
		"sasha_rescue_reaction",     # angry, disgusted, relieved

		# Shift 10 & Endings
		"fellow_officer_response_2", # cautious, sympathetic
		"final_mission_response",    # determined, cautious
		"resistance_trust",          # diplomatic, committed
		"ending_choice",             # diplomatic, justice, vengeance, dismantle

		# Loyalist Ending
		"accept_medal",              # accept, reluctant
		"eat_final",                 # eat, refuse
		"final_loyalist_choice",     # report, ignore, hope
	]

	for var_name in important_vars:
		if Dialogic.VAR.has(var_name):
			narrative_choices[var_name] = Dialogic.VAR.get(var_name)

	print("Captured narrative choices: ", narrative_choices)


func _restore_narrative_choices_deferred():
	"""Deferred restoration of narrative choices after Dialogic is fully initialized"""
	if narrative_choices.is_empty():
		return

	# Check if Dialogic is ready
	if not Dialogic or not Dialogic.has_method("get_class"):
		print("Dialogic not ready yet, skipping narrative choice restoration")
		return

	# REFACTORED: Emit event for narrative choices loading
	# NarrativeManager (if present in scene) will respond to this event
	if EventBus:
		EventBus.narrative_choices_load_requested.emit(narrative_choices)
		print("Requested narrative choices load via EventBus: ", narrative_choices.size(), " choices")

	# Fallback: restore via Global's built-in method
	restore_narrative_choices()


func restore_narrative_choices():
	"""Restore saved narrative choices back to Dialogic variables"""
	if not Dialogic or narrative_choices.is_empty():
		return

	# Check if Dialogic VAR subsystem is available (may not be ready during early startup)
	if not Dialogic.has_subsystem("VAR"):
		print("Dialogic VAR subsystem not ready yet, skipping narrative choice restoration")
		return

	for var_name in narrative_choices.keys():
		Dialogic.VAR.set(var_name, narrative_choices[var_name])

	print("Restored narrative choices: ", narrative_choices)


# Playtime tracking functions
func get_total_playtime() -> float:
	"""Get total playtime in seconds"""
	return total_playtime


func get_formatted_playtime() -> String:
	"""Get formatted playtime as 'Xh Ym'"""
	var hours = int(total_playtime / 3600)
	var minutes = int((total_playtime - hours * 3600) / 60)
	return "%dh %dm" % [hours, minutes]
