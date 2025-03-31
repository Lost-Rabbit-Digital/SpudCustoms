extends AnimatedSprite2D
class_name PotatoEmoteSystem
## A fully autonomous emote system for potato characters.
##
## Simply add this as a child of your PotatoEmote node and it will
## automatically work with the settings you configure in the Inspector.

## Types of emotes available
enum EmoteType {
	ANGRY_FACE,
	HAPPY_FACE,
	SAD_FACE,
	BLANK,
	DOT_1,
	DOT_2,
	DOT_3,
	SINGULAR_HEART,
	BROKEN_HEART,
	SWIRLING_HEARTS,
	POPPING_VEIN,
	QUESTION,
	DOUBLE_EXCLAMATION,
	SINGULAR_EXCLAMATION,
	CONFUSED
}

## Maps emote types to frame indices
var emote_frames = {
	EmoteType.ANGRY_FACE: 0,
	EmoteType.HAPPY_FACE: 1,
	EmoteType.SAD_FACE: 2,
	EmoteType.BLANK: 3,
	EmoteType.DOT_1: 4,
	EmoteType.DOT_2: 5,
	EmoteType.DOT_3: 6,
	EmoteType.SINGULAR_HEART: 7,
	EmoteType.BROKEN_HEART: 8,
	EmoteType.SWIRLING_HEARTS: 9,
	EmoteType.POPPING_VEIN: 10,
	EmoteType.QUESTION: 11,
	EmoteType.DOUBLE_EXCLAMATION: 12,
	EmoteType.SINGULAR_EXCLAMATION: 13,
	EmoteType.CONFUSED: 14
}

## Emote categories
var emote_categories = {
	"happy": [EmoteType.HAPPY_FACE, EmoteType.SINGULAR_HEART, EmoteType.SWIRLING_HEARTS],
	"thinking": [EmoteType.DOT_1, EmoteType.DOT_2, EmoteType.DOT_3, EmoteType.QUESTION, EmoteType.CONFUSED],
	"negative": [EmoteType.ANGRY_FACE, EmoteType.SAD_FACE, EmoteType.BROKEN_HEART, EmoteType.POPPING_VEIN],
	"surprise": [EmoteType.DOUBLE_EXCLAMATION, EmoteType.SINGULAR_EXCLAMATION],
	"blank": [EmoteType.BLANK]
}

## Maps categories to sound types
var category_sound_map = {
	"happy": "froggy_dislike",
	"thinking": "froggy_dislike",
	"negative": "froggy_pain",
	"surprise": "froggy_dislike"
}

## Core components
var emote_sprite: AnimatedSprite2D
var emote_timer: Timer
var emote_delay_timer: Timer
var emote_audio_player: AudioStreamPlayer

## Configuration options (exposed to the Inspector)
@export_category("Initital Emote")
@export_range(1.0, 30.0) var minimum_initial_emote_delay: float = 1.0
@export_range(1.0, 30.0) var maximum_initial_emote_delay: float = 5.0
@export_category("General Emotes")
## Whether the emotes will be displayed at all
@export var emoting_enabled: bool = false
## [Seconds] How long the emote will remained displayed
@export_range(0.1, 10.0) var emote_duration: float = 2.0
## [Seconds] Minimum amount of time before the next emote is displayed
@export_range(1.0, 30.0) var minimum_emote_delay: float = 1.0
## [Seconds] Maximum amount of time before the next emote is dispalyed
@export_range(1.0, 30.0) var maximum_emote_delay: float = 5.0
@export_category("Audio")
## Whether to play audio when displaying an emote
@export var play_sounds: bool = false # Keep this shit off, it's so annoying
## [Decibels] How loud the audio for each emote is
@export_range(-100.0, 100.0) var emote_volume: float = -24.0

## Called when the node enters the scene tree
func _ready() -> void:
	# Setup timers and audio player
	_setup_timers()
	_setup_audio_player()
	
	emote_sprite = self
	
	# If we found a sprite and emoting is enabled, initialize the system
	if emoting_enabled and emote_sprite:
			_start_emoting()
	else:
		push_error("PotatoEmoteSystem: Could not find an AnimatedSprite2D to control")

## Setup the timers
func _setup_timers() -> void:
	# Setup display timer
	emote_timer = Timer.new()
	emote_timer.name = "EmoteTimer"
	emote_timer.one_shot = true
	emote_timer.wait_time = emote_duration
	emote_timer.timeout.connect(_on_emote_timer_timeout)
	add_child(emote_timer)

	# Setup delay timer
	emote_delay_timer = Timer.new()
	emote_delay_timer.name = "EmoteDelayTimer"
	emote_delay_timer.one_shot = true
	emote_delay_timer.wait_time = randf_range(minimum_emote_delay, maximum_emote_delay)
	emote_delay_timer.timeout.connect(_on_emote_delay_timer_timeout)
	add_child(emote_delay_timer)

