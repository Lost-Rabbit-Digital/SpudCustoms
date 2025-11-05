# scripts/core/analytics.gd
extends Node

## Unified analytics system for MixPanel tracking
## Handles all game events, session management, and batching

# ==================== CONFIGURATION ====================

const PROJECT_TOKEN: String = "dd0955f1c7dad8a039e31fa5741f3304"
const API_URL: String = "https://api.mixpanel.com/track"
const BATCH_SIZE: int = 10
const BATCH_INTERVAL: float = 30.0
const CONFIG_PATH: String = "user://analytics.cfg"

# ==================== STATE ====================

var http_request: HTTPRequest
var batch_timer: Timer

# Session tracking
var session_start_time: float = 0.0
var events_this_session: int = 0
var current_session_id: String = ""
var analytics_enabled: bool = true

# Game session metrics
var session_metrics: Dictionary = {
	"shifts_completed": 0,
	"potatoes_processed": 0,
	"correct_decisions": 0,
	"incorrect_decisions": 0,
	"strikes_received": 0,
	"border_runners_caught": 0,
	"border_runners_escaped": 0,
	"cutscenes_watched": 0,
	"cutscenes_skipped": 0,
	"achievements_unlocked": 0,
	"passport_opens": 0,
	"guidebook_opens": 0,
}

# Event batching
var event_queue: Array[Dictionary] = []

# Persistent data cache
var _config: ConfigFile
var _distinct_id: String = ""

# ==================== INITIALIZATION ====================


func _ready() -> void:
	_setup_http_request()
	_setup_batch_timer()
	_load_or_create_config()
	_initialize_session()

	print("📊 Analytics initialized - Session ID: %s" % current_session_id)


func _setup_http_request() -> void:
	http_request = HTTPRequest.new()
	http_request.timeout = 10.0
	http_request.request_completed.connect(_on_request_completed)
	add_child(http_request)


func _setup_batch_timer() -> void:
	batch_timer = Timer.new()
	batch_timer.wait_time = BATCH_INTERVAL
	batch_timer.timeout.connect(_send_batched_events)
	batch_timer.autostart = true
	add_child(batch_timer)


func _load_or_create_config() -> void:
	_config = ConfigFile.new()
	var err := _config.load(CONFIG_PATH)

	if err != OK:
		# First launch - create new ID
		_distinct_id = _generate_unique_id()
		_config.set_value("user", "distinct_id", _distinct_id)
		_config.set_value("stats", "total_sessions", 0)
		_config.set_value("stats", "total_playtime", 0.0)
		_config.set_value("stats", "last_session_time", 0)
		_config.save(CONFIG_PATH)
	else:
		_distinct_id = _config.get_value("user", "distinct_id", _generate_unique_id())


func _initialize_session() -> void:
	session_start_time = Time.get_unix_time_from_system()
	current_session_id = "%s_%d" % [_distinct_id, int(session_start_time)]
	_increment_stat("total_sessions")

	track_session_start()


func _generate_unique_id() -> String:
	return (
		"%d_%d_%s"
		% [
			OS.get_unique_id().hash(),
			Time.get_unix_time_from_system(),
			str(randf()).md5_text().substr(0, 8)
		]
	)


# ==================== CORE TRACKING ====================


func track_event(event_name: String, properties: Dictionary = {}) -> void:
	"""
	Track an analytics event with optional properties.
	Events are batched and sent periodically for performance.
	"""
	if not analytics_enabled:
		return

	# Enrich with session context
	var enriched_properties := _enrich_properties(properties)

	# Build event payload
	var event_data := {
		"event": event_name, "properties": enriched_properties.merged({"token": PROJECT_TOKEN})
	}

	# Add to batch queue
	event_queue.append(event_data)
	events_this_session += 1

	# Send immediately if queue is full
	if event_queue.size() >= BATCH_SIZE:
		_send_batched_events()

	# Debug logging
	if OS.is_debug_build():
		print("📊 [%s] %s" % [event_name, _format_properties(properties)])


