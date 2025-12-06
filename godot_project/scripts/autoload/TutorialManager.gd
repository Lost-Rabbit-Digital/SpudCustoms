extends Node

## TutorialManager
## Manages interactive tutorial system with shader-based highlighting
## Guides players through gameplay mechanics step-by-step

# Signals for tutorial events
signal tutorial_started(tutorial_id: String)
signal tutorial_step_changed(tutorial_id: String, step_index: int)
signal tutorial_step_completed(tutorial_id: String, step_index: int)
signal tutorial_completed(tutorial_id: String)
signal tutorial_skipped(tutorial_id: String)

# Tutorial state tracking
var tutorials_completed: Dictionary = {}  # {tutorial_id: bool}
var current_tutorial: String = ""
var current_step: int = 0
var tutorial_enabled: bool = true
var can_skip_tutorials: bool = true

# Highlight shader material
var highlight_shader: ShaderMaterial = null
var highlighted_nodes: Array[Node] = []
var original_materials: Dictionary = {}  # {node_id: original_material}

# Tutorial UI elements
var tutorial_panel: PanelContainer = null
var tutorial_label: RichTextLabel = null
var skip_button: Button = null
var continue_hint_label: Label = null
var progress_label: Label = null

# Step timing
var step_timer: Timer = null
var waiting_for_action: bool = false
var waiting_for_click: bool = false  # Waiting for user to click to continue

