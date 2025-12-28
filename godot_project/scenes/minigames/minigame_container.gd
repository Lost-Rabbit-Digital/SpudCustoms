class_name MinigameContainer
extends CanvasLayer
## Base container for all minigames using SubViewport isolation.
##
## Provides a clean interface for launching minigames that:
## - Run in their own SubViewport (isolated rendering/input)
## - Pause the main game automatically
## - Emit results via EventBus when complete
## - Support smooth transitions in/out
##
## Design Philosophy: Minigames should be REWARDING, not punishing.
## - Success = bonus rewards
## - "Failure" = no penalty, just miss the bonus
## - Always feel fair and achievable

# General minigame audio assets
var _snd_success_options = [
	preload("res://assets/audio/minigames/minigame_success_fanfare.mp3"),
	preload("res://assets/audio/minigames/minigame_success_chiptune.mp3"),
	preload("res://assets/audio/minigames/minigame_success_cashregister.mp3")
]
var _snd_timeout_options = [
	preload("res://assets/audio/minigames/minigame_timeout_clock.mp3"),
	preload("res://assets/audio/minigames/minigame_timeout_trombone.mp3"),
	preload("res://assets/audio/minigames/minigame_timeout_whomp.mp3")
]
var _snd_music_fast = preload("res://assets/audio/minigames/minigame_music_fast.mp3")
var _snd_music_slow = preload("res://assets/audio/minigames/minigame_music_slow.mp3")

# General minigame UI texture assets (preloaded for future use)
var _tex_ui_timer_bar = preload("res://assets/minigames/textures/minigame_ui_timer_bar.png")
var _tex_ui_score_frame = preload("res://assets/minigames/textures/minigame_ui_score_frame.png")
var _tex_ui_result_success = preload("res://assets/minigames/textures/minigame_ui_result_splash_success.png")
var _tex_ui_result_failure = preload("res://assets/minigames/textures/minigame_ui_result_splash_failure.png")

## Emitted when minigame completes (success or skip)
signal minigame_completed(result: Dictionary)

## Emitted when minigame is skipped/cancelled
signal minigame_skipped()

## The type of minigame (for EventBus tracking)
@export var minigame_type: String = "base"

## Time limit in seconds (0 = no limit)
@export var time_limit: float = 0.0

## Whether player can skip this minigame
@export var skippable: bool = true

## Reward multiplier for completing the minigame
@export var reward_multiplier: float = 1.5

## Sound to play on success
@export var success_sound: AudioStream

## Sound to play on time running out (not failure, just "time's up!")
@export var timeout_sound: AudioStream

# Internal state
var _is_active: bool = false
var _time_remaining: float = 0.0
var _was_tree_paused: bool = false
var _result: Dictionary = {}

# Node references
@onready var subviewport_container: SubViewportContainer = $SubViewportContainer
@onready var subviewport: SubViewport = $SubViewportContainer/SubViewport
@onready var timer_label: Label = $UI/TimerLabel
@onready var skip_button: Button = $UI/SkipButton
@onready var title_label: Label = $UI/TitleLabel
@onready var instruction_label: Label = $UI/InstructionLabel
@onready var audio_player: AudioStreamPlayer = $AudioPlayer


func _ready() -> void:
	# Hide by default
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS  # Process even when tree is paused

	# Connect skip button
	if skip_button:
		skip_button.pressed.connect(_on_skip_pressed)
		skip_button.visible = skippable

	# Hide timer if no time limit
	if timer_label and time_limit <= 0:
		timer_label.visible = false


func _process(delta: float) -> void:
	if not _is_active:
		return

	# Update timer if we have a time limit
	if time_limit > 0:
		_time_remaining -= delta
		_update_timer_display()

		if _time_remaining <= 0:
			_on_time_up()


## Start the minigame with optional configuration
func start(config: Dictionary = {}) -> void:
	if _is_active:
		push_warning("Minigame already active!")
		return

	# Store if tree was already paused
	_was_tree_paused = get_tree().paused

	# Pause the main game
	get_tree().paused = true

	# Reset state
	_is_active = true
	_time_remaining = time_limit
	_result = {
		"success": false,
		"score_bonus": 0,
		"time_taken": 0.0,
		"minigame_type": minigame_type
	}

	# Apply config
	if config.has("time_limit"):
		time_limit = config.time_limit
		_time_remaining = time_limit

	# Show the minigame
	visible = true
	_update_timer_display()

	# Call subclass setup
	_on_minigame_start(config)

	# Emit event via EventBus
	if EventBus:
		EventBus.minigame_started.emit(minigame_type)

	print("[Minigame] Started: ", minigame_type)


