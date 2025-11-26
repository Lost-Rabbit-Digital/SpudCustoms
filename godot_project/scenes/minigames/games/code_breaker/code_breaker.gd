class_name CodeBreakerMinigame
extends MinigameContainer
## Crack the security code to verify documents!
##
## A Mastermind-style code guessing game.
## Enter a code, get feedback on correct positions and values.
## Simple and satisfying puzzle.
##
## Unlocks: Shift 4+

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


func _ready() -> void:
	super._ready()
	minigame_type = "code_breaker"
	time_limit = 45.0
	skippable = true
	reward_multiplier = 1.0

	if title_label:
		title_label.text = "CODE BREAKER"
	if instruction_label:
		instruction_label.text = "Crack the code! Green = correct position, Yellow = wrong position"


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


func _on_clear_pressed() -> void:
	_current_input.clear()
	_update_input_display()


func _on_submit_pressed() -> void:
	if not _is_active:
		return

	if _current_input.size() != code_length:
		return

	_current_attempt += 1

	# Check the guess
	var result = _check_guess(_current_input)

	# Add to history
	_add_history_entry(_current_input, result)

	# Check win condition
	if result.correct_position == code_length:
		_code_cracked()
		return

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

	var secret_copy = _secret_code.duplicate()
	var guess_copy = guess.duplicate()

	# First pass: check correct positions
	for i in range(code_length):
		if guess[i] == _secret_code[i]:
			correct_position += 1
			secret_copy[i] = -1
			guess_copy[i] = -2

	# Second pass: check correct digits in wrong positions
	for i in range(code_length):
		if guess_copy[i] >= 0:
			var idx = secret_copy.find(guess_copy[i])
			if idx >= 0:
				correct_digit += 1
				secret_copy[idx] = -1

	return {
		"correct_position": correct_position,
		"correct_digit": correct_digit
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

	# Show the guess
	var guess_label = Label.new()
	var guess_str = ""
	for d in guess:
		guess_str += str(d) + " "
	guess_label.text = guess_str.strip_edges()
	guess_label.add_theme_font_size_override("font_size", 18)
	guess_label.custom_minimum_size = Vector2(120, 25)
	entry.add_child(guess_label)

	# Show feedback
	var feedback = HBoxContainer.new()
	feedback.add_theme_constant_override("separation", 5)

	# Green dots for correct position
	for i in range(result.correct_position):
		var dot = ColorRect.new()
		dot.color = Color.GREEN
		dot.custom_minimum_size = Vector2(15, 15)
		feedback.add_child(dot)

	# Yellow dots for correct digit wrong position
	for i in range(result.correct_digit):
		var dot = ColorRect.new()
		dot.color = Color.YELLOW
		dot.custom_minimum_size = Vector2(15, 15)
		feedback.add_child(dot)

	# Gray dots for wrong
	var wrong = code_length - result.correct_position - result.correct_digit
	for i in range(wrong):
		var dot = ColorRect.new()
		dot.color = Color.GRAY
		dot.custom_minimum_size = Vector2(15, 15)
		feedback.add_child(dot)

	entry.add_child(feedback)
	_history_container.add_child(entry)


func _code_cracked() -> void:
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
