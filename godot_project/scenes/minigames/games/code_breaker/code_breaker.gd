class_name CodeBreakerMinigame
extends MinigameContainer
## Crack the security code to verify documents!
##
## A Mastermind-style code guessing game.
## Enter a code, get feedback on correct positions and values.
## Simple and satisfying puzzle.
##
## Unlocks: Shift 4+

# Audio assets
var _snd_digit_input = preload("res://assets/audio/minigames/code_breaker_digit_input.mp3")
var _snd_submit = preload("res://assets/audio/minigames/code_breaker_submit.mp3")
var _snd_correct_position = preload("res://assets/audio/minigames/code_breaker_correct_position.mp3")
var _snd_wrong_position = preload("res://assets/audio/minigames/code_breaker_wrong_position.mp3")
var _snd_incorrect_digit = preload("res://assets/audio/minigames/code_breaker_incorrect_digit.mp3")
var _snd_cracked = preload("res://assets/audio/minigames/code_breaker_cracked.mp3")

# Texture assets (preloaded for future use)
var _tex_terminal_frame = preload("res://assets/minigames/textures/code_breaker_terminal_frame.png")
var _tex_keypad_buttons = preload("res://assets/minigames/textures/code_breaker_keypad_buttons.png")
var _tex_feedback_dots = preload("res://assets/minigames/textures/code_breaker_feedback_dots.png")
var _tex_lock_animation = preload("res://assets/minigames/textures/code_breaker_lock_animation.png")

## Number of digits in the code
@export var code_length: int = 4

## Maximum number of attempts
@export var max_attempts: int = 6

## Points per remaining attempt (bonus for fewer guesses)
@export var points_per_attempt_saved: int = 50

## Base points for cracking the code
@export var base_points: int = 150

# Internal state
var _secret_code: Array[int] = []
var _current_attempt: int = 0
var _current_input: Array[int] = []
var _digit_buttons: Array[Button] = []
var _input_display: Array[Label] = []
var _history_container: VBoxContainer


