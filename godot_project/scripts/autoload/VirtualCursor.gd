extends CanvasLayer
## VirtualCursor - Gamepad-controlled virtual cursor for menu navigation and gameplay
##
## This autoload provides a virtual mouse cursor that can be controlled with
## a gamepad's analog stick. It enables full controller support for:
## - Menu navigation (when focus-based navigation isn't sufficient)
## - Gameplay interactions (missile targeting, document interaction)
## - Drag and drop operations
##
## The cursor automatically shows/hides based on input mode.

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when virtual cursor position changes
signal cursor_moved(position: Vector2)

## Emitted when virtual cursor clicks
signal cursor_clicked(position: Vector2, button: int)

## Emitted when virtual cursor starts/stops dragging
signal drag_state_changed(is_dragging: bool)

# ============================================================================
# CONFIGURATION
# ============================================================================

## Base cursor movement speed (pixels per second)
@export var base_speed: float = 800.0

## Acceleration curve for cursor movement (higher = faster acceleration)
@export var acceleration: float = 2.0

## Whether to use acceleration (stick position affects speed)
@export var use_acceleration: bool = true

## Minimum speed multiplier when stick is barely tilted
@export var min_speed_multiplier: float = 0.2

## Cursor sprite scale
@export var cursor_scale: Vector2 = Vector2(1.0, 1.0)

## Whether the virtual cursor is enabled
@export var enabled: bool = true

## Edge padding - cursor won't go past this many pixels from viewport edge
@export var edge_padding: float = 5.0

# ============================================================================
# CURSOR TEXTURES
# ============================================================================

var cursor_textures = {
	"default": preload("res://assets/user_interface/cursor/cursor_default.png"),
	"hover_1": preload("res://assets/user_interface/cursor/cursor_hover_1.png"),
	"hover_2": preload("res://assets/user_interface/cursor/cursor_hover_2.png"),
	"grab": preload("res://assets/user_interface/cursor/cursor_grab.png"),
	"click": preload("res://assets/user_interface/cursor/cursor_click.png"),
	"target": preload("res://assets/user_interface/cursor/cursor_target.png")
}

# Cursor hotspots (where the "click point" is on each cursor)
var cursor_hotspots = {
	"default": Vector2(8, 3),
	"hover_1": Vector2(12, 4),
	"hover_2": Vector2(12, 4),
	"grab": Vector2(12, 8),
	"click": Vector2(12, 4),
	"target": Vector2(16, 16)
}

# ============================================================================
# STATE
# ============================================================================

## Current virtual cursor position
var cursor_position: Vector2 = Vector2.ZERO

## Current cursor state (for visual appearance)
var cursor_state: String = "default"

## Whether the cursor is currently visible
var is_visible: bool = false

## Whether we're currently dragging something
var is_dragging: bool = false

## The control being hovered over (if any)
var hovered_control: Control = null

## Button currently being held
var held_button: int = MOUSE_BUTTON_NONE

## Sprite node for the cursor visual
var _cursor_sprite: Sprite2D = null

## Container for the cursor
var _cursor_container: Control = null

## Last known viewport size
var _viewport_size: Vector2 = Vector2.ZERO

## Whether left trigger is being used for firing
var _left_trigger_was_pressed: bool = false

## Whether right trigger is being used for alt action
var _right_trigger_was_pressed: bool = false

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	# Set layer to be on top of everything
	layer = 100

	# Create the cursor container
	_cursor_container = Control.new()
	_cursor_container.name = "VirtualCursorContainer"
	_cursor_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cursor_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_cursor_container)

	# Create the cursor sprite
	_cursor_sprite = Sprite2D.new()
	_cursor_sprite.name = "CursorSprite"
	_cursor_sprite.texture = cursor_textures["default"]
	_cursor_sprite.centered = false
	_cursor_sprite.scale = cursor_scale
	_cursor_sprite.z_index = 1000
	_cursor_sprite.visible = false
	_cursor_container.add_child(_cursor_sprite)

	# Get initial viewport size
	_update_viewport_size()

	# Center cursor initially
	cursor_position = _viewport_size / 2

	# Connect to ControllerManager signals
	if ControllerManager:
		ControllerManager.input_mode_changed.connect(_on_input_mode_changed)

		# Set initial visibility based on current mode
		if ControllerManager.is_controller_mode():
			show_cursor()
		else:
			hide_cursor()

	# Set process mode to always process
	process_mode = Node.PROCESS_MODE_ALWAYS

	LogManager.write_info("VirtualCursor initialized")


