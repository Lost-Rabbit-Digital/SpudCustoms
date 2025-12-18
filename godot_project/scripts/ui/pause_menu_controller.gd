class_name PauseMenuController
extends Node

## Node for opening a pause menu when detecting a 'ui_cancel' event.
## Wraps the pause menu in a high-layer CanvasLayer to ensure visibility
## above cutscene layers (Dialogic, post-processing, skip button).

@export var pause_menu_packed: PackedScene
@export var focused_viewport: Viewport

## CanvasLayer used to render pause menu above cutscene layers
var _pause_menu_layer: CanvasLayer = null


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if not focused_viewport:
			focused_viewport = get_viewport()
		var initial_focus_control = focused_viewport.gui_get_focus_owner()
		var current_menu = pause_menu_packed.instantiate()

		# Create a high-layer CanvasLayer to ensure pause menu is visible
		# above cutscene layers (Dialogic, post-processing at 50, skip button at 100)
		_pause_menu_layer = CanvasLayer.new()
		_pause_menu_layer.name = "PauseMenuLayer"
		_pause_menu_layer.layer = 110  # Above skip button (100) and all cutscene layers
		_pause_menu_layer.add_child(current_menu)

		# Add to root viewport for consistent rendering
		get_tree().root.call_deferred("add_child", _pause_menu_layer)

		await current_menu.tree_exited

		# Clean up the layer when menu closes
		if is_instance_valid(_pause_menu_layer):
			_pause_menu_layer.queue_free()
			_pause_menu_layer = null

		if is_inside_tree() and initial_focus_control:
			initial_focus_control.grab_focus()
