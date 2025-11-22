extends Node
## EventBus - Centralized event management system
##
## This autoload provides a decoupled communication system between game components.
## Instead of direct references to singletons, systems emit and subscribe to events.
##
## Benefits:
## - Reduces coupling between systems
## - Makes dependencies explicit through event subscriptions
## - Easier to test individual components
## - Clearer data flow throughout the application

# ============================================================================
# SCORE AND GAME STATE EVENTS
# ============================================================================

## Emitted when score should be added (systems request score change)
signal score_add_requested(points: int, source: String, metadata: Dictionary)

## Emitted when score was successfully changed
signal score_changed(new_score: int, delta: int, source: String)

## Emitted when a new high score is achieved
signal high_score_achieved(difficulty: String, score: int, level: int)

## Emitted when score should be reset
signal score_reset_requested()

# ============================================================================
# STRIKE AND PENALTY EVENTS
# ============================================================================

## Emitted when a strike should be added
signal strike_add_requested(reason: String, metadata: Dictionary)

## Emitted when strike count changed
signal strike_changed(current_strikes: int, max_strikes: int, delta: int)

## Emitted when a strike is removed (forgiven)
signal strike_removed(current_strikes: int, max_strikes: int)

## Emitted when maximum strikes reached - game over condition
signal max_strikes_reached()

# ============================================================================
# GAME FLOW EVENTS
# ============================================================================

## Emitted when game over is triggered
signal game_over_triggered(reason: String)

## Emitted to request shift advancement
signal shift_advance_requested()

## Emitted when shift/level advances
signal shift_advanced(from_shift: int, to_shift: int)

## Emitted to request story state advancement
signal story_state_advance_requested()

## Emitted when shift stats are reset
signal shift_stats_reset()

## Emitted when quota target is updated
signal quota_updated(new_target: int, current_met: int)

## Emitted to request unlocking a level
signal level_unlock_requested(level_id: int)

## Emitted when a level is unlocked
signal level_unlocked(level_id: int)

## Emitted when game mode changes
signal game_mode_changed(new_mode: String)

# ============================================================================
# GAMEPLAY ACTION EVENTS
# ============================================================================

## Emitted when a runner escapes
signal runner_escaped(runner_data: Dictionary)

## Emitted when a runner is successfully stopped
signal runner_stopped(runner_data: Dictionary)

## Emitted when an innocent is incorrectly hit
signal innocent_hit(penalty: int, metadata: Dictionary)

## Emitted when a perfect hit is achieved
signal perfect_hit_achieved(bonus_points: int)

## Emitted when missile is launched
signal missile_launched(position: Vector2)

## Emitted when missile hits target
signal missile_hit(target_type: String, position: Vector2)

# ============================================================================
# POTATO/DOCUMENT PROCESSING EVENTS
# ============================================================================

## Emitted when a potato is approved
signal potato_approved(potato_data: Dictionary)

## Emitted when a potato is rejected
signal potato_rejected(potato_data: Dictionary)

## Emitted when stamp is applied
signal stamp_applied(stamp_type: String, document_type: String)

## Emitted when document is opened
signal document_opened(document_type: String)

## Emitted when document is closed
signal document_closed(document_type: String)

# ============================================================================
# NARRATIVE AND DIALOGUE EVENTS
# ============================================================================

## Emitted when a narrative choice is made
signal narrative_choice_made(choice_key: String, choice_value: Variant)

## Emitted when dialogue starts
signal dialogue_started(timeline_name: String)

## Emitted when dialogue ends
signal dialogue_ended(timeline_name: String)

## Emitted when story state changes
signal story_state_changed(new_state: int)

## Emitted when narrative choices should be saved
signal narrative_choices_save_requested()

## Emitted when narrative choices should be loaded
signal narrative_choices_load_requested(choices: Dictionary)

# ============================================================================
# UI AND FEEDBACK EVENTS
# ============================================================================

## Emitted to show a red (negative) alert
signal alert_red_requested(message: String, duration: float)

## Emitted to show a green (positive) alert
signal alert_green_requested(message: String, duration: float)

