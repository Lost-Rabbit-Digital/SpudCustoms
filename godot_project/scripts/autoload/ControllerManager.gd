extends Node
## ControllerManager - Handles controller detection, state management, and input mode switching
##
## This autoload singleton manages:
## - Controller connection/disconnection detection
## - Input mode switching (keyboard/mouse vs controller)
## - Controller type detection (Xbox, PlayStation, Nintendo, Steam Deck)
## - Haptic feedback/rumble
## - Focus management for controller navigation

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when input mode changes between keyboard/mouse and controller
signal input_mode_changed(mode: InputMode)

## Emitted when a controller is connected
signal controller_connected(device_id: int, device_name: String)

## Emitted when a controller is disconnected
signal controller_disconnected(device_id: int)

## Emitted when controller type is detected or changed
signal controller_type_changed(controller_type: ControllerType)

# ============================================================================
# ENUMS
# ============================================================================

## Current input mode
enum InputMode {
	KEYBOARD_MOUSE,  ## Using keyboard and mouse
	CONTROLLER       ## Using gamepad/controller
}

## Controller type for button glyph display
enum ControllerType {
	UNKNOWN,         ## Unknown or generic controller
	XBOX,            ## Xbox controller (Series X/S, One, 360)
	PLAYSTATION,     ## PlayStation controller (DualSense, DualShock)
	NINTENDO,        ## Nintendo controller (Pro Controller, Joy-Cons)
	STEAM_DECK,      ## Steam Deck built-in controls
	STEAM_CONTROLLER ## Steam Controller
}

# ============================================================================
# CONFIGURATION
# ============================================================================

## Deadzone for analog sticks
@export var stick_deadzone: float = 0.2

## Deadzone for triggers
@export var trigger_deadzone: float = 0.1

## Time in seconds before switching to controller mode after controller input
@export var mode_switch_delay: float = 0.0

## Whether to automatically grab focus when switching to controller mode
@export var auto_grab_focus: bool = true

## Rumble intensity multiplier (0.0 to 1.0)
@export var rumble_intensity: float = 1.0

## Whether rumble is enabled
@export var rumble_enabled: bool = true

# ============================================================================
# STATE
# ============================================================================

## Current input mode
var current_mode: InputMode = InputMode.KEYBOARD_MOUSE

## Current controller type
var current_controller_type: ControllerType = ControllerType.UNKNOWN

## Currently active controller device ID (-1 if none)
var active_controller_id: int = -1

## Dictionary of connected controllers {device_id: device_name}
var connected_controllers: Dictionary = {}

## Whether Steam Input is being used (set by SteamInputManager)
var using_steam_input: bool = false

## Last focused control before mode switch
var _last_focused_control: Control = null

## Timer for mode switch delay
var _mode_switch_timer: float = 0.0

## Whether we're waiting to switch modes
var _pending_mode_switch: bool = false

## Pending mode to switch to
var _pending_mode: InputMode = InputMode.KEYBOARD_MOUSE

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	# Connect to joy connection signals
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

	# Check for already connected controllers
	_scan_connected_controllers()

	# Set process mode to always process (even when paused)
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Subscribe to EventBus haptic feedback requests
	if EventBus:
		EventBus.haptic_feedback_requested.connect(_on_haptic_feedback_requested)

	LogManager.write_info("ControllerManager initialized")
	LogManager.write_info("Connected controllers: " + str(connected_controllers.size()))


func _process(delta: float) -> void:
	# Handle pending mode switch with delay
	if _pending_mode_switch:
		_mode_switch_timer -= delta
		if _mode_switch_timer <= 0.0:
			_apply_mode_switch(_pending_mode)
			_pending_mode_switch = false


func _input(event: InputEvent) -> void:
	# Detect input type and switch modes if needed
	if _is_controller_input(event):
		_request_mode_switch(InputMode.CONTROLLER)
	elif _is_keyboard_mouse_input(event):
		_request_mode_switch(InputMode.KEYBOARD_MOUSE)

