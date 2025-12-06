extends Node
## SentryManager - Centralized Sentry SDK integration for error tracking
##
## This manager handles:
## - Setting user context (Steam ID when available)
## - Setting release/environment information
## - Adding breadcrumbs for important game events
## - Capturing errors with game context

# Whether Sentry is available and initialized
var _sentry_available: bool = false

# User context
var _user_id: String = ""
var _user_name: String = ""


func _ready() -> void:
	# Check if SentrySDK is available (it's a GDExtension singleton)
	_sentry_available = _check_sentry_available()

	if not _sentry_available:
		LogManager.write_warning("SentryManager: Sentry SDK not available")
		return

	LogManager.write_info("SentryManager: Initializing Sentry integration")

	# Set release version from project settings
	_set_release_info()

	# Connect to EventBus signals for breadcrumbs
	_connect_eventbus_signals()

	# Set up user context when Steam is ready
	_setup_user_context()

	# Add initial breadcrumb
	add_breadcrumb("app", "Game started", {"version": ProjectSettings.get_setting("application/config/version", "unknown")})

	LogManager.write_info("SentryManager: Sentry integration initialized")


func _check_sentry_available() -> bool:
	# Check if the SentrySDK singleton exists
	# The GDExtension automatically registers this when loaded
	return ClassDB.class_exists("SentrySDK")


func _set_release_info() -> void:
	if not _sentry_available:
		return

	var version = ProjectSettings.get_setting("application/config/version", "1.0.0")
	var app_name = ProjectSettings.get_setting("application/config/name", "SpudCustoms")

	# Set release in format "app-name@version"
	var release = "%s@%s" % [app_name.to_lower().replace(" ", "-"), version]
	SentrySDK.set_tag("release", release)
	SentrySDK.set_tag("version", version)

	# Set environment based on debug/release build
	var environment = "development" if OS.is_debug_build() else "production"
	SentrySDK.set_tag("environment", environment)

	# Set platform info
	SentrySDK.set_tag("platform", OS.get_name())
	SentrySDK.set_tag("godot_version", Engine.get_version_info().string)

	LogManager.write_info("SentryManager: Release set to %s (%s)" % [release, environment])


func _setup_user_context() -> void:
	if not _sentry_available:
		return

	# Try to get Steam user info if available
	if not Global.DEV_MODE and Steam.isSteamRunning():
		var steam_id = Steam.getSteamID()
		var steam_name = Steam.getPersonaName()

		if steam_id > 0:
			_user_id = str(steam_id)
			_user_name = steam_name

			SentrySDK.set_user({"id": _user_id, "username": _user_name})
			SentrySDK.set_tag("steam_id", _user_id)

			LogManager.write_info("SentryManager: User context set for Steam user")
	else:
		# Generate anonymous user ID for non-Steam users
		_user_id = _generate_anonymous_id()
		SentrySDK.set_user({"id": _user_id})
		LogManager.write_info("SentryManager: Anonymous user context set")


func _generate_anonymous_id() -> String:
	# Generate a consistent anonymous ID based on system info
	var system_info = OS.get_unique_id()
	if system_info.is_empty():
		system_info = str(Time.get_unix_time_from_system())
	return system_info.sha256_text().substr(0, 16)


func _connect_eventbus_signals() -> void:
	if not EventBus:
		return

	# Game flow events
	EventBus.session_started.connect(_on_session_started)
	EventBus.session_ended.connect(_on_session_ended)
	EventBus.game_over_triggered.connect(_on_game_over_triggered)
	EventBus.game_mode_changed.connect(_on_game_mode_changed)

	# Level/shift events
	EventBus.shift_advanced.connect(_on_shift_advanced)
	EventBus.level_unlocked.connect(_on_level_unlocked)

	# Score and strike events
	EventBus.score_changed.connect(_on_score_changed)
	EventBus.strike_changed.connect(_on_strike_changed)
	EventBus.max_strikes_reached.connect(_on_max_strikes_reached)
	EventBus.high_score_achieved.connect(_on_high_score_achieved)

	# Gameplay events
	EventBus.runner_escaped.connect(_on_runner_escaped)
	EventBus.runner_stopped.connect(_on_runner_stopped)
	EventBus.perfect_hit_achieved.connect(_on_perfect_hit_achieved)

	# Minigame events
	EventBus.minigame_started.connect(_on_minigame_started)
	EventBus.minigame_completed.connect(_on_minigame_completed)

	# Dialogue events
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)
	EventBus.narrative_choice_made.connect(_on_narrative_choice_made)

	LogManager.write_info("SentryManager: EventBus signals connected")


# Breadcrumb helpers
func add_breadcrumb(category: String, message: String, data: Dictionary = {}) -> void:
	if not _sentry_available:
		return

	SentrySDK.add_breadcrumb(message, category, "info", data)


func add_error_breadcrumb(category: String, message: String, data: Dictionary = {}) -> void:
	if not _sentry_available:
		return

	SentrySDK.add_breadcrumb(message, category, "error", data)


