## Achievements gallery panel displaying all achievements with unlock status.
##
## Shows achievements organized by category with icons, names, descriptions,
## and progress bars for trackable achievements.
class_name AchievementsPanel
extends Control

## Emitted when panel should close
signal close_requested

## Achievement tile scene for instantiation
const ACHIEVEMENT_TILE_SCENE: PackedScene = preload("res://scenes/ui/achievement_tile.tscn")

## UI references
@onready var close_button: Button = %CloseButton
@onready var title_label: Label = %TitleLabel
@onready var progress_label: Label = %ProgressLabel
@onready var category_tabs: TabContainer = %CategoryTabs
@onready var controller_hints: Control = %ControllerHints

## Category tab containers
var _category_containers: Dictionary = {}


func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)

	# Set translated UI text
	title_label.text = tr("achievements_panel_title")
	close_button.text = tr("achievements_panel_close")

	# Setup controller hints if available
	_setup_controller_hints()

	# Populate achievements
	_setup_categories()
	_populate_achievements()
	_update_progress_label()

	# Grab focus for controller support
	_grab_initial_focus()


func _setup_controller_hints() -> void:
	if controller_hints == null:
		return

	if controller_hints is ControllerHintsBar:
		controller_hints.show_back_hint = true
		controller_hints.show_select_hint = true


func _setup_categories() -> void:
	# Clear existing tabs
	for child in category_tabs.get_children():
		child.queue_free()

	# Create tabs for each category
	var categories: Array = [
		AchievementData.Category.GAMEPLAY,
		AchievementData.Category.NARRATIVE_RESISTANCE,
		AchievementData.Category.NARRATIVE_LOYALIST,
		AchievementData.Category.CHARACTER_ARC,
		AchievementData.Category.DISCOVERY
	]

	for category in categories:
		var scroll := ScrollContainer.new()
		scroll.name = tr(AchievementData.CATEGORY_NAMES[category])
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

		var grid := GridContainer.new()
		grid.name = "Grid"
		grid.columns = 2
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_theme_constant_override("h_separation", 16)
		grid.add_theme_constant_override("v_separation", 16)

		scroll.add_child(grid)
		category_tabs.add_child(scroll)
		_category_containers[category] = grid


func _populate_achievements() -> void:
	if not AchievementsManager:
		LogManager.write_warning("AchievementsPanel: AchievementsManager not available")
		return

	for category in _category_containers.keys():
		var grid: GridContainer = _category_containers[category]
		var achievements: Array[Dictionary] = AchievementsManager.get_achievements_by_category_with_status(category)

		for data in achievements:
			var tile: Control = ACHIEVEMENT_TILE_SCENE.instantiate()
			tile.setup(data.achievement, data.unlocked, data.progress, data.progress_percent)
			grid.add_child(tile)


func _update_progress_label() -> void:
	if AchievementsManager:
		var unlocked: int = AchievementsManager.get_unlocked_count()
		var total: int = AchievementsManager.get_total_count()
		progress_label.text = tr("achievements_progress_format") % [unlocked, total]
	else:
		progress_label.text = ""


func _grab_initial_focus() -> void:
	if ControllerManager and ControllerManager.is_controller_mode():
		close_button.grab_focus.call_deferred()


func _on_close_pressed() -> void:
	close_requested.emit()
	queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
