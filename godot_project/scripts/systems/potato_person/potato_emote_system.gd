extends Node
## A system to manage and display emotes for the potato character.
##
## This script handles loading, categorizing, and displaying emotes using an AnimatedSprite2D.
## It provides functions to display random emotes, emotes from specific categories,
## and manages the timing and animation of emote displays.

# Get reference to the PotatoEmote animated sprite node
@onready var emote_sprite: AnimatedSprite2D = %PotatoEmote

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

## Dictionary mapping category names to lists of emote types in that category
var emote_categories = {
	"happy": [EmoteType.HAPPY_FACE, EmoteType.SINGULAR_HEART, EmoteType.SWIRLING_HEARTS],
	"thinking": [EmoteType.DOT_1, EmoteType.DOT_2, EmoteType.DOT_3, EmoteType.QUESTION, EmoteType.CONFUSED],
	"negative": [EmoteType.ANGRY_FACE, EmoteType.SAD_FACE, EmoteType.BROKEN_HEART, EmoteType.POPPING_VEIN],
	"surprise": [EmoteType.DOUBLE_EXCLAMATION, EmoteType.SINGULAR_EXCLAMATION],
	"blank": [EmoteType.BLANK]
}

## Timer for automatically hiding emotes after display
var emote_timer: Timer

## Timer for dot sequence animation
var dot_sequence_timer: Timer

## Current emote being displayed
var current_emote: int = -1

## Emote display duration in seconds
@export var emote_duration: float = 2.0

## Whether the emote is currently visible
var is_emote_visible: bool = false

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create and configure the emote timer
	emote_timer = Timer.new()
	emote_timer.one_shot = true
	emote_timer.wait_time = emote_duration
	emote_timer.timeout.connect(_on_emote_timer_timeout)
	add_child(emote_timer)
	
	# Create and configure the dot sequence timer
	dot_sequence_timer = Timer.new()
	dot_sequence_timer.one_shot = false
	dot_sequence_timer.wait_time = 0.4
	dot_sequence_timer.timeout.connect(_on_dot_sequence_timer_timeout)
	add_child(dot_sequence_timer)
	
	# Hide the emote sprite initially
	hide_emote()

## Shows a random emote from any category
## @return The EmoteType that was displayed
func show_random_emote() -> int:
	var emote_keys = emote_frames.keys()
	var random_emote = emote_keys[randi() % emote_keys.size()]
	return show_emote(random_emote)

## Shows a random emote from a specific category
## @param category The category to choose from ("happy", "thinking", "negative", "surprise", "blank")
## @return The EmoteType that was displayed or -1 if category doesn't exist
func show_random_emote_from_category(category: String) -> int:
	if not emote_categories.has(category):
		push_error("Invalid emote category: " + category)
		return -1
	
	var category_emotes = emote_categories[category]
	var random_emote = category_emotes[randi() % category_emotes.size()]
	return show_emote(random_emote)

## Shows a specific emote by its type
## @param emote_type The specific EmoteType to display
## @return The EmoteType that was displayed or -1 if type doesn't exist
func show_emote(emote_type: int) -> int:
	if not emote_frames.has(emote_type):
		push_error("Invalid emote type: " + str(emote_type))
		return -1
	
	# Stop any ongoing dot sequence
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
	
	# Start the timer to hide the emote after duration
	emote_timer.start(emote_duration)
	
	return emote_type

## Shows the thinking dots animation sequence (DOT_1 -> DOT_2 -> DOT_3)
## @param duration How long to show the entire sequence before hiding
func show_thinking_dots(duration: float = 3.0) -> void:
	# Start with DOT_1
	show_emote(EmoteType.DOT_1)
	
	# Reset the main timer for the entire sequence
	emote_timer.stop()
	emote_timer.start(duration)
	
	# Start the dot sequence timer
	dot_sequence_timer.start()

## Hides the current emote
func hide_emote() -> void:
	emote_sprite.visible = false
	is_emote_visible = false
	current_emote = -1
	emote_timer.stop()
	dot_sequence_timer.stop()

## Callback for when the emote timer expires
func _on_emote_timer_timeout() -> void:
	hide_emote()

## Callback for dot sequence animation
func _on_dot_sequence_timer_timeout() -> void:
	if current_emote == EmoteType.DOT_1:
		show_emote(EmoteType.DOT_2)
	elif current_emote == EmoteType.DOT_2:
		show_emote(EmoteType.DOT_3)
	elif current_emote == EmoteType.DOT_3:
		show_emote(EmoteType.DOT_1)
	else:
		# If we're not in the dot sequence, stop the timer
		dot_sequence_timer.stop()

## Sets the duration for which emotes are displayed
## @param duration The time in seconds to display emotes
func set_emote_duration(duration: float) -> void:
	emote_duration = max(0.1, duration)  # Ensure minimum duration
	emote_timer.wait_time = emote_duration
