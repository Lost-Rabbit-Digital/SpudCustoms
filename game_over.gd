extends Control
var score = 0

func _ready():
	$MarginContainer/ScoreLabel.text = """You caused too much suffering and have been removed from your post. You ultimately helped """ + str(Global.final_score) + " potatoes find their way to safety."

func _on_restart_button_pressed():
	score = 0
	Global.final_score = 0
	get_tree().change_scene_to_file("res://mainGame.tscn")

func _on_quit_button_pressed():
	score = 0
	Global.final_score = 0
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
