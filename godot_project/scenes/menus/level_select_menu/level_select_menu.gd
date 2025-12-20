extends Control
# Emitted when a level is selected
signal level_selected
# Emitted when back button is pressed
signal back_pressed

@onready var level_buttons_container: ItemList = %LevelButtonsContainer
@onready var back_button: Button = %BackButton

## Reference to the narrative choice popup
var choice_info_popup: Window
var narrative_choice_display: NarrativeChoiceDisplay
var selected_level_id: int = -1

# Dictionary mapping level IDs to their translation keys
const LEVEL_NAME_KEYS: Dictionary = {
	0: "level_name_0",
	1: "level_name_1",
	2: "level_name_2",
	3: "level_name_3",
	4: "level_name_4",
	5: "level_name_5",
	6: "level_name_6",
	7: "level_name_7",
	8: "level_name_8",
	9: "level_name_9",
	10: "level_name_10"
}


## Gets the translated level name for a given level ID
func get_level_name(level_id: int) -> String:
	if LEVEL_NAME_KEYS.has(level_id):
		return tr(LEVEL_NAME_KEYS[level_id])
	return tr("continue_dialog_day").format({"day": level_id})


func _ready() -> void:
	add_levels_to_container()
	_setup_choice_info_popup()
	# Connect item selection change signal
	if not level_buttons_container.item_selected.is_connected(_on_level_selected):
		level_buttons_container.item_selected.connect(_on_level_selected)
	# Debug initial shift value
	# REFACTORED: Use GameStateManager
	var current_shift = GameStateManager.get_shift() if GameStateManager else 1
	print("DEBUG: Initial shift value: ", current_shift)
	GlobalState.save()


## Setup the popup window for showing narrative choices
func _setup_choice_info_popup() -> void:
	choice_info_popup = Window.new()
	choice_info_popup.title = tr("level_select_story_choices")
	choice_info_popup.size = Vector2i(480, 420)
	choice_info_popup.unresizable = true
	choice_info_popup.transient = true
	choice_info_popup.exclusive = true
	choice_info_popup.wrap_controls = true

	# Apply game theme
	var dialog_theme = load("res://assets/styles/confirmation_dialog_theme.tres")
	if dialog_theme:
		choice_info_popup.theme = dialog_theme

	# Create a PanelContainer with border styling matching the level select ItemList
	var panel_container = PanelContainer.new()
	panel_container.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Create a StyleBoxFlat that matches the ItemList panel style (2px border, 3px corner radius)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.25, 0.14, 0.06, 1)  # Dark brown background
	panel_style.set_border_width_all(2)  # Match ItemList's 2px border
	panel_style.border_color = Color(0.896599, 0.712161, 0.435342, 1)  # Gold border
	panel_style.set_corner_radius_all(3)  # Match ItemList's 3px corner radius
	panel_style.set_content_margin_all(4)
	panel_container.add_theme_stylebox_override("panel", panel_style)

	# Main container with margin
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 11)
	margin.add_theme_constant_override("margin_right", 11)
	margin.add_theme_constant_override("margin_top", 11)
	margin.add_theme_constant_override("margin_bottom", 11)

	var main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 10)

	# Header label
	var header_label = Label.new()
	header_label.name = "HeaderLabel"
	header_label.text = tr("level_select_choices_header").format({"day": 1})
	header_label.add_theme_font_size_override("font_size", 18)
	header_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	main_container.add_child(header_label)

	# Separator
	var sep = HSeparator.new()
	main_container.add_child(sep)

	# Narrative choice display
	var choice_display_scene = load("res://scenes/ui/narrative_choice_display.tscn")
	if choice_display_scene:
		narrative_choice_display = choice_display_scene.instantiate()
		narrative_choice_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
		main_container.add_child(narrative_choice_display)

	# Button container
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 20)

	var play_button = Button.new()
	play_button.name = "PlayButton"
	play_button.text = tr("level_select_play_day")
	play_button.custom_minimum_size = Vector2(140, 40)
	play_button.pressed.connect(_on_play_button_pressed)

	var close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = tr("level_select_close")
	close_button.custom_minimum_size = Vector2(100, 40)
	close_button.pressed.connect(_on_choice_popup_closed)

	button_container.add_child(play_button)
	button_container.add_child(close_button)
	main_container.add_child(button_container)

	margin.add_child(main_container)
	panel_container.add_child(margin)
	choice_info_popup.add_child(panel_container)
	add_child(choice_info_popup)

	# Hide the popup initially - Windows are visible by default in Godot 4
	choice_info_popup.hide()

	# Connect close request
	choice_info_popup.close_requested.connect(_on_choice_popup_closed)

	# Setup juicy hover effects for popup buttons
	_setup_popup_button_effects.call_deferred()