func _play_sound(sound: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.volume_db = volume_db
		audio_player.pitch_scale = pitch
		audio_player.play()


func _ready() -> void:
	super._ready()
	minigame_type = "code_breaker"
	time_limit = 45.0
	skippable = true
	reward_multiplier = 1.0

	if title_label:
		title_label.text = "CODE BREAKER"
	if instruction_label:
		instruction_label.text = "Crack the code! Green = exact match, Yellow = right digit wrong spot"


func _on_minigame_start(config: Dictionary) -> void:
	_current_attempt = 0
	_current_input.clear()
	_secret_code.clear()
	_digit_buttons.clear()
	_input_display.clear()

	if config.has("code_length"):
		code_length = config.code_length
	if config.has("max_attempts"):
		max_attempts = config.max_attempts

	# Generate secret code
	for i in range(code_length):
		_secret_code.append(randi() % 10)

	_setup_minigame_scene()


func _setup_minigame_scene() -> void:
	for child in subviewport.get_children():
		child.queue_free()

	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.08, 0.1, 0.12)
	bg.size = subviewport.size
	subviewport.add_child(bg)

	# Title
	var title = Label.new()
	title.text = "ENTER THE CODE"
	title.add_theme_font_size_override("font_size", 24)
	title.position = Vector2(subviewport.size.x / 2 - 100, 30)
	subviewport.add_child(title)

	# Current input display
	var input_container = HBoxContainer.new()
	input_container.name = "InputContainer"
	input_container.position = Vector2(subviewport.size.x / 2 - code_length * 35, 80)
	input_container.add_theme_constant_override("separation", 15)
	subviewport.add_child(input_container)

	for i in range(code_length):
		var digit_display = Label.new()
		digit_display.text = "_"
		digit_display.add_theme_font_size_override("font_size", 48)
		digit_display.custom_minimum_size = Vector2(50, 60)
		digit_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		input_container.add_child(digit_display)
		_input_display.append(digit_display)

	# Number pad (0-9)
	var numpad = GridContainer.new()
	numpad.name = "Numpad"
	numpad.columns = 5
	numpad.position = Vector2(subviewport.size.x / 2 - 175, 160)
	numpad.add_theme_constant_override("h_separation", 10)
	numpad.add_theme_constant_override("v_separation", 10)
	subviewport.add_child(numpad)

	for i in range(10):
		var btn = Button.new()
		btn.text = str(i)
		btn.custom_minimum_size = Vector2(60, 50)
		btn.add_theme_font_size_override("font_size", 24)
		btn.pressed.connect(_on_digit_pressed.bind(i))
		numpad.add_child(btn)
		_digit_buttons.append(btn)

	# Submit button
	var submit_btn = Button.new()
	submit_btn.name = "SubmitButton"
	submit_btn.text = "SUBMIT"
	submit_btn.custom_minimum_size = Vector2(150, 50)
	submit_btn.add_theme_font_size_override("font_size", 20)
	submit_btn.position = Vector2(subviewport.size.x / 2 - 75, 280)
	submit_btn.pressed.connect(_on_submit_pressed)
	subviewport.add_child(submit_btn)

	# Clear button
	var clear_btn = Button.new()
	clear_btn.name = "ClearButton"
	clear_btn.text = "CLEAR"
	clear_btn.custom_minimum_size = Vector2(100, 40)
	clear_btn.position = Vector2(subviewport.size.x / 2 - 50, 340)
	clear_btn.pressed.connect(_on_clear_pressed)
	subviewport.add_child(clear_btn)

	# History panel (previous guesses)
	var history_panel = Panel.new()
	history_panel.position = Vector2(50, 400)
	history_panel.size = Vector2(subviewport.size.x - 100, 180)
	subviewport.add_child(history_panel)

	var history_label = Label.new()
	history_label.text = "Previous Attempts:"
	history_label.add_theme_font_size_override("font_size", 16)
	history_label.position = Vector2(60, 385)
	subviewport.add_child(history_label)

	_history_container = VBoxContainer.new()
	_history_container.name = "HistoryContainer"
	_history_container.position = Vector2(60, 410)
	_history_container.add_theme_constant_override("separation", 5)
	subviewport.add_child(_history_container)

	# Attempts counter
	var attempts_label = Label.new()
	attempts_label.name = "AttemptsLabel"
	attempts_label.add_theme_font_size_override("font_size", 18)
	attempts_label.position = Vector2(subviewport.size.x - 180, 30)
	subviewport.add_child(attempts_label)
	_update_attempts_display()


func _on_digit_pressed(digit: int) -> void:
	if not _is_active:
		return

	if _current_input.size() < code_length:
		_current_input.append(digit)
		_update_input_display()
		# Pitch increases as more digits are entered
		var pitch = 0.9 + (_current_input.size() * 0.1)
		_play_sound(_snd_digit_input, -3.0, pitch)


func _on_clear_pressed() -> void:
	_current_input.clear()
	_update_input_display()


func _on_submit_pressed() -> void:
	if not _is_active:
		return

	if _current_input.size() != code_length:
		return

	_play_sound(_snd_submit, 0.0)
	_current_attempt += 1

	# Check the guess
	var result = _check_guess(_current_input)

	# Add to history
	_add_history_entry(_current_input, result)

	# Play feedback sound based on result
	if result.correct_position == code_length:
		_code_cracked()
		return
	elif result.correct_position > 0:
		_play_sound(_snd_correct_position, 0.0, 1.0 + result.correct_position * 0.05)
	elif result.correct_digit > 0:
		_play_sound(_snd_wrong_position, 0.0)
	else:
		_play_sound(_snd_incorrect_digit, 0.0)

	# Check lose condition
	if _current_attempt >= max_attempts:
		_out_of_attempts()
		return

	# Clear for next attempt
	_current_input.clear()
	_update_input_display()
	_update_attempts_display()


func _check_guess(guess: Array[int]) -> Dictionary:
	var correct_position = 0
	var correct_digit = 0

	# Per-position feedback: "green" = exact, "yellow" = wrong position, "gray" = not in code
	var position_feedback: Array[String] = []
	position_feedback.resize(code_length)
	for i in range(code_length):
		position_feedback[i] = "gray"

	var secret_copy = _secret_code.duplicate()
	var guess_copy = guess.duplicate()

	# First pass: check correct positions (green)
	for i in range(code_length):
		if guess[i] == _secret_code[i]:
			correct_position += 1
			position_feedback[i] = "green"
			secret_copy[i] = -1
			guess_copy[i] = -2

	# Second pass: check correct digits in wrong positions (yellow)
	for i in range(code_length):
		if guess_copy[i] >= 0:
			var idx = secret_copy.find(guess_copy[i])
			if idx >= 0:
				correct_digit += 1
				position_feedback[i] = "yellow"
				secret_copy[idx] = -1

	return {
		"correct_position": correct_position,
		"correct_digit": correct_digit,
		"position_feedback": position_feedback
	}