func _process(delta: float) -> void:
	if not enabled or not is_visible:
		return

	# Update viewport size if needed
	_update_viewport_size()

	# Get movement input
	var movement = _get_cursor_movement()

	if movement.length() > 0.0:
		# Calculate speed based on stick deflection
		var speed = base_speed
		if use_acceleration:
			var deflection = movement.length()
			speed *= lerp(min_speed_multiplier, 1.0, pow(deflection, acceleration))

		# Move cursor
		cursor_position += movement.normalized() * speed * delta

		# Clamp to viewport bounds
		cursor_position.x = clampf(cursor_position.x, edge_padding, _viewport_size.x - edge_padding)
		cursor_position.y = clampf(cursor_position.y, edge_padding, _viewport_size.y - edge_padding)

		# Update sprite position (accounting for hotspot)
		_update_sprite_position()

		# Emit movement signal
		cursor_moved.emit(cursor_position)

		# Update hover state
		_update_hover_state()

		# Warp the actual mouse to match (for UI interactions)
		_warp_mouse_to_cursor()

	# Handle button inputs
	_handle_button_inputs()

	# Handle trigger inputs (for gameplay)
	_handle_trigger_inputs()


func _get_cursor_movement() -> Vector2:
	var movement = Vector2.ZERO

	# Try Steam Input first
	if SteamInputManager and SteamInputManager.is_initialized:
		movement = SteamInputManager.get_analog_action(SteamInputManager.ACTION_CURSOR_MOVE)
		if movement.length() > 0.1:
			return movement

	# Fall back to standard controller input
	if ControllerManager:
		movement = ControllerManager.get_right_stick()
		if movement.length() > 0.1:
			return movement

		# Also check left stick as fallback
		movement = ControllerManager.get_left_stick()

	return movement

# ============================================================================
# BUTTON HANDLING
# ============================================================================

func _handle_button_inputs() -> void:
	# A button / Cross = Left click (primary action)
	if Input.is_action_just_pressed("controller_accept"):
		_simulate_click(MOUSE_BUTTON_LEFT, true)
	elif Input.is_action_just_released("controller_accept"):
		_simulate_click(MOUSE_BUTTON_LEFT, false)

	# B button / Circle = Right click (secondary action / cancel)
	if Input.is_action_just_pressed("controller_cancel"):
		_simulate_click(MOUSE_BUTTON_RIGHT, true)
	elif Input.is_action_just_released("controller_cancel"):
		_simulate_click(MOUSE_BUTTON_RIGHT, false)

	# X button / Square = Middle click (alternate action)
	if Input.is_action_just_pressed("controller_alt"):
		_simulate_click(MOUSE_BUTTON_MIDDLE, true)
	elif Input.is_action_just_released("controller_alt"):
		_simulate_click(MOUSE_BUTTON_MIDDLE, false)


