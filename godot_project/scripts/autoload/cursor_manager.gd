extends Node
## Utility class for dynamic cursor management
##
## This autoload singleton provides utilities for managing the cursor appearance
## based on different states. It automatically updates the cursor when hovering
## over interactive elements or when in different game states.

# Cached node references to avoid repeated get_tree()/get_viewport() calls every frame
var _tree: SceneTree
var _viewport: Viewport

# Cursor texture paths - customize these to match your assets
var cursor_textures = {
	"default": preload("res://assets/user_interface/cursor/cursor_default.png"),
	"hover_1": preload("res://assets/user_interface/cursor/cursor_hover_1.png"),
	"hover_2": preload("res://assets/user_interface/cursor/cursor_hover_2.png"),
	"grab": preload("res://assets/user_interface/cursor/cursor_grab.png"),
	"click": preload("res://assets/user_interface/cursor/cursor_click.png"),
	"target": preload("res://assets/user_interface/cursor/cursor_target.png")
}

# Cursor hotspot positions (origin point of cursor)
var cursor_hotspots = {
	"default": Vector2(8, 3),
	"hover": Vector2(12, 4),
	"grab": Vector2(12, 8),
	"click": Vector2(12, 4),
	"target": Vector2(16, 16)  # Center of targeting reticle
}

# Input map actions that trigger cursor state changes
var action_cursor_states = {
	"primary_interaction": "click",  # Left mouse button pressed
	"secondary_interaction": "click",  # Right mouse button pressed
}

# Current cursor state tracking
var current_state: String = "default"
var hover_state_stack: Array = []
var input_pressed: bool = false

# Whether the manager is active or not
var active: bool = true
var missile_zone_callback: Callable

# Track dialogue state via EventBus
var is_in_dialogue: bool = false


func _ready():
	# Cache node references to avoid repeated lookups in _process()
	_tree = get_tree()
	_viewport = get_viewport()

	# Set initial cursor
	update_cursor("default")

	# Connect to EventBus for dialogue state tracking
	if EventBus:
		EventBus.dialogue_started.connect(_on_dialogue_started)
		EventBus.dialogue_ended.connect(_on_dialogue_ended)

	# Connect to UI input signals system-wide
	if _tree:
		_tree.node_added.connect(_on_node_added)

		# Process all existing buttons in the scene
		if _tree.current_scene:
			_connect_buttons_in_node(_tree.current_scene)


func _on_dialogue_started(_timeline_name: String) -> void:
	is_in_dialogue = true


func _on_dialogue_ended(_timeline_name: String) -> void:
	is_in_dialogue = false


func _process(_delta):
	if not active:
		return

	# Skip cursor updates if game is paused or in dialogue
	# Use cached _tree reference to avoid get_tree() call every frame
	if _tree.paused or is_in_dialogue:
		return

	# Handle mouse button pressed state
	# Primary interaction pressed for first time
	if Input.is_action_pressed("primary_interaction") and not input_pressed:
		input_pressed = true
		update_cursor("click")
	# Release of the primary interaction
	elif not Input.is_action_pressed("primary_interaction") and input_pressed:
		input_pressed = false
		# If no hover item, restore to default, otherwise use appropriate hover state
		if hover_state_stack.is_empty():
			update_cursor("default")
		else:
			var top_control = hover_state_stack.back()
			var hover_state = _get_hover_state_for_control(top_control) if top_control else "hover_2"
			update_cursor(hover_state)

	# Check for missile zone if callback provided
	# Use cached _viewport reference to avoid get_viewport() call every frame
	if missile_zone_callback.is_valid() and hover_state_stack.is_empty() and not input_pressed:
		var mouse_pos = _viewport.get_mouse_position()
		if missile_zone_callback.call(mouse_pos):
			update_cursor("target")


# Connect button signals when nodes are added to the scene
func _on_node_added(node: Node):
	if node is BaseButton or node is TextureButton:
		_connect_button_signals(node)

	# For non-Control nodes, check their children immediately
	if not node is Control and node.get_child_count() > 0:
		for child in node.get_children():
			_on_node_added(child)


