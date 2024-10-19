extends HBoxContainer

var is_game_muted = false
var is_fullscreen = false

var master_bus = AudioServer.get_bus_index("Master")

func _on_mute_button_toggled(_toggled_on):
	if MuteFullscreenMenuButtons.is_game_muted == false:
		MuteFullscreenMenuButtons.is_game_muted = true
		AudioServer.set_bus_mute(master_bus, is_game_muted)
		$MuteButton.texture_normal = preload("res://assets/ui_buttons/muted_button.png")
		$MuteButton.texture_pressed = preload("res://assets/ui_buttons/muted_button_pressed.png")
		$MuteButton.texture_hover = preload("res://assets/ui_buttons/muted_button_highlighted.png")
	else:
		MuteFullscreenMenuButtons.is_game_muted = false
		AudioServer.set_bus_mute(master_bus, is_game_muted)
		$MuteButton.texture_normal = preload("res://assets/ui_buttons/not_muted_button.png")
		$MuteButton.texture_pressed = preload("res://assets/ui_buttons/not_muted_button_pressed.png")
		$MuteButton.texture_hover = preload("res://assets/ui_buttons/not_muted_button_highlighted.png")
	

func _on_fullscreen_button_toggled(_toggled_on):
	if MuteFullscreenMenuButtons.is_fullscreen == false:
		MuteFullscreenMenuButtons.is_fullscreen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		MuteFullscreenMenuButtons.is_fullscreen = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