# Tutorial definitions with expanded, friendly dialogue
# Tutorial definitions - text uses placeholders for controller-aware prompts
# {interact} = Click / Press RT, {drag} = Drag / Use Left Stick
const TUTORIALS = {
	"welcome": {
		"name": "Welcome to Spud Customs",
		"steps": [
			{
				"text": "[center][b]Welcome to Spud Customs![/b][/center]\n\nYour job is to process incoming potatoes at the border checkpoint. Let's learn the basics!",
				"target": null,
				"highlight": false,
				"duration": 4.0,
				"pause_game": false
			}
		],
		"shift_trigger": 1,
		"priority": 0
	},
	"gate_control": {
		"name": "Opening the Gate",
		"steps": [
			{
				"text": "[center][b]Opening Your Booth[/b][/center]\n\nSee that lever? {interact} it to raise the shutter and open your booth for business!\n\n[color=yellow]{interact} the lever now.[/color]",
				"target": "ShutterLever",
				"highlight": true,
				"wait_for_action": "lever_pulled",
				"pause_game": false
			},
			{
				"text": "[center][b]Great job![/b][/center]\n\nYour booth is now open. Potatoes in the queue can see you're ready for service.",
				"target": null,
				"highlight": false,
				"duration": 2.5,
				"pause_game": false
			}
		],
		"shift_trigger": 1,
		"priority": 1
	},
	"megaphone_call": {
		"name": "Calling Potatoes",
		"steps": [
			{
				"text": "[center][b]Calling the Next Potato[/b][/center]\n\nUse the megaphone to call the next potato from the queue to your booth.\n\n[color=yellow]{interact} the megaphone![/color]",
				"target": "Megaphone",
				"highlight": true,
				"wait_for_action": "megaphone_clicked",
				"pause_game": false
			},
			{
				"text": "[center][b]Here they come![/b][/center]\n\nWatch as the potato approaches your booth. They'll present their documents for inspection.",
				"target": null,
				"highlight": false,
				"duration": 3.0,
				"pause_game": false
			}
		],
		"shift_trigger": 1,
		"priority": 2
	},
	"document_inspection": {
		"name": "Inspecting Documents",
		"steps": [
			{
				"text": "[center][b]Document Inspection[/b][/center]\n\nThe potato has handed you their passport. {drag} it to your inspection table to examine it closely.\n\n[color=yellow]{drag} the passport to the table.[/color]",
				"target": "Passport",
				"highlight": true,
				"wait_for_action": "document_picked_up",
				"pause_game": false
			},
			{
				"text": "[center][b]Examining the Passport[/b][/center]\n\n{interact} the passport to open it and review the potato's information:\n\n- Name and photo\n- Country of origin\n- Potato type and condition\n\nLook for anything suspicious!",
				"target": "Passport",
				"highlight": true,
				"wait_for_action": "passport_opened",
				"pause_game": false
			},
			{
				"text": "[center][b]Check the Rules![/b][/center]\n\nBefore making your decision, you need to check the immigration rules. Let's learn about them!",
				"target": null,
				"highlight": false,
				"duration": 3.0,
				"pause_game": false
			}
		],
		"shift_trigger": 1,
		"priority": 3
	},
	"rules_checking": {
		"name": "Immigration Rules",
		"steps": [
			{
				"text": "[center][b]Immigration Rules[/b][/center]\n\nLook at the rules pamphlet on the right side. These rules tell you which potatoes to [color=green]APPROVE[/color] or [color=red]REJECT[/color].\n\nReject any potato that violates the current rules!",
				"target": "RulesLabel",
				"highlight": true,
				"duration": 5.0,
				"pause_game": false
			},
			{
				"text": "[center][b]Stay Vigilant![/b][/center]\n\nRules change between shifts. Always check the current rules before making decisions.\n\nCompare passport information against active rules carefully.",
				"target": null,
				"highlight": false,
				"duration": 3.5,
				"pause_game": false
			}
		],
		"shift_trigger": 1,
		"priority": 4
	},
	"stamp_usage": {
		"name": "Using the Stamps",
		"steps": [
			{
				"text": "[center][b]The Stamp Bar[/b][/center]\n\nSee the stamp bar at the top? {interact} the handle to reveal your approval and rejection stamps.\n\n[color=yellow]{interact} to open the stamp bar.[/color]",
				"target": "StampBarController",
				"highlight": true,
				"wait_for_action": "stamp_bar_opened",
				"pause_game": false
			},
			{
				"text": "[center][b]Positioning for Stamping[/b][/center]\n\n{drag} the passport under the stamps. You'll see a guide showing where to place it.\n\n[color=green]Green stamp[/color] = APPROVE\n[color=red]Red stamp[/color] = REJECT\n\n[color=yellow]Position the passport under a stamp.[/color]",
				"target": "Passport",
				"highlight": true,
				"wait_for_action": "document_under_stamp",
				"pause_game": false
			},
			{
				"text": "[center][b]Apply the Stamp![/b][/center]\n\n{interact} the stamp to mark the passport with your decision.\n\n[color=yellow]{interact} a stamp to apply it.[/color]",
				"target": "StampBarController",
				"highlight": true,
				"wait_for_action": "stamp_applied",
				"pause_game": false
			},
			{
				"text": "[center][b]Return the Documents[/b][/center]\n\nNow {drag} the stamped passport back to the potato to complete their processing.\n\n[color=yellow]Return the passport to the potato.[/color]",
				"target": "Passport",
				"highlight": true,
				"wait_for_action": "document_returned",
				"pause_game": false
			},
			{
				"text": "[center][b]Well Done![/b][/center]\n\nYou've processed your first potato! Keep an eye on your quota - you need to process enough potatoes each shift.",
				"target": null,
				"highlight": false,
				"duration": 3.5,
				"pause_game": false
			}
		],
		"shift_trigger": 1,
		"priority": 5
	},
	"strikes_and_quota": {
		"name": "Strikes and Quota",
		"steps": [
			{
				"text": "[center][b]The Quota System[/b][/center]\n\nLook at the [color=yellow]Quota[/color] display. This shows how many potatoes you must process correctly each shift.",
				"target": "QuotaLabel",
				"highlight": true,
				"duration": 4.0,
				"pause_game": false
			},
			{
				"text": "[center][b]Avoid Strikes![/b][/center]\n\nThe [color=red]Strikes[/color] counter shows your mistakes. Too many strikes and it's game over!\n\nMake wrong decisions and you'll earn strikes.",
				"target": "StrikesLabel",
				"highlight": true,
				"duration": 4.0,
				"pause_game": false
			},
			{
				"text": "[center][b]Training Complete![/b][/center]\n\nContinue processing potatoes to complete your training shift.\n\nOnce finished, you'll be [color=green]certified as a Customs Officer[/color] and ready for your first real day!",
				"target": null,
				"highlight": false,
				"duration": 5.0,
				"pause_game": false
			}
		],
		"shift_trigger": 1,
		"priority": 6
	}
}

# Queue for tutorials to run in order
var tutorial_queue: Array = []
var total_tutorials_in_session: int = 0  # Total tutorials queued at start of shift
var current_tutorial_index: int = 0  # Which tutorial we're on (1-indexed for display)


func _ready():
	# Ensure TutorialManager always processes even when tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Load the highlight shader (using consolidated highlight_indicator)
	highlight_shader = preload("res://assets/shaders/highlight_indicator.tres")

	# Create step timer
	step_timer = Timer.new()
	step_timer.one_shot = true
	step_timer.process_mode = Node.PROCESS_MODE_ALWAYS  # Timer must also always process
	step_timer.timeout.connect(_on_step_timer_timeout)
	add_child(step_timer)
	print("[TutorialManager] Initialized - step_timer created with PROCESS_MODE_ALWAYS")

	# Load saved progress
	load_tutorial_progress()
	_connect_input_signals()


