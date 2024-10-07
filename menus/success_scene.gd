extends Control


func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://mainGame.tscn")


func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
