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
	"initial_scale": Vector2(0.8, 0.8),    # Initial press-down scale
	"bounce_scale": Vector2(1.1, 1.1),     # Bounce-back scale
	"final_scale": Vector2(1.0, 1.0),      # Final resting scale
	
	# Color values
	"initial_color": Color(0.7, 0.7, 0.7, 1.0),  # Darkened color during press
	"final_color": Color(1.0, 1.0, 1.0, 1.0),    # Normal color
	
	# Timing values (in seconds)
	"initial_time": 0.05,   # Duration of press-down animation
	"bounce_time": 0.1,     # Duration of bounce-back animation
	"final_time": 0.1,      # Duration of settling animation
	
	# Audio settings
	"click_sfx_path": "res://assets/user_interface/audio/click_sound_4.mp3",
	"volume_db": -6.0,      # Volume in decibels
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
	button_down_player.finished.connect(func(): button_down_player.queue_free())
	button_down_player.play()
	
	# Create press animation tween with all phases running in sequence
	var tween = create_tween().set_parallel()
	
	# Phase 1: Initial shrink/darken animation
	tween.tween_property(
		button, 
		"scale", 
		settings.initial_scale, 
		settings.initial_time
	).set_ease(settings.initial_ease).set_trans(settings.initial_trans)
	
	tween.tween_property(
		button, 
		"modulate", 
		settings.initial_color, 
		settings.initial_time
	).set_ease(settings.initial_ease).set_trans(settings.initial_trans)
	
	# Phase 2: Bounce animation
	var bounce_tween = tween.chain()
	bounce_tween.tween_property(
		button, 
		"scale", 
		settings.bounce_scale, 
		settings.bounce_time
	).set_ease(settings.bounce_ease).set_trans(settings.bounce_trans)
	
	# Phase 3: Final settling animation
	var final_tween = bounce_tween.chain()
	
	# Scale back to normal
	final_tween.tween_property(
		button, 
		"scale", 
		settings.final_scale, 
		settings.final_time
	).set_ease(settings.final_ease).set_trans(settings.final_trans)
	
	# Color back to normal
	final_tween.tween_property(
		button, 
		"modulate", 
		settings.final_color, 
		settings.final_time
	).set_ease(settings.final_ease).set_trans(settings.final_trans)
	
	# Open URL if provided
	if url.strip_edges() != "":
		tween.finished.connect(func(): 
			OS.shell_open(url)
		)
	
	# Return the tween's finished signal for awaiting
	return tween.finished

## Sets up hover effects for a button.
##
## Creates subtle scale and sound effects when hovering over a button.
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
		"audio_bus": "SFX"
	}
	
	# Merge provided config with defaults
	for key in config:
		hover_defaults[key] = config[key]
	
	# Set up the hover effect
	button.mouse_entered.connect(func():
		# Ensure the button scales from its center
		button.pivot_offset = button.size / 2
		
		# Create hover animation
		var tween = create_tween()
		tween.tween_property(
			button, 
			"scale", 
			hover_defaults.hover_scale, 
			hover_defaults.hover_time
		).set_ease(hover_defaults.hover_ease).set_trans(hover_defaults.hover_trans)
		
		# Play hover sound
		var sound_player := AudioStreamPlayer.new()
		button.add_child(sound_player)
		sound_player.stream = load(hover_defaults.hover_sfx_path)
		sound_player.volume_db = hover_defaults.volume_db
		sound_player.bus = hover_defaults.audio_bus
		sound_player.finished.connect(func(): sound_player.queue_free())
		sound_player.play()
	)
	
	# Set up the exit effect
	button.mouse_exited.connect(func():
		# Revert to normal scale
		var tween = create_tween()
		tween.tween_property(
			button, 
			"scale", 
			Vector2(1.0, 1.0), 
			hover_defaults.hover_time
		).set_ease(hover_defaults.hover_ease)
	)

## Setup juicy effects for all buttons in a container.
##
## Automatically applies hover and click effects to all buttons found
## within the specified container and its children.
##
## @param container The node containing buttons to enhance.
## @param hover_config Optional configuration for hover effects.
## @param click_config Optional configuration for click effects.
func enhance_all_buttons(container: Node, hover_config: Dictionary = {}, click_config: Dictionary = {}) -> void:
	# Process all children
	for child in container.get_children():
		# If it's a button, enhance it
		if child is BaseButton:
			# Add hover effects
			setup_hover(child, hover_config)
			
			# Add click effects by connecting to pressed signal
			child.pressed.connect(func():
				setup_button(child, "", click_config)
			)
		
		# Recursively process children of this node
		if child.get_child_count() > 0:
			enhance_all_buttons(child, hover_config, click_config)

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
