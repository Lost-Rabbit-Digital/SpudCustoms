class_name MainMenu
extends Control

## Defines the path to the game scene. Hides the play button if empty.
@export_file("*.tscn") var story_game_scene_path: String
@export_file("*.tscn") var endless_game_scene_path: String
@export var options_packed_scene: PackedScene
@export var credits_packed_scene: PackedScene

var options_scene
var credits_scene
var sub_menu


func _ready():
	# Apply to all buttons in containers
	var button_containers = [
		$MenuContainer/MenuButtonsMargin/MenuButtonsContainer,
		%MenuButtonsBoxContainer,
		$MenuContainer/MenuButtonsMargin/MenuButtonsContainer/HBoxContainer
	]

	var hover_config = {
		"hover_scale": Vector2(1.05, 1.05),
		"hover_time": 0.1,
		"hover_sfx_path": "res://assets/user_interface/audio/hover_sound.mp3",
		"volume_db": -6.0
	}

	for container in button_containers:
		# Note that we're using the autoload without "static"
		JuicyButtons.enhance_all_buttons(container, hover_config)

	# Initialize cursor manager if it exists
	if Engine.has_singleton("CursorManager"):
		# Set initial cursor state
		CursorManager.set_cursor_state("default")

	# Continue with your other setup
	_setup_for_web()
	_setup_options()
	_setup_credits()
	_setup_game_buttons()

	# Setup keyboard navigation for accessibility
	_setup_keyboard_navigation()


func _exit_tree() -> void:
	# Kill any running tweens to prevent memory leaks
	JuicyButtons.kill_all_tweens(self)

	# Reset cursor manager state
	if Engine.has_singleton("CursorManager"):
		CursorManager.clear_hover_stack()
		CursorManager.set_cursor_state("default")


func _open_sub_menu(menu: Control):
	# Clear cursor hover state when switching UI contexts
	if Engine.has_singleton("CursorManager"):
		CursorManager.clear_hover_stack()

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


func _event_is_mouse_button_released(event: InputEvent):
	return event is InputEventMouseButton and not event.is_pressed()


func _input(event):
	# Override the current state to display a click
	if (
		event.is_action_pressed("ui_accept")
		or event.is_action_pressed("ui_select")
		or (
			event is InputEventMouseButton
			and event.pressed
			and event.button_index == MOUSE_BUTTON_LEFT
		)
	):
		CursorManager.override_cursor("click")

	if event.is_action_released("ui_cancel"):
		if sub_menu:
			_close_sub_menu()
		else:
			get_tree().quit()
	if event.is_action_released("ui_accept") and get_viewport().gui_get_focus_owner() == null:
		%MenuButtonsBoxContainer.focus_first()


## Setup keyboard navigation for accessibility.
## Ensures all visible buttons are focusable and properly linked.
func _setup_keyboard_navigation():
	# Get main menu button container
	var menu_buttons = get_node_or_null("%MenuButtonsBoxContainer")
	if not menu_buttons:
		return

	# Get all visible buttons
	var visible_buttons: Array[Button] = []
	for child in menu_buttons.get_children():
		if child is Button and child.visible:
			visible_buttons.append(child)
			# Ensure button can receive focus
			child.focus_mode = Control.FOCUS_ALL

	# Setup focus neighbors for vertical navigation
	for i in visible_buttons.size():
		var button = visible_buttons[i]

		# Previous button (wrap around)
		var prev_idx = i - 1 if i > 0 else visible_buttons.size() - 1
		button.focus_neighbor_top = visible_buttons[prev_idx].get_path()

		# Next button (wrap around)
		var next_idx = i + 1 if i < visible_buttons.size() - 1 else 0
		button.focus_neighbor_bottom = visible_buttons[next_idx].get_path()

		# Horizontal navigation loops back to same button
		button.focus_neighbor_left = button.get_path()
		button.focus_neighbor_right = button.get_path()

	# Set initial focus to first visible button after a short delay
	# (allows menu animations to complete first)
	if visible_buttons.size() > 0:
		_set_initial_focus.call_deferred(visible_buttons[0])


## Set initial focus after scene is ready.
func _set_initial_focus(button: Button):
	# Only grab focus if no other control has focus
	if get_viewport().gui_get_focus_owner() == null:
		button.grab_focus()


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


func _on_options_button_pressed():
	await JuicyButtons.setup_button(%OptionsButton)
	_open_sub_menu(options_scene)


func _on_credits_button_pressed():
	await JuicyButtons.setup_button(%CreditsButton)
	_open_sub_menu(credits_scene)
	credits_scene.reset()


func _on_exit_button_pressed():
	await JuicyButtons.setup_button(%ExitButton)
	get_tree().quit()


func _on_credits_end_reached():
	if sub_menu == credits_scene:
		_close_sub_menu()


func _on_back_button_pressed():
	await JuicyButtons.setup_button(%BackButton)
	_close_sub_menu()


func _on_discord_button_pressed() -> void:
	await JuicyButtons.setup_button(%DiscordButton, "https://discord.gg/Y7caBf7gBj")


func _on_blue_sky_heart_coded_button_pressed() -> void:
	await JuicyButtons.setup_button(
		%BlueSkyHeartCodedButton, "https://bsky.app/profile/heartcoded.bsky.social"
	)


func _on_blue_sky_boden_game_dev_button_pressed() -> void:
	await JuicyButtons.setup_button(
		%BlueSkyBodenGameDevButton, "https://bsky.app/profile/bodengamedev.bsky.social"
	)


func _on_feedback_button_pressed() -> void:
	await JuicyButtons.setup_button(%FeedbackButton, "https://forms.gle/SP3CFfJVrF3wNBFJ8")