func _update_input_display() -> void:
	for i in range(code_length):
		if i < _current_input.size():
			_input_display[i].text = str(_current_input[i])
		else:
			_input_display[i].text = "_"


func _update_attempts_display() -> void:
	var label = subviewport.get_node_or_null("AttemptsLabel")
	if label:
		label.text = "Attempts: %d / %d" % [_current_attempt, max_attempts]


func _add_history_entry(guess: Array[int], result: Dictionary) -> void:
	var entry = HBoxContainer.new()
	entry.add_theme_constant_override("separation", 10)

	# Show the guess with Wordle-style per-digit coloring
	var digits_container = HBoxContainer.new()
	digits_container.add_theme_constant_override("separation", 5)

	var position_feedback: Array = result.get("position_feedback", [])

	for i in range(guess.size()):
		var digit_box = PanelContainer.new()
		digit_box.custom_minimum_size = Vector2(28, 28)

		# Create a stylebox for the background color
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4

		# Set color based on position feedback
		var feedback_color = "gray"
		if i < position_feedback.size():
			feedback_color = position_feedback[i]

		match feedback_color:
			"green":
				style.bg_color = Color(0.2, 0.7, 0.2)  # Green
			"yellow":
				style.bg_color = Color(0.8, 0.7, 0.1)  # Yellow/Gold
			_:
				style.bg_color = Color(0.3, 0.3, 0.35)  # Gray

		digit_box.add_theme_stylebox_override("panel", style)

		var digit_label = Label.new()
		digit_label.text = str(guess[i])
		digit_label.add_theme_font_size_override("font_size", 16)
		digit_label.add_theme_color_override("font_color", Color.WHITE)
		digit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		digit_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		digit_box.add_child(digit_label)

		digits_container.add_child(digit_box)

	entry.add_child(digits_container)

	# Add summary text (e.g., "2 exact, 1 close")
	var summary_label = Label.new()
	var exact = result.correct_position
	var close = result.correct_digit
	if exact > 0 and close > 0:
		summary_label.text = "%d exact, %d close" % [exact, close]
	elif exact > 0:
		summary_label.text = "%d exact" % exact
	elif close > 0:
		summary_label.text = "%d close" % close
	else:
		summary_label.text = "no matches"
	summary_label.add_theme_font_size_override("font_size", 14)
	summary_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	summary_label.custom_minimum_size = Vector2(100, 25)
	entry.add_child(summary_label)

	_history_container.add_child(entry)


func _code_cracked() -> void:
	_play_sound(_snd_cracked, 0.0)

	var attempts_saved = max_attempts - _current_attempt
	var total_score = base_points + (attempts_saved * points_per_attempt_saved)

	if instruction_label:
		instruction_label.text = "Code cracked in %d attempts! +%d points!" % [_current_attempt, total_score]

	# Reveal the code with celebration
	for i in range(code_length):
		_input_display[i].text = str(_secret_code[i])
		_input_display[i].add_theme_color_override("font_color", Color.GREEN)

	complete_success(total_score, {
		"attempts": _current_attempt,
		"max_attempts": max_attempts,
		"code": _secret_code,
		"cracked": true
	})


func _out_of_attempts() -> void:
	# Show the correct code
	for i in range(code_length):
		_input_display[i].text = str(_secret_code[i])
		_input_display[i].add_theme_color_override("font_color", Color.RED)

	if instruction_label:
		instruction_label.text = "Out of attempts! The code was shown above."

	# Small consolation points
	var consolation = int(base_points * 0.25)
	complete_success(consolation, {
		"attempts": _current_attempt,
		"max_attempts": max_attempts,
		"code": _secret_code,
		"cracked": false
	})
