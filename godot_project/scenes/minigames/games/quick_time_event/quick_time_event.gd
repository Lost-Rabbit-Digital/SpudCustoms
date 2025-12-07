class_name QuickTimeEventMinigame
extends MinigameContainer
## Quick Time Event (QTE) minigame for dramatic narrative transitions.
##
## Shows a sequence of key prompts that the player must press within a time window.
## Success leads to bonus points and narrative progression.
## Great for tense moments like escapes, infiltrations, or confrontations.
##
## Unlocks: Shift 8+

# Audio assets
var _snd_prompt_appear = preload("res://assets/audio/ui_feedback/motion_straight_air.wav")
var _snd_key_success = preload("res://assets/audio/ui_feedback/Task Complete Ensemble 001.wav")
var _snd_key_fail = preload("res://assets/audio/minigames/minigame_timeout_whomp.mp3")
var _snd_sequence_complete = preload("res://assets/audio/minigames/minigame_success_fanfare.mp3")

## Number of QTE prompts in the sequence
@export var prompt_count: int = 5

## Time window to press each key (seconds)
@export var time_per_prompt: float = 2.0

## Points per successful key press
@export var points_per_press: int = 50

## Available keys for QTE prompts
const QTE_KEYS = [
	{"key": KEY_SPACE, "display": "SPACE", "action": "ui_select"},
	{"key": KEY_E, "display": "E", "action": null},
	{"key": KEY_Q, "display": "Q", "action": null},
	{"key": KEY_F, "display": "F", "action": null},
]

# Internal state
var _current_prompt_index: int = 0
var _current_key: Dictionary = {}
var _prompt_time_remaining: float = 0.0
var _successful_presses: int = 0
var _is_waiting_for_input: bool = false

# UI elements
var _prompt_label: Label = null
var _key_label: Label = null
var _progress_bar: ProgressBar = null
var _feedback_label: Label = null
var _timer_bar: ProgressBar = null


func _ready() -> void:
	super._ready()
	minigame_type = "quick_time_event"
	time_limit = 0.0  # We use per-prompt timing instead
	skippable = true
	reward_multiplier = 1.0

	if title_label:
		title_label.text = "QUICK TIME EVENT"
	if instruction_label:
		instruction_label.text = "Press the keys as they appear!"


func _on_minigame_start(config: Dictionary) -> void:
	_current_prompt_index = 0
	_successful_presses = 0
	_is_waiting_for_input = false

	if config.has("prompt_count"):
		prompt_count = config.prompt_count
	if config.has("time_per_prompt"):
		time_per_prompt = config.time_per_prompt
	if config.has("narrative_context"):
		# Use narrative context to customize the display
		if instruction_label:
			instruction_label.text = config.narrative_context

	_setup_minigame_scene()
	_show_next_prompt()


func _setup_minigame_scene() -> void:
	for child in subviewport.get_children():
		child.queue_free()

	# Dark dramatic background
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08, 0.95)
	bg.size = subviewport.size
	subviewport.add_child(bg)

	# Narrative prompt (top)
	_prompt_label = Label.new()
	_prompt_label.name = "PromptLabel"
	_prompt_label.text = "Get ready..."
	_prompt_label.add_theme_font_size_override("font_size", 24)
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.size = Vector2(subviewport.size.x, 50)
	_prompt_label.position = Vector2(0, 80)
	subviewport.add_child(_prompt_label)

	# Key to press (center, large)
	_key_label = Label.new()
	_key_label.name = "KeyLabel"
	_key_label.text = ""
	_key_label.add_theme_font_size_override("font_size", 72)
	_key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_key_label.size = Vector2(subviewport.size.x, 100)
	_key_label.position = Vector2(0, subviewport.size.y / 2 - 50)
	_key_label.modulate = Color.WHITE
	subviewport.add_child(_key_label)

	# Timer bar (below key)
	_timer_bar = ProgressBar.new()
	_timer_bar.name = "TimerBar"
	_timer_bar.min_value = 0
	_timer_bar.max_value = 100
	_timer_bar.value = 100
	_timer_bar.show_percentage = false
	_timer_bar.size = Vector2(400, 20)
	_timer_bar.position = Vector2(subviewport.size.x / 2 - 200, subviewport.size.y / 2 + 70)
	subviewport.add_child(_timer_bar)

	# Progress indicator (bottom)
	_progress_bar = ProgressBar.new()
	_progress_bar.name = "ProgressBar"
	_progress_bar.min_value = 0
	_progress_bar.max_value = prompt_count
	_progress_bar.value = 0
	_progress_bar.show_percentage = false
	_progress_bar.size = Vector2(300, 15)
	_progress_bar.position = Vector2(subviewport.size.x / 2 - 150, subviewport.size.y - 100)
	subviewport.add_child(_progress_bar)

	var progress_label = Label.new()
	progress_label.text = "Progress"
	progress_label.add_theme_font_size_override("font_size", 14)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.size = Vector2(300, 20)
	progress_label.position = Vector2(subviewport.size.x / 2 - 150, subviewport.size.y - 120)
	subviewport.add_child(progress_label)

	# Feedback label
	_feedback_label = Label.new()
	_feedback_label.name = "FeedbackLabel"
	_feedback_label.text = ""
	_feedback_label.add_theme_font_size_override("font_size", 28)
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_label.size = Vector2(subviewport.size.x, 40)
	_feedback_label.position = Vector2(0, subviewport.size.y / 2 + 110)
	_feedback_label.modulate = Color.WHITE
	subviewport.add_child(_feedback_label)


