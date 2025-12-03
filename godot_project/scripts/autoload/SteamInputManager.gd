extends Node
## SteamInputManager - Steam Input API integration for controller support
##
## This autoload handles Steam Input API features:
## - Action sets for different game contexts (menus, gameplay, dialogues)
## - Controller glyphs from Steam
## - Haptic feedback through Steam
## - Controller configuration through Steam's Big Picture
##
## Requires GodotSteam to be properly initialized

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when Steam Input is initialized
signal steam_input_initialized()

## Emitted when Steam Input fails to initialize
signal steam_input_failed(reason: String)

## Emitted when action set changes
signal action_set_changed(action_set_name: String)

## Emitted when controller glyph is requested
signal glyph_requested(action_name: String, glyph_path: String)

# ============================================================================
# CONSTANTS - ACTION SETS
# ============================================================================

## Action set for menu navigation
const ACTION_SET_MENU = "MenuControls"

## Action set for gameplay
const ACTION_SET_GAMEPLAY = "GameplayControls"

## Action set for dialogue/cutscenes
const ACTION_SET_DIALOGUE = "DialogueControls"

# ============================================================================
# CONSTANTS - DIGITAL ACTIONS
# ============================================================================

## Menu actions
const ACTION_MENU_SELECT = "menu_select"
const ACTION_MENU_CANCEL = "menu_cancel"
const ACTION_MENU_UP = "menu_up"
const ACTION_MENU_DOWN = "menu_down"
const ACTION_MENU_LEFT = "menu_left"
const ACTION_MENU_RIGHT = "menu_right"
const ACTION_MENU_PAUSE = "menu_pause"

## Gameplay actions
const ACTION_FIRE = "fire"
const ACTION_ALT_FIRE = "alt_fire"
const ACTION_INTERACT = "interact"
const ACTION_APPROVE = "approve"
const ACTION_REJECT = "reject"
const ACTION_PAUSE = "pause"
const ACTION_QUICK_MENU = "quick_menu"

## Dialogue actions
const ACTION_ADVANCE = "advance"
const ACTION_SKIP = "skip"
const ACTION_CHOICE_UP = "choice_up"
const ACTION_CHOICE_DOWN = "choice_down"
const ACTION_CHOICE_SELECT = "choice_select"

# ============================================================================
# CONSTANTS - ANALOG ACTIONS
# ============================================================================

const ACTION_CURSOR_MOVE = "cursor_move"
const ACTION_CAMERA_MOVE = "camera_move"

# ============================================================================
# STATE
# ============================================================================

## Whether Steam Input is initialized and available
var is_initialized: bool = false

## Current action set handle
var current_action_set_handle: int = 0

## Current action set name
var current_action_set_name: String = ""

## All connected Steam Input controllers
var connected_controllers: Array = []

## Cached action handles
var _action_set_handles: Dictionary = {}
var _digital_action_handles: Dictionary = {}
var _analog_action_handles: Dictionary = {}

## Glyph cache to avoid repeated lookups
var _glyph_cache: Dictionary = {}

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	# Wait a frame for Steam to initialize
	await get_tree().process_frame
	_initialize_steam_input()


func _process(_delta: float) -> void:
	if not is_initialized:
		return

	# Run Steam Input frame (required for Steam Input to work)
	if Steam.isSteamRunning():
		# Note: Steam.run_callbacks() is called in SteamManager already
		pass


