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

## Sets up hover effects for a button with a floating animation.
##
## Creates a subtle floating animation with sound effects when hovering over a button.
## The button will gently float up and down while hovered, then return to normal when exited.
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
		
		# Floating animation settings
		"float_height": 3.0,         # How high the button floats in pixels
		"float_duration": 1.2,       # Complete cycle duration in seconds
		"float_ease": Tween.EASE_IN_OUT,
		"float_trans": Tween.TRANS_SINE
	}
	
	# Merge provided config with defaults
	for key in config:
		hover_defaults[key] = config[key]
	
	# Store the original position on the button as metadata
	button.set_meta("original_position", button.position)
	
	# Set up the hover effect
	button.mouse_entered.connect(func():
		# Ensure the button scales from its center
		button.pivot_offset = button.size / 2
		
		# Create hover scale animation
		var scale_tween = create_tween()
		scale_tween.tween_property(
			button, 
			"scale", 
			hover_defaults.hover_scale, 
			hover_defaults.hover_time
		).set_ease(hover_defaults.hover_ease).set_trans(hover_defaults.hover_trans)
		
		# Set a flag to indicate we're hovering
		button.set_meta("is_hovering", true)
		
		# Create and store a single-use floating tween
		var float_tween = create_tween()
		button.set_meta("float_tween", float_tween)
		
		# Play hover sound
		var sound_player := AudioStreamPlayer.new()
		button.add_child(sound_player)
		sound_player.stream = load(hover_defaults.hover_sfx_path)
		sound_player.volume_db = hover_defaults.volume_db
		sound_player.bus = hover_defaults.audio_bus
		sound_player.finished.connect(func(): sound_player.queue_free())
		sound_player.play()
		
		# Start a process function on the button if it doesn't exist
		if not button.has_node("FloatController"):
			var timer = Timer.new()
			timer.name = "FloatController"
			timer.wait_time = 0.016  # ~60fps
			timer.autostart = true
			button.add_child(timer)
			
			# Direction -1 = going up, 1 = going down
			button.set_meta("float_direction", -1)
			button.set_meta("float_progress", 0.0)
			
			# Connect timer to a custom function to handle the floating
			timer.timeout.connect(func():
				# Only animate if still hovering
				if not button.get_meta("is_hovering"):
					timer.queue_free()
					return
				
				var original_pos = button.get_meta("original_position")
				var direction = button.get_meta("float_direction")
				var progress = button.get_meta("float_progress")
				
				# Update progress
				progress += 0.016 / (hover_defaults.float_duration / 2)
				button.set_meta("float_progress", progress)
				
				# Calculate new position using sine wave
				var t = min(progress, 1.0)
				var factor = sin(t * PI/2) # Smooth easing
				var offset = hover_defaults.float_height * factor * direction * -1
				
				# Apply the new position
				button.position.y = original_pos.y + offset
				
				# Check if we need to change direction
				if progress >= 1.0:
					button.set_meta("float_direction", direction * -1)
					button.set_meta("float_progress", 0.0)
			)
	)
	
	# Set up the exit effect
	button.mouse_exited.connect(func():
		# Mark that we're no longer hovering
		button.set_meta("is_hovering", false)
		
		# Get original position
		var original_position = button.get_meta("original_position")
		
		# Tween back to original position
		var position_tween = create_tween()
		position_tween.tween_property(
			button,
			"position:y", 
			original_position.y,
			hover_defaults.hover_time
		).set_ease(hover_defaults.hover_ease)
		
		# Revert to normal scale
		var scale_tween = create_tween()
		scale_tween.tween_property(
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