## Complete the minigame successfully
func complete_success(bonus_score: int = 0, extra_data: Dictionary = {}) -> void:
	if not _is_active:
		return

	_result.success = true
	_result.score_bonus = int(bonus_score * reward_multiplier)
	_result.time_taken = time_limit - _time_remaining if time_limit > 0 else 0.0
	_result.merge(extra_data)

	# Play a random success sound
	if audio_player and _snd_success_options.size() > 0:
		var random_success = _snd_success_options[randi() % _snd_success_options.size()]
		audio_player.stream = random_success
		audio_player.play()

	# Call subclass cleanup
	_on_minigame_complete()

	# Small delay for feedback, then close
	await get_tree().create_timer(0.5).timeout
	_finish()


## Called when time runs out - NOT a failure, just end without bonus
func _on_time_up() -> void:
	if not _is_active:
		return

	_result.success = false
	_result.score_bonus = 0
	_result.time_taken = time_limit

	# Play a random timeout sound (friendly, not punishing)
	if audio_player and _snd_timeout_options.size() > 0:
		var random_timeout = _snd_timeout_options[randi() % _snd_timeout_options.size()]
		audio_player.stream = random_timeout
		audio_player.play()

	# Show encouraging message
	if instruction_label:
		instruction_label.text = tr("minigame_times_up")

	_on_minigame_complete()

	await get_tree().create_timer(1.0).timeout
	_finish()


## Skip the minigame (no penalty)
func _on_skip_pressed() -> void:
	if not _is_active or not skippable:
		return

	_result.success = false
	_result.score_bonus = 0
	_result.skipped = true

	minigame_skipped.emit()
	_finish()


## Finish and clean up
func _finish() -> void:
	_is_active = false
	visible = false

	# Stop any timer animations
	_stop_timer_pulse()

	# Restore pause state
	get_tree().paused = _was_tree_paused

	# Emit completion
	minigame_completed.emit(_result)

	if EventBus:
		EventBus.minigame_completed.emit(_result)

	print("[Minigame] Completed: ", minigame_type, " Result: ", _result)


## Update the timer display
func _update_timer_display() -> void:
	if not timer_label or time_limit <= 0:
		return

	var seconds = int(_time_remaining)
	var fraction = int((_time_remaining - seconds) * 10)
	timer_label.text = "%d.%d" % [seconds, fraction]

	# Color and animation warning when low on time (accessibility: use color + animation)
	if _time_remaining <= 1.0:
		# Critical time - red + fast pulse
		timer_label.add_theme_color_override("font_color", Color.RED)
		_start_timer_pulse(0.15)  # Fast pulse
	elif _time_remaining <= 3.0:
		# Warning time - orange + slow pulse
		timer_label.add_theme_color_override("font_color", Color.ORANGE)
		_start_timer_pulse(0.3)  # Slower pulse
	else:
		# Normal time - stop any pulsing
		_stop_timer_pulse()
		timer_label.remove_theme_color_override("font_color")


## Start a pulsing animation on the timer label for accessibility (non-color indicator)
func _start_timer_pulse(pulse_speed: float = 0.3) -> void:
	if not timer_label:
		return

	# Only create new tween if not already pulsing at this speed
	if timer_label.has_meta("pulse_speed") and timer_label.get_meta("pulse_speed") == pulse_speed:
		return

	# Stop existing pulse
	_stop_timer_pulse()

	timer_label.set_meta("pulse_speed", pulse_speed)
	timer_label.set_meta("pulsing", true)

	var tween = create_tween()
	tween.set_loops()  # Infinite loop
	tween.tween_property(timer_label, "scale", Vector2(1.2, 1.2), pulse_speed).set_ease(Tween.EASE_OUT)
	tween.tween_property(timer_label, "scale", Vector2(1.0, 1.0), pulse_speed).set_ease(Tween.EASE_IN)

	timer_label.set_meta("pulse_tween", tween)


## Stop the timer pulse animation
func _stop_timer_pulse() -> void:
	if not timer_label:
		return

	if timer_label.has_meta("pulse_tween"):
		var tween = timer_label.get_meta("pulse_tween")
		if tween and tween.is_valid():
			tween.kill()
		timer_label.remove_meta("pulse_tween")

	if timer_label.has_meta("pulse_speed"):
		timer_label.remove_meta("pulse_speed")

	if timer_label.has_meta("pulsing"):
		timer_label.remove_meta("pulsing")

	# Reset scale
	timer_label.scale = Vector2.ONE


# === Virtual methods for subclasses ===

## Override to set up minigame-specific content
func _on_minigame_start(_config: Dictionary) -> void:
	pass


## Override to clean up minigame-specific content
func _on_minigame_complete() -> void:
	pass