func _enrich_properties(properties: Dictionary) -> Dictionary:
	"""Add standard session and game context to all events."""
	var enriched := properties.duplicate()

	# Session metadata
	enriched["distinct_id"] = _distinct_id
	enriched["session_id"] = current_session_id
	enriched["time"] = Time.get_unix_time_from_system()
	enriched["session_duration"] = Time.get_unix_time_from_system() - session_start_time
	enriched["events_this_session"] = events_this_session

	# App metadata
	enriched["game_version"] = ProjectSettings.get_setting("application/config/version", "unknown")
	enriched["platform"] = OS.get_name()
	enriched["godot_version"] = Engine.get_version_info().string
	enriched["locale"] = TranslationServer.get_locale()

	# Game state (if Global exists)
	if Global:
		enriched["current_shift"] = Global.shift
		enriched["current_score"] = Global.score
		enriched["current_strikes"] = Global.strikes
		enriched["difficulty"] = Global.difficulty_level

	return enriched


func _format_properties(properties: Dictionary) -> String:
	"""Format properties for debug output."""
	var parts: Array[String] = []
	for key in properties.keys():
		parts.append("%s=%s" % [key, str(properties[key])])
	return " | ".join(parts) if parts.size() > 0 else "no properties"


# ==================== BATCH SENDING ====================


func _send_batched_events() -> void:
	"""Send all queued events to MixPanel."""
	if event_queue.is_empty():
		return

	var events_to_send := event_queue.duplicate()
	event_queue.clear()

	for event_data in events_to_send:
		var json_string := JSON.stringify(event_data)
		var encoded_data := Marshalls.utf8_to_base64(json_string)
		var full_url := API_URL + "?data=" + encoded_data

		var err := http_request.request(full_url)
		if err != OK:
			push_warning("Analytics request failed: %d" % err)
			# Re-queue failed events (with limit to prevent infinite growth)
			if event_queue.size() < BATCH_SIZE * 3:
				event_queue.append(event_data)

	if OS.is_debug_build() and events_to_send.size() > 0:
		print("📊 Sent batch of %d events" % events_to_send.size())


func _on_request_completed(
	result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray
) -> void:
	"""Handle HTTP response."""
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		push_warning("Analytics request failed: result=%d, code=%d" % [result, response_code])


# ==================== SESSION MANAGEMENT ====================


func track_session_start() -> void:
	track_event(
		"Session Started",
		{
			"is_first_launch": _is_first_launch(),
			"total_sessions": _get_stat("total_sessions"),
			"days_since_last_session": _get_days_since_last_session(),
			"total_playtime_hours": _get_stat("total_playtime") / 3600.0,
		}
	)


func track_session_end() -> void:
	var session_duration := Time.get_unix_time_from_system() - session_start_time

	track_event(
		"Session Ended",
		{
			"session_duration_minutes": session_duration / 60.0,
			"total_events": events_this_session,
			"shifts_completed": session_metrics.shifts_completed,
			"potatoes_processed": session_metrics.potatoes_processed,
			"accuracy_percent": _calculate_accuracy(),
			"strikes_received": session_metrics.strikes_received,
			"cutscene_skip_rate": _calculate_skip_rate(),
		}
	)

	# Update persistent stats
	_increment_stat("total_playtime", session_duration)
	_set_stat("last_session_time", Time.get_unix_time_from_system())
	_save_config()

	# Force send remaining events
	_send_batched_events()


func set_analytics_enabled(enabled: bool) -> void:
	"""Enable/disable analytics (GDPR compliance)."""
	analytics_enabled = enabled
	_set_stat("analytics_enabled", enabled)
	_save_config()

	track_event("Analytics %s" % ("Enabled" if enabled else "Disabled"))
	print("📊 Analytics %s" % ("enabled" if enabled else "disabled"))


# ==================== GAME EVENTS - MENU ====================


func track_game_launched() -> void:
	track_event(
		"Game Launched",
		{
			"launch_count": _get_stat("total_sessions"),
			"is_first_launch": _is_first_launch(),
		}
	)


func track_main_menu_action(action: String) -> void:
	track_event("Main Menu Action", {"action": action})


func track_difficulty_selected(difficulty: String) -> void:
	track_event(
		"Difficulty Selected",
		{
			"difficulty": difficulty,
			"is_first_playthrough": Global.shift <= 1 if Global else true,
		}
	)