## Setup hover effects for popup buttons
func _setup_popup_button_effects() -> void:
	var hover_config = {
		"hover_scale": Vector2(1.03, 1.03),
		"hover_time": 0.1,
		"float_height": 2.0,
		"float_duration": 0.8,
		"bounce_factor": 0.8,
		"damping": 0.85,
		"wiggle_enabled": true,
		"wiggle_angle": 1.5,
		"wiggle_speed": 10.0
	}

	# Hierarchy: choice_info_popup -> panel_container -> margin -> main_container
	var panel_container = choice_info_popup.get_child(0)
	if not panel_container:
		return
	var margin = panel_container.get_child(0)
	if not margin:
		return
	var main_container = margin.get_child(0)
	if not main_container:
		return

	for child in main_container.get_children():
		if child is HBoxContainer:
			for button in child.get_children():
				if button is Button:
					JuicyButtons.setup_hover(button, hover_config)


## Handle when a level item is selected (single click)
func _on_level_selected(index: int) -> void:
	var level_id = level_buttons_container.get_item_metadata(index)

	# Only show popup for unlocked levels
	if level_id <= GameState.get_max_level_reached():
		selected_level_id = level_id
		_show_choice_info_popup(level_id)


## Show the choice info popup for a specific level
func _show_choice_info_popup(level_id: int) -> void:
	# Load saved narrative choices
	var game_state = SaveManager.load_game_state()
	var saved_choices = game_state.get("narrative_choices", {})

	# If no saved choices and level > 1, use defaults for display
	var display_choices = saved_choices
	if saved_choices.is_empty() and level_id > 1:
		display_choices = _get_default_choices_for_level(level_id)

	# Update header
	# Hierarchy: choice_info_popup -> panel_container -> margin -> main_container
	var panel_container = choice_info_popup.get_child(0)
	var margin = panel_container.get_child(0)
	var main_container = margin.get_child(0)
	var header_label = main_container.get_node("HeaderLabel")
	if header_label:
		var level_name = get_level_name(level_id)
		header_label.text = tr("level_select_choices_header_named").format({"day": level_id, "name": level_name})

	# Update the narrative choice display (show choices up to selected level)
	if narrative_choice_display:
		narrative_choice_display.display_choices(display_choices, level_id)

	# Show popup centered
	choice_info_popup.popup_centered()


## Handle popup close
func _on_choice_popup_closed() -> void:
	choice_info_popup.hide()


## Handle play button in popup
func _on_play_button_pressed() -> void:
	choice_info_popup.hide()
	if selected_level_id >= 0:
		_start_level(selected_level_id)


func add_levels_to_container() -> void:
	# Clear existing buttons
	level_buttons_container.clear()

	# Ensure we have the latest unlock data by syncing
	var max_unlocked_level = GameState.get_max_level_reached()

	# Note: Level unlock syncing is now handled by GameState/SaveManager

	# Add levels to the container
	for level_id in range(LEVEL_NAME_KEYS.size()):
		var level_name = get_level_name(level_id)

		# Check if the level is unlocked
		var is_unlocked = level_id <= max_unlocked_level

		# Add the level button
		var item_index = level_buttons_container.add_item(
			("%d - " % level_id) + level_name, null, is_unlocked  # Icon  # Selectable based on unlock status
		)

		# Set the item metadata to the level ID
		level_buttons_container.set_item_metadata(item_index, level_id)

		# Adjust item appearance based on unlock status
		if not is_unlocked:
			level_buttons_container.set_item_disabled(item_index, true)
			level_buttons_container.set_item_custom_fg_color(item_index, Color(0.5, 0.5, 0.5))


func _on_back_button_pressed() -> void:
	back_pressed.emit()


func _on_level_buttons_container_item_activated(index: int) -> void:
	# Get the level ID from metadata
	var level_id = level_buttons_container.get_item_metadata(index)

	# Only proceed if the level is unlocked
	if level_id <= GameState.get_max_level_reached():
		_start_level(level_id)


