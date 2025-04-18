extends Node
## Utility class for dynamic cursor management
##
## This autoload singleton provides utilities for managing the cursor appearance
## based on different states. It automatically updates the cursor when hovering
## over interactive elements or when in different game states.

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


func _ready():
	# Set initial cursor
	update_cursor("default")

	# Connect to UI input signals system-wide
	var tree = get_tree()
	if tree:
		get_tree().node_added.connect(_on_node_added)

		# Process all existing buttons in the scene
		if tree.current_scene:
			_connect_buttons_in_node(tree.current_scene)


func _process(_delta):
	if not active:
		return

	# Skip cursor updates if game is paused or in dialogue
	var is_paused = get_tree().paused
	var is_in_dialogue = false
	var narrative_manager = get_node_or_null("/root/NarrativeManager")
	if narrative_manager and narrative_manager.has_method("is_dialogue_active"):
		is_in_dialogue = narrative_manager.is_dialogue_active()
		
	if is_paused or is_in_dialogue:
		return

	# Handle mouse button pressed state
	# Primary interaction pressed for first time
	if Input.is_action_pressed("primary_interaction") and not input_pressed:
		input_pressed = true
		update_cursor("click")
	# Release of the primary interaction
	elif not Input.is_action_pressed("primary_interaction") and input_pressed:
		input_pressed = false
		# If no hover item, restore to default, otherwise stay on hover state
		if hover_state_stack.is_empty():
			update_cursor("default")
		else:
			update_cursor("hover_2")

	# Check for missile zone if callback provided
	if missile_zone_callback.is_valid() and hover_state_stack.is_empty() and not input_pressed:
		var mouse_pos = get_viewport().get_mouse_position()
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

	#print("Mouse entered: ", button.name)
	# Add button to hover stack
	hover_state_stack.append(button)

	# Update cursor to hover state unless mouse is being pressed
	# TODO: This is where we would implement the check for which hover state to use,
	# hover_1 for draggables or hover_2 for clickables
	if not input_pressed:
		update_cursor("hover_2")
		#print("Set cursor to hover state")


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
