class_name MainMenu
extends Control

## Defines the path to the game scene. Hides the play button if empty.
@export_file("*.tscn") var story_game_scene_path : String
@export_file("*.tscn") var endless_game_scene_path : String
@export var options_packed_scene : PackedScene
@export var credits_packed_scene : PackedScene

var options_scene
var credits_scene
var sub_menu

func _open_sub_menu(menu : Control):
	sub_menu = menu
	sub_menu.show()
	%BackButton.show()
	%MenuContainer.hide()

func _close_sub_menu():
	if sub_menu == null:
		return
	sub_menu.hide()
	sub_menu = null
	%BackButton.hide()
	%MenuContainer.show()

func _event_is_mouse_button_released(event : InputEvent):
	return event is InputEventMouseButton and not event.is_pressed()

func _input(event):
	if event.is_action_released("ui_cancel"):
		if sub_menu:
			_close_sub_menu()
		else:
			get_tree().quit()
	if event.is_action_released("ui_accept") and get_viewport().gui_get_focus_owner() == null:
		%MenuButtonsBoxContainer.focus_first()

func _setup_for_web():
	if OS.has_feature("web"):
		%ExitButton.hide()

func _setup_game_buttons():
	if story_game_scene_path.is_empty():
		%NewGameButton.hide()

func _setup_options():
	if options_packed_scene == null:
		%OptionsButton.hide()
	else:
		options_scene = options_packed_scene.instantiate()
		options_scene.hide()
		%OptionsContainer.call_deferred("add_child", options_scene)

func _setup_credits():
	if credits_packed_scene == null:
		%CreditsButton.hide()
	else:
		credits_scene = credits_packed_scene.instantiate()
		credits_scene.hide()
		if credits_scene.has_signal("end_reached"):
			credits_scene.connect("end_reached", _on_credits_end_reached)
		%CreditsContainer.call_deferred("add_child", credits_scene)

func _ready():
	_setup_for_web()
	_setup_options()
	_setup_credits()
	_setup_game_buttons()

func _on_options_button_pressed():
	await apply_button_juice(%OptionsButton)
	_open_sub_menu(options_scene)

func _on_credits_button_pressed():
	await apply_button_juice(%CreditsButton)
	_open_sub_menu(credits_scene)
	credits_scene.reset()

func _on_exit_button_pressed():
	await apply_button_juice(%ExitButton)
	get_tree().quit()

func _on_credits_end_reached():
	if sub_menu == credits_scene:
		_close_sub_menu()

func _on_back_button_pressed():
	await apply_button_juice(%BackButton)
	_close_sub_menu()

func _on_discord_button_pressed() -> void:
	await apply_button_juice(%DiscordButton, "Hidden; Use copy button")

func _on_blue_sky_heart_coded_button_pressed() -> void:
	await apply_button_juice(%BlueSkyHeartCodedButton, "https://bsky.app/profile/heartcoded.bsky.social")


func _on_blue_sky_boden_game_dev_button_pressed() -> void:
	await apply_button_juice(%BlueSkyBodenGameDevButton, "https://bsky.app/profile/bodengamedev.bsky.social")

func _on_feedback_button_pressed() -> void:
	await apply_button_juice(%FeedbackButton, "https://docs.google.com/forms/d/1COq7e4ODVKL4HbWyhuthXT73FaxXd5YcBlJwtp6kPZY/edit")

## Applies a juicy animation effect to a button and optionally opens a URL.
##
## This function handles the entire animation sequence including shrinking,
## darkening, bouncing back, and then optionally opening a URL. The button
## will animate from its center for a polished effect.
##
## @param button The button control node to animate
## @param url The URL to open after animation completes (optional)
func apply_button_juice(button: Control, url: String = "") -> void:
	# Animation configuration variables
	var initial_shrink_scale := Vector2(0.8, 0.8)
	var initial_shrink_time := 0.1
	var initial_darken_color := Color(0.7, 0.7, 0.7, 1.0)
	var initial_darken_time := 0.1
	
	var bounce_scale := Vector2(1.1, 1.1)
	var bounce_time := 0.2
	
	var final_scale := Vector2(1.0, 1.0)
	var final_scale_time := 0.1
	var final_color := Color(1.0, 1.0, 1.0, 1.0)
	var final_color_time := 0.2
	
	# Ensure the button scales from its center
	button.pivot_offset = button.size / 2
	
	# Create a tween for smooth animations
	var tween = create_tween().set_parallel()
	
	# Initial shrink animation (quick)
	tween.tween_property(button, "scale", initial_shrink_scale, initial_shrink_time).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", initial_darken_color, initial_darken_time)
	
	# Chain a tween for the bounce-back animation
	tween.chain().tween_property(button, "scale", bounce_scale, bounce_time).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(button, "scale", final_scale, final_scale_time).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_property(button, "modulate", final_color, final_color_time)
	
	# Wait for animation to finish before opening the URL (if provided)
	await tween.finished
	
	# Only open the URL if one was provided
	if url.strip_edges() != "":
		OS.shell_open(url)