func _handle_trigger_inputs() -> void:
	if not ControllerManager:
		return

	# Right trigger = Fire (primary interaction in gameplay)
	var right_trigger = ControllerManager.get_right_trigger()
	if right_trigger > 0.5 and not _right_trigger_was_pressed:
		_right_trigger_was_pressed = true
		_simulate_click(MOUSE_BUTTON_LEFT, true)
		cursor_clicked.emit(cursor_position, MOUSE_BUTTON_LEFT)
	elif right_trigger <= 0.5 and _right_trigger_was_pressed:
		_right_trigger_was_pressed = false
		_simulate_click(MOUSE_BUTTON_LEFT, false)

	# Left trigger = Alt fire (secondary interaction)
	var left_trigger = ControllerManager.get_left_trigger()
	if left_trigger > 0.5 and not _left_trigger_was_pressed:
		_left_trigger_was_pressed = true
		_simulate_click(MOUSE_BUTTON_RIGHT, true)
	elif left_trigger <= 0.5 and _left_trigger_was_pressed:
		_left_trigger_was_pressed = false
		_simulate_click(MOUSE_BUTTON_RIGHT, false)


func _simulate_click(button: int, pressed: bool) -> void:
	# Create and dispatch mouse button event
	var event = InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	event.position = cursor_position
	event.global_position = cursor_position

	# Set button mask
	if pressed:
		held_button = button
		if button == MOUSE_BUTTON_LEFT:
			event.button_mask = MOUSE_BUTTON_MASK_LEFT
		elif button == MOUSE_BUTTON_RIGHT:
			event.button_mask = MOUSE_BUTTON_MASK_RIGHT
		elif button == MOUSE_BUTTON_MIDDLE:
			event.button_mask = MOUSE_BUTTON_MASK_MIDDLE
	else:
		held_button = MOUSE_BUTTON_NONE
		event.button_mask = 0

	# Update cursor visual
	if pressed:
		set_cursor_state("click")
		# Provide haptic feedback
		if ControllerManager:
			ControllerManager.rumble_light()
	else:
		# Restore appropriate cursor state
		if hovered_control:
			set_cursor_state("hover_2")
		else:
			set_cursor_state("default")

	# Emit signal
	if pressed:
		cursor_clicked.emit(cursor_position, button)

	# Parse the input
	Input.parse_input_event(event)

# ============================================================================
# CURSOR VISIBILITY
# ============================================================================

func show_cursor() -> void:
	if is_visible:
		return

	is_visible = true
	_cursor_sprite.visible = true

	# Warp cursor to center if it's at origin
	if cursor_position == Vector2.ZERO:
		_update_viewport_size()
		cursor_position = _viewport_size / 2

	_update_sprite_position()
	LogManager.write_info("VirtualCursor: Cursor shown")


func hide_cursor() -> void:
	if not is_visible:
		return

	is_visible = false
	_cursor_sprite.visible = false
	LogManager.write_info("VirtualCursor: Cursor hidden")


func toggle_cursor() -> void:
	if is_visible:
		hide_cursor()
	else:
		show_cursor()

# ============================================================================
# CURSOR STATE
# ============================================================================

func set_cursor_state(state: String) -> void:
	if not cursor_textures.has(state):
		return

	cursor_state = state
	_cursor_sprite.texture = cursor_textures[state]
	_update_sprite_position()


func get_cursor_state() -> String:
	return cursor_state

# ============================================================================
# POSITION MANAGEMENT
# ============================================================================

func set_cursor_position(pos: Vector2) -> void:
	cursor_position = pos
	cursor_position.x = clampf(cursor_position.x, edge_padding, _viewport_size.x - edge_padding)
	cursor_position.y = clampf(cursor_position.y, edge_padding, _viewport_size.y - edge_padding)
	_update_sprite_position()
	_warp_mouse_to_cursor()


func get_cursor_position() -> Vector2:
	return cursor_position


func center_cursor() -> void:
	_update_viewport_size()
	set_cursor_position(_viewport_size / 2)


func _update_sprite_position() -> void:
	if not _cursor_sprite:
		return

	# Get the hotspot for current cursor state
	var hotspot = cursor_hotspots.get(cursor_state, Vector2.ZERO)

	# Position sprite so hotspot is at cursor position
	_cursor_sprite.position = cursor_position - (hotspot * cursor_scale)


