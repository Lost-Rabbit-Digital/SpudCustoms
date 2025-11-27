extends Node

## TutorialManager
## Manages interactive tutorial system, tracks completion, and provides dynamic tutorial triggers
## Replaces screenshot-based Dialogic tutorial with in-game contextual tutorials

# Signals for tutorial events
signal tutorial_started(tutorial_id: String)
signal tutorial_step_completed(tutorial_id: String, step_index: int)
signal tutorial_completed(tutorial_id: String)
signal tutorial_skipped(tutorial_id: String)

# Tutorial state tracking
var tutorials_completed: Dictionary = {}  # {tutorial_id: bool}
var current_tutorial: String = ""
var current_step: int = 0
var tutorial_enabled: bool = true
var can_skip_tutorials: bool = false

# Tutorial definitions
const TUTORIALS = {
	"gate_control": {
		"name": "Opening Your Booth",
		"steps": [
			{
				"text": "Click the lever to open your booth for service",
				"target": "booth_lever",
				"highlight": true,
				"wait_for_action": "lever_pulled"
			}
		],
		"shift_trigger": 1
	},
	"megaphone_call": {
		"name": "Calling Potatoes",
		"steps": [
			{
				"text": "Click the megaphone to call the next potato to your booth",
				"target": "megaphone",
				"highlight": true,
				"wait_for_action": "megaphone_clicked"
			}
		],
		"shift_trigger": 1
	},
	"document_inspection": {
		"name": "Inspecting Documents",
		"steps": [
			{
				"text": "Drag the passport from the booth to the inspection table",
				"target": "inspection_table",
				"highlight": true,
				"wait_for_action": "document_dragged"
			},
			{
				"text": "Read the document carefully and check for discrepancies",
				"target": "passport",
				"highlight": false,
				"duration": 3.0
			}
		],
		"shift_trigger": 1
	},
	"stamp_usage": {
		"name": "Stamping Documents",
		"steps": [
			{
				"text": "Click the stamp bar to reveal the approval and rejection stamps",
				"target": "stamp_bar",
				"highlight": true,
				"wait_for_action": "stamp_bar_opened"
			},
			{
				"text": "Drag the document under the green stamp to approve, or red stamp to reject",
				"target": "stamp_area",
				"highlight": true,
				"wait_for_action": "document_moved_to_stamp"
			},
			{
				"text": "Click the stamp to mark the document",
				"target": "stamp",
				"highlight": true,
				"wait_for_action": "stamp_clicked"
			},
			{
				"text": "Return the stamped document to the potato to complete processing",
				"target": "booth_area",
				"highlight": true,
				"wait_for_action": "document_returned"
			}
		],
		"shift_trigger": 1
	},
	"border_runners": {
		"name": "Stopping Border Runners",
		"steps": [
			{
				"text": "Watch for potatoes with exclamation marks - they're about to run!",
				"target": "border_wall",
				"highlight": false,
				"duration": 2.0
			},
			{
				"text": "Click on running potatoes to launch missiles and stop them",
				"target": "runner_potato",
				"highlight": true,
				"wait_for_action": "missile_launched"
			},
			{
				"text": "Be careful! Killing approved potatoes results in strikes",
				"target": null,
				"highlight": false,
				"duration": 2.5
			}
		],
		"shift_trigger": 1
	},
	"rules_checking": {
		"name": "Following Immigration Rules",
		"steps": [
			{
				"text": "Check the rules panel for today's immigration requirements",
				"target": "rules_panel",
				"highlight": true,
				"duration": 3.0
			},
			{
				"text": "Compare document information against the active rules",
				"target": "rules_panel",
				"highlight": false,
				"duration": 2.0
			}
		],
		"shift_trigger": 2
	},
	"xray_scanner": {
		"name": "X-Ray Scanning",
		"steps": [
			{
				"text": "Click the X-ray button to scan potatoes for hidden items",
				"target": "xray_button",
				"highlight": true,
				"wait_for_action": "xray_activated"
			},
			{
				"text": "Look for contraband or resistance messages inside potatoes",
				"target": "potato_display",
				"highlight": true,
				"duration": 3.0
			}
		],
		"shift_trigger": 3
	}
}

# Active tutorial overlay
var tutorial_overlay: Control = null
var highlight_rect: ColorRect = null
var tutorial_label: Label = null


func _ready():
	load_tutorial_progress()


