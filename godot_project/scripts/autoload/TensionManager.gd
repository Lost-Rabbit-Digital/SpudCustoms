extends Node
## TensionManager - Handles tension escalation visual/audio feedback
##
## This manager tracks game state (strikes, quota, time) and applies
## escalating feedback when the player is near failure states.
##
## Features:
## - Pulsing UI elements when in danger
## - Screen tint shifts (subtle → red) as strikes accumulate
## - Audio tension layers (heartbeat, alarms)
## - Haptic feedback escalation

# ============================================================================
# CONFIGURATION
# ============================================================================

## Strike thresholds for tension levels (as percentage of max strikes)
const STRIKE_WARNING_THRESHOLD: float = 0.5  # 50% of max strikes
const STRIKE_DANGER_THRESHOLD: float = 0.75   # 75% of max strikes
const STRIKE_CRITICAL_THRESHOLD: float = 1.0  # At max strikes (before game over)

## Tension levels
enum TensionLevel {
	CALM,      # Normal gameplay
	WARNING,   # Getting close to danger
	DANGER,    # High risk
	CRITICAL   # One mistake from failure
}

## Pulse animation settings
const PULSE_SPEED_CALM: float = 0.0
const PULSE_SPEED_WARNING: float = 1.0
const PULSE_SPEED_DANGER: float = 2.0
const PULSE_SPEED_CRITICAL: float = 4.0

## Screen tint colors per tension level
const TINT_CALM: Color = Color(1.0, 1.0, 1.0, 0.0)
const TINT_WARNING: Color = Color(1.0, 0.95, 0.9, 0.05)
const TINT_DANGER: Color = Color(1.0, 0.85, 0.8, 0.1)
const TINT_CRITICAL: Color = Color(1.0, 0.7, 0.7, 0.15)

# ============================================================================
# AUDIO RESOURCES
# ============================================================================

## Tension audio layers (loaded on demand)
var heartbeat_sound: AudioStream = null
var warning_ambient: AudioStream = null

## Audio players for tension sounds
var _heartbeat_player: AudioStreamPlayer = null
var _ambient_player: AudioStreamPlayer = null

# ============================================================================
# STATE
# ============================================================================

## Current tension level
var _current_level: TensionLevel = TensionLevel.CALM

## Current tension value (0.0 - 1.0)
var _tension_value: float = 0.0

## Whether tension system is active (disabled during dialogue, menus, etc.)
var _is_active: bool = false

## Screen overlay for tint effects
var _screen_overlay: ColorRect = null
var _overlay_layer: CanvasLayer = null

## Pulse animation state
var _pulse_time: float = 0.0
var _pulse_tween: Tween = null

## Track previous state for change detection
var _previous_strikes: int = 0
var _was_critical: bool = false

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	_setup_audio_players()
	_setup_screen_overlay()
	_connect_signals()
	LogManager.write_info("TensionManager initialized")


func _process(delta: float) -> void:
	if not _is_active:
		return

	# Update pulse animation
	_update_pulse(delta)

	# Update screen tint interpolation
	_update_screen_tint(delta)


func _setup_audio_players() -> void:
	# Create heartbeat player
	_heartbeat_player = AudioStreamPlayer.new()
	_heartbeat_player.bus = "SFX"
	_heartbeat_player.volume_db = -20.0
	add_child(_heartbeat_player)

	# Create ambient tension player
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = "Ambient"
	_ambient_player.volume_db = -15.0
	add_child(_ambient_player)


func _setup_screen_overlay() -> void:
	# Create canvas layer for overlay (below UI, above game)
	_overlay_layer = CanvasLayer.new()
	_overlay_layer.name = "TensionOverlay"
	_overlay_layer.layer = 80  # Below dialogue/UI

	# Create color rect for screen tint
	_screen_overlay = ColorRect.new()
	_screen_overlay.name = "TintOverlay"
	_screen_overlay.color = TINT_CALM
	_screen_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_screen_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_overlay_layer.add_child(_screen_overlay)
	add_child(_overlay_layer)
	_overlay_layer.visible = false


func _connect_signals() -> void:
	# Subscribe to game state changes
	EventBus.strike_changed.connect(_on_strike_changed)
	EventBus.strike_removed.connect(_on_strike_removed)
	EventBus.quota_updated.connect(_on_quota_updated)
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	EventBus.shift_stats_reset.connect(_on_shift_reset)
	EventBus.game_over_triggered.connect(_on_game_over)