func track_language_changed(from_lang: String, to_lang: String) -> void:
	track_event(
		"Language Changed",
		{
			"from_language": from_lang,
			"to_language": to_lang,
		}
	)


# ==================== GAME EVENTS - SHIFTS ====================


func track_shift_started(shift_number: int) -> void:
	track_event(
		"Shift Started",
		{
			"shift_number": shift_number,
			"difficulty": Global.difficulty_level if Global else "unknown",
		}
	)


func track_shift_completed(
	shift_number: int, success: bool, final_score: int, time_taken: float = 0.0
) -> void:
	session_metrics.shifts_completed += 1

	track_event(
		"Shift Completed",
		{
			"shift_number": shift_number,
			"success": success,
			"final_score": final_score,
			"time_taken_seconds": time_taken,
			"potatoes_processed": session_metrics.potatoes_processed,
			"accuracy_percent": _calculate_accuracy(),
		}
	)


func track_shift_failed(shift_number: int, reason: String) -> void:
	track_event(
		"Shift Failed",
		{
			"shift_number": shift_number,
			"failure_reason": reason,
			"final_score": Global.score if Global else 0,
			"final_strikes": Global.strikes if Global else 0,
		}
	)


# ==================== GAME EVENTS - POTATO PROCESSING ====================


func track_potato_processed(
	decision: String, was_correct: bool, potato_info: Dictionary, processing_time: float = 0.0
) -> void:
	"""
	CRITICAL: This tracks player decisions and helps identify confusing rules.
	"""
	session_metrics.potatoes_processed += 1

	if was_correct:
		session_metrics.correct_decisions += 1
	else:
		session_metrics.incorrect_decisions += 1

	track_event(
		"Potato Processed",
		{
			"decision": decision,
			"was_correct": was_correct,
			"potato_type": potato_info.get("type", "unknown"),
			"potato_condition": potato_info.get("condition", "unknown"),
			"potato_country": potato_info.get("origin", "unknown"),
			"processing_time_seconds": processing_time,
		}
	)


func track_incorrect_decision(potato_info: Dictionary, violated_rules: Array) -> void:
	"""
	ANSWERS YOUR NEGATIVE REVIEW PROBLEM: 
	This will show you which rules confuse players the most.
	"""
	session_metrics.strikes_received += 1

	track_event(
		"Incorrect Decision",
		{
			"potato_type": potato_info.get("type", "unknown"),
			"violated_rules": str(violated_rules),
			"cumulative_strikes": Global.strikes if Global else 0,
		}
	)


func track_rule_confusion(rule_key: String, consecutive_mistakes: int = 1) -> void:
	"""Track repeated mistakes with the same rule."""
	track_event(
		"Rule Confusion",
		{
			"rule": rule_key,
			"consecutive_mistakes": consecutive_mistakes,
		}
	)


# ==================== GAME EVENTS - INTERACTIONS ====================


func track_passport_opened(potato_type: String) -> void:
	session_metrics.passport_opens += 1
	track_event("Passport Opened", {"potato_type": potato_type})


func track_passport_field_examined(field_name: String, duration: float) -> void:
	track_event(
		"Passport Field Examined",
		{
			"field": field_name,
			"examination_duration_seconds": duration,
		}
	)


func track_guide_book_opened() -> void:
	session_metrics.guidebook_opens += 1
	track_event(
		"Guide Book Opened",
		{
			"current_score": Global.score if Global else 0,
			"current_strikes": Global.strikes if Global else 0,
		}
	)


# ==================== GAME EVENTS - BORDER RUNNER ====================


func track_border_runner_appeared() -> void:
	track_event("Border Runner Appeared")


func track_border_runner_result(caught: bool, reaction_time: float) -> void:
	if caught:
		session_metrics.border_runners_caught += 1
	else:
		session_metrics.border_runners_escaped += 1

	track_event(
		"Border Runner Result",
		{
			"caught": caught,
			"reaction_time_ms": reaction_time * 1000.0,
		}
	)


# ==================== GAME EVENTS - STORY ====================


func track_cutscene_started(cutscene_name: String) -> void:
	track_event("Cutscene Started", {"cutscene_name": cutscene_name})