## Connect to input mode change signals to update tutorial text
func _connect_input_signals() -> void:
	if ControllerManager:
		if not ControllerManager.input_mode_changed.is_connected(_on_input_mode_changed):
			ControllerManager.input_mode_changed.connect(_on_input_mode_changed)


func _on_input_mode_changed(_mode: int) -> void:
	# Refresh tutorial text if currently showing
	if current_tutorial != "" and tutorial_label:
		var tutorial = TUTORIALS[current_tutorial]
		if current_step < tutorial["steps"].size():
			var step = tutorial["steps"][current_step]
			tutorial_label.text = _format_tutorial_text(step["text"])


## Format tutorial text with controller-aware prompts
## Replaces {interact}, {drag}, {fire} with appropriate text
func _format_tutorial_text(text: String) -> String:
	var result = text
	var is_controller = ControllerManager and ControllerManager.is_controller_mode()

	# Get appropriate prompt text
	if is_controller:
		# Controller prompts - use button names
		var interact_text = "Press " + _get_controller_button_text("primary_interaction")
		var drag_text = "Use Left Stick to move cursor and " + _get_controller_button_text("controller_accept") + " to grab"
		var fire_text = "Press " + _get_controller_button_text("primary_interaction")

		result = result.replace("{interact}", interact_text)
		result = result.replace("{drag}", drag_text)
		result = result.replace("{fire}", fire_text)
	else:
		# Mouse/keyboard prompts
		result = result.replace("{interact}", "Click")
		result = result.replace("{drag}", "Drag")
		result = result.replace("{fire}", "Click")

	return result


## Get button text for a controller action
func _get_controller_button_text(action: String) -> String:
	if InputGlyphManager:
		var button_name = InputGlyphManager.get_button_for_action(action)
		if not button_name.is_empty():
			return "[" + InputGlyphManager.get_button_text(button_name) + "]"
	# Fallback
	match action:
		"primary_interaction": return "[RT]"
		"controller_accept": return "[A]"
		"controller_cancel": return "[B]"
		_: return "[" + action + "]"


func _process(_delta):
	# Update continue hint visibility based on waiting state
	if continue_hint_label and waiting_for_action:
		continue_hint_label.visible = false


## Load tutorial completion state from save
func load_tutorial_progress():
	if SaveManager:
		var save_data = SaveManager.load_game_state()
		if save_data and save_data.has("tutorials_completed"):
			tutorials_completed = save_data["tutorials_completed"]
		if save_data and save_data.has("tutorial_enabled"):
			tutorial_enabled = save_data["tutorial_enabled"]


## Save tutorial completion state
func save_tutorial_progress():
	if SaveManager:
		var save_data = SaveManager.load_game_state()
		if not save_data:
			save_data = {}
		save_data["tutorials_completed"] = tutorials_completed
		save_data["tutorial_enabled"] = tutorial_enabled
		SaveManager.save_game_state(save_data)


## Check if tutorials should trigger for the current shift
func check_shift_tutorials(shift_number: int):
	print("[TutorialManager] check_shift_tutorials called with shift: ", shift_number, " | tutorial_enabled: ", tutorial_enabled)
	if not tutorial_enabled:
		print("[TutorialManager] Tutorials disabled, skipping")
		return

	# Build queue of tutorials for this shift
	tutorial_queue.clear()

	# In tutorial mode (shift 0), use shift 1 tutorials for the interactive walkthrough
	var effective_shift = shift_number
	if shift_number == 0:
		var is_tutorial_mode = GameStateManager.is_tutorial_mode() if GameStateManager else false
		if is_tutorial_mode:
			effective_shift = 1  # Use shift 1 tutorials for the training shift

	for tutorial_id in TUTORIALS:
		var tutorial = TUTORIALS[tutorial_id]
		if tutorial.get("shift_trigger", 0) == effective_shift:
			if not is_tutorial_completed(tutorial_id):
				tutorial_queue.append({
					"id": tutorial_id,
					"priority": tutorial.get("priority", 99)
				})

	# Sort by priority
	tutorial_queue.sort_custom(func(a, b): return a["priority"] < b["priority"])

	# Track total tutorials for this session (for progress display)
	total_tutorials_in_session = tutorial_queue.size()
	current_tutorial_index = 0

	# Start first tutorial in queue
	_start_next_queued_tutorial()


func _start_next_queued_tutorial():
	if tutorial_queue.is_empty():
		print("[TutorialManager] No more tutorials in queue, cleaning up panel")
		# Hide and disable the panel when all tutorials are done
		if tutorial_panel and is_instance_valid(tutorial_panel):
			tutorial_panel.visible = false
			tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return

	current_tutorial_index += 1
	var next = tutorial_queue.pop_front()
	print("[TutorialManager] Starting next queued tutorial: ", next["id"], " (", current_tutorial_index, "/", total_tutorials_in_session, ")")
	start_tutorial(next["id"])


