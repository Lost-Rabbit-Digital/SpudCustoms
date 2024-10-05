extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://mainGame.tscn")

func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://menus/options_menu.tscn")

func _on_how_to_button_pressed():
	get_tree().change_scene_to_file("res://menus/how_to_play_menu.tscn")

func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://menus/confirmation_scene.tscn")