# ============================================================================
# PUBLIC API
# ============================================================================

## Activate tension tracking (call when gameplay starts)
func activate() -> void:
	_is_active = true
	_overlay_layer.visible = true
	_recalculate_tension()
	LogManager.write_info("TensionManager activated")


## Deactivate tension tracking (call when leaving gameplay)
func deactivate() -> void:
	_is_active = false
	_overlay_layer.visible = false
	_reset_tension()
	LogManager.write_info("TensionManager deactivated")


## Get current tension level enum
func get_tension_level() -> TensionLevel:
	return _current_level


## Get current tension value (0.0 - 1.0)
func get_tension_value() -> float:
	return _tension_value


## Check if in critical state
func is_critical() -> bool:
	return _current_level == TensionLevel.CRITICAL

# ============================================================================
# TENSION CALCULATION
# ============================================================================

func _recalculate_tension() -> void:
	if not _is_active:
		return

	var strikes = GameStateManager.get_strikes()
	var max_strikes = GameStateManager.get_max_strikes()

	# Calculate strike-based tension (primary factor)
	var strike_ratio: float = 0.0
	if max_strikes > 0:
		strike_ratio = float(strikes) / float(max_strikes)

	# Determine tension level
	var new_level: TensionLevel
	var new_value: float

	if strike_ratio >= STRIKE_CRITICAL_THRESHOLD - 0.01:
		# At max strikes minus 1 (one more = game over)
		new_level = TensionLevel.CRITICAL
		new_value = 1.0
	elif strikes >= max_strikes - 1:
		# One strike away from game over
		new_level = TensionLevel.CRITICAL
		new_value = 1.0
	elif strike_ratio >= STRIKE_DANGER_THRESHOLD:
		new_level = TensionLevel.DANGER
		new_value = 0.7
	elif strike_ratio >= STRIKE_WARNING_THRESHOLD:
		new_level = TensionLevel.WARNING
		new_value = 0.4
	else:
		new_level = TensionLevel.CALM
		new_value = strike_ratio * 0.4

	# Apply changes if level changed
	if new_level != _current_level:
		_apply_tension_level_change(new_level, new_value)

	_tension_value = new_value


func _apply_tension_level_change(new_level: TensionLevel, new_value: float) -> void:
	var old_level = _current_level
	_current_level = new_level

	# Emit tension change event
	EventBus.tension_level_changed.emit(new_value, _get_level_name(new_level))

	# Handle critical state transitions
	if new_level == TensionLevel.CRITICAL and not _was_critical:
		_was_critical = true
		_enter_critical_state()
	elif new_level != TensionLevel.CRITICAL and _was_critical:
		_was_critical = false
		_exit_critical_state()

	# Update audio
	_update_tension_audio(new_level)

	# Trigger haptic feedback for escalation
	if new_level > old_level:
		_trigger_escalation_haptic(new_level)

	LogManager.write_info("Tension level changed: %s -> %s" % [
		_get_level_name(old_level),
		_get_level_name(new_level)
	])


func _get_level_name(level: TensionLevel) -> String:
	match level:
		TensionLevel.CALM:
			return "calm"
		TensionLevel.WARNING:
			return "warning"
		TensionLevel.DANGER:
			return "danger"
		TensionLevel.CRITICAL:
			return "critical"
	return "unknown"

# ============================================================================
# VISUAL EFFECTS
# ============================================================================

func _update_pulse(delta: float) -> void:
	var pulse_speed: float
	match _current_level:
		TensionLevel.CALM:
			pulse_speed = PULSE_SPEED_CALM
		TensionLevel.WARNING:
			pulse_speed = PULSE_SPEED_WARNING
		TensionLevel.DANGER:
			pulse_speed = PULSE_SPEED_DANGER
		TensionLevel.CRITICAL:
			pulse_speed = PULSE_SPEED_CRITICAL

	if pulse_speed > 0:
		_pulse_time += delta * pulse_speed
		# Emit pulse value for UI elements to use
		var pulse_value = (sin(_pulse_time * TAU) + 1.0) / 2.0
		# UI elements can subscribe to tension_level_changed and use pulse timing