## Load tutorial completion state from save
func load_tutorial_progress():
	if SaveManager:
		var save_data = SaveManager.load_game()
		if save_data and save_data.has("tutorials_completed"):
			tutorials_completed = save_data["tutorials_completed"]
		if save_data and save_data.has("tutorial_enabled"):
			tutorial_enabled = save_data["tutorial_enabled"]


## Save tutorial completion state
func save_tutorial_progress():
	if SaveManager:
		var save_data = SaveManager.load_game()
		if not save_data:
			save_data = {}
		save_data["tutorials_completed"] = tutorials_completed
		save_data["tutorial_enabled"] = tutorial_enabled
		SaveManager.save_game(save_data)


## Check if a tutorial should trigger for the current shift
func check_shift_tutorials(shift_number: int):
	if not tutorial_enabled:
		return

	for tutorial_id in TUTORIALS:
		var tutorial = TUTORIALS[tutorial_id]
		if tutorial.get("shift_trigger", 0) == shift_number:
			if not is_tutorial_completed(tutorial_id):
				start_tutorial(tutorial_id)
				return  # Only one tutorial at a time


## Start a tutorial
func start_tutorial(tutorial_id: String):
	if not tutorial_id in TUTORIALS:
		push_error("Tutorial not found: " + tutorial_id)
		return

	if is_tutorial_completed(tutorial_id):
		return  # Already completed

	current_tutorial = tutorial_id
	current_step = 0

	tutorial_started.emit(tutorial_id)

	# Show first step
	show_tutorial_step()


## Show current tutorial step
func show_tutorial_step():
	if current_tutorial == "":
		return

	var tutorial = TUTORIALS[current_tutorial]
	if current_step >= tutorial["steps"].size():
		complete_tutorial()
		return

	var step = tutorial["steps"][current_step]

	# Create or update tutorial overlay
	create_tutorial_overlay(step)


## Create tutorial overlay UI
func create_tutorial_overlay(step: Dictionary):
	# Clean up existing overlay
	if tutorial_overlay:
		tutorial_overlay.queue_free()

	# Create new overlay
	tutorial_overlay = Control.new()
	tutorial_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_PASS  # Allow clicks through
	get_tree().root.add_child(tutorial_overlay)

	# Create semi-transparent background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.5)
	bg.mouse_filter = Control.MOUSE_FILTER_PASS
	tutorial_overlay.add_child(bg)

	# Create highlight area if target specified
	if step.get("highlight", false) and step.get("target"):
		create_highlight_area(step["target"])

	# Create tutorial text label
	tutorial_label = Label.new()
	tutorial_label.text = step["text"]
	tutorial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tutorial_label.add_theme_font_size_override("font_size", 24)
	tutorial_label.add_theme_color_override("font_color", Color.WHITE)

	# Position label at top of screen
	tutorial_label.position = Vector2(
		get_viewport().get_visible_rect().size.x / 2 - 200, 50
	)
	tutorial_label.custom_minimum_size = Vector2(400, 80)
	tutorial_overlay.add_child(tutorial_label)

	# Add skip button if allowed
	if can_skip_tutorials:
		add_skip_button()

	# Handle step duration or wait for action
	if step.has("duration"):
		await get_tree().create_timer(step["duration"]).timeout
		advance_tutorial_step()
	# Otherwise, wait for action signal (handled by trigger_tutorial_action)


## Create highlight area around target element
func create_highlight_area(target_name: String):
	highlight_rect = ColorRect.new()
	highlight_rect.color = Color(1, 1, 0, 0.3)  # Yellow semi-transparent

	# Try to find the target node in the scene
	var target_node = _find_target_node(target_name)

	if target_node:
		# Position and size based on actual target node
		var target_rect = _get_node_global_rect(target_node)
		if target_rect.size.x > 0 and target_rect.size.y > 0:
			# Add padding around the highlight
			var padding = 8.0
			highlight_rect.global_position = target_rect.position - Vector2(padding, padding)
			highlight_rect.size = target_rect.size + Vector2(padding * 2, padding * 2)
		else:
			# Fallback: center on the node with default size
			highlight_rect.global_position = target_node.global_position - Vector2(50, 50)
			highlight_rect.size = Vector2(100, 100)
	else:
		# Fallback: centered placeholder highlight
		var viewport_size = get_viewport().get_visible_rect().size
		highlight_rect.position = viewport_size / 2 - Vector2(75, 75)
		highlight_rect.size = Vector2(150, 150)

	tutorial_overlay.add_child(highlight_rect)


