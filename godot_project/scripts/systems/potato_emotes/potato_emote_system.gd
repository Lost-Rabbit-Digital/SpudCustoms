class_name PotatoEmoteSystem
extends AnimatedSprite2D
## A fully autonomous emote system for potato characters.
##
## Simply add this as a child of your PotatoEmote node and it will
## automatically work with the settings you configure in the Inspector.

## Types of emotes available
enum EmoteType {
	ANGRY_FACE,
	HAPPY_FACE,
	SAD_FACE,
	#BLANK,
	#DOT_1,
	#DOT_2,
	#DOT_3,
	SINGULAR_HEART,
	BROKEN_HEART,
	SWIRLING_HEARTS,
	POPPING_VEIN,
	QUESTION,
	DOUBLE_EXCLAMATION,
	SINGULAR_EXCLAMATION,
	CONFUSED
}

## Configuration options (exposed to the Inspector)
@export_category("Initital Emote")
@export_range(1.0, 30.0) var minimum_initial_emote_delay: float = 5.0
@export_range(1.0, 30.0) var maximum_initial_emote_delay: float = 25.0
@export_category("General Emotes")
## Whether the emotes will be displayed at all
@export var emoting_enabled: bool = false
## [Seconds] How long the emote will remained displayed
@export_range(0.1, 10.0) var emote_duration: float = 3.0
## [Seconds] Minimum amount of time before the next emote is displayed
@export_range(1.0, 30.0) var minimum_emote_delay: float = 10.0
## [Seconds] Maximum amount of time before the next emote is dispalyed
@export_range(1.0, 30.0) var maximum_emote_delay: float = 25.0
@export_category("Audio")
## Whether to play audio when displaying an emote
@export var play_sounds: bool = false  # Keep this shit off, it's so annoying
## [Decibels] How loud the audio for each emote is
@export_range(-100.0, 100.0) var emote_volume: float = -24.0

# TODO: The blank and dots have been commented out until the show_thinking_dots() function is
# properly implemented, these emotes are also removed from the "thinking" emote category
## Maps emote types to frame indices
var emote_frames = {
	EmoteType.ANGRY_FACE: 0,
	EmoteType.HAPPY_FACE: 1,
	EmoteType.SAD_FACE: 2,
	#EmoteType.BLANK: 3,
	#EmoteType.DOT_1: 4,
	#EmoteType.DOT_2: 5,
	#EmoteType.DOT_3: 6,
	EmoteType.SINGULAR_HEART: 7,
	EmoteType.BROKEN_HEART: 8,
	EmoteType.SWIRLING_HEARTS: 9,
	EmoteType.POPPING_VEIN: 10,
	EmoteType.QUESTION: 11,
	EmoteType.DOUBLE_EXCLAMATION: 12,
	EmoteType.SINGULAR_EXCLAMATION: 13,
	EmoteType.CONFUSED: 14
}