func _update_screen_tint(delta: float) -> void:
	if not _screen_overlay:
		return

	var target_tint: Color
	match _current_level:
		TensionLevel.CALM:
			target_tint = TINT_CALM
		TensionLevel.WARNING:
			target_tint = TINT_WARNING
		TensionLevel.DANGER:
			target_tint = TINT_DANGER
		TensionLevel.CRITICAL:
			# Pulse the critical tint
			var pulse = (sin(_pulse_time * TAU) + 1.0) / 2.0
			target_tint = TINT_CRITICAL
			target_tint.a = lerpf(0.1, 0.2, pulse)

	# Smooth interpolation
	_screen_overlay.color = _screen_overlay.color.lerp(target_tint, delta * 3.0)


func _enter_critical_state() -> void:
	EventBus.critical_state_entered.emit("strikes")

	# Strong screen shake
	UIManager.shake_screen(15.0, 0.4)

	# Heavy haptic feedback
	EventBus.haptic_feedback_requested.emit(0.8, 0.3)

	LogManager.write_info("Entered CRITICAL tension state")


func _exit_critical_state() -> void:
	EventBus.critical_state_exited.emit()
	LogManager.write_info("Exited critical tension state")

# ============================================================================
# AUDIO EFFECTS
# ============================================================================

func _update_tension_audio(level: TensionLevel) -> void:
	match level:
		TensionLevel.CALM:
			_stop_tension_audio()
		TensionLevel.WARNING:
			_play_warning_audio()
		TensionLevel.DANGER:
			_play_danger_audio()
		TensionLevel.CRITICAL:
			_play_critical_audio()


func _stop_tension_audio() -> void:
	if _heartbeat_player.playing:
		var tween = create_tween()
		tween.tween_property(_heartbeat_player, "volume_db", -40.0, 0.5)
		tween.tween_callback(_heartbeat_player.stop)


func _play_warning_audio() -> void:
	# Subtle audio cue - could add ambient tension sound here
	pass


func _play_danger_audio() -> void:
	# More noticeable audio - heartbeat at low volume
	# TODO: Add heartbeat audio asset
	pass


func _play_critical_audio() -> void:
	# Full tension audio - heartbeat prominently
	# TODO: Add heartbeat and alarm audio assets
	pass

# ============================================================================
# HAPTIC FEEDBACK
# ============================================================================

func _trigger_escalation_haptic(level: TensionLevel) -> void:
	match level:
		TensionLevel.WARNING:
			EventBus.haptic_feedback_requested.emit(0.2, 0.1)
		TensionLevel.DANGER:
			EventBus.haptic_feedback_requested.emit(0.4, 0.15)
		TensionLevel.CRITICAL:
			# Double pulse for critical
			EventBus.haptic_feedback_requested.emit(0.6, 0.15)
			await get_tree().create_timer(0.2).timeout
			EventBus.haptic_feedback_requested.emit(0.8, 0.2)

# ============================================================================
# RESET
# ============================================================================

func _reset_tension() -> void:
	_current_level = TensionLevel.CALM
	_tension_value = 0.0
	_was_critical = false
	_pulse_time = 0.0

	if _screen_overlay:
		_screen_overlay.color = TINT_CALM

	_stop_tension_audio()

# ============================================================================
# EVENT HANDLERS
# ============================================================================

func _on_strike_changed(current: int, max_val: int, delta: int) -> void:
	if delta > 0:
		# Strike added - recalculate tension
		_recalculate_tension()

		# Extra feedback for strike received
		if current >= max_val - 1:
			# One strike from game over - extra warning
			UIManager.shake_screen(12.0, 0.3)


func _on_strike_removed(current: int, max_val: int) -> void:
	# Strike removed (forgiven) - recalculate tension
	_recalculate_tension()


func _on_quota_updated(_target: int, _current: int) -> void:
	# Could add quota-based tension in the future
	pass


func _on_dialogue_started(_timeline: String) -> void:
	# Pause tension effects during dialogue
	_overlay_layer.visible = false


func _on_dialogue_ended(_timeline: String) -> void:
	# Resume tension effects after dialogue
	if _is_active:
		_overlay_layer.visible = true


func _on_shift_reset() -> void:
	_reset_tension()


func _on_game_over(_reason: String) -> void:
	# Final dramatic effect
	if _screen_overlay:
		var tween = create_tween()
		tween.tween_property(_screen_overlay, "color", Color(0.8, 0.2, 0.2, 0.3), 0.5)
