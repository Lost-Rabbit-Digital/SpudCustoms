class_name HotkeyRebindButton
extends Control

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button


@export var action_name : String = "primary_interaction"

func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()

func set_action_name() -> void:
	label.text = "Unassigned"
	
	match action_name:
		"primary_interaction":
			label.text = "Primary Interaction"
		"secondary_interaction":
			label.text = "Seconday Interaction"