# ============================================================================
# INPUT DETECTION
# ============================================================================

## Check if an input event is from a controller
func _is_controller_input(event: InputEvent) -> bool:
	if event is InputEventJoypadButton:
		return true
	if event is InputEventJoypadMotion:
		# Only count as controller input if motion exceeds deadzone
		return abs(event.axis_value) > stick_deadzone
	return false


## Check if an input event is from keyboard/mouse
func _is_keyboard_mouse_input(event: InputEvent) -> bool:
	if event is InputEventKey:
		return true
	if event is InputEventMouseButton:
		return true
	if event is InputEventMouseMotion:
		# Only count significant mouse movement
		return event.relative.length() > 5.0
	return false

# ============================================================================
# MODE SWITCHING
# ============================================================================

## Request a mode switch (with optional delay)
func _request_mode_switch(new_mode: InputMode) -> void:
	if current_mode == new_mode:
		return

	if mode_switch_delay > 0.0:
		_pending_mode_switch = true
		_pending_mode = new_mode
		_mode_switch_timer = mode_switch_delay
	else:
		_apply_mode_switch(new_mode)


## Apply the mode switch
func _apply_mode_switch(new_mode: InputMode) -> void:
	if current_mode == new_mode:
		return

	var old_mode = current_mode
	current_mode = new_mode

	LogManager.write_info("Input mode changed: " + InputMode.keys()[old_mode] + " -> " + InputMode.keys()[new_mode])

	# Handle focus when switching to controller mode
	if new_mode == InputMode.CONTROLLER and auto_grab_focus:
		_ensure_focus()

	# Update cursor visibility
	_update_cursor_visibility()

	# Emit signal
	input_mode_changed.emit(new_mode)

	# Also emit through EventBus for broader integration
	if EventBus:
		EventBus.input_mode_changed.emit(new_mode == InputMode.CONTROLLER)


## Ensure something has focus when using controller
func _ensure_focus() -> void:
	var viewport = get_viewport()
	if viewport and viewport.gui_get_focus_owner() == null:
		# Try to find a focusable control
		var focusable = _find_first_focusable(get_tree().current_scene)
		if focusable:
			focusable.grab_focus()


## Find the first focusable control in a node tree
func _find_first_focusable(node: Node) -> Control:
	if node is Control:
		var control = node as Control
		if control.visible and control.focus_mode != Control.FOCUS_NONE:
			if control is Button or control is ItemList or control is LineEdit or control is TextEdit:
				return control

	for child in node.get_children():
		var result = _find_first_focusable(child)
		if result:
			return result

	return null


## Update cursor visibility based on input mode
func _update_cursor_visibility() -> void:
	if current_mode == InputMode.CONTROLLER:
		# Hide system cursor when using controller (virtual cursor will be shown)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		# Show system cursor for keyboard/mouse
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# ============================================================================
# CONTROLLER CONNECTION
# ============================================================================

## Scan for already connected controllers
func _scan_connected_controllers() -> void:
	var joypad_ids = Input.get_connected_joypads()
	for joy_id in joypad_ids:
		var joy_name = Input.get_joy_name(joy_id)
		connected_controllers[joy_id] = joy_name
		_detect_controller_type(joy_id, joy_name)

		# Set first connected controller as active
		if active_controller_id == -1:
			active_controller_id = joy_id