func _initialize_steam_input() -> void:
	# Check if Steam is running
	if not Steam.isSteamRunning():
		LogManager.write_warning("SteamInputManager: Steam is not running, Steam Input disabled")
		steam_input_failed.emit("Steam not running")
		return

	# Check if we're in dev mode
	if Global.DEV_MODE:
		LogManager.write_info("SteamInputManager: DEV_MODE enabled, Steam Input disabled")
		steam_input_failed.emit("DEV_MODE enabled")
		return

	# Initialize Steam Input
	var init_result = Steam.inputInit(false)  # false = not running in background

	if not init_result:
		LogManager.write_warning("SteamInputManager: Failed to initialize Steam Input")
		steam_input_failed.emit("inputInit failed")
		return

	# Give Steam Input a moment to enumerate controllers
	await get_tree().create_timer(0.5).timeout

	# Get connected controllers
	_refresh_controllers()

	if connected_controllers.size() == 0:
		LogManager.write_info("SteamInputManager: No Steam Input controllers detected")
		# Still consider initialized - controllers might connect later
	else:
		LogManager.write_info("SteamInputManager: " + str(connected_controllers.size()) + " controller(s) detected")

	# Cache action set handles
	_cache_action_handles()

	# Set initial action set to menu
	set_action_set(ACTION_SET_MENU)

	is_initialized = true

	# Notify ControllerManager that we're using Steam Input
	if ControllerManager:
		ControllerManager.using_steam_input = true

	LogManager.write_info("SteamInputManager: Steam Input initialized successfully")
	steam_input_initialized.emit()

# ============================================================================
# CONTROLLER MANAGEMENT
# ============================================================================

## Refresh the list of connected Steam Input controllers
func _refresh_controllers() -> void:
	connected_controllers = Steam.getConnectedControllers()


## Get the primary controller handle
func get_primary_controller() -> int:
	if connected_controllers.size() > 0:
		return connected_controllers[0]
	return 0

# ============================================================================
# ACTION HANDLE CACHING
# ============================================================================

## Cache all action handles for faster lookup
func _cache_action_handles() -> void:
	# Cache action set handles
	_action_set_handles[ACTION_SET_MENU] = Steam.getActionSetHandle(ACTION_SET_MENU)
	_action_set_handles[ACTION_SET_GAMEPLAY] = Steam.getActionSetHandle(ACTION_SET_GAMEPLAY)
	_action_set_handles[ACTION_SET_DIALOGUE] = Steam.getActionSetHandle(ACTION_SET_DIALOGUE)

	# Cache digital action handles - Menu
	_digital_action_handles[ACTION_MENU_SELECT] = Steam.getDigitalActionHandle(ACTION_MENU_SELECT)
	_digital_action_handles[ACTION_MENU_CANCEL] = Steam.getDigitalActionHandle(ACTION_MENU_CANCEL)
	_digital_action_handles[ACTION_MENU_UP] = Steam.getDigitalActionHandle(ACTION_MENU_UP)
	_digital_action_handles[ACTION_MENU_DOWN] = Steam.getDigitalActionHandle(ACTION_MENU_DOWN)
	_digital_action_handles[ACTION_MENU_LEFT] = Steam.getDigitalActionHandle(ACTION_MENU_LEFT)
	_digital_action_handles[ACTION_MENU_RIGHT] = Steam.getDigitalActionHandle(ACTION_MENU_RIGHT)
	_digital_action_handles[ACTION_MENU_PAUSE] = Steam.getDigitalActionHandle(ACTION_MENU_PAUSE)

	# Cache digital action handles - Gameplay
	_digital_action_handles[ACTION_FIRE] = Steam.getDigitalActionHandle(ACTION_FIRE)
	_digital_action_handles[ACTION_ALT_FIRE] = Steam.getDigitalActionHandle(ACTION_ALT_FIRE)
	_digital_action_handles[ACTION_INTERACT] = Steam.getDigitalActionHandle(ACTION_INTERACT)
	_digital_action_handles[ACTION_APPROVE] = Steam.getDigitalActionHandle(ACTION_APPROVE)
	_digital_action_handles[ACTION_REJECT] = Steam.getDigitalActionHandle(ACTION_REJECT)
	_digital_action_handles[ACTION_PAUSE] = Steam.getDigitalActionHandle(ACTION_PAUSE)
	_digital_action_handles[ACTION_QUICK_MENU] = Steam.getDigitalActionHandle(ACTION_QUICK_MENU)

	# Cache digital action handles - Dialogue
	_digital_action_handles[ACTION_ADVANCE] = Steam.getDigitalActionHandle(ACTION_ADVANCE)
	_digital_action_handles[ACTION_SKIP] = Steam.getDigitalActionHandle(ACTION_SKIP)
	_digital_action_handles[ACTION_CHOICE_UP] = Steam.getDigitalActionHandle(ACTION_CHOICE_UP)
	_digital_action_handles[ACTION_CHOICE_DOWN] = Steam.getDigitalActionHandle(ACTION_CHOICE_DOWN)
	_digital_action_handles[ACTION_CHOICE_SELECT] = Steam.getDigitalActionHandle(ACTION_CHOICE_SELECT)

	# Cache analog action handles
	_analog_action_handles[ACTION_CURSOR_MOVE] = Steam.getAnalogActionHandle(ACTION_CURSOR_MOVE)
	_analog_action_handles[ACTION_CAMERA_MOVE] = Steam.getAnalogActionHandle(ACTION_CAMERA_MOVE)

	LogManager.write_info("SteamInputManager: Cached " + str(_digital_action_handles.size()) + " digital actions, " + str(_analog_action_handles.size()) + " analog actions")

