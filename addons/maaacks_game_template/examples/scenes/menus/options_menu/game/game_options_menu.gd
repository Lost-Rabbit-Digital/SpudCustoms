extends Control

func _on_ResetGameControl_reset_confirmed():
	GameLevelLog.reset_game_data()
	
func _ready():
	Global.load_game_state()
	var dropdown = $VBoxContainer/OptionButton # Replace with actual node path
	match Global.difficulty_level:
		"Easy": dropdown.select(0)
		"Normal": dropdown.select(1)
		"Expert": dropdown.select(2)