## Start a specific tutorial
func start_tutorial(tutorial_id: String):
	print("[TutorialManager] start_tutorial called for: ", tutorial_id)
	if not tutorial_id in TUTORIALS:
		push_error("Tutorial not found: " + tutorial_id)
		return

	if is_tutorial_completed(tutorial_id):
		print("[TutorialManager] Tutorial already completed: ", tutorial_id, ", skipping to next")
		_start_next_queued_tutorial()
		return

	current_tutorial = tutorial_id
	current_step = 0
	waiting_for_action = false
	print("[TutorialManager] Starting tutorial: ", tutorial_id)

	tutorial_started.emit(tutorial_id)
	# Also emit via EventBus for system-wide awareness
	if EventBus:
		EventBus.tutorial_step_advanced.emit(tutorial_id + "_start")

	# Create the tutorial UI if needed
	_create_tutorial_ui()

	# Show first step
	_show_current_step()


## Show the current tutorial step
func _show_current_step():
	if current_tutorial == "":
		print("[TutorialManager] _show_current_step called but no current tutorial")
		return

	var tutorial = TUTORIALS[current_tutorial]
	print("[TutorialManager] _show_current_step: ", current_tutorial, " step ", current_step, "/", tutorial["steps"].size())
	if current_step >= tutorial["steps"].size():
		print("[TutorialManager] All steps complete, calling _complete_tutorial")
		_complete_tutorial()
		return

	var step = tutorial["steps"][current_step]

	# Emit step changed signal
	tutorial_step_changed.emit(current_tutorial, current_step)
	# Also emit via EventBus
	if EventBus:
		EventBus.tutorial_step_advanced.emit(current_tutorial + "_step_" + str(current_step))

	# Update UI text and progress
	_update_tutorial_text(step["text"])
	_update_progress_label()

	# Position panel based on target - move to top for document-related targets
	_position_panel_for_step(step)

	# Clear previous highlights
	_clear_all_highlights()

	# Apply highlight if needed
	if step.get("highlight", false) and step.get("target"):
		_highlight_target(step["target"])

	# Handle step progression
	if step.has("wait_for_action"):
		var action = step.get("wait_for_action")
		print("[TutorialManager] Step waiting for action: ", action)

		# Check if action condition is already met (e.g., passport already open)
		if _is_action_condition_met(action):
			print("[TutorialManager] Action condition already met: ", action)
			# Wait for user to read the text, allow click to skip
			# Use longer wait time (6 seconds) since tutorial steps often have a lot of text
			_start_click_to_continue_wait(6.0)
			return

		waiting_for_action = true
		_update_continue_hint(false)
	elif step.has("duration"):
		var duration = step["duration"]
		print("[TutorialManager] Step has duration: ", duration, " seconds - starting timer")
		waiting_for_action = false
		step_timer.start(duration)
		print("[TutorialManager] Timer started, time_left: ", step_timer.time_left, ", is_stopped: ", step_timer.is_stopped())
		_update_continue_hint(true)
	else:
		# Default: wait 3 seconds
		print("[TutorialManager] Step has no duration/action, using default 3 seconds")
		waiting_for_action = false
		step_timer.start(3.0)
		_update_continue_hint(true)


