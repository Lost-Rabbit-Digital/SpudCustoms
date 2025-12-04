extends Node
## GameStateManager - Centralized game state management
##
## This manager subscribes to EventBus events and manages game state.
## Instead of systems directly modifying Global, they emit events that
## this manager processes and updates state accordingly.
##
## This provides:
## - Single source of truth for game state
## - Auditable state changes through events
## - Decoupled systems that communicate through events

# ============================================================================
# STATE VARIABLES (moved from Global to be managed centrally)
# ============================================================================

# Core game state
var _score: int = 0
var _strikes: int = 0
var _max_strikes: int = 4
var _shift: int = 0
var _quota_target: int = 8
var _quota_met: int = 0
var _difficulty_level: String = "Normal"
var _game_mode: String = "score_attack"
var _story_state: int = 0

# Statistics
var _total_runners_stopped: int = 0
var _perfect_hits: int = 0
var _total_shifts_completed: int = 0
var _last_game_stats: Dictionary = {}
var _total_playtime: float = 0.0

# ============================================================================
# PUBLIC READ-ONLY ACCESSORS
# ============================================================================

func get_score() -> int:
	return _score


func get_strikes() -> int:
	return _strikes


func get_max_strikes() -> int:
	return _max_strikes


func get_shift() -> int:
	return _shift


func set_shift(value: int) -> void:
	_shift = value
	# Also update GameState persistence
	if GameState:
		GameState.set_current_level(value)


func get_quota_target() -> int:
	return _quota_target


func get_quota_met() -> int:
	return _quota_met


func set_quota_met(value: int) -> void:
	_quota_met = value
	# Also sync to Global for consistency
	if Global:
		Global.quota_met = value


func set_strikes(value: int) -> void:
	var old_strikes = _strikes
	_strikes = value
	# Sync with Global
	if Global:
		Global.strikes = value
	# Emit UI update
	EventBus.strike_changed.emit(_strikes, _max_strikes, _strikes - old_strikes)
	EventBus.ui_strike_update_requested.emit(_strikes, _max_strikes)


func get_difficulty() -> String:
	return _difficulty_level


func get_game_mode() -> String:
	return _game_mode


func set_game_mode(mode: String) -> void:
	_game_mode = mode


func switch_game_mode(mode: String) -> void:
	set_game_mode(mode)

	if mode == "story":
		# Load story progress from GameState
		if GameState:
			set_shift(GameState.get_current_level())
		# Set quota based on current level (simplified logic for now)
		var base_quota = 8
		_quota_target = base_quota + (_shift - 1)

	elif mode == "score_attack":
		# For score attack, reset to level 1
		set_shift(1)
		_quota_target = 9999

	# Emit game mode changed signal
	EventBus.game_mode_changed.emit(mode)

	# Save state after mode switch
	EventBus.save_game_requested.emit()

	LogManager.write_info("Game mode switched to: " + mode)


func get_story_state() -> int:
	return _story_state


func set_story_state(state: int) -> void:
	_story_state = state
	# Emit event if needed, or just update state
	# EventBus.story_state_changed.emit(state)


func is_dev_mode() -> bool:
	return Global.DEV_MODE if Global else false


func get_total_runners_stopped() -> int:
	return _total_runners_stopped


func get_perfect_hits() -> int:
	return _perfect_hits


func get_total_playtime() -> float:
	return _total_playtime


func get_last_game_stats() -> Dictionary:
	return _last_game_stats


func set_last_game_stats(stats: Dictionary) -> void:
	_last_game_stats = stats


func get_build_type() -> String:
	return "Full Release"


# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	_connect_to_event_bus()
	print("GameStateManager initialized - listening to EventBus")


func _process(delta: float) -> void:
	_total_playtime += delta


