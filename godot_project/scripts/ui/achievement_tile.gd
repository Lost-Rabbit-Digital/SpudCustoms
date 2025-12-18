## Individual achievement tile for the achievements gallery.
##
## Displays achievement icon, name, description, and progress bar.
## Shows locked/unlocked state with appropriate styling.
class_name AchievementTile
extends PanelContainer

## UI references
@onready var icon_texture: TextureRect = %IconTexture
@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_label: Label = %ProgressLabel
@onready var lock_overlay: ColorRect = %LockOverlay

## Achievement data
var _achievement: AchievementData.Achievement = null
var _is_unlocked: bool = false


func setup(
	achievement: AchievementData.Achievement,
	is_unlocked: bool,
	current_progress: int,
	progress_percent: float
) -> void:
	_achievement = achievement
	_is_unlocked = is_unlocked

	# Wait for ready if needed
	if not is_node_ready():
		await ready

	_update_display(current_progress, progress_percent)


func _update_display(current_progress: int, progress_percent: float) -> void:
	if _achievement == null:
		return

	# Handle hidden achievements
	if _achievement.is_hidden and not _is_unlocked:
		name_label.text = tr("achievement_hidden_name")
		description_label.text = tr("achievement_hidden_desc")
		icon_texture.texture = null
		lock_overlay.visible = true
		progress_bar.visible = false
		progress_label.visible = false
		return

	# Set name and description
	name_label.text = tr(_achievement.name_key)
	description_label.text = tr(_achievement.description_key)

	# Set icon based on unlock state
	_load_icon()

	# Lock overlay
	lock_overlay.visible = not _is_unlocked

	# Progress bar (only for trackable achievements that aren't unlocked)
	if _achievement.progress_max > 0 and not _is_unlocked:
		progress_bar.visible = true
		progress_bar.max_value = _achievement.progress_max
		progress_bar.value = current_progress
		progress_label.visible = true
		progress_label.text = "%d / %d" % [current_progress, _achievement.progress_max]
	else:
		progress_bar.visible = false
		progress_label.visible = false

	# Adjust styling based on unlock state
	if _is_unlocked:
		modulate = Color(1, 1, 1, 1)
		name_label.modulate = Color(1, 0.85, 0.2, 1)  # Gold color for unlocked
	else:
		modulate = Color(0.7, 0.7, 0.7, 1)
		name_label.modulate = Color(1, 1, 1, 1)


func _load_icon() -> void:
	var icon_path: String
	if _is_unlocked:
		icon_path = _achievement.icon_completed
	else:
		icon_path = _achievement.icon_locked

	if ResourceLoader.exists(icon_path):
		var texture: Texture2D = load(icon_path)
		if texture:
			icon_texture.texture = texture
			return

	# Try fallback paths
	var fallback_path: String
	if _is_unlocked:
		fallback_path = "res://assets/achievements/%s.png" % _achievement.steam_id
	else:
		fallback_path = "res://assets/achievements/%s_uncompleted.png" % _achievement.steam_id

	if ResourceLoader.exists(fallback_path):
		icon_texture.texture = load(fallback_path)
	else:
		icon_texture.texture = null
		LogManager.write_warning("AchievementTile: Missing icon for %s" % _achievement.id)