## Create the tutorial UI panel
func _create_tutorial_ui():
	if tutorial_panel:
		print("[TutorialManager] Tutorial panel already exists, restoring visibility")
		# Restore visibility after previous fade out
		tutorial_panel.modulate.a = 0
		tutorial_panel.visible = true
		tutorial_panel.show()
		# Ensure mouse filter is set correctly (in case panel was created before fix)
		tutorial_panel.mouse_filter = Control.MOUSE_FILTER_PASS
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(tutorial_panel, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		return

	print("[TutorialManager] Creating tutorial UI panel...")

	# Create canvas layer for UI
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "TutorialCanvasLayer"
	canvas_layer.layer = 100  # Above everything
	get_tree().root.add_child(canvas_layer)
	print("[TutorialManager] Canvas layer added to root at layer 100")

	# Create a full-screen Control container for proper anchor positioning
	var full_screen_container = Control.new()
	full_screen_container.name = "TutorialFullScreenContainer"
	full_screen_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(full_screen_container)
	# Set anchors after adding to tree for proper sizing
	full_screen_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	full_screen_container.set_offsets_preset(Control.PRESET_FULL_RECT)
	print("[TutorialManager] Full screen container size: ", full_screen_container.size)

	# Create main panel
	tutorial_panel = PanelContainer.new()
	tutorial_panel.name = "TutorialPanel"
	# Allow mouse events to pass through to game elements behind the panel
	# The panel itself handles its own button clicks, but shouldn't block the game area
	tutorial_panel.mouse_filter = Control.MOUSE_FILTER_PASS

	# Style the panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	style.border_color = Color(0.8, 0.6, 0.2, 1.0)  # Golden border
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(15)
	tutorial_panel.add_theme_stylebox_override("panel", style)
	tutorial_panel.custom_minimum_size = Vector2(0, 140)

	# Add to container first, then set anchors
	full_screen_container.add_child(tutorial_panel)

	# Position at bottom center of screen using anchors
	# Anchor to bottom, centered horizontally with 15% margins on each side
	tutorial_panel.anchor_left = 0.15
	tutorial_panel.anchor_right = 0.85
	tutorial_panel.anchor_top = 1.0  # Bottom
	tutorial_panel.anchor_bottom = 1.0  # Bottom
	# Offset upward from bottom edge
	tutorial_panel.offset_top = -180
	tutorial_panel.offset_bottom = -20
	tutorial_panel.offset_left = 0
	tutorial_panel.offset_right = 0

	# Ensure visibility
	tutorial_panel.visible = true
	tutorial_panel.show()
	print("[TutorialManager] Tutorial panel added - visible: ", tutorial_panel.visible, ", size: ", tutorial_panel.size, ", global_position: ", tutorial_panel.global_position)

	# Create vertical container
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	tutorial_panel.add_child(vbox)

	# Create top row with progress indicator
	var top_row = HBoxContainer.new()
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(top_row)

	# Progress label (e.g., "Step 1 of 3")
	progress_label = Label.new()
	progress_label.text = ""
	progress_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.2))  # Golden
	progress_label.add_theme_font_size_override("font_size", 12)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_row.add_child(progress_label)

	# Create rich text label for tutorial text
	tutorial_label = RichTextLabel.new()
	tutorial_label.bbcode_enabled = true
	tutorial_label.fit_content = true
	tutorial_label.custom_minimum_size = Vector2(0, 70)
	tutorial_label.add_theme_font_size_override("normal_font_size", 18)
	tutorial_label.add_theme_font_size_override("bold_font_size", 20)
	tutorial_label.add_theme_color_override("default_color", Color.WHITE)
	vbox.add_child(tutorial_label)

	# Create bottom row for hints and skip buttons
	var bottom_row = HBoxContainer.new()
	bottom_row.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(bottom_row)

	# Continue hint
	continue_hint_label = Label.new()
	continue_hint_label.text = ""
	continue_hint_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	continue_hint_label.add_theme_font_size_override("font_size", 14)
	continue_hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_row.add_child(continue_hint_label)

	# Skip buttons
	if can_skip_tutorials:
		skip_button = Button.new()
		skip_button.text = "Skip"
		skip_button.add_theme_font_size_override("font_size", 14)
		skip_button.pressed.connect(skip_current_tutorial)
		bottom_row.add_child(skip_button)

		var skip_all_button = Button.new()
		skip_all_button.text = "Skip All Tutorials"
		skip_all_button.add_theme_font_size_override("font_size", 14)
		skip_all_button.pressed.connect(skip_all_tutorials)
		bottom_row.add_child(skip_all_button)

	# Animate panel appearing
	tutorial_panel.modulate.a = 0
	var tween = create_tween()
	# Ensure tween runs even when tree is paused
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(tutorial_panel, "modulate:a", 1.0, 0.3)


## Update the tutorial text with controller-aware formatting
func _update_tutorial_text(text: String):
	if tutorial_label:
		var formatted_text = _format_tutorial_text(text)
		tutorial_label.text = formatted_text
		print("[TutorialManager] Updated tutorial text: ", formatted_text.left(50), "...")
	else:
		push_warning("[TutorialManager] Cannot update text - tutorial_label is null")


## Update the progress indicator label
func _update_progress_label():
	if not progress_label or current_tutorial == "":
		return

	var tutorial = TUTORIALS[current_tutorial]
	var total_steps = tutorial["steps"].size()
	var current_step_display = current_step + 1  # 1-indexed for display

	# Show overall tutorial progress and step within current tutorial
	var tutorial_name = tutorial.get("name", current_tutorial)
	if total_tutorials_in_session > 1:
		# Show "Tutorial X of Y: Name - Step A of B"
		progress_label.text = "Tutorial %d of %d: %s - Step %d of %d" % [
			current_tutorial_index,
			total_tutorials_in_session,
			tutorial_name,
			current_step_display,
			total_steps
		]
	else:
		# Single tutorial, just show name and step
		progress_label.text = "%s - Step %d of %d" % [tutorial_name, current_step_display, total_steps]