func _connect_to_event_bus() -> void:
	# Score events
	EventBus.score_add_requested.connect(_on_score_add_requested)
	EventBus.score_reset_requested.connect(_on_score_reset_requested)

	# Strike events
	EventBus.strike_add_requested.connect(_on_strike_add_requested)

	# Gameplay events
	EventBus.runner_stopped.connect(_on_runner_stopped)
	EventBus.runner_escaped.connect(_on_runner_escaped)
	EventBus.innocent_hit.connect(_on_innocent_hit)
	EventBus.perfect_hit_achieved.connect(_on_perfect_hit)

	# Game flow events
	EventBus.shift_stats_reset.connect(_on_shift_stats_reset)
	EventBus.reset_shift_requested.connect(_on_reset_shift_requested)
	EventBus.reset_game_requested.connect(_on_reset_game_requested)

	# Save/load events
	EventBus.save_game_requested.connect(_on_save_requested)
	EventBus.load_game_requested.connect(_on_load_requested)


# ============================================================================
# EVENT HANDLERS
# ============================================================================

func _on_score_add_requested(points: int, source: String, metadata: Dictionary) -> void:
	var old_score = _score
	_score += points

	# Emit the change event
	EventBus.score_changed.emit(_score, points, source)
	EventBus.ui_score_update_requested.emit(_score)

	# Light haptic feedback for score increases
	if points > 0:
		EventBus.haptic_feedback_requested.emit(0.15, 0.1)

	# Check for high score
	_check_high_score()

	LogManager.write_info("Score changed: %d -> %d (source: %s)" % [old_score, _score, source])


func _on_score_reset_requested() -> void:
	var old_score = _score
	_score = 0

	EventBus.score_changed.emit(0, -old_score, "reset")
	EventBus.ui_score_update_requested.emit(0)

	LogManager.write_info("Score reset from %d to 0" % old_score)


func _on_strike_add_requested(reason: String, _metadata: Dictionary) -> void:
	var old_strikes = _strikes
	_strikes += 1

	# Emit strike change event
	EventBus.strike_changed.emit(_strikes, _max_strikes, 1)
	EventBus.ui_strike_update_requested.emit(_strikes, _max_strikes)

	# Haptic feedback for strike - medium intensity
	EventBus.haptic_feedback_requested.emit(0.5, 0.2)

	LogManager.write_info("Strike added: %d -> %d (reason: %s)" % [old_strikes, _strikes, reason])

	# Check for game over
	if _strikes >= _max_strikes:
		LogManager.write_info("Maximum strikes reached! Game over triggered.")
		# Heavy haptic feedback for game over
		EventBus.haptic_feedback_requested.emit(0.8, 0.4)
		EventBus.max_strikes_reached.emit()
		EventBus.game_over_triggered.emit("max_strikes")


func _on_runner_stopped(runner_data: Dictionary) -> void:
	_total_runners_stopped += 1

	# Haptic feedback for runner stopped - heavy intensity
	var was_perfect = runner_data.get("was_perfect", false)
	if was_perfect:
		EventBus.haptic_feedback_requested.emit(1.0, 0.3)  # Extra heavy for perfect
	else:
		EventBus.haptic_feedback_requested.emit(0.7, 0.25)  # Heavy for normal stop

	# Handle score if included in event data
	if runner_data.has("points_earned"):
		var points = runner_data.points_earned
		EventBus.request_score_add(points, "runner_stopped", runner_data)

	# Handle strike forgiveness (reduce strike on successful stop)
	if _strikes > 0:
		_strikes -= 1
		EventBus.strike_removed.emit(_strikes, _max_strikes)
		EventBus.ui_strike_update_requested.emit(_strikes, _max_strikes)

	LogManager.write_info("Runner stopped. Total: %d" % _total_runners_stopped)


func _on_runner_escaped(runner_data: Dictionary) -> void:
	# Apply escape penalty
	var penalty = runner_data.get("penalty", 50)
	var points_to_remove = min(penalty, _score)

	if points_to_remove > 0:
		_score = max(0, _score - points_to_remove)
		EventBus.score_changed.emit(_score, -points_to_remove, "runner_escaped")
		EventBus.ui_score_update_requested.emit(_score)

	# Add strike
	EventBus.request_strike_add("runner_escaped", runner_data)

	# Show alert
	if points_to_remove > 0:
		EventBus.show_alert(tr("alert_points_deducted").format({"penalty": points_to_remove}), false)
	else:
		EventBus.show_alert(tr("alert_runner_escaped"), false)


