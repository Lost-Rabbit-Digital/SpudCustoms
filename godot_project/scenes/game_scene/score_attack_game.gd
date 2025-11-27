# score_attack_game.gd
extends "res://scenes/game_scene/mainGame.gd"

# Override variables for score attack mode
var initial_difficulty_multiplier = 1.0
var difficulty_increase_rate = 0.05  # Per minute
var score_multiplier = 1.0
var time_survived = 0.0


func _ready():
	# Call parent _ready first
	super._ready()

	# Configure for endless mode
	# Configure for endless mode
	# REFACTORED: Use GameStateManager
	if GameStateManager:
		GameStateManager._quota_target = 9999  # Effectively infinite

	# Update UI to show score attack mode
	$UI/Labels/QuotaLabel.text = "Score Attack Mode"

	# Set initial difficulty based on selected difficulty
	# Set initial difficulty based on selected difficulty
	# REFACTORED: Use GameStateManager
	var difficulty = GameStateManager.get_difficulty() if GameStateManager else "Normal"
	match difficulty:
		"Easy":
			initial_difficulty_multiplier = 0.8
		"Normal":
			initial_difficulty_multiplier = 1.0
		"Expert":
			initial_difficulty_multiplier = 1.3

	# Apply initial settings
	border_runner_system.runner_chance = original_runner_chance * initial_difficulty_multiplier

	# Special welcome message
	# Special welcome message
	# REFACTORED: Use EventBus
	EventBus.show_alert(
		"SCORE ATTACK MODE!\nSurvive as long as possible!\nDifficulty increases over time!",
		true
	)


func _process(delta):
	if !is_game_paused and !narrative_manager.is_dialogue_active():
		# Track time survived
		time_survived += delta

		# Update score multiplier based on time (every 3 minutes = +0.5x multiplier)
		score_multiplier = 1.0 + (time_survived / 180.0) * 0.5

		# Gradually increase difficulty
		var time_minutes = time_survived / 60.0
		border_runner_system.runner_chance = min(
			(
				original_runner_chance
				* (initial_difficulty_multiplier + time_minutes * difficulty_increase_rate)
			),
			0.5  # Cap at 50% chance
		)

		# Make potatoes walk slightly faster over time too
		var speed_increase = time_minutes * 0.01  # 1% faster per minute
		regular_potato_speed = min(regular_potato_speed * (1.0 + speed_increase), 1.0)  # Cap at 1.0 speed

		# Update UI to show current multiplier and time
		# Update UI to show current multiplier and time
		# REFACTORED: Use GameStateManager
		var current_score = GameStateManager.get_score() if GameStateManager else 0
		$UI/Labels/ScoreLabel.text = "Score: %s (x%.1f)" % [current_score, score_multiplier]

		# Add a time survived display
		var minutes = int(time_survived / 60)
		var seconds = int(time_survived) % 60
		$UI/Labels/TimeLabel.text = "Time: %02d:%02d" % [minutes, seconds]

	# Call parent process last
	super._process(delta)


# Override add_score to apply multiplier
func award_points(base_points: int):
	var combo_multiplier = add_to_combo()
	var total_points = base_points * combo_multiplier * score_multiplier
	# REFACTORED: Use EventBus
	EventBus.request_score_add(int(total_points), "score_attack_award", {})
	return total_points


# Special end condition - can only lose in score attack, never "win"
func end_shift(success: bool = true):
	# Override success parameter - in score attack, always show the "survived for X time" message
	shift_stats.time_taken = time_survived

	# Add special score attack fields to stats
	shift_stats.score_attack_time = time_survived
	shift_stats.score_attack_multiplier = score_multiplier

	# Call the parent method with success=false to show the game over screen
	super.end_shift(false)
