class_name AudioReactiveBloom
extends Node
## Audio-reactive bloom effect that makes lighter portions of the screen glow
## in sync with the music.

## The audio bus to analyze (should have AudioEffectSpectrumAnalyzer)
@export var audio_bus: StringName = &"Music"

## Base glow intensity when no audio is playing
@export_range(0.0, 2.0) var base_glow_intensity: float = 0.02

## Maximum additional glow intensity added by audio
@export_range(0.0, 3.0) var max_audio_glow: float = 0.25

## Smoothing factor for glow transitions (higher = smoother but less responsive)
@export_range(0.0, 0.99) var smoothing: float = 0.7

## Frequency range to analyze (in Hz) - bass frequencies have the most impact
@export var min_frequency: float = 20.0
@export var max_frequency: float = 500.0

## Glow bloom level (controls which brightness levels glow)
@export_range(0.0, 1.0) var glow_bloom: float = 0.08

## HDR threshold - pixels brighter than this will glow
@export_range(0.0, 4.0) var glow_hdr_threshold: float = 0.9

## Enable/disable the effect
@export var enabled: bool = true

var _spectrum_analyzer: AudioEffectSpectrumAnalyzerInstance
var _world_environment: WorldEnvironment
var _environment: Environment
var _current_glow: float = 0.0
var _bus_index: int = -1


func _ready() -> void:
	# Find or create the WorldEnvironment
	_setup_world_environment()

	# Get the spectrum analyzer from the audio bus
	_setup_spectrum_analyzer()


func _setup_world_environment() -> void:
	# Look for existing WorldEnvironment in parent or create one
	_world_environment = get_node_or_null("WorldEnvironment") as WorldEnvironment

	if not _world_environment:
		_world_environment = WorldEnvironment.new()
		_world_environment.name = "WorldEnvironment"
		add_child(_world_environment)

	# Create or get the Environment resource
	if _world_environment.environment:
		_environment = _world_environment.environment
	else:
		_environment = Environment.new()
		_world_environment.environment = _environment

	# Configure the environment for 2D glow
	_environment.background_mode = Environment.BG_CANVAS
	_environment.glow_enabled = true
	_environment.glow_intensity = base_glow_intensity
	_environment.glow_bloom = glow_bloom
	_environment.glow_hdr_threshold = glow_hdr_threshold
	_environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE

	# Set glow levels - enable first few for a nice bloom effect
	_environment.set_glow_level(0, true)
	_environment.set_glow_level(1, true)
	_environment.set_glow_level(2, true)
	_environment.set_glow_level(3, false)
	_environment.set_glow_level(4, false)
	_environment.set_glow_level(5, false)
	_environment.set_glow_level(6, false)


func _setup_spectrum_analyzer() -> void:
	_bus_index = AudioServer.get_bus_index(audio_bus)

	if _bus_index == -1:
		push_warning("AudioReactiveBloom: Audio bus '%s' not found" % audio_bus)
		return

	# Find the spectrum analyzer effect on the bus
	var effect_count = AudioServer.get_bus_effect_count(_bus_index)
	for i in effect_count:
		var effect = AudioServer.get_bus_effect(_bus_index, i)
		if effect is AudioEffectSpectrumAnalyzer:
			_spectrum_analyzer = AudioServer.get_bus_effect_instance(_bus_index, i)
			break

	if not _spectrum_analyzer:
		push_warning("AudioReactiveBloom: No AudioEffectSpectrumAnalyzer found on bus '%s'" % audio_bus)


func _process(delta: float) -> void:
	if not enabled or not _spectrum_analyzer or not _environment:
		return

	# Get the audio magnitude from the spectrum
	var magnitude = _get_audio_magnitude()

	# Calculate target glow based on audio
	var target_glow = base_glow_intensity + (magnitude * max_audio_glow)

	# Smooth the transition
	_current_glow = lerp(_current_glow, target_glow, 1.0 - smoothing)

	# Apply to environment
	_environment.glow_intensity = _current_glow


func _get_audio_magnitude() -> float:
	if not _spectrum_analyzer:
		return 0.0

	# Get magnitude from the frequency range
	var magnitude = _spectrum_analyzer.get_magnitude_for_frequency_range(
		min_frequency,
		max_frequency
	)

	# Convert to a 0-1 range using linear magnitude
	# The magnitude is returned as a Vector2 (left, right channels)
	var avg_magnitude = (magnitude.x + magnitude.y) / 2.0

	# Scale the magnitude to a usable range
	# Audio magnitude is typically very small, so we amplify and clamp it
	var scaled = clampf(avg_magnitude * 10.0, 0.0, 1.0)

	return scaled


## Update glow settings at runtime
func set_base_intensity(intensity: float) -> void:
	base_glow_intensity = intensity
	if _environment and not enabled:
		_environment.glow_intensity = base_glow_intensity


## Enable or disable the audio-reactive effect
func set_enabled(value: bool) -> void:
	enabled = value
	if _environment and not enabled:
		_environment.glow_intensity = base_glow_intensity


## Get the current glow intensity
func get_current_glow() -> float:
	return _current_glow
