extends Control
# Emitted when a level is selected
signal level_selected
# Emitted when back button is pressed
signal back_pressed

@onready var level_buttons_container: ItemList = %LevelButtonsContainer
@onready var back_button: Button = %BackButton

# Dictionary mapping level IDs to their display names
var levels = {
	0: "Tutorial",
	1: "First Day on the Job",
	2: "New Regulations",
	3: "Increasing Pressure",
	4: "Contraband Check",
	5: "Midpoint Crisis",
	6: "Increased Security",
	7: "Under Scrutiny",
	8: "Double Agents",
	9: "Border Chaos",
	10: "The Final Countdown"
}


func _ready() -> void:
	add_levels_to_container()
	# Debug initial shift value
	# REFACTORED: Use GameStateManager
	var current_shift = GameStateManager.get_shift() if GameStateManager else 1
	print("DEBUG: Initial shift value: ", current_shift)
	GlobalState.save()


func add_levels_to_container() -> void:
	# Clear existing buttons
	level_buttons_container.clear()

	# Ensure we have the latest unlock data by syncing
	var max_unlocked_level = GameState.get_max_level_reached()

	# Note: Level unlock syncing is now handled by GameState/SaveManager

	# Add levels to the container
	for level_id in range(levels.size()):
		var level_name = levels[level_id]

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

	# Debug what the level_id is
	print("DEBUG: Selected level_id: ", level_id)

	# Only proceed if the level is unlocked
	if level_id <= GameState.get_max_level_reached():
		# Print current shift value before changing anything
		var current_shift = GameStateManager.get_shift() if GameStateManager else 1
		print("DEBUG: Before change - shift value: ", current_shift)

		# Set the current level in GameState
		GameState.set_current_level(level_id)

		# Set the shift in the GameStateManager
		# REFACTORED: Use GameStateManager
		if GameStateManager:
			GameStateManager.set_shift(level_id)
		print("DEBUG: Set shift to: ", level_id)

		# Handle narrative choices for level select
		_handle_narrative_choices_for_level(level_id)

		# Update mode back to story mode
		# REFACTORED: Use GameStateManager
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
		# Has saved choices - restore them via Global
		Global.narrative_choices = saved_choices
		Global.restore_narrative_choices()
		print("Loaded saved narrative choices for level select: ", saved_choices.size(), " choices")
	elif level_id > 1:
		# Starting from a later level without save - set "committed ally" defaults
		# This gives the player the full experience
		var defaults = _get_default_choices_for_level(level_id)
		Global.narrative_choices = defaults
		Global.restore_narrative_choices()
		print("Set default narrative choices for level ", level_id, ": ", defaults.size(), " choices")


## Get sensible default choices for starting from a specific level
## These defaults create a "committed ally" playthrough
func _get_default_choices_for_level(level_id: int) -> Dictionary:
	var defaults = {}

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