## Position the tutorial panel based on the current step's target
## Moves panel to top for document-related steps to avoid blocking the workspace
func _position_panel_for_step(step: Dictionary):
	if not tutorial_panel:
		return

	var target = step.get("target", "")

	# Document-related targets that require the panel at the top
	var document_targets = ["Passport", "LawReceipt", "StampBarController", "RulesLabel"]
	var should_be_at_top = target in document_targets

	# Animate position change
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

	if should_be_at_top:
		# Position at top of screen
		tween.tween_property(tutorial_panel, "anchor_top", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(tutorial_panel, "anchor_bottom", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(tutorial_panel, "offset_top", 20, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(tutorial_panel, "offset_bottom", 180, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	else:
		# Position at bottom of screen (default)
		tween.tween_property(tutorial_panel, "anchor_top", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(tutorial_panel, "anchor_bottom", 1.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(tutorial_panel, "offset_top", -180, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(tutorial_panel, "offset_bottom", -20, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


## Update continue hint visibility
func _update_continue_hint(auto_progress: bool):
	if continue_hint_label:
		if auto_progress:
			continue_hint_label.text = "(continuing automatically...)"
			continue_hint_label.visible = true
		else:
			continue_hint_label.text = ""
			continue_hint_label.visible = false


## Start waiting for click to continue (with optional auto-advance after delay)
func _start_click_to_continue_wait(delay: float = 6.0):
	waiting_for_click = true
	waiting_for_action = false

	# Show click hint
	if continue_hint_label:
		continue_hint_label.text = "(click to continue...)"
		continue_hint_label.visible = true

	# Start timer for auto-advance
	step_timer.start(delay)
	print("[TutorialManager] Waiting for click or ", delay, " seconds")


## Handle click to continue
func _on_panel_clicked():
	if waiting_for_click:
		print("[TutorialManager] Panel clicked, advancing step")
		waiting_for_click = false
		step_timer.stop()
		_advance_step()


## Input handler for click-to-continue
func _input(event: InputEvent):
	if not waiting_for_click:
		return

	# Check for mouse click on the tutorial panel only
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Only advance if clicking on the tutorial panel itself
			if tutorial_panel and tutorial_panel.get_global_rect().has_point(event.position):
				_on_panel_clicked()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("primary_interaction"):
		_on_panel_clicked()


## Check if an action condition is already met
## This handles cases where the action happened before the tutorial step started
func _is_action_condition_met(action: String) -> bool:
	var scene = get_tree().current_scene
	if not scene:
		return false

	match action:
		"document_picked_up":
			# Check if any document is currently being dragged
			var dnd_system = scene.find_child("DragAndDropSystem", true, false)
			if dnd_system and "dragged_item" in dnd_system and dnd_system.dragged_item != null:
				return true
		"passport_opened":
			# Check if the passport is already open
			var passport = scene.find_child("Passport", true, false)
			if passport:
				var doc_controller = passport.get_node_or_null("DocumentController")
				if doc_controller and doc_controller.is_open:
					return true
		"document_placed_on_table":
			# Check if passport is on the inspection table
			var passport = scene.find_child("Passport", true, false)
			var inspection_table = scene.find_child("InspectionTable", true, false)
			if passport and inspection_table:
				var table_rect = Rect2(inspection_table.global_position, Vector2(400, 300))
				if table_rect.has_point(passport.global_position):
					return true
		"stamp_bar_opened":
			# Check if stamp bar is already open
			var stamp_bar = scene.find_child("StampBarController", true, false)
			if stamp_bar and "is_visible" in stamp_bar and stamp_bar.is_visible:
				return true
		"document_under_stamp":
			# Check if document is already under stamp (alignment guide showing)
			var stamp_bar = scene.find_child("StampBarController", true, false)
			if stamp_bar and "is_showing_guide" in stamp_bar and stamp_bar.is_showing_guide:
				return true

	return false


## Highlight a target node using the sweep shader
func _highlight_target(target_name: String):
	var target_node = _find_target_node(target_name)
	if not target_node:
		push_warning("[TutorialManager] Could not find target node: " + target_name)
		return

	print("[TutorialManager] Highlighting target: ", target_name, " -> ", target_node.name, " (", target_node.get_class(), ")")
	# Apply shader to the target
	_apply_highlight_shader(target_node)


## Find a target node by name
func _find_target_node(target_name: String) -> Node:
	var scene = get_tree().current_scene
	if not scene:
		return null

	# Try direct find by name
	var node = scene.find_child(target_name, true, false)
	if node:
		return node

	# Try finding by unique name (%)
	node = scene.get_node_or_null("%" + target_name)
	if node:
		return node

	# Try common path patterns for game elements
	var common_paths = [
		"Gameplay/InteractiveElements/%s" % target_name,
		"Gameplay/InteractiveElements/OfficeShutterController/%s" % target_name,
		"Gameplay/InteractiveElements/StampBarController/%s" % target_name,
		"Gameplay/%s" % target_name,
		"UI/%s" % target_name,
		"UI/Labels/%s" % target_name,
		"UI/Labels/MarginContainer/%s" % target_name,
		"HUD/%s" % target_name
	]

	for path in common_paths:
		node = scene.get_node_or_null(path)
		if node:
			return node

	# Try finding by group
	var group_name = target_name.to_lower().replace(" ", "_")
	var nodes_in_group = get_tree().get_nodes_in_group(group_name)
	if nodes_in_group.size() > 0:
		return nodes_in_group[0]

	return null


## Apply the highlight shader to a node
func _apply_highlight_shader(node: Node):
	if not node:
		return

	# Check if node can have a material (Sprite2D, Control with shader support, etc.)
	if node is CanvasItem:
		# Store original material
		var node_id = node.get_instance_id()
		if not original_materials.has(node_id):
			original_materials[node_id] = node.material

		# Use the sweep highlight shader for all elements
		# The text_readability shader didn't work well because Labels have tight bounding boxes
		# and the backdrop effect only shows in transparent areas
		var new_material: ShaderMaterial = highlight_shader.duplicate()
		new_material.set_shader_parameter("enable_highlight", true)

		# Use different settings for text labels vs other elements
		if node is Label or node is RichTextLabel:
			# For text: subtle, gentle golden sweep
			new_material.set_shader_parameter("speed", 1.0)
			new_material.set_shader_parameter("line_width", 0.04)
			new_material.set_shader_parameter("line_color", Color(1.0, 0.85, 0.4, 0.4))
			print("[TutorialManager] Applying highlight sweep shader to label: ", node.name)
		else:
			# For other elements: standard sweep
			new_material.set_shader_parameter("speed", 1.5)
			new_material.set_shader_parameter("line_color", Color(1.0, 0.95, 0.8, 0.5))

		node.material = new_material
		highlighted_nodes.append(node)


## Clear all highlights
func _clear_all_highlights():
	for node in highlighted_nodes:
		if is_instance_valid(node):
			var node_id = node.get_instance_id()
			if original_materials.has(node_id):
				node.material = original_materials[node_id]
			else:
				# If we can't restore, just disable the highlight
				if node.material and node.material.has_method("set_shader_parameter"):
					node.material.set_shader_parameter("enable_highlight", false)

	highlighted_nodes.clear()
	original_materials.clear()


## Timer timeout - advance to next step
func _on_step_timer_timeout():
	print("[TutorialManager] Timer fired! Advancing step for: ", current_tutorial)
	waiting_for_click = false  # Clear click wait state
	_advance_step()


## Trigger a tutorial action (called from game code)
func trigger_tutorial_action(action_name: String):
	if current_tutorial == "" or not waiting_for_action:
		return

	var tutorial = TUTORIALS[current_tutorial]
	if current_step >= tutorial["steps"].size():
		return

	var step = tutorial["steps"][current_step]
	if step.get("wait_for_action") == action_name:
		# Small delay before advancing for visual feedback
		if is_inside_tree() and get_tree():
			await get_tree().create_timer(0.5).timeout
		_advance_step()


## Advance to next step
func _advance_step():
	print("[TutorialManager] _advance_step: from step ", current_step, " to step ", current_step + 1)
	tutorial_step_completed.emit(current_tutorial, current_step)
	current_step += 1
	waiting_for_action = false
	waiting_for_click = false
	_show_current_step()


## Complete current tutorial
func _complete_tutorial():
	print("[TutorialManager] _complete_tutorial called for: ", current_tutorial)
	if current_tutorial == "":
		print("[TutorialManager] No current tutorial to complete")
		return

	var completed_id = current_tutorial
	tutorials_completed[completed_id] = true
	print("[TutorialManager] Marked ", completed_id, " as completed")
	tutorial_completed.emit(completed_id)
	# Also emit via EventBus
	if EventBus:
		EventBus.tutorial_completed.emit()

	# Clear highlights
	_clear_all_highlights()

	# Hide panel briefly
	if tutorial_panel and is_instance_valid(tutorial_panel):
		print("[TutorialManager] Fading out tutorial panel")
		# Disable mouse input while panel is invisible to prevent blocking
		tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tween = create_tween()
		if tween:
			# Ensure tween runs even when tree is paused
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(tutorial_panel, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			await tween.finished
			print("[TutorialManager] Panel fade complete")

	current_tutorial = ""
	current_step = 0

	save_tutorial_progress()
	print("[TutorialManager] Progress saved, queue size: ", tutorial_queue.size())

	# Start next tutorial in queue after a short delay
	# Use call_deferred as a fallback to ensure the next tutorial starts
	if is_inside_tree() and get_tree():
		print("[TutorialManager] Waiting 1 second before next tutorial...")
		await get_tree().create_timer(1.0).timeout
		print("[TutorialManager] Wait complete, starting next tutorial")
		_start_next_queued_tutorial()
	else:
		# Fallback: use call_deferred if tree is not available
		print("[TutorialManager] Not in tree, using call_deferred")
		call_deferred("_start_next_queued_tutorial")


## Skip current tutorial
func skip_current_tutorial():
	if current_tutorial == "":
		return

	var skipped_id = current_tutorial
	tutorial_skipped.emit(skipped_id)

	# Mark as completed so it doesn't show again
	tutorials_completed[skipped_id] = true

	# Clear highlights
	_clear_all_highlights()

	# Hide panel
	if tutorial_panel and is_instance_valid(tutorial_panel):
		# Disable mouse input while panel is invisible to prevent blocking
		tutorial_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tween = create_tween()
		if tween:
			# Ensure tween runs even when tree is paused
			tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(tutorial_panel, "modulate:a", 0.0, 0.4).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			await tween.finished

	current_tutorial = ""
	current_step = 0

	save_tutorial_progress()

	# Start next tutorial in queue
	if is_inside_tree() and get_tree():
		await get_tree().create_timer(0.5).timeout
		_start_next_queued_tutorial()
	else:
		call_deferred("_start_next_queued_tutorial")


## Skip all tutorials for this session
func skip_all_tutorials():
	tutorial_queue.clear()
	skip_current_tutorial()


## Clean up tutorial UI when leaving the scene
func cleanup_tutorial_ui():
	_clear_all_highlights()

	if tutorial_panel:
		# tutorial_panel is child of full_screen_container which is child of canvas_layer
		var full_screen_container = tutorial_panel.get_parent()
		var canvas_layer = full_screen_container.get_parent() if full_screen_container else null
		tutorial_panel.queue_free()
		tutorial_panel = null
		tutorial_label = null
		skip_button = null
		continue_hint_label = null
		progress_label = null

		# Free the canvas layer (which will also free the full_screen_container)
		if canvas_layer:
			canvas_layer.queue_free()

	current_tutorial = ""
	current_step = 0
	tutorial_queue.clear()
	total_tutorials_in_session = 0
	current_tutorial_index = 0


## Check if tutorial is completed
func is_tutorial_completed(tutorial_id: String) -> bool:
	return tutorials_completed.get(tutorial_id, false)


## Enable or disable tutorials globally
func set_tutorials_enabled(enabled: bool):
	tutorial_enabled = enabled
	if not enabled:
		cleanup_tutorial_ui()
	save_tutorial_progress()


## Mark tutorial as completed (for debug/testing)
func mark_tutorial_completed(tutorial_id: String):
	tutorials_completed[tutorial_id] = true
	save_tutorial_progress()


## Reset all tutorial progress
func reset_all_tutorials():
	# Clean up any existing tutorial UI first
	cleanup_tutorial_ui()

	tutorials_completed.clear()
	current_tutorial = ""
	current_step = 0
	tutorial_queue.clear()
	total_tutorials_in_session = 0
	current_tutorial_index = 0
	tutorial_enabled = true  # Re-enable tutorials when resetting
	save_tutorial_progress()


## Get completion percentage
func get_tutorial_completion_percentage() -> float:
	var total = TUTORIALS.size()
	var completed = 0
	for tutorial_id in TUTORIALS:
		if is_tutorial_completed(tutorial_id):
			completed += 1
	return (float(completed) / float(total)) * 100.0 if total > 0 else 0.0


## Check if any tutorial is currently active
func is_tutorial_active() -> bool:
	return current_tutorial != ""


## Get current tutorial ID
func get_current_tutorial() -> String:
	return current_tutorial


## Get current step index
func get_current_step() -> int:
	return current_step


# ==================== BACKWARDS COMPATIBILITY ====================
# Public API methods for backwards compatibility with tests

## Advance to next tutorial step (public API)
func advance_tutorial_step():
	_advance_step()


## Complete current tutorial (public API)
func complete_tutorial():
	_complete_tutorial()


## Show current tutorial step (public API)
func show_tutorial_step():
	_show_current_step()


## Legacy property aliases for compatibility
var tutorial_overlay: Control:
	get:
		return tutorial_panel

var highlight_rect: ColorRect:
	get:
		# Return null since we don't use ColorRect anymore
		# Tests should be updated to check for highlighted_nodes instead
		return null
