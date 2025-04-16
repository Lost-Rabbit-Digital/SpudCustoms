extends Node
## Utility class for creating juicy button effects.
##
## This autoload singleton provides utilities for creating satisfying,
## responsive button animations with sound effects.

## Default configuration parameters for button animations.
##
## These values can be overridden on a per-call basis by passing
## a custom configuration dictionary to setup_button().
const DEFAULT_CONFIG = {
	# Scale values
	"initial_scale": Vector2(0.8, 0.8),  # Initial press-down scale
	"bounce_scale": Vector2(1.1, 1.1),  # Bounce-back scale
	"final_scale": Vector2(1.0, 1.0),  # Final resting scale
	# Color values
	"initial_color": Color(0.7, 0.7, 0.7, 1.0),  # Darkened color during press
	"final_color": Color(1.0, 1.0, 1.0, 1.0),  # Normal color
	# Timing values (in seconds)
	"initial_time": 0.05,  # Duration of press-down animation
	"bounce_time": 0.1,  # Duration of bounce-back animation
	"final_time": 0.1,  # Duration of settling animation
	# Audio settings
	"click_sfx_path": "res://assets/user_interface/audio/click_sound_4.mp3",
	"volume_db": -6.0,  # Volume in decibels
	"audio_bus": "SFX",
	# Easing functions
	"initial_ease": Tween.EASE_OUT,
	"bounce_ease": Tween.EASE_OUT,
	"final_ease": Tween.EASE_IN_OUT,
	# Transition types
	"initial_trans": Tween.TRANS_QUAD,
	"bounce_trans": Tween.TRANS_BACK,
	"final_trans": Tween.TRANS_QUAD
}


## Creates an interactive "juicy" button animation with sound effects.
##
## @param button The button to animate - can be any Control-derived node.
## @param url Optional URL to open when animation completes.
## @param config Optional dictionary with animation parameters to override defaults.
## @return Signal from the tween that can be awaited to detect completion.
func setup_button(button: Control, url: String = "", config: Dictionary = {}) -> Signal:
	# Merge the provided config with the defaults
	var settings = DEFAULT_CONFIG.duplicate()
	for key in config:
		settings[key] = config[key]

	# Ensure the button scales from its center
	button.pivot_offset = button.size / 2

	# Play button click sound
	var button_down_player := AudioStreamPlayer.new()
	button.add_child(button_down_player)
	button_down_player.stream = load(settings.click_sfx_path)
	button_down_player.volume_db = settings.volume_db
	button_down_player.bus = settings.audio_bus
	button_down_player.finished.connect(_free_audio_player.bind(button_down_player))
	button_down_player.play()

	# Create press animation tween with all phases running in sequence
	var tween = create_tween().set_parallel()

	# Phase 1: Initial shrink/darken animation
	(
		tween
		. tween_property(button, "scale", settings.initial_scale, settings.initial_time)
		. set_ease(settings.initial_ease)
		. set_trans(settings.initial_trans)
	)

	(
		tween
		. tween_property(button, "modulate", settings.initial_color, settings.initial_time)
		. set_ease(settings.initial_ease)
		. set_trans(settings.initial_trans)
	)

	# Phase 2: Bounce animation
	var bounce_tween = tween.chain()
	(
		bounce_tween
		. tween_property(button, "scale", settings.bounce_scale, settings.bounce_time)
		. set_ease(settings.bounce_ease)
		. set_trans(settings.bounce_trans)
	)

	# Phase 3: Final settling animation
	var final_tween = bounce_tween.chain()

	# Scale back to normal
	(
		final_tween
		. tween_property(button, "scale", settings.final_scale, settings.final_time)
		. set_ease(settings.final_ease)
		. set_trans(settings.final_trans)
	)

	# Color back to normal
	(
		final_tween
		. tween_property(button, "modulate", settings.final_color, settings.final_time)
		. set_ease(settings.final_ease)
		. set_trans(settings.final_trans)
	)

	# Open URL if provided
	if url.strip_edges() != "":
		tween.finished.connect(_open_url.bind(url))

	# Return the tween's finished signal for awaiting
	return tween.finished


## Helper method to free audio players after completion
func _free_audio_player(player: AudioStreamPlayer) -> void:
	player.queue_free()


## Helper method to open URL after tween completion
func _open_url(url: String) -> void:
	OS.shell_open(url)


## Sets up hover effects for a button with a smooth bouncy floating animation.
##
## Creates a subtle bouncy floating animation with sound effects when hovering over a button.
## The button will gently float with a spring-like motion while hovered, then smoothly return
## to its original position when exited.
##
## @param button The button to set up hover effects for.
## @param config Optional dictionary with hover effect parameters.
func setup_hover(button: Control, config: Dictionary = {}) -> void:
	# Default hover settings
	var hover_defaults = {
		"hover_scale": Vector2(1.05, 1.05),
		"hover_time": 0.1,
		"hover_ease": Tween.EASE_OUT,
		"hover_trans": Tween.TRANS_QUAD,
		"hover_sfx_path": "res://assets/user_interface/audio/hover_sound.mp3",
		"volume_db": -8.0,
		"audio_bus": "SFX",
		# Bouncy floating animation settings
		"float_height": 16.0,  # Maximum float height in pixels
		"float_duration": 1.0,  # Complete cycle duration in seconds
		"bounce_factor": 1.2,  # Higher values = more bounce
		"damping": 0.7  # How quickly bounce settles (0-1, lower = faster settle)
	}

	# Merge provided config with defaults
	for key in config:
		hover_defaults[key] = config[key]

	# Store the original position on the button as metadata
	button.set_meta("original_position", button.position)