## Setup the audio player
func _setup_audio_player() -> void:
	emote_audio_player = AudioStreamPlayer.new()
	emote_audio_player.name = "EmoteAudioPlayer"
	emote_audio_player.bus = "SFX"
	emote_audio_player.volume_db = -16.00
	add_child(emote_audio_player)

## Process function to handle inspector changes
func _process(_delta) -> void:
	# Handle inspector changes
	if emoting_enabled and emote_timer and emote_timer.is_stopped():
		emote_timer.wait_time = emote_duration
		
	if emoting_enabled and emote_delay_timer and emote_delay_timer.is_stopped():
		emote_delay_timer.wait_time = randf_range(minimum_emote_delay, maximum_emote_delay)
	
	# Handle emoting enabled/disabled toggling
	if emoting_enabled and emote_delay_timer.is_stopped() and (not emote_sprite or not emote_sprite.visible):
		_start_emoting()
	elif not emoting_enabled and not emote_delay_timer.is_stopped():
		emote_delay_timer.stop()

## Start automatic emoting
func _start_emoting() -> void:
	if not emote_sprite:
		return
	
	var delay = randf_range(minimum_initial_emote_delay, maximum_initial_emote_delay)
	emote_delay_timer.start(delay)

## Shows a random emote
func show_random_emote() -> void:
	if not emote_sprite:
		return
		
	# Get a random emote
	var emote_keys = emote_frames.keys()
	var random_emote = emote_keys[randi() % emote_keys.size()]
	
	# Show it
	_show_emote(random_emote)

## Shows a random emote from a specific category
func show_random_emote_from_category(category: String) -> void:
	if not emote_sprite or not emote_categories.has(category):
		return
	
	# Get a random emote from this category
	var category_emotes = emote_categories[category]
	var random_emote = category_emotes[randi() % category_emotes.size()]
	
	# Show it
	_show_emote(random_emote)

## Internal function to display an emote
func _show_emote(emote_type: int) -> void:
	if not emote_sprite or not emote_frames.has(emote_type):
		return
	
	# Stop any running emote timer
	if not emote_timer.is_stopped():
		emote_timer.stop()
	
	# Set and display the emote
	emote_sprite.frame = emote_frames[emote_type]
	emote_sprite.visible = true
	
	# Play sound if enabled
	if play_sounds:
		_play_emote_sound(emote_type)
	
	# Start timer to hide the emote
	emote_timer.start(emote_duration)

## Hides the current emote
func _hide_emote() -> void:
	if not emote_sprite:
		return
		
	# Hide the emote
	emote_sprite.visible = false
	
	# If emoting is enabled, schedule the next emote
	if emoting_enabled:
		var next_delay = randf_range(minimum_emote_delay, maximum_emote_delay)
		emote_delay_timer.start(next_delay)

## Plays a sound effect for the given emote
func _play_emote_sound(emote_type: int) -> void:
	if not emote_audio_player or not play_sounds:
		return
		
	# Find which category this emote belongs to
	var emote_category = ""
	for category in emote_categories:
		if emote_type in emote_categories[category]:
			emote_category = category
			break
	
	# No sound for blank category
	if emote_category == "blank":
		return
	
	# Get sound type and number
	var sound_type = category_sound_map.get(emote_category, "froggy_dislike")
	var max_num = 9 if sound_type == "froggy_dislike" else 7
	var sound_num = (randi() % max_num) + 1
	
	# Build file path and load sound
	var sound_path = "res://assets/audio/talking/{0}_{1}.wav".format([sound_type, sound_num])
	var stream = load(sound_path)
	
	if stream:
		emote_audio_player.stream = stream
		emote_audio_player.pitch_scale = randf_range(0.6, 1.2)
		emote_audio_player.play()

## Timer callbacks
func _on_emote_timer_timeout() -> void:
	_hide_emote()

func _on_emote_delay_timer_timeout() -> void:
	if emoting_enabled:
		show_random_emote()

## Clean up when removed from the scene
func _exit_tree() -> void:
	# Ensure timers are stopped to prevent errors
	if emote_timer and not emote_timer.is_stopped():
		emote_timer.stop()
	
	if emote_delay_timer and not emote_delay_timer.is_stopped():
		emote_delay_timer.stop()