func _show_next_prompt() -> void:
	if _current_prompt_index >= prompt_count:
		_sequence_complete()
		return

	# Pick a random key
	_current_key = QTE_KEYS[randi() % QTE_KEYS.size()]

	# Reset timer
	_prompt_time_remaining = time_per_prompt

	# Update UI
	_key_label.text = "[%s]" % _current_key.display
	_key_label.modulate = Color.WHITE
	_feedback_label.text = ""
	_timer_bar.value = 100

	# Play prompt sound
	_play_sound(_snd_prompt_appear, -5.0, 1.0 + _current_prompt_index * 0.1)

	# Animate key appearing
	_key_label.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(_key_label, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	_is_waiting_for_input = true


func _process(delta: float) -> void:
	super._process(delta)

	if not _is_active or not _is_waiting_for_input:
		return

	# Update prompt timer
	_prompt_time_remaining -= delta
	_timer_bar.value = (_prompt_time_remaining / time_per_prompt) * 100

	# Color timer bar based on urgency
	if _prompt_time_remaining < time_per_prompt * 0.3:
		_timer_bar.modulate = Color.RED
		_key_label.modulate = Color(1.0, 0.5, 0.5)
	elif _prompt_time_remaining < time_per_prompt * 0.6:
		_timer_bar.modulate = Color.ORANGE
	else:
		_timer_bar.modulate = Color.WHITE

	# Check for timeout
	if _prompt_time_remaining <= 0:
		_on_prompt_timeout()


func _input(event: InputEvent) -> void:
	if not _is_active or not _is_waiting_for_input:
		return

	# Check for key press
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == _current_key.key:
			_on_correct_key_pressed()
		else:
			# Wrong key - show feedback but don't fail
			_show_feedback("Wrong key!", Color.YELLOW)

	# Also check for action if defined
	if _current_key.action and event.is_action_pressed(_current_key.action):
		_on_correct_key_pressed()


func _on_correct_key_pressed() -> void:
	_is_waiting_for_input = false
	_successful_presses += 1
	_current_prompt_index += 1

	# Update progress
	_progress_bar.value = _current_prompt_index

	# Visual feedback
	_key_label.modulate = Color.GREEN
	_show_feedback("Nice!", Color.GREEN)

	# Play success sound with increasing pitch
	_play_sound(_snd_key_success, -3.0, 0.9 + _successful_presses * 0.05)

	# Small delay before next prompt
	await get_tree().create_timer(0.4).timeout

	if _is_active:
		_show_next_prompt()


func _on_prompt_timeout() -> void:
	_is_waiting_for_input = false
	_current_prompt_index += 1

	# Update progress
	_progress_bar.value = _current_prompt_index

	# Visual feedback
	_key_label.modulate = Color.RED
	_show_feedback("Missed!", Color.RED)

	# Play fail sound
	_play_sound(_snd_key_fail, -5.0)

	# Delay before next prompt
	await get_tree().create_timer(0.6).timeout

	if _is_active:
		_show_next_prompt()


func _show_feedback(text: String, color: Color) -> void:
	_feedback_label.text = text
	_feedback_label.modulate = color

	# Fade out feedback
	var tween = create_tween()
	tween.tween_property(_feedback_label, "modulate:a", 0.0, 0.5).set_delay(0.3)


func _sequence_complete() -> void:
	_is_waiting_for_input = false

	# Calculate score
	var total_score = _successful_presses * points_per_press
	var success_rate = float(_successful_presses) / float(prompt_count)

	# Determine outcome message
	var outcome_message: String
	if success_rate >= 0.8:
		outcome_message = "Excellent! Perfect timing!"
		_key_label.modulate = Color.GREEN
	elif success_rate >= 0.5:
		outcome_message = "Good effort! You made it through!"
		_key_label.modulate = Color.YELLOW
	else:
		outcome_message = "Close call! But you survived!"
		_key_label.modulate = Color.ORANGE

	_key_label.text = outcome_message
	_key_label.add_theme_font_size_override("font_size", 32)
	_feedback_label.text = "%d / %d successful (+%d points)" % [_successful_presses, prompt_count, total_score]
	_feedback_label.modulate = Color.WHITE

	# Play completion sound
	_play_sound(_snd_sequence_complete, -3.0)

	complete_success(total_score, {
		"successful_presses": _successful_presses,
		"total_prompts": prompt_count,
		"success_rate": success_rate
	})


func _play_sound(sound: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.volume_db = volume_db
		audio_player.pitch_scale = pitch
		audio_player.play()
