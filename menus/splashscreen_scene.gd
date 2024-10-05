extends Control

func _on_slide_godot_finished():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
