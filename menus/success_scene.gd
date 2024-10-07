extends Control
var score = 0
var win_statement = """You have successfully let %s permitted citizens into Spudorado.

You now have the choice to rejoin your family or work your next shift tomorrow.

Choose wisely, for you only have one life.""" % str(score)

func _ready():
	$MarginContainer/ScoreLabel.text = win_statement
	
func _process(float) -> void:
	$MarginContainer/ScoreLabel.text = win_statement

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://mainGame.tscn")


func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
