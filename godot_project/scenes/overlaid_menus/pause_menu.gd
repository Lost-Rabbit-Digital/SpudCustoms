class_name PauseMenu
extends OverlaidMenu

@export var options_packed_scene: PackedScene
@export var help_packed_scene: PackedScene
@export_file("*.tscn") var main_menu_scene: String

var popup_open
var _controller_hints_bar: ControllerHintsBar = null


func close_popup():
	if popup_open != null:
		popup_open.hide()
		popup_open = null


func _disable_focus():
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_NONE


func _enable_focus():
	for child in %MenuButtons.get_children():
		if child is Control:
			child.focus_mode = FOCUS_ALL
	# Ensure first button gets focus in controller mode
	_grab_initial_focus()


## Grab focus on first button when in controller mode
func _grab_initial_focus() -> void:
	if ControllerManager and ControllerManager.is_controller_mode():
		var first_button = %MenuButtons.get_child(0)
		if first_button and first_button is Button:
			first_button.grab_focus.call_deferred()


func _load_scene(scene_path: String):
	_scene_tree.paused = false
	SceneLoader.load_scene(scene_path)


func open_options_menu():
	var options_scene = options_packed_scene.instantiate()
	add_child(options_scene)
	_disable_focus.call_deferred()
	await options_scene.tree_exiting
	_enable_focus.call_deferred()


func open_help_menu():
	var help_scene = help_packed_scene.instantiate()
	add_child(help_scene)
	_disable_focus.call_deferred()
	await help_scene.tree_exiting
	_enable_focus.call_deferred()


func _handle_cancel_input():
	if popup_open != null:
		close_popup()
	else:
		super._handle_cancel_input()


func _setup_options():
	if options_packed_scene == null:
		%OptionsButton.hide()


func _setup_help():
	if help_packed_scene == null:
		%HelpButton.hide()


func _setup_main_menu():
	if main_menu_scene.is_empty():
		%MainMenuButton.hide()


func _ready():
	if OS.has_feature("web"):
		%ExitButton.hide()
	_setup_options()
	_setup_help()
	_setup_main_menu()
	_setup_controller_hints()
	_grab_initial_focus()


## Setup controller hints bar at bottom of menu
func _setup_controller_hints() -> void:
	_controller_hints_bar = ControllerHintsBar.new()
	_controller_hints_bar.show_select_hint = true
	_controller_hints_bar.show_back_hint = true
	_controller_hints_bar.name = "ControllerHints"

	# Add at bottom of menu
	var margin = MarginContainer.new()
	margin.name = "ControllerHintsMargin"
	margin.add_theme_constant_override("margin_top", 16)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(_controller_hints_bar)

	# Find MenuButtons parent and add after it
	var menu_box = %MenuButtons.get_parent().get_parent()
	if menu_box is BoxContainer:
		menu_box.add_child(margin)


func _on_restart_button_pressed():
	%ConfirmRestart.popup_centered()
	popup_open = %ConfirmRestart


func _on_options_button_pressed():
	open_options_menu()


func _on_help_button_pressed():
	open_help_menu()


func _on_main_menu_button_pressed():
	%ConfirmMainMenu.popup_centered()
	popup_open = %ConfirmMainMenu


func _on_exit_button_pressed():
	%ConfirmExit.popup_centered()
	popup_open = %ConfirmExit


func _on_confirm_restart_confirmed():
	# REFACTORED: Use EventBus
	EventBus.shift_stats_reset.emit()
	SceneLoader.reload_current_scene()
	close()


func _on_confirm_main_menu_confirmed():
	print("Main menu confirmed, loading scene")
	# REFACTORED: Use EventBus
	EventBus.shift_stats_reset.emit()

	# FIXED: End Dialogic timeline cleanly before scene change
	# This prevents music from stopping when Dialogic's cleanup triggers
	if Dialogic.current_timeline:
		Dialogic.Audio.stop_all_one_shot_sounds()
		Dialogic.end_timeline()

	get_tree().change_scene_to_file("res://scenes/menus/main_menu/main_menu_with_animations.tscn")
	close()


func _on_confirm_exit_confirmed():
	get_tree().quit()