func _on_innocent_hit(penalty: int, metadata: Dictionary) -> void:
	var points_to_remove = min(penalty, _score)

	if points_to_remove > 0:
		_score = max(0, _score - points_to_remove)
		EventBus.score_changed.emit(_score, -points_to_remove, "innocent_hit")
		EventBus.ui_score_update_requested.emit(_score)

	var message = metadata.get("message", tr("alert_innocent_hit"))
	EventBus.show_alert(message, false)

	LogManager.write_info("Innocent hit. Penalty: %d" % penalty)


func _on_perfect_hit(bonus_points: int) -> void:
	_perfect_hits += 1

	# Extra heavy haptic feedback for perfect hits
	EventBus.haptic_feedback_requested.emit(1.0, 0.35)

	LogManager.write_info("Perfect hit! Total: %d" % _perfect_hits)


func _on_shift_stats_reset() -> void:
	_score = 0
	_strikes = 0
	_quota_met = 0

	EventBus.ui_score_update_requested.emit(0)
	EventBus.ui_strike_update_requested.emit(0, _max_strikes)

	LogManager.write_info("Shift stats reset")


func _on_reset_shift_requested() -> void:
	# Reset shift-specific stats (score, strikes, quota) before scene reload
	_score = 0
	_strikes = 0
	_quota_met = 0

	# Sync with Global
	if Global:
		Global.score = 0
		Global.strikes = 0
		Global.quota_met = 0

	LogManager.write_info("Shift reset requested - stats cleared for restart")


func _on_reset_game_requested() -> void:
	# Additional game reset logic if needed
	# This is called alongside reset_shift_requested when restarting
	LogManager.write_info("Game reset requested")


func _on_save_requested() -> void:
	# Save logic should be handled by SaveManager listening to this event
	# or GameStateManager calling SaveManager
	if SaveManager:
		SaveManager.save_game_state(get_state_snapshot())
	EventBus.game_saved.emit()


func _on_load_requested() -> void:
	if SaveManager:
		var data = SaveManager.load_game_state()
		if not data.is_empty():
			# Restore state from data
			_score = data.get("score", 0)
			_strikes = data.get("strikes", 0)
			_shift = data.get("shift", 0)
			_difficulty_level = data.get("difficulty", "Normal")
			_game_mode = data.get("game_mode", "score_attack")
			_story_state = data.get("story_state", 0)
			_total_playtime = data.get("total_playtime", 0.0)
			_total_runners_stopped = data.get("total_runners_stopped", 0)
			_perfect_hits = data.get("perfect_hits", 0)
			_total_shifts_completed = data.get("total_shifts_completed", 0)
	EventBus.game_loaded.emit({})


# ============================================================================
# HELPER METHODS
# ============================================================================

func _check_high_score() -> void:
	if not SaveManager:
		return

	var high_score = SaveManager.get_level_high_score(_shift, _difficulty_level)

	if _score > high_score:
		SaveManager.save_level_high_score(_shift, _difficulty_level, _score)
		EventBus.high_score_achieved.emit(_difficulty_level, _score, _shift)
		LogManager.write_info("New high score: %d for shift %d on %s" % [_score, _shift, _difficulty_level])


func set_difficulty(new_difficulty: String) -> void:
	if new_difficulty not in ["Easy", "Normal", "Expert"]:
		return

	_difficulty_level = new_difficulty

	match _difficulty_level:
		"Easy":
			_max_strikes = 6
		"Normal":
			_max_strikes = 4
		"Expert":
			_max_strikes = 3


func get_state_snapshot() -> Dictionary:
	"""Get a complete snapshot of current game state"""
	return {
		"score": _score,
		"strikes": _strikes,
		"max_strikes": _max_strikes,
		"shift": _shift,
		"quota_target": _quota_target,
		"quota_met": _quota_met,
		"difficulty": _difficulty_level,
		"game_mode": _game_mode,
		"total_runners_stopped": _total_runners_stopped,
		"perfect_hits": _perfect_hits,
		"total_shifts_completed": _total_shifts_completed,
		"total_playtime": _total_playtime
	}
