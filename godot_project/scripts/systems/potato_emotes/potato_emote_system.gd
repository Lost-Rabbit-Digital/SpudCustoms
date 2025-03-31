extends Node
class_name PotatoEmoteSystem
## A non-static emote system to be attached to each potato character.
##
## This script handles displaying emotes using an [AnimatedSprite2D].
## Each potato has its own instance of this script.
##
## @tutorial: https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html

## Enum defining all available emote types
enum EmoteType {
	# Facial expressions
	ANGRY_FACE,
	HAPPY_FACE,
	SAD_FACE,
	
	# Ellipses
	BLANK,
	DOT_1,
	DOT_2,
	DOT_3,
	
	# Emotional Reponse
	SINGULAR_HEART,
	BROKEN_HEART,
	SWIRLING_HEARTS,
	POPPING_VEIN,
	
	# General Reactions
	QUESTION,
	DOUBLE_EXCLAMATION,
	SINGULAR_EXCLAMATION,
	CONFUSED
}

## Dictionary that maps emote types to their corresponding frame indices
var emote_frames: Dictionary = {
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

## Dictionary mapping category names to lists of emote types in that category
var emote_categories: Dictionary = {
	"happy": [EmoteType.HAPPY_FACE, EmoteType.SINGULAR_HEART, EmoteType.SWIRLING_HEARTS],
	"thinking": [EmoteType.DOT_1, EmoteType.DOT_2, EmoteType.DOT_3, EmoteType.QUESTION, EmoteType.CONFUSED],
	"negative": [EmoteType.ANGRY_FACE, EmoteType.SAD_FACE, EmoteType.BROKEN_HEART, EmoteType.POPPING_VEIN],
	"surprise": [EmoteType.DOUBLE_EXCLAMATION, EmoteType.SINGULAR_EXCLAMATION],
	"blank": [EmoteType.BLANK]
}

## Dictionary mapping emote categories to sound types
var category_sound_map: Dictionary = {
	"happy": "froggy_dislike",
	"thinking": "froggy_dislike",
	"negative": "froggy_pain",
	"surprise": "froggy_dislike"
}

## Reference to the emote sprite
var emote_sprite: AnimatedSprite2D

## Timer for automatically hiding emotes after display
var emote_timer: Timer

## Timer for the delay between random emotes
var emote_delay_timer: Timer

## Audio player for emote sounds
var emote_audio_player: AudioStreamPlayer

## Current emote being displayed
var current_emote: int = -1

## Emote display duration in seconds
@export var emote_duration: float = 2.0

## Delay between automatic emotes in seconds
@export var emote_delay: float = 5.0

## Whether the emote is currently visible
var is_emote_visible: bool = false

## Whether to play sounds with emotes
@export var play_sounds: bool = true

## Whether to automatically show random emotes
@export var auto_emote: bool = false

## Flag to track if the system has been initialized
var is_initialized: bool = false

## Initialize the emote system with the given sprite
## 
## Sets up timers, audio player, and initializes the emote system.
## @param sprite The [AnimatedSprite2D] to use for emotes
func init(sprite: AnimatedSprite2D) -> void:
	emote_sprite = sprite
	
	# Create and configure the emote timer
	emote_timer = Timer.new()
	emote_timer.one_shot = true
	emote_timer.wait_time = emote_duration
	emote_timer.timeout.connect(_on_emote_timer_timeout)
	add_child(emote_timer)

	# Create and configure the emote delay timer for automatic emoting
	emote_delay_timer = Timer.new()
	emote_delay_timer.one_shot = true
	emote_delay_timer.wait_time = emote_delay
	emote_delay_timer.timeout.connect(_on_emote_delay_timer_timeout)
	add_child(emote_delay_timer)
	
	# Create audio player for emote sounds
	emote_audio_player = AudioStreamPlayer.new()
	add_child(emote_audio_player)
	
	# Hide the emote sprite initially
	hide_emote()
	
	is_initialized = true
	
	# Start automatic emoting if enabled
	if auto_emote:
		start_auto_emoting()

## Starts automatic random emoting with the configured delay
func start_auto_emoting() -> void:
	if not is_initialized:
		push_error("Emote system not initialized!")
		return
		
	auto_emote = true
	# Start the timer for the first emote
	emote_delay_timer.start(randf_range(emote_delay * 0.5, emote_delay * 1.5))

## Stops automatic emoting
func stop_auto_emoting() -> void:
	auto_emote = false
	emote_delay_timer.stop()

## Shows a random emote from any category
## 
## Selects a random emote from all available types and displays it.
## @return The [enum EmoteType] that was displayed or -1 if not initialized
func show_random_emote() -> int:
	if not is_initialized:
		push_error("Emote system not initialized!")
		return -1
		
	var emote_keys: Array = emote_frames.keys()
	var random_emote: int = emote_keys[randi() % emote_keys.size()]
	return show_emote(random_emote)

## Shows a random emote from a specific category
## 
## Selects a random emote from the specified category and displays it.
## @param category The category to choose from ("happy", "thinking", "negative", "surprise", "blank")
## @return The [enum EmoteType] that was displayed or -1 if category doesn't exist or not initialized
func show_random_emote_from_category(category: String) -> int:
	if not is_initialized:
		push_error("Emote system not initialized!")
		return -1
		
	if not emote_categories.has(category):
		push_error("Invalid emote category: " + category)
		return -1
	
	var category_emotes: Array = emote_categories[category]
	var random_emote: int = category_emotes[randi() % category_emotes.size()]
	return show_emote(random_emote)

## Shows a specific emote by its type
## 
## Displays the specified emote and starts a timer to automatically hide it.
## @param emote_type The specific [enum EmoteType] to display
## @return The [enum EmoteType] that was displayed or -1 if type doesn't exist or not initialized
func show_emote(emote_type: int) -> int:
	if not is_initialized:
		push_error("Emote system not initialized!")
		return -1
		
	if not emote_frames.has(emote_type):
		push_error("Invalid emote type: " + str(emote_type))
		return -1
	
	# Get the frame index for this emote type
	var frame_index: int = emote_frames[emote_type]
	
	# Update the current emote
	current_emote = emote_type
	
	# Set the sprite's frame to the correct emote
	emote_sprite.frame = frame_index
	
	# Make the emote visible
	emote_sprite.visible = true
	is_emote_visible = true
	
	# Play sound if enabled
	if play_sounds:
		_play_emote_sound()
	
	# Start the timer to hide the emote after duration
	emote_timer.start(emote_duration)
	
	return emote_type

## Shows a simple thinking dots animation sequence (DOT_1 -> DOT_2 -> DOT_3)
## 
## Creates an animation of dots to indicate thinking.
## @param duration How long to show the entire animation before hiding
func show_thinking_dots(duration: float = 3.0) -> void:
	if not is_initialized:
		push_error("Emote system not initialized!")
		return
	
	# We'll create a simple tween to animate through the dots
	var tween = create_tween()
	
	# Make the emote visible and start with DOT_1
	emote_sprite.visible = true
	is_emote_visible = true
	current_emote = EmoteType.DOT_1
	emote_sprite.frame = emote_frames[EmoteType.DOT_1]
	
	# Chain the dot animations with delays
	var dot_duration: float = 0.4
	var total_cycles: int = int(duration / (dot_duration * 3))
	
	# Play sound if enabled (just once at the start)
	if play_sounds:
		_play_emote_sound()
	
	# Create the dot animation sequence
	for i in range(total_cycles):
		# DOT_1 is already showing to start
		if i > 0:
			tween.tween_property(emote_sprite, "frame", emote_frames[EmoteType.DOT_1], 0)
			tween.tween_interval(dot_duration)
		
		# DOT_2
		tween.tween_property(emote_sprite, "frame", emote_frames[EmoteType.DOT_2], 0)
		tween.tween_interval(dot_duration)
		
		# DOT_3
		tween.tween_property(emote_sprite, "frame", emote_frames[EmoteType.DOT_3], 0)
		tween.tween_interval(dot_duration)
	
	# Hide the emote when done
	tween.tween_callback(hide_emote)

## Hides the current emote
## 
## Resets the emote state and stops all timers.
func hide_emote() -> void:
	if not is_initialized:
		return
		
	if emote_sprite:
		emote_sprite.visible = false
		is_emote_visible = false
		current_emote = -1
		
	if emote_timer:
		emote_timer.stop()
	
	# If auto-emoting is enabled, start the delay timer for the next emote
	if auto_emote:
		emote_delay_timer.start(randf_range(emote_delay * 0.75, emote_delay * 1.25))

## Play a sound effect for the current emote
## 
## Selects an appropriate sound based on the emote category and plays it.
func _play_emote_sound() -> void:
	if not is_initialized:
		return
		
	# Find which category the current emote belongs to
	var emote_category: String = ""
	for category in emote_categories:
		if current_emote in emote_categories[category]:
			emote_category = category
			break
	
	# No sound for blank category
	if emote_category == "blank":
		return
	
	# Get the sound type for this category
	var sound_type: String = category_sound_map.get(emote_category, "froggy_dislike")
	
	# Choose a random number for the sound file
	var max_num: int = 9 if sound_type == "froggy_dislike" else 7
	var sound_num: int = (randi() % max_num) + 1
	
	# Construct the path to the sound file
	var sound_path: String = "res://assets/audio/talking/{0}_{1}.wav".format([sound_type, sound_num])
	
	# Load the audio stream
	var stream = load(sound_path)
	if stream:
		# Set the stream to the audio player
		emote_audio_player.stream = stream
		
		# Apply random pitch shift
		emote_audio_player.pitch_scale = randf_range(0.6, 1.2)
		
		# Set Bus
		emote_audio_player.bus = "SFX"
		
		# Set volume
		emote_audio_player.volume_db = -16.00
		
		# Play the sound
		#emote_audio_player.play()

## Callback for when the emote timer expires
## 
## Hides the current emote when its display duration is over.
func _on_emote_timer_timeout() -> void:
	hide_emote()

## Callback for the emote delay timer
## 
## Triggers a random emote when the delay between emotes has passed.
func _on_emote_delay_timer_timeout() -> void:
	if auto_emote:
		# Show a random emote
		show_random_emote()
		# The next delay timer will be started in hide_emote()
