class_name CutsceneBloomPulse
extends Node
## Animated bloom effect that creates a gentle ebb and flow for cutscenes.
## Uses a sinusoidal wave to smoothly pulse the glow intensity.

## Base glow intensity (the center point of the pulse)
@export_range(0.0, 2.0) var base_glow_intensity: float = 0.08

## How much the glow intensity varies from the base (amplitude of the wave)
@export_range(0.0, 1.0) var pulse_amplitude: float = 0.02

## Speed of the pulse cycle (lower = slower, more dreamy)
@export_range(0.1, 5.0) var pulse_speed: float = 0.5

## Secondary slower pulse for more organic feel (layered on top of main pulse)
@export_range(0.0, 0.5) var secondary_amplitude: float = 0.01

## Speed of the secondary pulse
@export_range(0.05, 2.0) var secondary_speed: float = 0.17

## Glow bloom level (controls which brightness levels glow)
@export_range(0.0, 1.0) var glow_bloom: float = 0.02

## HDR threshold - pixels brighter than this will glow
@export_range(0.0, 4.0) var glow_hdr_threshold: float = 0.95

## Smoothing factor for transitions (higher = smoother)
@export_range(0.0, 0.99) var smoothing: float = 0.85

## Enable/disable the effect
@export var enabled: bool = true

var _world_environment: WorldEnvironment
var _environment: Environment
var _time: float = 0.0
var _current_glow: float = 0.0
var _target_glow: float = 0.0


func _ready() -> void:
	_setup_world_environment()
	_current_glow = base_glow_intensity
	_target_glow = base_glow_intensity


func _setup_world_environment() -> void:
	# Look for existing WorldEnvironment in scene tree
	_world_environment = _find_world_environment()

	if not _world_environment:
		_world_environment = WorldEnvironment.new()
		_world_environment.name = "CutsceneWorldEnvironment"
		add_child(_world_environment)

	# Create or get the Environment resource
	if _world_environment.environment:
		# Duplicate to avoid modifying the shared resource
		_environment = _world_environment.environment.duplicate()
		_world_environment.environment = _environment
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
	_environment.glow_strength = 0.1
	_environment.glow_hdr_scale = 1.0
	_environment.glow_hdr_luminance_cap = 12.0

	# Set glow levels for a nice bloom effect
	_environment.set_glow_level(0, true)
	_environment.set_glow_level(1, true)
	_environment.set_glow_level(2, true)
	_environment.set_glow_level(3, true)
	_environment.set_glow_level(4, false)
	_environment.set_glow_level(5, false)
	_environment.set_glow_level(6, false)


func _find_world_environment() -> WorldEnvironment:
	# First check if there's one as a direct child
	var child_env = get_node_or_null("WorldEnvironment") as WorldEnvironment
	if child_env:
		return child_env

	# Check parent and siblings
	var parent = get_parent()
	if parent:
		for child in parent.get_children():
			if child is WorldEnvironment:
				return child

	# Search the entire scene tree
	var root = get_tree().root
	return _find_world_environment_recursive(root)


func _find_world_environment_recursive(node: Node) -> WorldEnvironment:
	if node is WorldEnvironment:
		return node
	for child in node.get_children():
		var result = _find_world_environment_recursive(child)
		if result:
			return result
	return null


func _process(delta: float) -> void:
	if not enabled or not _environment:
		return

	# Advance time
	_time += delta

	# Calculate pulse using layered sine waves for organic feel
	# Main pulse: larger, faster oscillation
	var main_pulse: float = sin(_time * pulse_speed * TAU) * pulse_amplitude

	# Secondary pulse: smaller, slower oscillation for organic variation
	var secondary_pulse: float = sin(_time * secondary_speed * TAU) * secondary_amplitude

	# Combine pulses
	_target_glow = base_glow_intensity + main_pulse + secondary_pulse

	# Clamp to valid range
	_target_glow = clampf(_target_glow, 0.1, 2.0)

	# Smooth the transition
	_current_glow = lerpf(_current_glow, _target_glow, 1.0 - smoothing)

	# Apply to environment
	_environment.glow_intensity = _current_glow


## Update base intensity at runtime
func set_base_intensity(intensity: float) -> void:
	base_glow_intensity = intensity


## Enable or disable the pulsing effect
func set_enabled(value: bool) -> void:
	enabled = value
	if _environment and not enabled:
		_environment.glow_intensity = base_glow_intensity


## Get the current glow intensity
func get_current_glow() -> float:
	return _current_glow


## Reset the time to start the pulse from the beginning
func reset_pulse() -> void:
	_time = 0.0
	_current_glow = base_glow_intensity
