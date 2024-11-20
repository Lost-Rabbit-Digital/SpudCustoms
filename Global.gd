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

# Signals
signal score_updated(new_score: int)
signal high_score_achieved(difficulty: String, score: int)

func _ready():
	# Initialize score to final_score if it exists
	score = final_score
	load_high_scores()

func add_score(points: int):
	score += points
	final_score = score  # Keep final_score in sync
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