func track_cutscene_completed(
	cutscene_name: String, watched_duration: float, total_duration: float
) -> void:
	var completion_percent := (watched_duration / total_duration) * 100.0
	var was_skipped := completion_percent < 90.0

	if was_skipped:
		session_metrics.cutscenes_skipped += 1
	else:
		session_metrics.cutscenes_watched += 1

	track_event(
		"Cutscene Completed",
		{
			"cutscene_name": cutscene_name,
			"was_skipped": was_skipped,
			"completion_percent": completion_percent,
		}
	)


func track_story_choice_made(choice_id: String, choice_value: Variant) -> void:
	track_event(
		"Story Choice Made",
		{
			"choice_id": choice_id,
			"choice_value": str(choice_value),
		}
	)


func track_character_state_change(character_name: String, new_state: String) -> void:
	track_event(
		"Character State Changed",
		{
			"character": character_name,
			"new_state": new_state,
		}
	)


# ==================== GAME EVENTS - ACHIEVEMENTS ====================


func track_achievement_unlocked(achievement_id: String) -> void:
	session_metrics.achievements_unlocked += 1
	track_event(
		"Achievement Unlocked",
		{
			"achievement_id": achievement_id,
			"total_playtime_hours": _get_stat("total_playtime") / 3600.0,
		}
	)


func track_achievement_failed(achievement_id: String, reason: String) -> void:
	track_event(
		"Achievement Failed",
		{
			"achievement_id": achievement_id,
			"failure_reason": reason,
		}
	)


# ==================== GAME EVENTS - COMPLETION ====================


func track_game_completed(ending: String, final_shift: int) -> void:
	track_event(
		"Game Completed",
		{
			"ending": ending,
			"final_shift": final_shift,
			"total_playtime_hours": _get_stat("total_playtime") / 3600.0,
			"overall_accuracy": _calculate_accuracy(),
		}
	)


# ==================== GAME EVENTS - ERRORS ====================


func track_error(error_type: String, error_message: String, context: Dictionary = {}) -> void:
	track_event(
		"Error Encountered",
		{
			"error_type": error_type,
			"error_message": error_message,
			"context": str(context),
		}
	)


func track_bug_report(description: String, game_state: Dictionary = {}) -> void:
	track_event(
		"Bug Reported",
		{
			"description": description,
			"game_state": str(game_state),
		}
	)


# ==================== GAME EVENTS - UI ====================


func track_ui_interaction(element: String, action: String) -> void:
	track_event(
		"UI Interaction",
		{
			"element": element,
			"action": action,
		}
	)


func track_tutorial_step_completed(step_number: int, step_name: String) -> void:
	track_event(
		"Tutorial Step Completed",
		{
			"step_number": step_number,
			"step_name": step_name,
		}
	)


func track_tutorial_skipped() -> void:
	track_event("Tutorial Skipped")


# ==================== HELPER FUNCTIONS ====================


func _calculate_accuracy() -> float:
	var total: int = session_metrics.correct_decisions + session_metrics.incorrect_decisions
	if total == 0:
		return 0.0
	return (float(session_metrics.correct_decisions) / float(total)) * 100.0


func _calculate_skip_rate() -> float:
	var total: int = session_metrics.cutscenes_watched + session_metrics.cutscenes_skipped
	if total == 0:
		return 0.0
	return (float(session_metrics.cutscenes_skipped) / float(total)) * 100.0


func _is_first_launch() -> bool:
	return _get_stat("total_sessions") == 1


func _get_days_since_last_session() -> float:
	var last_time: float = _get_stat("last_session_time", 0.0)
	if last_time == 0.0:
		return 0.0
	var current_time: float = Time.get_unix_time_from_system()
	return (current_time - last_time) / 86400.0


# ==================== CONFIG PERSISTENCE ====================


func _get_stat(key: String, default: Variant = 0) -> Variant:
	return _config.get_value("stats", key, default)


func _set_stat(key: String, value: Variant) -> void:
	_config.set_value("stats", key, value)


func _increment_stat(key: String, amount: float = 1.0) -> void:
	var current: float = float(_get_stat(key, 0.0))
	_set_stat(key, current + amount)


func _save_config() -> void:
	var err := _config.save(CONFIG_PATH)
	if err != OK:
		push_error("Failed to save analytics config: %d" % err)


# ==================== CLEANUP ====================


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		track_session_end()
