extends Control
# Emitted when a level is selected
signal level_selected
@onready var level_buttons_container: ItemList = %LevelButtonsContainer
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
	10: "The Last Shift",
	11: "Infiltration", 
	12: "Final Confrontation",
	13: "Facility Escape"
}

func _ready() -> void:
	add_levels_to_container()
	# Debug initial shift value in Global singleton
	print("DEBUG: Initial Global.shift value: ", Global.shift)
	GlobalState.save()

	
func add_levels_to_container() -> void:
	level_buttons_container.clear()
	var max_level_reached := GameState.get_max_level_reached()
	
	# Get all level IDs and sort them numerically
	var level_ids = levels.keys()
	level_ids.sort()
	
	for level_id in level_ids:
		# Format the display name with day number
		var display_name = "Day %d - %s" % [level_id, levels[level_id]]
		
		# Add the item to the ItemList
		var item_index = level_buttons_container.add_item(display_name)
		
		# Store the level ID as metadata for easy retrieval
		level_buttons_container.set_item_metadata(item_index, level_id)
		
		# Set visual state based on unlock status
		var is_unlocked = level_id <= max_level_reached
		level_buttons_container.set_item_disabled(item_index, !is_unlocked)
		
		# Visually distinguish locked levels
		if !is_unlocked:
			level_buttons_container.set_item_custom_fg_color(item_index, Color(0.5, 0.5, 0.5, 0.5))

func _on_level_buttons_container_item_activated(index: int) -> void:
	# Get the level ID from metadata
	var level_id = level_buttons_container.get_item_metadata(index)
	
	# Debug what the level_id is
	print("DEBUG: Selected level_id: ", level_id)
	
	# Only proceed if the level is unlocked
	if level_id <= GameState.get_max_level_reached():
		# Print current shift value before changing anything
		print("DEBUG: Before change - Global.shift value: ", Global.shift)
		
		# Set the current level in GameState
		GameState.set_current_level(level_id)
		
		# Set the shift in the Global singleton to match the level_id
		Global.shift = level_id
		print("DEBUG: Set Global.shift to: ", level_id)
		
		# Print value after the change to verify
		print("DEBUG: After change - Global.shift value: ", Global.shift)
		
		# Emit signal to inform parent that a level was selected
		level_selected.emit()
