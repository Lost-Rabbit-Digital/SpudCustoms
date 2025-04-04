extends Control

@onready var difficulty_option_button = $VBoxContainer/DifficultyControl/OptionButton

func _ready():
	# Set up the difficulty option button
	if difficulty_option_button:
		# Clear any existing items
		difficulty_option_button.clear()
		
		# Add difficulty options
		difficulty_option_button.add_item("Easy")
		difficulty_option_button.add_item("Normal")
		difficulty_option_button.add_item("Expert")
		
		# Set current selection based on Global setting
		match Global.difficulty_level:
			"Easy":
				difficulty_option_button.select(0)
			"Normal":
				difficulty_option_button.select(1)
			"Expert":
				difficulty_option_button.select(2)
		
		# Connect signal
		difficulty_option_button.item_selected.connect(_on_difficulty_changed)

func _on_difficulty_changed(index):
	var difficulty = difficulty_option_button.get_item_text(index)
	Global.set_difficulty(difficulty)
	print("Difficulty changed to: ", difficulty)

func _on_ResetGameControl_reset_confirmed():
	GlobalState.reset()
