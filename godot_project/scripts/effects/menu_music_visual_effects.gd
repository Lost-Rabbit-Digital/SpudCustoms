class_name MenuMusicVisualEffects
extends Node
## Music-reactive visual effects for the main menu.
##
## Analyzes audio spectrum in multiple frequency bands and applies
## synchronized visual effects to menu elements like the title, buttons,
## and background.

## The audio bus to analyze (should have AudioEffectSpectrumAnalyzer)
@export var audio_bus: StringName = &"Music"

## Enable/disable all effects
@export var enabled: bool = true

@export_group("Frequency Bands")
## Bass frequency range (Hz) - for strong pulses
@export var bass_min: float = 20.0
@export var bass_max: float = 150.0
## Mid frequency range (Hz) - for subtle movement
@export var mid_min: float = 150.0
@export var mid_max: float = 2000.0
## High frequency range (Hz) - for sparkle effects
@export var high_min: float = 2000.0
@export var high_max: float = 8000.0

@export_group("Beat Detection")
## Threshold multiplier for beat detection (higher = less sensitive)
@export_range(1.0, 3.0) var beat_threshold: float = 1.5
## Minimum time between beats in seconds
@export var beat_cooldown: float = 0.15
## How quickly the average adapts (lower = slower adaptation)
@export_range(0.01, 0.2) var average_decay: float = 0.05

@export_group("Title Effects")
## The title label to animate
@export var title_label: Label
## Base scale for the title
@export var title_base_scale: Vector2 = Vector2(1.0, 1.0)
## Maximum additional scale on bass hits
@export var title_max_pulse: float = 0.03
## Title glow/modulate pulse intensity
@export var title_glow_intensity: float = 0.15
## Smoothing for title animations
@export_range(0.0, 0.99) var title_smoothing: float = 0.85

@export_group("Button Effects")
## Container holding the menu buttons
@export var button_container: Control
## Maximum rotation wiggle in degrees on beats
@export var button_wiggle_angle: float = 1.0
## Scale pulse amount for buttons
@export var button_pulse_amount: float = 0.015
## Smoothing for button animations
@export_range(0.0, 0.99) var button_smoothing: float = 0.9

@export_group("Background Effects")
## The background TextureRect to animate
@export var background: TextureRect
## Maximum scale increase on bass
@export var bg_max_scale: float = 0.01
## Color temperature shift amount (warm on bass)
@export var bg_color_shift: float = 0.03
## Smoothing for background animations
@export_range(0.0, 0.99) var bg_smoothing: float = 0.92

# Audio analysis
var _spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance
var _bus_index: int = -1

# Current frequency band magnitudes (0-1 range)
var _bass_magnitude: float = 0.0
var _mid_magnitude: float = 0.0
var _high_magnitude: float = 0.0

# Smoothed values for visual effects
var _bass_smoothed: float = 0.0
var _mid_smoothed: float = 0.0
var _high_smoothed: float = 0.0

# Beat detection
var _bass_average: float = 0.0
var _beat_cooldown_timer: float = 0.0
var _is_beat: bool = false

# Visual state
var _title_current_scale: Vector2 = Vector2.ONE
var _title_current_glow: float = 0.0
var _bg_current_scale: float = 1.0
var _bg_current_color: Color = Color.WHITE
var _button_current_rotation: float = 0.0
var _button_current_scale: float = 1.0

# Original states for restoration
var _title_original_scale: Vector2
var _title_original_modulate: Color
var _bg_original_scale: Vector2
var _bg_original_modulate: Color
var _buttons: Array[Control] = []
var _button_original_scales: Array[Vector2] = []


func _ready() -> void:
	_setup_spectrum_analyzer()
	_cache_original_states()


func _setup_spectrum_analyzer() -> void:
	_bus_index = AudioServer.get_bus_index(audio_bus)

	if _bus_index == -1:
		push_warning("MenuMusicVisualEffects: Audio bus '%s' not found" % audio_bus)
		return

	# Find the spectrum analyzer effect on the bus
	var effect_count = AudioServer.get_bus_effect_count(_bus_index)
	for i in effect_count:
		var effect = AudioServer.get_bus_effect(_bus_index, i)
		if effect is AudioEffectSpectrumAnalyzer:
			_spectrum_analyzer = AudioServer.get_bus_effect_instance(_bus_index, i)
			break

	if not _spectrum_analyzer:
		push_warning("MenuMusicVisualEffects: No AudioEffectSpectrumAnalyzer found on bus '%s'" % audio_bus)


func _cache_original_states() -> void:
	# Cache title original state
	if title_label:
		title_label.pivot_offset = title_label.size / 2
		_title_original_scale = title_label.scale
		_title_original_modulate = title_label.modulate

	# Cache background original state
	if background:
		background.pivot_offset = background.size / 2
		_bg_original_scale = background.scale
		_bg_original_modulate = background.modulate

	# Cache button states
	if button_container:
		_find_buttons(button_container)
		for button in _buttons:
			button.pivot_offset = button.size / 2
			_button_original_scales.append(button.scale)


func _find_buttons(node: Node) -> void:
	for child in node.get_children():
		if child is BaseButton:
			_buttons.append(child as Control)
		if child.get_child_count() > 0:
			_find_buttons(child)


func _process(delta: float) -> void:
	if not enabled or not _spectrum_analyzer:
		return

	_analyze_spectrum()
	_detect_beats(delta)
	_apply_title_effects(delta)
	_apply_button_effects(delta)
	_apply_background_effects(delta)


