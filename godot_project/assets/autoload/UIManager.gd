extends Node

# Audio resources for alerts
var positive_alert_sound = preload("res://assets/audio/ui_feedback/accept_green_alert.wav")
var perfect_stamp_alert_sound = preload("res://assets/audio/ui_feedback/Task Complete Ensemble 002.wav")
var negative_alert_sound = preload("res://assets/audio/ui_feedback/decline_red_alert.wav")

# Screen shake settings
var screen_shake_intensity_multiplier: float = 1.0  # Gets set from options menu

# Signal for alert events
signal alert_displayed(alert_type: String, message: String)
signal alert_cleared()

# Initialize the UI manager
func _ready():
	# Load screen shake setting from config
	update_camera_shake_setting()

## Load the screen shake setting from config
func update_camera_shake_setting():
	# Get the camera shake value from Config
	var shake_value = Config.get_config("VideoSettings", "CameraShake", 1.0)
	
	# Update the multiplier
	screen_shake_intensity_multiplier = shake_value

## Clear alert after a delay
func clear_alert_after_delay(alert_label: Label, alert_timer: Timer):
	alert_timer.start()
	# Delay is the "wait_time" property on the timer
	await alert_timer.timeout
	# Hide the alert
	alert_label.visible = false
	# Set to placeholder text for debugging
	alert_label.text = "PLACEHOLDER ALERT TEXT"
	# Set to a noticable color for debugging
	alert_label.add_theme_color_override("font_color", Color.BLUE)
	
	# Emit signal
	alert_cleared.emit()

## Display a red alert with negative sound
func display_red_alert(alert_label: Label, alert_timer: Timer, text: String):
	# Load and play the audio file
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = negative_alert_sound
	audio_player.volume_db = -5
	audio_player.bus = "SFX"
	
	# Random pitch variation - slightly higher range for positive alerts
	audio_player.pitch_scale = randf_range(0.9, 1.2)
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(func(): audio_player.queue_free())
	
	# Display the alert
	alert_label.visible = true
	# Update the text
	alert_label.text = text
	# Update z-index
	alert_label.z_index = 120
	# Set desired color
	alert_label.add_theme_color_override("font_color", Color.RED)
	alert_label.add_theme_font_size_override("font_color", 24)
	alert_label.position = alert_label.position.round()
	# Hide the alert after a few seconds
	clear_alert_after_delay(alert_label, alert_timer)
	
	# Emit signal
	alert_displayed.emit("red", text)

# Display a green alert with positive sound
# In UIManager.gd (or wherever your display_green_alert function is defined)

# Display a green alert with positive sound
func display_green_alert(alert_label: Label, alert_timer: Timer, text: String):
	# Load and play the audio file
	var audio_player = AudioStreamPlayer.new()
	if "PERFECT STAMP" in text:
		audio_player.stream = perfect_stamp_alert_sound
	
	else:
		audio_player.stream = positive_alert_sound
	audio_player.volume_db = -5
	audio_player.bus = "SFX"
	
	# Add pitch variation - slightly higher range for positive alerts
	audio_player.pitch_scale = randf_range(0.95, 1.25)
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(func(): audio_player.queue_free())

	# Display the alert
	alert_label.visible = true
	
	# Update the text
	alert_label.text = text
	
	# Update z-index
	alert_label.z_index = 120
	
	# Set desired color with a brighter green for perfect stamp alerts
	if "PERFECT STAMP" in text:
		# Use a more vibrant green with slight glow effect for perfect stamps
		alert_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		
		# Make perfect stamp alerts slightly larger
		alert_label.add_theme_font_size_override("font_size", 28)
	else:
		# Standard green for other positive alerts
		alert_label.add_theme_color_override("font_color", Color.GREEN)
		alert_label.add_theme_font_size_override("font_size", 24)
	
	alert_label.position = alert_label.position.round()
	
	# Add bounce animation for perfect stamp alerts
	if "PERFECT STAMP" in text:
		var tween = create_tween()
		
		# Original position and scale
		var original_pos = alert_label.position
		var original_scale = alert_label.scale
		
		# Scale up animation
		tween.tween_property(alert_label, "scale", original_scale * 1.2, 0.1)
		
		# Bounce back with slight overshoot
		tween.tween_property(alert_label, "scale", original_scale * 0.95, 0.15)
		
		# Return to original scale
		tween.tween_property(alert_label, "scale", original_scale, 0.1)
	
	# Hide the alert after a few seconds
	clear_alert_after_delay(alert_label, alert_timer)
	
	# Emit signal
	alert_displayed.emit("green", text)

# Screen shake with configurable intensity and duration
# Mild: intensity 3-5, duration 0.2
# Medium: intensity 10-15, duration 0.3
# Strong: intensity 20-25, duration 0.4
func shake_screen(intensity: float = 10.0, duration: float = 0.3):
	# Apply screen shake setting from options
	intensity *= screen_shake_intensity_multiplier
	
	# If screen shake is disabled, return early
	if screen_shake_intensity_multiplier <= 0.01:
		return
	
	# Get the current scene root node
	var root = get_tree().current_scene
	if not root:
		return
		
	# Get the actual initial position rather than forcing to zero
	var initial_position = root.position
	
	# Cancel any active tweens related to screen shake
	var active_tweens = get_tree().get_nodes_in_group("ScreenShakeTween")
	for tween_node in active_tweens:
		if tween_node is Tween and tween_node.is_valid():
			tween_node.kill()
	
	# Create a screen shake tween
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Number of shake steps
	var steps = 12
	
	# Store the initial random offset
	var random_shake = Vector2(
		randf_range(-intensity, intensity),
		randf_range(-intensity, intensity)
	)
	
	# Apply the initial shake
	root.position += random_shake
	
	# Shake with diminishing intensity
	for i in range(steps):
		var shake_intensity = intensity * (1.0 - (i / float(steps)))
		random_shake = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		
		# Move relative to the initial position
		tween.tween_property(root, "position", initial_position + random_shake, duration / steps)
	
	# IMPORTANT: Final tween to EXACTLY the initial position
	tween.tween_property(root, "position", initial_position, duration / steps)
	
	# Add a safety callback to force position reset when the tween finishes
	tween.finished.connect(func(): root.position = initial_position)
# Helper function to format score with commas
func format_score(value: int) -> String:
	var formatted = ""
	var str_value = str(value)
	var count = 0
	
	for i in range(str_value.length() - 1, -1, -1):
		if count == 3:
			formatted = "," + formatted
			count = 0
		formatted = str_value[i] + formatted
		count += 1
	
	return formatted
