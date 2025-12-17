## Manages achievement state, progress tracking, and UI notifications.
##
## Centralizes achievement logic, tracks unlock state (synced with Steam),
## and provides data for the achievements UI panel.
class_name AchievementsManager
extends Node

## Emitted when any achievement is unlocked (for UI notifications)
signal achievement_display_requested(achievement: AchievementData.Achievement)

## Emitted when achievement progress updates
signal achievement_progress_updated(achievement_id: String, current: int, max_value: int)

## Toast scene for achievement notifications
const TOAST_SCENE: PackedScene = preload("res://scenes/ui/achievement_toast.tscn")

## Cache of unlocked achievement IDs
var _unlocked_achievements: Dictionary = {}

## Progress values for trackable achievements
var _achievement_progress: Dictionary = {}

## Whether we've synced with Steam this session
var _steam_synced: bool = false

## Toast UI instance (CanvasLayer for overlay)
var _toast_layer: CanvasLayer = null
var _toast_instance: Control = null


func _ready() -> void:
	# Connect to EventBus achievement signal
	if EventBus:
		EventBus.achievement_unlocked.connect(_on_achievement_unlocked)

	# Defer Steam sync to ensure Steam is initialized
	call_deferred("_sync_with_steam")

	# Defer toast setup to ensure scene tree is ready
	call_deferred("_setup_toast_ui")


## Sync achievement state with Steam
func _sync_with_steam() -> void:
	if _steam_synced:
		return

	if Global.DEV_MODE:
		LogManager.write_info("AchievementsManager: DEV_MODE - skipping Steam sync")
		_steam_synced = true
		return

	if not Steam.isSteamRunning():
		LogManager.write_warning("AchievementsManager: Steam not running, using local state only")
		_steam_synced = true
		return

	# Query each achievement's unlock status from Steam
	for id in AchievementData.get_all_ids():
		var achievement: AchievementData.Achievement = AchievementData.get_achievement(id)
		if achievement:
			var steam_status: Dictionary = Steam.getAchievement(achievement.steam_id)
			if steam_status.get("achieved", false):
				_unlocked_achievements[id] = true

	_steam_synced = true
	LogManager.write_info("AchievementsManager: Synced %d unlocked achievements from Steam" % _unlocked_achievements.size())

	# Also sync progress stats
	_sync_progress_from_global()


## Setup toast UI as a CanvasLayer overlay
func _setup_toast_ui() -> void:
	if _toast_layer != null:
		return

	# Create a CanvasLayer to ensure toast appears on top
	_toast_layer = CanvasLayer.new()
	_toast_layer.name = "AchievementToastLayer"
	_toast_layer.layer = 100  # High layer to be on top of everything

	# Instantiate the toast scene
	_toast_instance = TOAST_SCENE.instantiate()
	_toast_layer.add_child(_toast_instance)

	# Add to the tree
	get_tree().root.add_child.call_deferred(_toast_layer)
	LogManager.write_info("AchievementsManager: Toast UI initialized")


## Sync progress values from Global/GameStateManager
func _sync_progress_from_global() -> void:
	if GameStateManager:
		_achievement_progress["total_shifts_completed"] = GameStateManager.get_total_shifts_completed()
		_achievement_progress["total_runners_stopped"] = GameStateManager.get_total_runners_stopped()
		_achievement_progress["perfect_hits"] = GameStateManager.get_perfect_hits()
		_achievement_progress["high_score"] = GameStateManager.get_high_score()
	elif Global:
		_achievement_progress["total_shifts_completed"] = Global.total_shifts_completed
		_achievement_progress["total_runners_stopped"] = Global.total_runners_stopped
		_achievement_progress["perfect_hits"] = Global.perfect_hits
		_achievement_progress["high_score"] = Global.high_score


## Handle achievement unlock from EventBus
func _on_achievement_unlocked(steam_id: String) -> void:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement_by_steam_id(steam_id)
	if achievement == null:
		LogManager.write_warning("AchievementsManager: Unknown achievement steam_id: %s" % steam_id)
		return

	# Skip if already unlocked
	if _unlocked_achievements.get(achievement.id, false):
		return

	_unlocked_achievements[achievement.id] = true
	LogManager.write_info("AchievementsManager: Achievement unlocked - %s" % achievement.id)

	# Emit signal for toast notification
	achievement_display_requested.emit(achievement)


## Check if an achievement is unlocked
func is_unlocked(achievement_id: String) -> bool:
	return _unlocked_achievements.get(achievement_id, false)


## Check if an achievement is unlocked by Steam ID
func is_unlocked_by_steam_id(steam_id: String) -> bool:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement_by_steam_id(steam_id)
	if achievement:
		return is_unlocked(achievement.id)
	return false


## Get current progress for a trackable achievement
func get_progress(achievement_id: String) -> int:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement(achievement_id)
	if achievement == null or achievement.progress_stat.is_empty():
		return 0

	# Refresh from current state
	_sync_progress_from_global()
	return _achievement_progress.get(achievement.progress_stat, 0)


## Get progress as percentage (0.0 to 1.0)
func get_progress_percent(achievement_id: String) -> float:
	var achievement: AchievementData.Achievement = AchievementData.get_achievement(achievement_id)
	if achievement == null or achievement.progress_max <= 0:
		return 0.0

	var current: int = get_progress(achievement_id)
	return clampf(float(current) / float(achievement.progress_max), 0.0, 1.0)


## Get count of unlocked achievements
func get_unlocked_count() -> int:
	return _unlocked_achievements.size()


## Get total achievement count
func get_total_count() -> int:
	return AchievementData.get_total_count()


## Get all achievements with their unlock status
func get_all_achievements_with_status() -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for id in AchievementData.get_all_ids():
		var achievement: AchievementData.Achievement = AchievementData.get_achievement(id)
		if achievement:
			result.append({
				"achievement": achievement,
				"unlocked": is_unlocked(id),
				"progress": get_progress(id),
				"progress_percent": get_progress_percent(id)
			})

	return result


## Get achievements by category with status
func get_achievements_by_category_with_status(category: AchievementData.Category) -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for achievement in AchievementData.get_achievements_by_category(category):
		result.append({
			"achievement": achievement,
			"unlocked": is_unlocked(achievement.id),
			"progress": get_progress(achievement.id),
			"progress_percent": get_progress_percent(achievement.id)
		})

	return result


## Force refresh achievement state (call after game events)
func refresh_state() -> void:
	_sync_progress_from_global()


## Debug: Reset all achievements (development only)
func debug_reset_all() -> void:
	if not Global.DEV_MODE:
		LogManager.write_warning("AchievementsManager: debug_reset_all only available in DEV_MODE")
		return

	_unlocked_achievements.clear()

	if Steam.isSteamRunning():
		Steam.resetAllStats(true)  # true = also reset achievements
		LogManager.write_info("AchievementsManager: Reset all Steam achievements")


## Debug: Unlock specific achievement (development only)
func debug_unlock(achievement_id: String) -> void:
	if not Global.DEV_MODE:
		return

	var achievement: AchievementData.Achievement = AchievementData.get_achievement(achievement_id)
	if achievement:
		_unlocked_achievements[achievement_id] = true
		achievement_display_requested.emit(achievement)
		LogManager.write_info("AchievementsManager: Debug unlocked - %s" % achievement_id)