## Find a target node by name in the current scene.
## Searches through common groups and node paths.
func _find_target_node(target_name: String) -> Node:
	var scene = get_tree().current_scene
	if not scene:
		return null

	# Try direct find by name
	var node = scene.find_child(target_name, true, false)
	if node:
		return node

	# Try finding by group (targets might be in groups)
	var group_name = target_name.replace("_", "")
	var nodes_in_group = get_tree().get_nodes_in_group(group_name)
	if nodes_in_group.size() > 0:
		return nodes_in_group[0]

	# Try common path patterns for game elements
	var common_paths = [
		"Gameplay/InteractiveElements/%s" % target_name,
		"Gameplay/%s" % target_name,
		"UI/%s" % target_name,
		"HUD/%s" % target_name
	]

	for path in common_paths:
		node = scene.get_node_or_null(path)
		if node:
			return node

	return null


## Get the global rectangle of a node for highlighting.
func _get_node_global_rect(node: Node) -> Rect2:
	# Handle Control nodes
	if node is Control:
		return Rect2(node.global_position, node.size)

	# Handle Sprite2D nodes
	if node is Sprite2D:
		var texture = node.texture
		if texture:
			var size = texture.get_size() * node.scale
			var pos = node.global_position
			if node.centered:
				pos -= size / 2
			return Rect2(pos, size)

	# Handle Node2D with custom size property
	if node is Node2D and node.has_method("get_rect"):
		var rect = node.get_rect()
		return Rect2(node.global_position + rect.position, rect.size)

	# Fallback: use position with default size
	if node is Node2D:
		return Rect2(node.global_position - Vector2(40, 40), Vector2(80, 80))

	return Rect2()


## Add skip tutorial button
func add_skip_button():
	var skip_button = Button.new()
	skip_button.text = "Skip Tutorial"
	skip_button.position = Vector2(
		get_viewport().get_visible_rect().size.x - 150, 20
	)
	skip_button.pressed.connect(skip_current_tutorial)
	tutorial_overlay.add_child(skip_button)


## Trigger tutorial action completion (called from game code)
func trigger_tutorial_action(action_name: String):
	if current_tutorial == "":
		return

	var tutorial = TUTORIALS[current_tutorial]
	if current_step >= tutorial["steps"].size():
		return

	var step = tutorial["steps"][current_step]
	if step.get("wait_for_action") == action_name:
		advance_tutorial_step()


## Advance to next tutorial step
func advance_tutorial_step():
	tutorial_step_completed.emit(current_tutorial, current_step)
	current_step += 1
	show_tutorial_step()


## Complete current tutorial
func complete_tutorial():
	if current_tutorial == "":
		return

	tutorials_completed[current_tutorial] = true
	tutorial_completed.emit(current_tutorial)

	# Clean up overlay
	if tutorial_overlay:
		tutorial_overlay.queue_free()
		tutorial_overlay = null

	current_tutorial = ""
	current_step = 0

	save_tutorial_progress()


## Skip current tutorial
func skip_current_tutorial():
	if current_tutorial == "":
		return

	tutorial_skipped.emit(current_tutorial)

	# Clean up overlay
	if tutorial_overlay:
		tutorial_overlay.queue_free()
		tutorial_overlay = null

	current_tutorial = ""
	current_step = 0


## Check if tutorial is completed
func is_tutorial_completed(tutorial_id: String) -> bool:
	return tutorials_completed.get(tutorial_id, false)


## Enable or disable tutorials globally
func set_tutorials_enabled(enabled: bool):
	tutorial_enabled = enabled
	save_tutorial_progress()


## Mark tutorial as completed (for debug/testing)
func mark_tutorial_completed(tutorial_id: String):
	tutorials_completed[tutorial_id] = true
	save_tutorial_progress()


## Reset all tutorial progress
func reset_all_tutorials():
	tutorials_completed.clear()
	current_tutorial = ""
	current_step = 0
	save_tutorial_progress()


## Get completion percentage
func get_tutorial_completion_percentage() -> float:
	var total = TUTORIALS.size()
	var completed = 0
	for tutorial_id in TUTORIALS:
		if is_tutorial_completed(tutorial_id):
			completed += 1
	return (float(completed) / float(total)) * 100.0 if total > 0 else 0.0