# TODO: Setup "thinking" category to have blank and dot emotes
## Emote categories
var emote_categories = {
	"positive": [EmoteType.HAPPY_FACE, EmoteType.SINGULAR_HEART, EmoteType.SWIRLING_HEARTS],
	"negative":
	[EmoteType.ANGRY_FACE, EmoteType.SAD_FACE, EmoteType.BROKEN_HEART, EmoteType.POPPING_VEIN],
	"thinking": [EmoteType.QUESTION, EmoteType.CONFUSED],
	"surprise": [EmoteType.DOUBLE_EXCLAMATION, EmoteType.SINGULAR_EXCLAMATION],
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
	if (
		emoting_enabled
		and emote_delay_timer.is_stopped()
		and (not emote_sprite or not emote_sprite.visible)
	):
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

	# Get the parent to check brain state
	var potato_person = get_parent()
	if potato_person and potato_person is PotatoPerson:
		# Try to determine which brain state this emote represents
		var matched_state = potato_person.PotatoBrainState.THINKING  # Default

		# Match the emote to a brain state if possible
		for category in emote_categories.keys():
			if random_emote in emote_categories[category]:
				if category == "positive":
					matched_state = potato_person.PotatoBrainState.HAPPY
				elif category == "negative":
					matched_state = potato_person.PotatoBrainState.SAD
				elif category == "thinking":
					matched_state = potato_person.PotatoBrainState.THINKING
				elif category == "surprise":
					matched_state = potato_person.PotatoBrainState.SURPRISED

				# Trigger wiggle with the determined state
				wiggle_animation(matched_state)
				break

	# Show the emote
	_show_emote(random_emote)


## Shows a random emote from a specific category
func show_random_emote_from_category(category: String) -> void:
	if not emote_sprite or not emote_categories.has(category):
		return

	# Get the parent to check brain state
	var potato_person = get_parent()
	if potato_person and potato_person is PotatoPerson:
		# Trigger wiggle if we're not in idle state
		if potato_person.current_potato_brain_state != potato_person.PotatoBrainState.IDLE:
			wiggle_animation(potato_person.current_potato_brain_state)

	# Get a random emote from this category
	var category_emotes = emote_categories[category]
	var random_emote = category_emotes[randi() % category_emotes.size()]

	# Show it
	_show_emote(random_emote)


## Internal function to display an emote
func _show_emote(emote_type: int) -> void:
	if not emote_sprite or not emote_frames.has(emote_type):
		return

	# Get the parent to check brain state
	var potato_person = get_parent()
	if potato_person and potato_person is PotatoPerson:
		# Trigger wiggle if we're not in idle state
		if potato_person.current_potato_brain_state != potato_person.PotatoBrainState.IDLE:
			wiggle_animation(potato_person.current_potato_brain_state)

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
		# Instead of directly calling show_random_emote, let's first
		# notify the PotatoPerson to trigger a brain state change
		var potato_person = get_parent()
		if potato_person and potato_person is PotatoPerson:
			# Pick a random brain state for idle emoting
			var possible_states = [
				potato_person.PotatoBrainState.HAPPY,
				potato_person.PotatoBrainState.THINKING,
				potato_person.PotatoBrainState.SURPRISED
			]
			# Don't pick IDLE or SAD/ANGRY as often for idle animations
			if randf() < 0.1:  # 10% chance to include negative emotions
				possible_states.append(potato_person.PotatoBrainState.SAD)
				possible_states.append(potato_person.PotatoBrainState.ANGRY)

			# Choose random state and trigger it
			var random_state = possible_states[randi() % possible_states.size()]
			potato_person.change_brain_state(random_state)
		else:
			# Fallback to direct emote if not attached to PotatoPerson
			show_random_emote()


## Clean up when removed from the scene
func _exit_tree() -> void:
	# Ensure timers are stopped to prevent errors
	if emote_timer and not emote_timer.is_stopped():
		emote_timer.stop()

	if emote_delay_timer and not emote_delay_timer.is_stopped():
		emote_delay_timer.stop()


## Shows the thinking dots animation
func _show_thinking() -> void:
	_show_emote(PotatoEmoteSystem.EmoteType.QUESTION)

	# TODO: Fix up the dots so that they actually animate
	# Choose between dots or question mark
	#if randf() < 0.3:  # 30% chance for dots
	#	show_thinking_dots()
	#else:
	#	_show_emote(PotatoEmoteSystem.EmoteType.QUESTION)


#func show_thinking_dots() -> void:
#pass


## Creates a fun wiggle animation to accompany emotes
##
## Generates random wiggles with rotation and scale variations
## that match the provided brain state.
## @param brain_state The current PotatoBrainState to adapt animation to
func wiggle_animation(brain_state: int) -> void:
	# Get the parent (PotatoPerson) that contains this emote system
	var potato_person = get_parent()
	if not potato_person or not potato_person is PotatoPerson:
		push_warning("WiggleAnimation: Not attached to a PotatoPerson")
		return

	# Basic error check - make sure we have a valid sprite to animate
	var sprite_node = potato_person.get_node_or_null("%PotatoSprite")
	if not is_instance_valid(sprite_node):
		push_warning("WiggleAnimation: Cannot wiggle, PotatoSprite not found or invalid")
		return

	# Stop any existing wiggle tween
	var existing_tweens: Array = []
	if potato_person.has_meta("potato_wiggle_tweens"):
		existing_tweens = potato_person.get_meta("potato_wiggle_tweens")

	for tween in existing_tweens:
		if is_instance_valid(tween) and tween.is_valid():
			tween.kill()

	# Clear the array
	existing_tweens.clear()

	# Create our new tween
	var tween = create_tween()
	tween.set_parallel(true)

	# Store the tween reference in potato's metadata
	existing_tweens.append(tween)
	potato_person.set_meta("potato_wiggle_tweens", existing_tweens)

	# Determine wiggle parameters based on brain state
	var rotation_intensity: float = 0.1  # Default rotation amplitude
	var scale_bounce: float = 0.05  # Default scale bounce
	var duration_multiplier: float = 1.0  # Default speed

	# Adjust parameters based on brain state
	if brain_state == potato_person.PotatoBrainState.ANGRY:
		rotation_intensity = 0.2
		scale_bounce = 0.08
		duration_multiplier = 0.7  # Faster for angry
	elif brain_state == potato_person.PotatoBrainState.HAPPY:
		rotation_intensity = 0.15
		scale_bounce = 0.1
		duration_multiplier = 0.9
	elif brain_state == potato_person.PotatoBrainState.SURPRISED:
		rotation_intensity = 0.25
		scale_bounce = 0.15
		duration_multiplier = 0.6  # Faster for surprised
	elif brain_state == potato_person.PotatoBrainState.SAD:
		rotation_intensity = 0.05
		scale_bounce = 0.03
		duration_multiplier = 1.3  # Slower for sad

	# Get random directions for wiggle
	var direction: int = 1 if randf() > 0.5 else -1
	var wiggle_count: int = randi_range(2, 4)  # Random number of wiggles
	var base_duration: float = 0.15 * duration_multiplier

	# Generate random rotation patterns
	var rot_sequence: Array = []
	for i in range(wiggle_count):
		var rot_value: float = direction * rotation_intensity * (1.0 - float(i) / wiggle_count)
		rot_sequence.append(rot_value)
		direction *= -1  # Alternate direction

	# Add final return to original rotation
	rot_sequence.append(0.0)

	# Create the rotation sequence tween
	var original_scale: Vector2 = sprite_node.scale
	var original_rotation: float = sprite_node.rotation

	# First phase: initial rotation and scale up
	(
		tween
		. tween_property(
			sprite_node, "rotation", original_rotation + rot_sequence[0], base_duration
		)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)

	(
		tween
		. tween_property(sprite_node, "scale", original_scale * (1.0 + scale_bounce), base_duration)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)

	# Second phase: chain the remaining rotations and scale bounce
	for i in range(1, rot_sequence.size()):
		var sequence_tween = create_tween()
		sequence_tween.set_parallel(true)

		# Store this tween too
		existing_tweens.append(sequence_tween)
		potato_person.set_meta("potato_wiggle_tweens", existing_tweens)

		# Timing gets progressively slower for more natural motion
		var phase_duration: float = base_duration * (1.0 + float(i) * 0.2)

		# Rotation tween
		(
			sequence_tween
			. tween_property(
				sprite_node, "rotation", original_rotation + rot_sequence[i], phase_duration
			)
			. set_trans(Tween.TRANS_SINE)
			. set_delay(base_duration * i)
		)

		# Scale variation if it's not the final one
		if i < rot_sequence.size() - 1:
			var scale_value: Vector2 = (
				original_scale * (1.0 + scale_bounce * (1.0 - float(i) / rot_sequence.size()))
			)
			(
				sequence_tween
				. tween_property(sprite_node, "scale", scale_value, phase_duration)
				. set_trans(Tween.TRANS_SINE)
				. set_delay(base_duration * i)
			)
		else:
			# Return to original scale in final step
			(
				sequence_tween
				. tween_property(sprite_node, "scale", original_scale, phase_duration)
				. set_trans(Tween.TRANS_BACK)
				. set_ease(Tween.EASE_OUT)
				. set_delay(base_duration * i)
			)
