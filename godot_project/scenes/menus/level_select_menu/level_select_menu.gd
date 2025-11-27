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
	10: "The Final Countdown"
}

# Add a new variable to store UI labels for high scores
var high_score_labels = []


func _ready() -> void:
	add_levels_to_container()
	# Debug initial shift value
	# REFACTORED: Use GameStateManager
	var current_shift = GameStateManager.get_shift() if GameStateManager else 1
	print("DEBUG: Initial shift value: ", current_shift)
	GlobalState.save()


func add_levels_to_container() -> void:
	# Clear existing buttons and high score labels
	level_buttons_container.clear()
	for label in high_score_labels:
		if is_instance_valid(label):
			label.queue_free()
	high_score_labels.clear()

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

		# Add high score label if level is unlocked
		if is_unlocked:
			add_high_score_label(item_index, level_id)


func add_high_score_label(item_index: int, level_id: int) -> void:
	# Create high score label
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))

	# Store reference to item index and level id
	label.set_meta("item_index", item_index)
	label.set_meta("level_id", level_id)

	# Add to the scene
	add_child(label)
	high_score_labels.append(label)

	# Update the label
	update_high_score_label(label)

	# Connect to draw signal to ensure labels stay in the right position
	if not is_connected("draw", Callable(self, "_update_high_score_positions")):
		connect("draw", Callable(self, "_update_high_score_positions"))


func update_high_score_label(label: Label) -> void:
	var level_id = label.get_meta("level_id")

	# Try to get high score from multiple sources to ensure we use the highest value
	var high_score = 0

	# REFACTORED: Use GameStateManager
	var diff_level = GameStateManager.get_difficulty() if GameStateManager else "Normal"
	high_score = GameState.get_high_score(level_id, diff_level)

	# Try SaveManager as fallback or to find a higher score
	if SaveManager.has_method("get_level_high_score"):
		var save_manager_score = SaveManager.get_level_high_score(level_id, diff_level)
		high_score = max(high_score, save_manager_score)

	# Update text if there's a high score
	if high_score > 0:
		label.text = "High: " + format_score(high_score)
	else:
		label.text = ""


# Format score with commas
func format_score(value: int) -> String:
	var str_value = str(value)
	var formatted = ""
	var count = 0

	for i in range(str_value.length() - 1, -1, -1):
		if count == 3:
			formatted = "," + formatted
			count = 0
		formatted = str_value[i] + formatted
		count += 1

	return formatted


func _update_high_score_positions() -> void:
	# Only proceed if the container exists
	if not is_instance_valid(level_buttons_container):
		return

	# Update the position of all high score labels
	for label in high_score_labels:
		if is_instance_valid(label):
			var item_index = label.get_meta("item_index")

			# Calculate the proper position
			var item_rect = level_buttons_container.get_item_rect(item_index)

			# Position the label to the right of the item, aligned with its text
			label.position = Vector2(
				level_buttons_container.global_position.x + level_buttons_container.size.x - 200,
				(
					level_buttons_container.global_position.y
					+ item_rect.position.y
					+ (item_rect.size.y / 2)
					- 10
				)
			)

			# Set appropriate size
			label.size = Vector2(180, 20)


# Function to update all high score labels with new difficulty
func update_high_scores_display(difficulty: String = "") -> void:
	if difficulty == "":
		difficulty = GameStateManager.get_difficulty() if GameStateManager else "Normal"
	for label in high_score_labels:
		if is_instance_valid(label):
			update_high_score_label(label)


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

		# Update mode back to story mode
		# REFACTORED: Use GameStateManager
		if GameStateManager:
			GameStateManager.switch_game_mode("story")

		# Print value after the change to verify
		var new_shift = GameStateManager.get_shift() if GameStateManager else level_id
		print("DEBUG: After change - shift value: ", new_shift)

		# Emit signal to inform parent that a level was selected
		level_selected.emit()