# ============================================================================
# ACTION SETS
# ============================================================================

## Set the current action set for all controllers
func set_action_set(action_set_name: String) -> void:
	if not is_initialized:
		return

	if not _action_set_handles.has(action_set_name):
		LogManager.write_warning("SteamInputManager: Unknown action set: " + action_set_name)
		return

	var handle = _action_set_handles[action_set_name]

	for controller in connected_controllers:
		Steam.activateActionSet(controller, handle)

	current_action_set_handle = handle
	current_action_set_name = action_set_name

	LogManager.write_info("SteamInputManager: Action set changed to " + action_set_name)
	action_set_changed.emit(action_set_name)


## Switch to menu controls
func use_menu_controls() -> void:
	set_action_set(ACTION_SET_MENU)


## Switch to gameplay controls
func use_gameplay_controls() -> void:
	set_action_set(ACTION_SET_GAMEPLAY)


## Switch to dialogue controls
func use_dialogue_controls() -> void:
	set_action_set(ACTION_SET_DIALOGUE)

# ============================================================================
# INPUT READING
# ============================================================================

## Get the state of a digital action
func get_digital_action(action_name: String) -> bool:
	if not is_initialized:
		return false

	var controller = get_primary_controller()
	if controller == 0:
		return false

	if not _digital_action_handles.has(action_name):
		return false

	var action_handle = _digital_action_handles[action_name]
	var action_data = Steam.getDigitalActionData(controller, action_handle)

	return action_data.state if action_data.has("state") else false


## Get the state of an analog action
func get_analog_action(action_name: String) -> Vector2:
	if not is_initialized:
		return Vector2.ZERO

	var controller = get_primary_controller()
	if controller == 0:
		return Vector2.ZERO

	if not _analog_action_handles.has(action_name):
		return Vector2.ZERO

	var action_handle = _analog_action_handles[action_name]
	var action_data = Steam.getAnalogActionData(controller, action_handle)

	if action_data.has("x") and action_data.has("y"):
		return Vector2(action_data.x, action_data.y)

	return Vector2.ZERO


## Check if a digital action was just pressed this frame
func is_action_just_pressed(action_name: String) -> bool:
	# Steam Input doesn't have built-in "just pressed" detection
	# This would need to be tracked manually with previous frame state
	return get_digital_action(action_name)

# ============================================================================
# GLYPHS
# ============================================================================

