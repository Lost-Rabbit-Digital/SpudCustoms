class_name HotkeyRebindButton
extends Control

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button


@export var action_name : String = "primary_interaction"

func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()
	
func set_action_name() -> void:
	label.text = "Unassigned"
	
	match action_name:
		"primary_interaction":
			label.text = "Primary Interaction"
		"secondary_interaction":
			label.text = "Seconday Interaction"
		"cancel_interaction":
			label.text = "Cancel Interaction"

func set_text_for_key() -> void:
	var action_events = InputMap.action_get_events(action_name)
	if action_events.size() > 0:
		var action_event = action_events[0]
		
		# Check the type of event and handle accordingly
		if action_event is InputEventKey:
			var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
			button.text = "%s" % action_keycode
		elif action_event is InputEventMouseButton:
			button.text = "Mouse %s" % action_event.button_index
		elif action_event is InputEventJoypadButton:
			button.text = "Joypad %s" % action_event.button_index