func _analyze_spectrum() -> void:
	# Get raw magnitudes for each frequency band
	_bass_magnitude = _get_band_magnitude(bass_min, bass_max)
	_mid_magnitude = _get_band_magnitude(mid_min, mid_max)
	_high_magnitude = _get_band_magnitude(high_min, high_max)

	# Apply smoothing for visual effects
	_bass_smoothed = lerp(_bass_smoothed, _bass_magnitude, 0.3)
	_mid_smoothed = lerp(_mid_smoothed, _mid_magnitude, 0.2)
	_high_smoothed = lerp(_high_smoothed, _high_magnitude, 0.25)


func _get_band_magnitude(min_freq: float, max_freq: float) -> float:
	if not _spectrum_analyzer:
		return 0.0

	var magnitude = _spectrum_analyzer.get_magnitude_for_frequency_range(min_freq, max_freq)
	var avg_magnitude = (magnitude.x + magnitude.y) / 2.0

	# Scale to usable range - audio magnitudes are typically very small
	# Using different scaling for different frequency bands
	var scale_factor = 10.0
	if min_freq > 1000:
		scale_factor = 15.0  # Highs need more amplification
	elif min_freq < 200:
		scale_factor = 8.0   # Bass is usually stronger

	return clampf(avg_magnitude * scale_factor, 0.0, 1.0)


func _detect_beats(delta: float) -> void:
	# Update cooldown timer
	if _beat_cooldown_timer > 0:
		_beat_cooldown_timer -= delta

	# Update running average of bass
	_bass_average = lerp(_bass_average, _bass_magnitude, average_decay)

	# Detect beat: current magnitude significantly above average
	_is_beat = false
	if _beat_cooldown_timer <= 0 and _bass_magnitude > _bass_average * beat_threshold and _bass_magnitude > 0.1:
		_is_beat = true
		_beat_cooldown_timer = beat_cooldown


func _apply_title_effects(_delta: float) -> void:
	if not title_label:
		return

	# Scale pulse based on bass
	var target_scale = title_base_scale + Vector2.ONE * (_bass_smoothed * title_max_pulse)
	_title_current_scale = _title_current_scale.lerp(target_scale, 1.0 - title_smoothing)
	title_label.scale = _title_original_scale * _title_current_scale

	# Glow/brightness pulse based on bass
	var target_glow = 1.0 + (_bass_smoothed * title_glow_intensity)
	_title_current_glow = lerp(_title_current_glow, target_glow, 1.0 - title_smoothing)

	# Apply subtle brightness boost
	var glow_color = Color(
		_title_original_modulate.r * _title_current_glow,
		_title_original_modulate.g * _title_current_glow,
		_title_original_modulate.b * _title_current_glow,
		_title_original_modulate.a
	)
	title_label.modulate = glow_color


func _apply_button_effects(_delta: float) -> void:
	if _buttons.is_empty():
		return

	# Calculate target rotation based on mids (subtle wiggle)
	var wiggle_target = sin(Time.get_ticks_msec() * 0.005) * _mid_smoothed * deg_to_rad(button_wiggle_angle)
	_button_current_rotation = lerp(_button_current_rotation, wiggle_target, 1.0 - button_smoothing)

	# Calculate scale pulse based on bass
	var scale_target = 1.0 + (_bass_smoothed * button_pulse_amount)
	_button_current_scale = lerp(_button_current_scale, scale_target, 1.0 - button_smoothing)

	# Apply to all buttons
	for i in range(_buttons.size()):
		var button = _buttons[i]
		# Skip buttons that are being hovered (JuicyButtons handles those)
		if button.has_meta("is_hovering") and button.get_meta("is_hovering"):
			continue

		button.rotation = _button_current_rotation
		button.scale = _button_original_scales[i] * _button_current_scale


func _apply_background_effects(_delta: float) -> void:
	if not background:
		return

	# Scale breathing based on bass
	var scale_target = 1.0 + (_bass_smoothed * bg_max_scale)
	_bg_current_scale = lerp(_bg_current_scale, scale_target, 1.0 - bg_smoothing)
	background.scale = _bg_original_scale * _bg_current_scale

	# Subtle color temperature shift - warmer on bass hits
	var warmth = _bass_smoothed * bg_color_shift
	var target_color = Color(
		_bg_original_modulate.r + warmth,
		_bg_original_modulate.g,
		_bg_original_modulate.b - warmth * 0.5,
		_bg_original_modulate.a
	)
	_bg_current_color = _bg_current_color.lerp(target_color, 1.0 - bg_smoothing)
	background.modulate = _bg_current_color


## Get the current bass magnitude (0-1)
func get_bass() -> float:
	return _bass_smoothed


## Get the current mid magnitude (0-1)
func get_mids() -> float:
	return _mid_smoothed


## Get the current high magnitude (0-1)
func get_highs() -> float:
	return _high_smoothed


## Returns true on the frame a beat is detected
func is_beat() -> bool:
	return _is_beat


## Enable or disable effects at runtime
func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		_reset_visuals()


func _reset_visuals() -> void:
	if title_label:
		title_label.scale = _title_original_scale
		title_label.modulate = _title_original_modulate

	if background:
		background.scale = _bg_original_scale
		background.modulate = _bg_original_modulate

	for i in range(_buttons.size()):
		var button = _buttons[i]
		button.scale = _button_original_scales[i]
		button.rotation = 0.0