## Get the glyph path for an action
## Returns the path to a Steam-provided button glyph image
func get_glyph_for_action(action_name: String, size: int = 1) -> String:
	if not is_initialized:
		return ""

	var controller = get_primary_controller()
	if controller == 0:
		return ""

	# Check cache first
	var cache_key = action_name + "_" + str(size)
	if _glyph_cache.has(cache_key):
		return _glyph_cache[cache_key]

	# Get the action handle
	var action_handle = 0
	if _digital_action_handles.has(action_name):
		action_handle = _digital_action_handles[action_name]
	elif _analog_action_handles.has(action_name):
		action_handle = _analog_action_handles[action_name]

	if action_handle == 0:
		return ""

	# Get action origins (which buttons are bound to this action)
	var origins = []
	if _digital_action_handles.has(action_name):
		origins = Steam.getDigitalActionOrigins(controller, current_action_set_handle, action_handle)
	else:
		origins = Steam.getAnalogActionOrigins(controller, current_action_set_handle, action_handle)

	if origins.size() == 0:
		return ""

	# Get glyph for the first origin
	# size: 0 = small, 1 = medium, 2 = large
	var glyph_size = clampi(size, 0, 2)
	var glyph_path = Steam.getGlyphForActionOrigin(origins[0])

	# Cache and return
	_glyph_cache[cache_key] = glyph_path
	glyph_requested.emit(action_name, glyph_path)

	return glyph_path


## Clear the glyph cache (call when controller type changes)
func clear_glyph_cache() -> void:
	_glyph_cache.clear()

# ============================================================================
# HAPTICS
# ============================================================================

## Trigger haptic pulse on controller
## @param pad: 0 = left, 1 = right
## @param duration_microseconds: Duration in microseconds (max ~65535)
func trigger_haptic_pulse(pad: int = 0, duration_microseconds: int = 5000) -> void:
	if not is_initialized:
		return

	var controller = get_primary_controller()
	if controller == 0:
		return

	Steam.triggerHapticPulse(controller, pad, duration_microseconds)


## Trigger repeated haptic pulse
func trigger_repeated_haptic_pulse(pad: int = 0, duration_microseconds: int = 5000, off_microseconds: int = 5000, repeat: int = 1) -> void:
	if not is_initialized:
		return

	var controller = get_primary_controller()
	if controller == 0:
		return

	Steam.triggerRepeatedHapticPulse(controller, pad, duration_microseconds, off_microseconds, repeat, 0)


## Trigger vibration (for Xbox-style controllers)
## @param left_speed: Left motor speed (0-65535)
## @param right_speed: Right motor speed (0-65535)
func trigger_vibration(left_speed: int = 10000, right_speed: int = 10000) -> void:
	if not is_initialized:
		return

	var controller = get_primary_controller()
	if controller == 0:
		return

	Steam.triggerVibration(controller, left_speed, right_speed)


## Light haptic feedback for UI
func haptic_light() -> void:
	trigger_haptic_pulse(0, 2000)


## Medium haptic feedback for actions
func haptic_medium() -> void:
	trigger_haptic_pulse(0, 8000)
	trigger_haptic_pulse(1, 8000)


## Heavy haptic feedback for impacts
func haptic_heavy() -> void:
	trigger_vibration(30000, 40000)
	await get_tree().create_timer(0.15).timeout
	trigger_vibration(0, 0)

# ============================================================================
# CONFIGURATION
# ============================================================================

## Open Steam controller configuration overlay
func show_binding_panel() -> void:
	if not is_initialized:
		return

	var controller = get_primary_controller()
	if controller == 0:
		return

	Steam.showBindingPanel(controller)


## Show Steam on-screen keyboard
func show_floating_keyboard(mode: int = 0, x: int = 0, y: int = 0, width: int = 640, height: int = 360) -> bool:
	if not is_initialized:
		return false

	# mode: 0 = single line, 1 = multi-line
	return Steam.showFloatingGamepadTextInput(mode, x, y, width, height)

# ============================================================================
# DEBUG
# ============================================================================

## Get debug info about Steam Input state
func get_debug_info() -> Dictionary:
	return {
		"is_initialized": is_initialized,
		"current_action_set": current_action_set_name,
		"connected_controllers": connected_controllers.size(),
		"action_set_handles": _action_set_handles.size(),
		"digital_action_handles": _digital_action_handles.size(),
		"analog_action_handles": _analog_action_handles.size(),
		"glyph_cache_size": _glyph_cache.size()
	}