## Handle mouse enter animation and floating effect
func _on_button_mouse_entered(button: Control, hover_defaults: Dictionary) -> void:
	# Ensure the button scales from its center
	button.pivot_offset = button.size / 2

	# Create hover scale animation
	var scale_tween = create_tween()
	(
		scale_tween
		. tween_property(button, "scale", hover_defaults.hover_scale, hover_defaults.hover_time)
		. set_ease(hover_defaults.hover_ease)
		. set_trans(hover_defaults.hover_trans)
	)

	# Set a flag to indicate we're hovering
	button.set_meta("is_hovering", true)

	# Play hover sound
	var sound_player := AudioStreamPlayer.new()
	button.add_child(sound_player)
	sound_player.stream = load(hover_defaults.hover_sfx_path)
	sound_player.volume_db = hover_defaults.volume_db
	sound_player.bus = hover_defaults.audio_bus
	sound_player.finished.connect(_free_audio_player.bind(sound_player))
	sound_player.play()

	# Start a process function on the button if it doesn't exist
	if not button.has_node("FloatController"):
		var timer = Timer.new()
		timer.set_name("FloatController")
		timer.wait_time = 0.016  # ~60fps
		timer.autostart = true
		button.add_child(timer)

		# Initialize spring physics variables
		button.set_meta("velocity", 0.0)
		button.set_meta(
			"target_y", button.get_meta("original_position").y - hover_defaults.float_height
		)
		button.set_meta("time_counter", 0.0)

		# Connect timer to the float animation handler
		timer.timeout.connect(_on_float_timer_timeout.bind(button, hover_defaults))


## Handle the floating animation update on each timer tick
func _on_float_timer_timeout(button: Control, hover_defaults: Dictionary) -> void:
	# Only animate if still hovering
	if not button.get_meta("is_hovering"):
		button.get_node("FloatController").queue_free()
		return

	var original_pos = button.get_meta("original_position")
	var current_pos = button.position
	var target_y = button.get_meta("target_y")
	var velocity = button.get_meta("velocity")
	var time_counter = button.get_meta("time_counter")

	# Update time counter
	time_counter += 0.016
	button.set_meta("time_counter", time_counter)

	# Create a smooth oscillation for the target position
	var oscillation = sin(time_counter * (2 * PI / hover_defaults.float_duration))
	var new_target = original_pos.y - (hover_defaults.float_height * oscillation)
	button.set_meta("target_y", new_target)

	# Spring physics for bouncy motion with overshoot
	var distance = new_target - current_pos.y
	# Add a very subtle jitter for liveliness (0.02 to 0.05 pixel)
	var jitter = (randf() - 0.5) * 0.05
	var spring_force = distance * hover_defaults.bounce_factor + jitter

	# Update velocity with spring force and apply adaptive damping
	# Stronger damping when moving away from target, lighter when returning
	var direction_factor: float = 1.0
	if sign(distance * velocity) >= 0:
		direction_factor = 1.0
	else:
		direction_factor = 0.7

	velocity += spring_force * 0.016
	velocity *= hover_defaults.damping * direction_factor

	# Add slight acceleration for more energetic bounce
	if abs(velocity) < 0.1 and abs(distance) > 1.0:
		velocity += sign(distance) * 0.05

	# Update position based on velocity with subtle easing
	current_pos.y += velocity * (1.0 - exp(-abs(velocity) * 0.5))
	button.position = current_pos

	# Store updated velocity
	button.set_meta("velocity", velocity)

	button.grab_focus()


## Handle mouse exit animation
func _on_button_mouse_exited(button: Control) -> void:
	# Mark that we're no longer hovering
	button.set_meta("is_hovering", false)

	# Get original position
	var original_position = button.get_meta("original_position")

	# Tween back to original position with a slight bounce
	var position_tween = create_tween()
	(
		position_tween
		. tween_property(button, "position:y", original_position.y, 0.3)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_BACK)
	)

	# Revert to normal scale with a slight bounce
	var scale_tween = create_tween()
	(
		scale_tween
		. tween_property(button, "scale", Vector2(1.0, 1.0), 0.3)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_BACK)
	)


## Setup juicy effects for all buttons in a container.
##
## Automatically applies hover and click effects to all buttons found
## within the specified container and its children.
##
## @param container The node containing buttons to enhance.
## @param hover_config Optional configuration for hover effects.
## @param click_config Optional configuration for click effects.
func enhance_all_buttons(
	container: Node, hover_config: Dictionary = {}, click_config: Dictionary = {}
) -> void:
	# Process all children
	for child in container.get_children():
		# If it's a button, enhance it
		if child is BaseButton:
			# Add hover effects
			setup_hover(child, hover_config)

		# Recursively process children of this node
		if child.get_child_count() > 0:
			enhance_all_buttons(child, hover_config, click_config)


## Handle button press animation
func _on_button_pressed(button: Control, click_config: Dictionary) -> void:
	setup_button(button, "", click_config)


## Forces all juicy button animations to complete.
##
## Useful for scene transitions to ensure no animations are left running.
func kill_all_tweens(node: Node) -> void:
	# Kill tweens on this node
	var tweens = node.get_incoming_connections()
	for connection in tweens:
		# Check if the connection has a 'source' property and if it's a Tween
		if connection is Dictionary and connection.has("source") and connection.source is Tween:
			connection.source.kill()
		# Alternative approach for connections that are objects
		elif connection.get("source") is Tween:
			connection.source.kill()

	# Process all children recursively
	for child in node.get_children():
		kill_all_tweens(child)
