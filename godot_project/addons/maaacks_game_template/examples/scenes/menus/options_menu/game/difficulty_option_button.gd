extends OptionButton

func on_difficulty_selected(index):
	var difficulty = ""
	match index:
		0: difficulty = "Easy"
		1: difficulty = "Normal"  
		2: difficulty = "Expert"
	Global.difficulty_level = difficulty
	Global.set_difficulty(difficulty)
	Global.save_game_state()  # Save the selected difficulty
