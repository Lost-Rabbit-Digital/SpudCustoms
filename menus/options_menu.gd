class_name OptionsMenu
extends Control

@onready var back_button = $MarginContainer/VBoxContainer/BackButton as Button

signal back_from_options_menu

func _ready():
	back_button.button_down.connect(on_back_button_pressed)
	set_process(false)

func on_back_button_pressed() -> void:
	back_from_options_menu.emit()
	set_process(false)