## Start playing a specific level
func _start_level(level_id: int) -> void:
	# Debug what the level_id is
	print("DEBUG: Starting level_id: ", level_id)

	# Print current shift value before changing anything
	var current_shift = GameStateManager.get_shift() if GameStateManager else 1
	print("DEBUG: Before change - shift value: ", current_shift)

	# Set the current level in GameState
	GameState.set_current_level(level_id)

	# Sync Global.shift to match the selected level
	# This ensures advance_shift() works correctly when replaying earlier levels
	if Global:
		Global.shift = level_id

	# Set the shift in the GameStateManager (source of truth)
	if GameStateManager:
		GameStateManager.set_shift(level_id)
	print("DEBUG: Set shift to: ", level_id)

	# Handle narrative choices for level select
	_handle_narrative_choices_for_level(level_id)

	# Update mode back to story mode
	if GameStateManager:
		GameStateManager.switch_game_mode("story")

	# Print value after the change to verify
	var new_shift = GameStateManager.get_shift() if GameStateManager else level_id
	print("DEBUG: After change - shift value: ", new_shift)

	# Emit signal to inform parent that a level was selected
	level_selected.emit()


## Handle narrative choices when starting from a specific level
## Loads saved choices if available, sets defaults for later levels
func _handle_narrative_choices_for_level(level_id: int) -> void:
	# First, try to load saved narrative choices
	var game_state = SaveManager.load_game_state()
	var saved_choices = game_state.get("narrative_choices", {})

	if not saved_choices.is_empty():
		# Has saved choices - store them in Global for later restoration
		# NOTE: Don't call restore_narrative_choices() here - Dialogic isn't ready yet.
		# NarrativeManager will restore these when the dialogue actually starts.
		Global.narrative_choices = saved_choices
		print("Stored saved narrative choices for level select: ", saved_choices.size(), " choices")
	elif level_id > 1:
		# Starting from a later level without save - set "committed ally" defaults
		# This gives the player the full experience
		var defaults = _get_default_choices_for_level(level_id)
		Global.narrative_choices = defaults
		print("Stored default narrative choices for level ", level_id, ": ", defaults.size(), " choices")


## Get sensible default choices for starting from a specific level
## These defaults create a "committed ally" playthrough
func _get_default_choices_for_level(level_id: int) -> Dictionary:
	var defaults = {}

	# Path tracking - build up pro_sasha_choice based on level
	# Each level adds ~1 point for a committed ally path
	var sasha_trust = mini(level_id, 10)
	defaults["pro_sasha_choice"] = sasha_trust
	defaults["loyalist_path"] = "no"
	defaults["chaos_agent"] = "no"
	defaults["chaos_points"] = 0

	# Level 2+: Shift 1 choices
	if level_id >= 2:
		defaults["initial_response"] = "questioning"
		defaults["note_reaction"] = "investigate"
		defaults["kept_note"] = "yes"

	# Level 3+: Shift 2 choices
	if level_id >= 3:
		defaults["murphy_trust"] = "open"
		defaults["eat_reserve"] = "refused"

	# Level 4+: Shift 3 choices
	if level_id >= 4:
		defaults["scanner_response"] = "questioning"
		defaults["family_response"] = "help"
		defaults["has_wife_photo"] = "yes"
		defaults["wife_name"] = "Maris Piper"
		defaults["reveal_reaction"] = "shocked"

	# Level 5+: Shift 4 choices
	if level_id >= 5:
		defaults["cafeteria_response"] = "serious"
		defaults["murphy_alliance"] = "ally"
		defaults["sasha_trust_level"] = "committed"

	# Level 6+: Shift 5 choices
	if level_id >= 6:
		defaults["sasha_investigation"] = "committed"
		defaults["loyalty_response"] = "idealistic"
		defaults["hide_choice"] = "desk"

	# Level 7+: Shift 6 choices
	if level_id >= 7:
		defaults["fellow_officer_response"] = "sympathetic"
		defaults["interrogation_response"] = "lie"
		defaults["viktor_conversation"] = "curious"
		defaults["scanner_choice"] = "viktor"
		defaults["helped_operative"] = "yes"
		defaults["viktor_allied"] = "yes"
		defaults["sasha_plan_response"] = "committed"

	# Level 8+: Shift 7 choices
	if level_id >= 8:
		defaults["resistance_mission"] = "committed"
		defaults["final_decision"] = "help"
		defaults["yellow_badge_response"] = "help"

	# Level 9+: Shift 8 choices
	if level_id >= 9:
		defaults["sasha_response"] = "concerned"
		defaults["interrogation_choice"] = "deny"
		defaults["sasha_arrest_reaction"] = "promise"
		defaults["murphy_final_alliance"] = "committed"

	# Level 10+: Shift 9 choices
	if level_id >= 10:
		defaults["critical_choice"] = "help"
		defaults["stay_or_go"] = "go"
		defaults["sasha_rescue_reaction"] = "relieved"

	return defaults
