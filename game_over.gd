extends Control

var score = 0

func _ready():
	$MarginContainer/ScoreLabel.text = """You caused too much suffering and have been removed from your post.
	
	Your final score was 
	""" + str(score)


func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://mainGame.tscn")

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
