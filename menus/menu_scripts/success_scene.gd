extends Control
var score = 0


func _ready():
	update_score_display()

	
func _process(_float) -> void:
	update_score_display()

func update_score_display():
	score = Global.final_score
	var win_statement = """You have successfully let %s permitted citizens into Spudorado.

You now have the choice to rejoin your family or work your next shift tomorrow.

Choose wisely, for you only have one life.""" % str(score)
	$MarginContainer/ScoreLabel.text = win_statement

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://mainGame.tscn")


func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