## Handle controller connection/disconnection
func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	var device_name = Input.get_joy_name(device_id) if connected else "Unknown"

	if connected:
		connected_controllers[device_id] = device_name
		_detect_controller_type(device_id, device_name)

		# Set as active if no controller is active
		if active_controller_id == -1:
			active_controller_id = device_id

		LogManager.write_info("Controller connected: " + device_name + " (ID: " + str(device_id) + ")")
		controller_connected.emit(device_id, device_name)
		# Also emit through EventBus
		if EventBus:
			EventBus.controller_connected.emit(device_name)
	else:
		connected_controllers.erase(device_id)

		# If this was the active controller, switch to another or none
		if active_controller_id == device_id:
			if connected_controllers.size() > 0:
				active_controller_id = connected_controllers.keys()[0]
				_detect_controller_type(active_controller_id, connected_controllers[active_controller_id])
			else:
				active_controller_id = -1
				current_controller_type = ControllerType.UNKNOWN

		LogManager.write_info("Controller disconnected: ID " + str(device_id))
		controller_disconnected.emit(device_id)
		# Also emit through EventBus
		if EventBus:
			EventBus.controller_disconnected.emit()


## Detect the type of controller based on name
func _detect_controller_type(device_id: int, device_name: String) -> void:
	var name_lower = device_name.to_lower()
	var old_type = current_controller_type

	# Check for Steam Deck first (highest priority)
	if name_lower.contains("steam deck") or name_lower.contains("steamdeck"):
		current_controller_type = ControllerType.STEAM_DECK
	# Check for Steam Controller
	elif name_lower.contains("steam controller") or name_lower.contains("valve"):
		current_controller_type = ControllerType.STEAM_CONTROLLER
	# Check for Xbox controllers
	elif name_lower.contains("xbox") or name_lower.contains("xinput") or name_lower.contains("x-box"):
		current_controller_type = ControllerType.XBOX
	# Check for PlayStation controllers
	elif name_lower.contains("playstation") or name_lower.contains("dualshock") or name_lower.contains("dualsense") or name_lower.contains("ps4") or name_lower.contains("ps5") or name_lower.contains("sony"):
		current_controller_type = ControllerType.PLAYSTATION
	# Check for Nintendo controllers
	elif name_lower.contains("nintendo") or name_lower.contains("pro controller") or name_lower.contains("joy-con") or name_lower.contains("switch"):
		current_controller_type = ControllerType.NINTENDO
	else:
		# Default to Xbox layout (most common on PC)
		current_controller_type = ControllerType.XBOX

	if old_type != current_controller_type:
		LogManager.write_info("Controller type detected: " + ControllerType.keys()[current_controller_type])
		controller_type_changed.emit(current_controller_type)
		# Also emit through EventBus
		if EventBus:
			EventBus.controller_type_changed.emit(current_controller_type)

# ============================================================================
# RUMBLE / HAPTIC FEEDBACK
# ============================================================================

## Trigger rumble/vibration on the active controller
## @param weak_magnitude: Low-frequency rumble (0.0 to 1.0)
## @param strong_magnitude: High-frequency rumble (0.0 to 1.0)
## @param duration: Duration in seconds
func rumble(weak_magnitude: float = 0.5, strong_magnitude: float = 0.5, duration: float = 0.2) -> void:
	if not rumble_enabled or active_controller_id < 0:
		return

	# Apply intensity multiplier
	weak_magnitude *= rumble_intensity
	strong_magnitude *= rumble_intensity

	# Clamp values
	weak_magnitude = clampf(weak_magnitude, 0.0, 1.0)
	strong_magnitude = clampf(strong_magnitude, 0.0, 1.0)

	# Start vibration
	Input.start_joy_vibration(active_controller_id, weak_magnitude, strong_magnitude, duration)


## Stop any active rumble
func stop_rumble() -> void:
	if active_controller_id >= 0:
		Input.stop_joy_vibration(active_controller_id)


## Light rumble for UI feedback
func rumble_light() -> void:
	rumble(0.1, 0.0, 0.05)


## Medium rumble for actions
func rumble_medium() -> void:
	rumble(0.3, 0.2, 0.15)


## Heavy rumble for impacts
func rumble_heavy() -> void:
	rumble(0.6, 0.8, 0.3)


## Pulse rumble (multiple short bursts)
func rumble_pulse(count: int = 3, interval: float = 0.1) -> void:
	for i in range(count):
		rumble(0.4, 0.3, interval * 0.5)
		await get_tree().create_timer(interval).timeout