# Capture methods
func capture_message(message: String, level: String = "info") -> void:
	if not _sentry_available:
		return

	# Add game context before capturing
	_add_game_context()
	SentrySDK.capture_message(message, level)


func capture_error(message: String) -> void:
	if not _sentry_available:
		return

	_add_game_context()
	SentrySDK.capture_message(message, "error")


func capture_exception(error_message: String, stack_trace: String = "") -> void:
	if not _sentry_available:
		return

	_add_game_context()

	var data = {"error": error_message}
	if not stack_trace.is_empty():
		data["stack_trace"] = stack_trace

	SentrySDK.add_breadcrumb(error_message, "exception", "error", data)
	SentrySDK.capture_message(error_message, "error")


func _add_game_context() -> void:
	if not _sentry_available:
		return

	# Add current game state context
	SentrySDK.set_context("game_state", {
		"shift": Global.shift,
		"score": Global.score,
		"strikes": Global.strikes,
		"difficulty": Global.difficulty_level,
		"game_mode": Global.game_mode,
		"story_state": Global.current_story_state,
		"playtime_seconds": Global.total_playtime
	})


# Set custom tags
func set_tag(key: String, value: String) -> void:
	if not _sentry_available:
		return

	SentrySDK.set_tag(key, value)


# Set custom context
func set_context(name: String, data: Dictionary) -> void:
	if not _sentry_available:
		return

	SentrySDK.set_context(name, data)


# EventBus signal handlers
func _on_session_started() -> void:
	add_breadcrumb("session", "Session started", {
		"difficulty": Global.difficulty_level,
		"game_mode": Global.game_mode
	})


func _on_session_ended() -> void:
	add_breadcrumb("session", "Session ended", {
		"final_score": Global.final_score,
		"total_playtime": Global.total_playtime
	})


func _on_game_over_triggered(reason: String) -> void:
	add_breadcrumb("game", "Game over", {
		"reason": reason,
		"final_score": Global.final_score,
		"shift": Global.shift,
		"strikes": Global.strikes
	})


func _on_game_mode_changed(new_mode: String) -> void:
	add_breadcrumb("game", "Game mode changed", {"mode": new_mode})
	set_tag("game_mode", new_mode)


func _on_shift_advanced(from_shift: int, to_shift: int) -> void:
	add_breadcrumb("shift", "Shift advanced", {
		"from_shift": from_shift,
		"to_shift": to_shift
	})
	set_tag("current_shift", str(to_shift))


func _on_level_unlocked(level_id: int) -> void:
	add_breadcrumb("progression", "Level unlocked", {"level_id": level_id})


func _on_score_changed(new_score: int, delta: int, source: String) -> void:
	# Only log significant score changes to avoid spam
	if new_score > 0 and new_score % 100 == 0:
		add_breadcrumb("score", "Score milestone", {"score": new_score})


func _on_strike_changed(current_strikes: int, max_strikes: int, delta: int) -> void:
	if delta > 0:
		add_breadcrumb("game", "Strike issued", {
			"current_strikes": current_strikes,
			"max_strikes": max_strikes
		})
	elif delta < 0:
		add_breadcrumb("game", "Strike removed", {
			"current_strikes": current_strikes,
			"max_strikes": max_strikes
		})


func _on_max_strikes_reached() -> void:
	add_error_breadcrumb("game", "Maximum strikes reached - game over")


func _on_high_score_achieved(difficulty: String, score: int, level: int) -> void:
	add_breadcrumb("achievement", "High score achieved", {
		"difficulty": difficulty,
		"score": score,
		"level": level
	})


func _on_runner_escaped(runner_data: Dictionary) -> void:
	add_breadcrumb("gameplay", "Runner escaped", runner_data)


func _on_runner_stopped(runner_data: Dictionary) -> void:
	add_breadcrumb("gameplay", "Runner stopped", runner_data)


func _on_perfect_hit_achieved(bonus_points: int) -> void:
	add_breadcrumb("gameplay", "Perfect hit", {"bonus_points": bonus_points})


func _on_minigame_started(minigame_type: String) -> void:
	add_breadcrumb("minigame", "Minigame started", {"type": minigame_type})


func _on_minigame_completed(result: Dictionary) -> void:
	add_breadcrumb("minigame", "Minigame completed", result)


func _on_dialogue_started(timeline_name: String) -> void:
	add_breadcrumb("narrative", "Dialogue started", {"timeline": timeline_name})


func _on_dialogue_ended(timeline_name: String) -> void:
	add_breadcrumb("narrative", "Dialogue ended", {"timeline": timeline_name})


func _on_narrative_choice_made(choice_key: String, choice_value: Variant) -> void:
	add_breadcrumb("narrative", "Choice made", {
		"key": choice_key,
		"value": str(choice_value)
	})


# Check if Sentry is available
func is_available() -> bool:
	return _sentry_available
