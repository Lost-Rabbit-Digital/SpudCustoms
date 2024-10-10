extends Control


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