func _update_viewport_size() -> void:
	var viewport = get_viewport()
	if viewport:
		_viewport_size = viewport.get_visible_rect().size


func _warp_mouse_to_cursor() -> void:
	# Warp the actual mouse position to match virtual cursor
	# This ensures UI elements respond correctly
	Input.warp_mouse(cursor_position)

# ============================================================================
# HOVER DETECTION
# ============================================================================

func _update_hover_state() -> void:
	var viewport = get_viewport()
	if not viewport:
		return

	# Find control under cursor
	var new_hovered = _find_control_at_position(cursor_position)

	if new_hovered != hovered_control:
		# Exit previous control
		if hovered_control and is_instance_valid(hovered_control):
			_send_mouse_event(hovered_control, false)

		# Enter new control
		hovered_control = new_hovered
		if hovered_control:
			_send_mouse_event(hovered_control, true)

			# Update cursor appearance based on control type
			if hovered_control is Button or hovered_control is LinkButton:
				set_cursor_state("hover_2")
			elif hovered_control.is_in_group("DraggableDocuments") or hovered_control.is_in_group("Draggable"):
				set_cursor_state("hover_1")
			else:
				set_cursor_state("hover_2")
		else:
			set_cursor_state("default")


func _find_control_at_position(pos: Vector2) -> Control:
	var viewport = get_viewport()
	if not viewport:
		return null

	# Get the current scene root
	var root = get_tree().current_scene
	if not root:
		return null

	# Find topmost control at position
	return _find_control_recursive(root, pos)


func _find_control_recursive(node: Node, pos: Vector2) -> Control:
	var result: Control = null
	var highest_z: int = -9999

	# Check children first (they're usually on top)
	for child in node.get_children():
		var child_result = _find_control_recursive(child, pos)
		if child_result and child_result.z_index >= highest_z:
			result = child_result
			highest_z = child_result.z_index

	# Check this node
	if node is Control:
		var control = node as Control
		if control.visible and control.mouse_filter != Control.MOUSE_FILTER_IGNORE:
			var rect = control.get_global_rect()
			if rect.has_point(pos):
				if control.z_index >= highest_z:
					result = control
					highest_z = control.z_index

	return result


func _send_mouse_event(control: Control, entering: bool) -> void:
	# Simulate mouse enter/exit events
	if entering:
		# Trigger mouse_entered signal if the control has it
		if control.has_signal("mouse_entered"):
			control.emit_signal("mouse_entered")
	else:
		if control.has_signal("mouse_exited"):
			control.emit_signal("mouse_exited")

# ============================================================================
# INPUT MODE HANDLING
# ============================================================================

func _on_input_mode_changed(mode: int) -> void:
	if mode == ControllerManager.InputMode.CONTROLLER:
		show_cursor()
	else:
		hide_cursor()

# ============================================================================
# DRAG AND DROP SUPPORT
# ============================================================================

func start_drag() -> void:
	is_dragging = true
	set_cursor_state("grab")
	drag_state_changed.emit(true)


func end_drag() -> void:
	is_dragging = false
	set_cursor_state("default")
	drag_state_changed.emit(false)

# ============================================================================
# TARGET CURSOR (for missile aiming)
# ============================================================================

## Check if cursor is in a targeting zone and update appearance
func update_target_mode(is_in_target_zone: bool) -> void:
	if is_in_target_zone and cursor_state != "click" and cursor_state != "grab":
		set_cursor_state("target")
	elif not is_in_target_zone and cursor_state == "target":
		set_cursor_state("default")

# ============================================================================
# DEBUG
# ============================================================================

func get_debug_info() -> Dictionary:
	return {
		"enabled": enabled,
		"is_visible": is_visible,
		"cursor_position": cursor_position,
		"cursor_state": cursor_state,
		"is_dragging": is_dragging,
		"hovered_control": hovered_control.name if hovered_control else "None",
		"viewport_size": _viewport_size
	}
