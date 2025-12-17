## Achievement unlock toast notification.
##
## Displays a slide-in notification when achievements are unlocked,
## showing the achievement icon, name, and description.
class_name AchievementToast
extends Control

## Duration toast stays visible (seconds)
const DISPLAY_DURATION: float = 4.0

## Animation duration for slide in/out (seconds)
const ANIMATION_DURATION: float = 0.5

## Toast panel
@onready var panel: PanelContainer = $Panel
@onready var icon_texture: TextureRect = $Panel/MarginContainer/HBoxContainer/IconTexture
@onready var title_label: Label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/TitleLabel
@onready var name_label: Label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var description_label: Label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/DescriptionLabel

## Queue of achievements to display
var _queue: Array[AchievementData.Achievement] = []
var _is_displaying: bool = false
var _tween: Tween = null


func _ready() -> void:
	# Start hidden off-screen
	panel.modulate.a = 0.0
	panel.position.x = get_viewport_rect().size.x + 50

	# Connect to AchievementsManager signal
	if AchievementsManager:
		AchievementsManager.achievement_display_requested.connect(_on_achievement_display_requested)


func _on_achievement_display_requested(achievement: AchievementData.Achievement) -> void:
	_queue.append(achievement)
	if not _is_displaying:
		_display_next()


func _display_next() -> void:
	if _queue.is_empty():
		_is_displaying = false
		return

	_is_displaying = true
	var achievement: AchievementData.Achievement = _queue.pop_front()

	# Set content
	title_label.text = tr("achievement_unlocked_title")
	name_label.text = tr(achievement.name_key)
	description_label.text = tr(achievement.description_key)

	# Load icon
	_load_achievement_icon(achievement)

	# Play unlock sound
	_play_unlock_sound()

	# Animate in
	_animate_in()


func _load_achievement_icon(achievement: AchievementData.Achievement) -> void:
	var icon_path: String = achievement.icon_completed
	if ResourceLoader.exists(icon_path):
		var texture: Texture2D = load(icon_path)
		if texture:
			icon_texture.texture = texture
			return

	# Fallback to a default icon if achievement icon doesn't exist
	icon_texture.texture = null
	LogManager.write_warning("AchievementToast: Missing icon for %s" % achievement.id)


func _play_unlock_sound() -> void:
	# The mainGame.gd already plays achievement_unlocked.mp3 via EventBus
	# This is just a fallback in case we want toast-specific audio later
	pass


func _animate_in() -> void:
	if _tween and _tween.is_running():
		_tween.kill()

	var viewport_width: float = get_viewport_rect().size.x
	var target_x: float = viewport_width - panel.size.x - 20  # 20px margin from right

	panel.position.x = viewport_width + 50
	panel.modulate.a = 1.0

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)

	_tween.tween_property(panel, "position:x", target_x, ANIMATION_DURATION)
	_tween.tween_interval(DISPLAY_DURATION)
	_tween.tween_callback(_animate_out)


func _animate_out() -> void:
	if _tween and _tween.is_running():
		_tween.kill()

	var viewport_width: float = get_viewport_rect().size.x

	_tween = create_tween()
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_BACK)

	_tween.tween_property(panel, "position:x", viewport_width + 50, ANIMATION_DURATION)
	_tween.tween_callback(_on_animation_complete)


func _on_animation_complete() -> void:
	# Display next in queue if any
	_display_next()
