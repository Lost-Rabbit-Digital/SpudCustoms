class_name PotatoEmoteSystem
extends Node
## A system to manage and display emotes for the potato character.
##
## This script handles loading, categorizing, and displaying emotes using an AnimatedSprite2D.
## It provides functions to display random emotes, emotes from specific categories,
## and manages the timing and animation of emote displays.

# Get reference to the PotatoEmote animated sprite node
static var emote_sprite: AnimatedSprite2D

## Node reference to manage timers and audio players
static var controller_node: Node

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
static var emote_frames = {
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
static var emote_categories = {
	"happy": [EmoteType.HAPPY_FACE, EmoteType.SINGULAR_HEART, EmoteType.SWIRLING_HEARTS],
	"thinking": [EmoteType.DOT_1, EmoteType.DOT_2, EmoteType.DOT_3, EmoteType.QUESTION, EmoteType.CONFUSED],
	"negative": [EmoteType.ANGRY_FACE, EmoteType.SAD_FACE, EmoteType.BROKEN_HEART, EmoteType.POPPING_VEIN],
	"surprise": [EmoteType.DOUBLE_EXCLAMATION, EmoteType.SINGULAR_EXCLAMATION],
	"blank": [EmoteType.BLANK]
}

## Dictionary mapping emote categories to sound types
static var category_sound_map = {
	"happy": "froggy_dislike",
	"thinking": "froggy_dislike",
	"negative": "froggy_pain",
	"surprise": "froggy_dislike"
}

## Timer for automatically hiding emotes after display
static var emote_timer: Timer

## Timer for dot sequence animation
static var dot_sequence_timer: Timer

## Audio player for emote sounds
static var emote_audio_player: AudioStreamPlayer

## Current emote being displayed
static var current_emote: int = -1

## Emote display duration in seconds
static var emote_duration: float = 2.0

## Whether the emote is currently visible
static var is_emote_visible: bool = false

## Whether the system is properly initialized
static var is_initialized: bool = false

## Called when the node enters the scene tree for the first time.
## Must be called manually to initialize the system
static func initialize(sprite_node: AnimatedSprite2D, parent_node: Node) -> void:
	emote_sprite = sprite_node
	
	# Create a controller node to manage timers and audio
	controller_node = Node.new()
	controller_node.name = "EmoteSystemController"
	parent_node.add_child(controller_node)
	
	# Create and configure the emote timer
	emote_timer = Timer.new()
	emote_timer.one_shot = true
	emote_timer.wait_time = emote_duration
	controller_node.add_child(emote_timer)
	
	# We need to connect signals through a method that exists on the controller_node
	# Since it's a plain Node, we need to extend it a bit
	controller_node.set_script(preload("res://scripts/systems/potato_emotes/emote_controller.gd"))
	
	# Create and configure the dot sequence timer
	dot_sequence_timer = Timer.new()
	dot_sequence_timer.one_shot = false
	dot_sequence_timer.wait_time = 0.4
	controller_node.add_child(dot_sequence_timer)
	
	# Create audio player for emote sounds
	emote_audio_player = AudioStreamPlayer.new()
	emote_audio_player.volume_db = -6.0  # Slightly quieter than default
	controller_node.add_child(emote_audio_player)
	
	# Hide the emote sprite initially
	hide_emote()
	
	is_initialized = true

## Shows a random emote from any category
## @return The EmoteType that was displayed
static func show_random_emote() -> int:
	if not _check_initialized():
		return -1
		
	var emote_keys = emote_frames.keys()
	var random_emote = emote_keys[randi() % emote_keys.size()]
	return show_emote(random_emote)

## Shows a random emote from a specific category
## @param category The category to choose from ("happy", "thinking", "negative", "surprise", "blank")
## @return The EmoteType that was displayed or -1 if category doesn't exist
static func show_random_emote_from_category(category: String) -> int:
	if not _check_initialized():
		return -1
		
	if not emote_categories.has(category):
		push_error("Invalid emote category: " + category)
		return -1
	
	var category_emotes = emote_categories[category]
	var random_emote = category_emotes[randi() % category_emotes.size()]
	return show_emote(random_emote)

## Shows a specific emote by its type
## @param emote_type The specific EmoteType to display
## @return The EmoteType that was displayed or -1 if type doesn't exist
static func show_emote(emote_type: int) -> int:
	if not _check_initialized():
		return -1
		
	if not emote_frames.has(emote_type):
		push_error("Invalid emote type: " + str(emote_type))
		return -1
	
	# Safely stop the dot sequence timer if it's running
	if dot_sequence_timer and dot_sequence_timer.is_inside_tree() and dot_sequence_timer.time_left > 0:
		dot_sequence_timer.stop()
	
	# Get the frame index for this emote type
	var frame_index = emote_frames[emote_type]
	
	# Update the current emote
	current_emote = emote_type
	
	# Set the sprite's frame to the correct emote
	emote_sprite.frame = frame_index
	
	# Make the emote visible
	emote_sprite.visible = true
	is_emote_visible = true
	
	# Play sound based on emote category
	_play_emote_sound()
	
	# Start the timer to hide the emote after duration
	if emote_timer and emote_timer.is_inside_tree():
		emote_timer.start(emote_duration)
	
	return emote_type

## Shows the thinking dots animation sequence (DOT_1 -> DOT_2 -> DOT_3)
## @param duration How long to show the entire sequence before hiding
static func show_thinking_dots(duration: float = 3.0) -> void:
	if not _check_initialized():
		return
		
	# Start with DOT_1
	show_emote(EmoteType.DOT_1)
	
	# Reset the main timer for the entire sequence
	if emote_timer and emote_timer.is_inside_tree():
		emote_timer.stop()
		emote_timer.start(duration)
	
	# Start the dot sequence timer
	if dot_sequence_timer and dot_sequence_timer.is_inside_tree():
		dot_sequence_timer.start()

## Hides the current emote
static func hide_emote() -> void:
	if not is_initialized:
		return
		
	if emote_sprite and is_instance_valid(emote_sprite):
		emote_sprite.visible = false
		is_emote_visible = false
		current_emote = -1
		
	if emote_timer and emote_timer.is_inside_tree() and emote_timer.time_left > 0:
		emote_timer.stop()
		
	if dot_sequence_timer and dot_sequence_timer.is_inside_tree() and dot_sequence_timer.time_left > 0:
		dot_sequence_timer.stop()

## Play a sound effect for the current emote
static func _play_emote_sound() -> void:
	if not is_initialized:
		return
		
	# Find which category the current emote belongs to
	var emote_category = ""
	for category in emote_categories:
		if current_emote in emote_categories[category]:
			emote_category = category
			break
	
	# No sound for blank category
	if emote_category == "blank":
		return
	
	# Get the sound type for this category
	var sound_type = category_sound_map.get(emote_category, "froggy_dislike")
	
	# Choose a random number for the sound file
	var max_num = 9 if sound_type == "froggy_dislike" else 7
	var sound_num = (randi() % max_num) + 1
	
	# Construct the path to the sound file
	var sound_path = "res://audio/talking/{0}_{1}.wav".format([sound_type, sound_num])
	
	# Load the audio stream
	var stream = load(sound_path)
	if stream:
		# Set the stream to the audio player
		emote_audio_player.stream = stream
		
		# Apply random pitch shift (between 0.8 and 1.2)
		emote_audio_player.pitch_scale = randf_range(0.8, 1.2)
		
		# Play the sound
		emote_audio_player.play()

## Check if the system is properly initialized, show error if not
static func _check_initialized() -> bool:
	if not is_initialized:
		push_error("PotatoEmoteSystem has not been initialized. Call initialize() first!")
		return false
	
	if not is_instance_valid(emote_sprite):
		push_error("PotatoEmoteSystem's emote_sprite is not valid!")
		return false
		
	if not is_instance_valid(controller_node):
		push_error("PotatoEmoteSystem's controller_node is not valid!")
		return false
	
	return true

## Sets the duration for which emotes are displayed
## @param duration The time in seconds to display emotes
static func set_emote_duration(duration: float) -> void:
	emote_duration = max(0.1, duration)  # Ensure minimum duration
	if emote_timer and emote_timer.is_inside_tree():
		emote_timer.wait_time = emote_duration