## Emitted to request screen shake effect
signal screen_shake_requested(intensity: float, duration: float)

## Emitted when UI needs to update score display
signal ui_score_update_requested(score: int)

## Emitted when UI needs to update strike display
signal ui_strike_update_requested(current: int, max_val: int)

# ============================================================================
# SAVE/LOAD EVENTS
# ============================================================================

## Emitted when game state should be saved
signal save_game_requested()

## Emitted when game state was successfully saved
signal game_saved()

## Emitted when game state should be loaded
signal load_game_requested()

## Emitted when game state was successfully loaded
signal game_loaded(data: Dictionary)

# ============================================================================
# ANALYTICS EVENTS
# ============================================================================

## Emitted to track a game event for analytics
signal analytics_event(event_name: String, event_data: Dictionary)

## Emitted when session starts
signal session_started()

## Emitted when session ends
signal session_ended()

# ============================================================================
# ACHIEVEMENT EVENTS
# ============================================================================

## Emitted when an achievement condition is met
signal achievement_unlocked(achievement_id: String)

## Emitted to check achievement progress
signal achievement_check_requested()

# ============================================================================
# ACCESSIBILITY EVENTS
# ============================================================================

## Emitted when accessibility settings change
signal accessibility_settings_changed(settings: Dictionary)

## Emitted when text-to-speech should read something
signal tts_speak_requested(text: String)

# ============================================================================
# TUTORIAL EVENTS
# ============================================================================

## Emitted when tutorial step advances
signal tutorial_step_advanced(step_id: String)

## Emitted when tutorial is completed
signal tutorial_completed()

## Emitted when tutorial hint should be shown
signal tutorial_hint_requested(hint_key: String)

# ============================================================================
# HELPER METHODS
# ============================================================================

## Convenience method to emit score add with standard metadata
func request_score_add(points: int, source: String = "unknown", extra_data: Dictionary = {}) -> void:
	var metadata = extra_data.duplicate()
	metadata["timestamp"] = Time.get_ticks_msec()
	score_add_requested.emit(points, source, metadata)


## Convenience method to request a strike with reason
func request_strike_add(reason: String = "unknown", extra_data: Dictionary = {}) -> void:
	var metadata = extra_data.duplicate()
	metadata["timestamp"] = Time.get_ticks_msec()
	strike_add_requested.emit(reason, metadata)


## Convenience method to emit runner escape event
func emit_runner_escaped(runner_type: String = "unknown", extra_data: Dictionary = {}) -> void:
	var data = extra_data.duplicate()
	data["runner_type"] = runner_type
	data["timestamp"] = Time.get_ticks_msec()
	runner_escaped.emit(data)


## Convenience method to emit runner stopped event
func emit_runner_stopped(runner_type: String, points_earned: int, was_perfect: bool = false, extra_data: Dictionary = {}) -> void:
	var data = extra_data.duplicate()
	data["runner_type"] = runner_type
	data["points_earned"] = points_earned
	data["was_perfect"] = was_perfect
	data["timestamp"] = Time.get_ticks_msec()
	runner_stopped.emit(data)


## Convenience method to show alert
func show_alert(message: String, is_positive: bool = true, duration: float = 2.0) -> void:
	if is_positive:
		alert_green_requested.emit(message, duration)
	else:
		alert_red_requested.emit(message, duration)


## Convenience method to track analytics
func track_event(event_name: String, data: Dictionary = {}) -> void:
	var enriched_data = data.duplicate()
	enriched_data["timestamp"] = Time.get_ticks_msec()
	analytics_event.emit(event_name, enriched_data)


## Debug method to list all connected signals
func get_connection_report() -> Dictionary:
	var report = {}
	for sig in get_signal_list():
		var connections = get_signal_connection_list(sig.name)
		if connections.size() > 0:
			report[sig.name] = []
			for conn in connections:
				report[sig.name].append({
					"callable": str(conn.callable),
					"flags": conn.flags
				})
	return report


func _ready() -> void:
	print("EventBus initialized - centralized event system ready")