## EventBus handler for haptic feedback requests
## Converts intensity (0.0-1.0) to appropriate rumble levels
func _on_haptic_feedback_requested(intensity: float, duration: float) -> void:
	if not rumble_enabled:
		return
	# Scale intensity to weak/strong magnitudes
	var weak = intensity * 0.5
	var strong = intensity * 0.8
	rumble(weak, strong, duration)

# ============================================================================
# INPUT HELPERS
# ============================================================================

## Get the current analog stick values (left stick)
func get_left_stick() -> Vector2:
	if active_controller_id < 0:
		return Vector2.ZERO

	var x = Input.get_joy_axis(active_controller_id, JOY_AXIS_LEFT_X)
	var y = Input.get_joy_axis(active_controller_id, JOY_AXIS_LEFT_Y)

	# Apply deadzone
	var stick = Vector2(x, y)
	if stick.length() < stick_deadzone:
		return Vector2.ZERO

	return stick


## Get the current analog stick values (right stick)
func get_right_stick() -> Vector2:
	if active_controller_id < 0:
		return Vector2.ZERO

	var x = Input.get_joy_axis(active_controller_id, JOY_AXIS_RIGHT_X)
	var y = Input.get_joy_axis(active_controller_id, JOY_AXIS_RIGHT_Y)

	# Apply deadzone
	var stick = Vector2(x, y)
	if stick.length() < stick_deadzone:
		return Vector2.ZERO

	return stick


## Get the left trigger value (0.0 to 1.0)
func get_left_trigger() -> float:
	if active_controller_id < 0:
		return 0.0

	var value = Input.get_joy_axis(active_controller_id, JOY_AXIS_TRIGGER_LEFT)
	return value if value > trigger_deadzone else 0.0


## Get the right trigger value (0.0 to 1.0)
func get_right_trigger() -> float:
	if active_controller_id < 0:
		return 0.0

	var value = Input.get_joy_axis(active_controller_id, JOY_AXIS_TRIGGER_RIGHT)
	return value if value > trigger_deadzone else 0.0


## Check if we're in controller mode
func is_controller_mode() -> bool:
	return current_mode == InputMode.CONTROLLER


## Check if we're in keyboard/mouse mode
func is_keyboard_mouse_mode() -> bool:
	return current_mode == InputMode.KEYBOARD_MOUSE


## Check if any controller is connected
func has_controller() -> bool:
	return connected_controllers.size() > 0


## Get the name of the active controller
func get_active_controller_name() -> String:
	if active_controller_id >= 0 and connected_controllers.has(active_controller_id):
		return connected_controllers[active_controller_id]
	return ""

# ============================================================================
# FOCUS MANAGEMENT
# ============================================================================

## Force focus to a specific control
func focus_control(control: Control) -> void:
	if control and control.is_visible_in_tree() and control.focus_mode != Control.FOCUS_NONE:
		control.grab_focus()


## Store the current focus for later restoration
func store_focus() -> void:
	var viewport = get_viewport()
	if viewport:
		_last_focused_control = viewport.gui_get_focus_owner()


## Restore previously stored focus
func restore_focus() -> void:
	if _last_focused_control and is_instance_valid(_last_focused_control):
		if _last_focused_control.is_visible_in_tree():
			_last_focused_control.grab_focus()
	_last_focused_control = null

# ============================================================================
# DEBUG
# ============================================================================

## Get debug info about controller state
func get_debug_info() -> Dictionary:
	return {
		"current_mode": InputMode.keys()[current_mode],
		"controller_type": ControllerType.keys()[current_controller_type],
		"active_controller_id": active_controller_id,
		"connected_controllers": connected_controllers,
		"using_steam_input": using_steam_input,
		"left_stick": get_left_stick(),
		"right_stick": get_right_stick(),
		"left_trigger": get_left_trigger(),
		"right_trigger": get_right_trigger()
	}
