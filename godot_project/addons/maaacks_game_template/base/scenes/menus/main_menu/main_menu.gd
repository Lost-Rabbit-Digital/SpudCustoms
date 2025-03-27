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
	# In your _ready() function
	for button in %MenuButtonsBoxContainer.get_children():
		if button is BaseButton:  # This will match all buttons that inherit from BaseButton
			button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
			button.mouse_exited.connect(_on_button_mouse_exited.bind(button))

	
	_setup_for_web()
	_setup_options()
	_setup_credits()
	_setup_game_buttons()

func _on_options_button_pressed():
	await setup_juicy_button(%OptionsButton)
	_open_sub_menu(options_scene)

func _on_credits_button_pressed():
	await setup_juicy_button(%CreditsButton)
	_open_sub_menu(credits_scene)
	credits_scene.reset()

func _on_exit_button_pressed():
	await setup_juicy_button(%ExitButton)
	get_tree().quit()

func _on_credits_end_reached():
	if sub_menu == credits_scene:
		_close_sub_menu()

func _on_back_button_pressed():
	await setup_juicy_button(%BackButton)
	_close_sub_menu()

func _on_discord_button_pressed() -> void:
	await setup_juicy_button(%DiscordButton, "Hidden; Use copy button")

func _on_blue_sky_heart_coded_button_pressed() -> void:
	await setup_juicy_button(%BlueSkyHeartCodedButton, "https://bsky.app/profile/heartcoded.bsky.social")


func _on_blue_sky_boden_game_dev_button_pressed() -> void:
	await setup_juicy_button(%BlueSkyBodenGameDevButton, "https://bsky.app/profile/bodengamedev.bsky.social")

func _on_feedback_button_pressed() -> void:
	await setup_juicy_button(%FeedbackButton, "https://docs.google.com/forms/d/1COq7e4ODVKL4HbWyhuthXT73FaxXd5YcBlJwtp6kPZY/edit")

# Define your handler functions
func _on_button_mouse_entered(button: BaseButton) -> void:
	var button_hover_sfx_path := "res://assets/user_interface/audio/click_sound_5.mp3"
	
	# Ensure the button scales from its center
	button.pivot_offset = button.size / 2
	
	# Play button down sound
	var button_down_player := AudioStreamPlayer.new()
	add_child(button_down_player)
	button_down_player.stream = load(button_hover_sfx_path)
	button_down_player.volume_db = -6.0
	button_down_player.bus = "SFX"
	button_down_player.finished.connect(func(): button_down_player.queue_free())
	button_down_player.play()
	
	pass
	# Handle mouse enter for any button
	# Your hover effect code here

func _on_button_mouse_exited(button: BaseButton) -> void:
	# Handle mouse exit for any button
	
	# Reset scale and appearance to normal
	var normal_scale := Vector2(1.0, 1.0)
	var normal_time := 0.1
	var normal_color := Color(1.0, 1.0, 1.0, 1.0)
	
	# Ensure the button scales from its center
	button.pivot_offset = button.size / 2
	
	# Create a tween for returning to normal
	var tween = create_tween().set_parallel()
	tween.tween_property(button, "scale", normal_scale, normal_time).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", normal_color, normal_time)

func setup_juicy_button(button: Control, url: String = "") -> Signal:
	# Animation configuration variables
	var initial_shrink_scale := Vector2(0.8, 0.8)
	var initial_shrink_time := 0.1
	var initial_darken_color := Color(0.7, 0.7, 0.7, 1.0)
	
	var bounce_scale := Vector2(1.1, 1.1)
	var bounce_time := 0.2
	
	var final_scale := Vector2(1.0, 1.0)
	var final_scale_time := 0.1
	var final_color := Color(1.0, 1.0, 1.0, 1.0)
	
	# Sound effect paths
	var button_down_sfx_path := "res://assets/user_interface/audio/click_sound_4.mp3"
	
	# Ensure the button scales from its center
	button.pivot_offset = button.size / 2
	
	# Play button down sound
	var button_down_player := AudioStreamPlayer.new()
	add_child(button_down_player)
	button_down_player.stream = load(button_down_sfx_path)
	button_down_player.volume_db = -6.0
	button_down_player.bus = "SFX"
	button_down_player.finished.connect(func(): button_down_player.queue_free())
	button_down_player.play()
	
	# Create press animation tween
	var tween = create_tween().set_parallel()
	
	# Initial shrink animation
	tween.tween_property(button, "scale", initial_shrink_scale, initial_shrink_time).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "modulate", initial_darken_color, initial_shrink_time)
	
	# Play button up sound at the bounce stage
	var bounce_tween = tween.chain()
	bounce_tween.tween_property(button, "scale", bounce_scale, bounce_time).set_ease(Tween.EASE_OUT)
	
	# Complete the animation
	bounce_tween.chain().tween_property(button, "scale", final_scale, final_scale_time).set_ease(Tween.EASE_IN_OUT)
	bounce_tween.chain().tween_property(button, "modulate", final_color, final_scale_time)
	
	# Open URL if provided
	if url.strip_edges() != "":
		tween.finished.connect(func(): OS.shell_open(url))
	
	# Return the tween's finished signal directly
	return tween.finished
