extends Node

# Audio resources for alerts
var positive_alert_sound = preload("res://assets/audio/ui_feedback/accept_green_alert.wav")
var perfect_stamp_alert_sound = preload(
	"res://assets/audio/ui_feedback/Task Complete Ensemble 002.wav"
)
var negative_alert_sound = preload("res://assets/audio/ui_feedback/decline_red_alert.wav")

# Perfect hit celebration sound (using the missile perfect hit sound)
var perfect_hit_celebration_sound = preload("res://assets/audio/gameplay/missile_perfect_hit.mp3")

# Screen shake settings
var screen_shake_intensity_multiplier: float = 1.0  # Gets set from options menu

# Perfect hit celebration settings
const CELEBRATION_FLASH_DURATION: float = 0.15
const CELEBRATION_SLOWMO_DURATION: float = 0.25
const CELEBRATION_SLOWMO_SCALE: float = 0.5
const CELEBRATION_ZOOM_AMOUNT: float = 1.03
const CELEBRATION_PARTICLE_COUNT: int = 12

# Celebration overlay components
var _celebration_layer: CanvasLayer = null
var _flash_rect: ColorRect = null
var _particle_container: Node2D = null

# Signal for alert events
signal alert_displayed(alert_type: String, message: String)
signal alert_cleared
signal celebration_started(celebration_type: String)
signal celebration_ended()


# Initialize the UI manager
func _ready():
	# Load screen shake setting from config
	update_camera_shake_setting()
	_setup_celebration_overlay()
	_connect_celebration_signals()


func _setup_celebration_overlay() -> void:
	# Create canvas layer for celebration effects
	_celebration_layer = CanvasLayer.new()
	_celebration_layer.name = "CelebrationLayer"
	_celebration_layer.layer = 95  # Above most UI but below dialogue

	# Create flash rect
	_flash_rect = ColorRect.new()
	_flash_rect.name = "FlashRect"
	_flash_rect.color = Color(1.0, 1.0, 0.9, 0.0)  # Warm white, transparent
	_flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_celebration_layer.add_child(_flash_rect)

	# Create particle container (centered in viewport)
	_particle_container = Node2D.new()
	_particle_container.name = "ParticleContainer"
	_celebration_layer.add_child(_particle_container)

	add_child(_celebration_layer)
	_celebration_layer.visible = false


func _connect_celebration_signals() -> void:
	if EventBus:
		EventBus.perfect_celebration_requested.connect(_on_perfect_celebration_requested)
		EventBus.perfect_hit_achieved.connect(_on_perfect_hit_achieved)


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
		randf_range(-intensity, intensity), randf_range(-intensity, intensity)
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


# ============================================================================
# PERFECT HIT CELEBRATION SYSTEM
# ============================================================================

## Trigger signature perfect hit celebration
## @param position: World position for particle effects
## @param celebration_type: "stamp" or "runner" for different effects
func trigger_perfect_celebration(position: Vector2 = Vector2.ZERO, celebration_type: String = "stamp") -> void:
	celebration_started.emit(celebration_type)

	# Show celebration layer
	_celebration_layer.visible = true

	# Position particles at event location (or center if not specified)
	if position == Vector2.ZERO:
		position = Vector2(640, 360)  # Center of 1280x720
	_particle_container.position = position

	# Run all celebration effects
	_play_celebration_sound(celebration_type)
	_trigger_screen_flash()
	_trigger_slowmo_effect()
	_trigger_zoom_punch()
	_spawn_celebration_particles(position, celebration_type)
	_trigger_celebration_haptic(celebration_type)

	# Schedule celebration end
	await get_tree().create_timer(0.5).timeout
	_celebration_layer.visible = false
	celebration_ended.emit()


func _play_celebration_sound(celebration_type: String) -> void:
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = perfect_hit_celebration_sound
	audio_player.volume_db = -3.0
	audio_player.bus = "SFX"
	audio_player.pitch_scale = 1.0 if celebration_type == "runner" else 1.1
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(audio_player.queue_free)


func _trigger_screen_flash() -> void:
	if not _flash_rect:
		return

	# Quick bright flash
	var tween = create_tween()
	tween.tween_property(_flash_rect, "color:a", 0.25, 0.05)
	tween.tween_property(_flash_rect, "color:a", 0.0, CELEBRATION_FLASH_DURATION)


func _trigger_slowmo_effect() -> void:
	# Brief slowmo for impact
	Engine.time_scale = CELEBRATION_SLOWMO_SCALE

	var tween = create_tween()
	tween.set_ignore_time_scale(true)  # Tween runs in real time
	tween.tween_property(Engine, "time_scale", 1.0, CELEBRATION_SLOWMO_DURATION)


func _trigger_zoom_punch() -> void:
	var root = get_tree().current_scene
	if not root:
		return

	var original_scale = root.scale

	var tween = create_tween()
	tween.set_ignore_time_scale(true)
	# Zoom in slightly
	tween.tween_property(root, "scale", original_scale * CELEBRATION_ZOOM_AMOUNT, 0.08)
	# Zoom back out with bounce
	tween.tween_property(root, "scale", original_scale, 0.15).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _spawn_celebration_particles(position: Vector2, celebration_type: String) -> void:
	# Determine particle color based on type
	var base_color: Color
	if celebration_type == "runner":
		base_color = Color(1.0, 0.5, 0.2)  # Orange for runner hits
	else:
		base_color = Color(1.0, 0.85, 0.3)  # Gold for perfect stamps

	# Spawn particles in a burst pattern
	for i in range(CELEBRATION_PARTICLE_COUNT):
		var particle: ColorRect = _create_celebration_particle(base_color)
		if particle == null:
			continue
		_particle_container.add_child(particle)

		# Calculate burst direction
		var angle: float = (TAU / CELEBRATION_PARTICLE_COUNT) * i + randf_range(-0.2, 0.2)
		var velocity: Vector2 = Vector2.from_angle(angle) * randf_range(150, 300)
		var target_position: Vector2 = particle.position + velocity

		# Animate particle
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.set_ignore_time_scale(true)
		tween.tween_property(particle, "position", target_position, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 0.4)
		tween.tween_property(particle, "scale", Vector2(0.3, 0.3), 0.4)

		# Cleanup
		tween.chain().tween_callback(particle.queue_free)


func _create_celebration_particle(base_color: Color) -> ColorRect:
	# Create a simple colored rect as particle
	var particle: ColorRect = ColorRect.new()
	particle.size = Vector2(8, 8)
	particle.position = -particle.size / 2  # Center the particle
	particle.color = base_color.lightened(randf_range(-0.1, 0.2))
	particle.rotation = randf() * TAU
	return particle


func _trigger_celebration_haptic(celebration_type: String) -> void:
	# Strong double-pulse haptic feedback
	if EventBus:
		var intensity = 1.0 if celebration_type == "runner" else 0.8
		EventBus.haptic_feedback_requested.emit(intensity, 0.15)


# ============================================================================
# CELEBRATION EVENT HANDLERS
# ============================================================================

func _on_perfect_celebration_requested(position: Vector2, celebration_type: String) -> void:
	trigger_perfect_celebration(position, celebration_type)


func _on_perfect_hit_achieved(_bonus_points: int) -> void:
	# Auto-trigger celebration for perfect runner hits
	# Position defaults to center since we don't know the exact hit location
	trigger_perfect_celebration(Vector2.ZERO, "runner")
