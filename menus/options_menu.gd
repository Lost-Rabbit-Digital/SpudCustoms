extends Control

@onready var back_button = $MarginContainer/VBoxContainer/BackButton as Button

signal exit_options_menu

func _ready():
	back_button.button_down.connect(on_back_button_pressed)

func on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