# Recursively connect to all buttons in a node hierarchy
func _connect_buttons_in_node(node: Node):
	if node is BaseButton or node is TextureButton:
		_connect_button_signals(node)

	# Process children
	for child in node.get_children():
		_connect_buttons_in_node(child)


# Connect the hover/exit signals for a button
func _connect_button_signals(button: Control):
	# We need to fix how we check for existing connections
	var already_connected = false

	# Check for existing connections using get_signal_connection_list
	for connection in button.get_signal_connection_list("mouse_entered"):
		if connection["callable"].get_object() == self:
			already_connected = true
			break

	if already_connected:
		return

	# Connect mouse signals
	button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_button_mouse_exited.bind(button))


func _on_button_mouse_entered(button: Control):
	if not active:
		return

	# Add button to hover stack
	hover_state_stack.append(button)

	# Update cursor to appropriate hover state unless mouse is being pressed
	if not input_pressed:
		var hover_state = _get_hover_state_for_control(button)
		update_cursor(hover_state)


## Determine the appropriate hover cursor state for a control.
## Returns "hover_1" for draggable items, "hover_2" for clickable buttons.
func _get_hover_state_for_control(control: Control) -> String:
	# Check if the control or its parent is a draggable document
	if _is_draggable_control(control):
		return "hover_1"
	return "hover_2"


## Check if a control is a draggable item (document, passport, etc.)
func _is_draggable_control(control: Control) -> bool:
	# Check by group membership
	if control.is_in_group("DraggableDocuments") or control.is_in_group("Draggable"):
		return true

	# Check by common draggable document names
	var draggable_names = ["Passport", "LawReceipt", "Document", "Paper"]
	for name_part in draggable_names:
		if name_part in control.name:
			return true

	# Check parent hierarchy for draggable context
	var parent = control.get_parent()
	while parent:
		if parent.is_in_group("DraggableDocuments") or parent.is_in_group("Draggable"):
			return true
		for name_part in draggable_names:
			if name_part in parent.name:
				return true
		parent = parent.get_parent()

	return false


func _on_button_mouse_exited(button: Control):
	if not active:
		return

	#print("Mouse exited: ", button.name)
	# Remove this specific button from hover stack
	hover_state_stack.erase(button)

	# If stack is empty and not pressing mouse, restore default cursor
	if hover_state_stack.is_empty() and not input_pressed:
		update_cursor("default")
		#print("Set cursor to default state")


# Update the cursor appearance
func update_cursor(state: String):
	if not active or not cursor_textures.has(state):
		return

	current_state = state
	var texture = cursor_textures[state]
	var hotspot = cursor_hotspots.get(state)

	# Determine the right cursor type constant based on state
	match state:
		"click":
			texture = cursor_textures["click"]
		"hover_1":
			texture = cursor_textures["hover_1"]
		"hover_2":
			texture = cursor_textures["hover_2"]
		"grab":
			texture = cursor_textures["grab"]
		"target":
			texture = cursor_textures["target"]

	# Set the custom cursor
	Input.set_custom_mouse_cursor(texture)


# Manually set cursor state (for game-specific logic)
func set_cursor_state(state: String):
	if cursor_textures.has(state):
		update_cursor(state)


# Register a callback function to check if mouse is in missile zone
func register_missile_zone_callback(callback: Callable):
	missile_zone_callback = callback


# Temporarily override current cursor (for dragging operations)
func override_cursor(state: String):
	update_cursor(state)


# Enable/disable the cursor manager
func set_active(is_active: bool):
	active = is_active

	# If becoming active again, refresh cursor state
	if active:
		update_cursor(current_state)


# Clear hover state stack (useful when changing scenes)
func clear_hover_stack():
	hover_state_stack.clear()

	# If not pressing mouse, reset to default cursor
	if not input_pressed:
		update_cursor("default")
