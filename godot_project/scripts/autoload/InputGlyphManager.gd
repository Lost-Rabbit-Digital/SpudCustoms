extends Node
## InputGlyphManager - Manages controller button glyph/prompt display
##
## This autoload handles:
## - Loading and caching controller button glyph textures
## - Providing the correct glyph based on controller type
## - Text substitution for button prompts (e.g., "Press [A]" -> icon)
## - Supporting multiple controller types (Xbox, PlayStation, Nintendo, Steam Deck)

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when glyph set changes (controller type changed)
signal glyph_set_changed(controller_type: int)

## Emitted when a glyph texture is requested
signal glyph_loaded(action: String, texture: Texture2D)

# ============================================================================
# CONSTANTS - BUTTON NAMES
# ============================================================================

## Standard button names used throughout the system
const BUTTON_A = "button_a"
const BUTTON_B = "button_b"
const BUTTON_X = "button_x"
const BUTTON_Y = "button_y"
const BUTTON_LB = "button_lb"
const BUTTON_RB = "button_rb"
const BUTTON_LT = "button_lt"
const BUTTON_RT = "button_rt"
const BUTTON_BACK = "button_back"
const BUTTON_START = "button_start"
const BUTTON_L3 = "button_l3"
const BUTTON_R3 = "button_r3"
const DPAD_UP = "dpad_up"
const DPAD_DOWN = "dpad_down"
const DPAD_LEFT = "dpad_left"
const DPAD_RIGHT = "dpad_right"
const STICK_LEFT = "stick_left"
const STICK_RIGHT = "stick_right"

# ============================================================================
# GLYPH PATHS
# ============================================================================

## Base path for controller glyph assets
const GLYPH_BASE_PATH = "res://assets/sprites/controller_glyphs/"

## Subfolder paths for each controller type
const XBOX_PATH = "Xbox Series/"
const PS5_PATH = "PS5/"
const SWITCH_PATH = "Switch/"
const STEAM_DECK_PATH = "Steam Deck/"
const KEYBOARD_PATH = "Keyboard & Mouse/Dark/"

## Glyph mappings for different controller types
## Maps our standard button names to texture file names
var _glyph_mappings = {
	ControllerManager.ControllerType.XBOX: {
		BUTTON_A: XBOX_PATH + "XboxSeriesX_A.png",
		BUTTON_B: XBOX_PATH + "XboxSeriesX_B.png",
		BUTTON_X: XBOX_PATH + "XboxSeriesX_X.png",
		BUTTON_Y: XBOX_PATH + "XboxSeriesX_Y.png",
		BUTTON_LB: XBOX_PATH + "XboxSeriesX_LB.png",
		BUTTON_RB: XBOX_PATH + "XboxSeriesX_RB.png",
		BUTTON_LT: XBOX_PATH + "XboxSeriesX_LT.png",
		BUTTON_RT: XBOX_PATH + "XboxSeriesX_RT.png",
		BUTTON_BACK: XBOX_PATH + "XboxSeriesX_View.png",
		BUTTON_START: XBOX_PATH + "XboxSeriesX_Menu.png",
		BUTTON_L3: XBOX_PATH + "XboxSeriesX_Left_Stick_Click.png",
		BUTTON_R3: XBOX_PATH + "XboxSeriesX_Right_Stick_Click.png",
		DPAD_UP: XBOX_PATH + "XboxSeriesX_Dpad_Up.png",
		DPAD_DOWN: XBOX_PATH + "XboxSeriesX_Dpad_Down.png",
		DPAD_LEFT: XBOX_PATH + "XboxSeriesX_Dpad_Left.png",
		DPAD_RIGHT: XBOX_PATH + "XboxSeriesX_Dpad_Right.png",
		STICK_LEFT: XBOX_PATH + "XboxSeriesX_Left_Stick.png",
		STICK_RIGHT: XBOX_PATH + "XboxSeriesX_Right_Stick.png"
	},
	ControllerManager.ControllerType.PLAYSTATION: {
		BUTTON_A: PS5_PATH + "PS5_Cross.png",
		BUTTON_B: PS5_PATH + "PS5_Circle.png",
		BUTTON_X: PS5_PATH + "PS5_Square.png",
		BUTTON_Y: PS5_PATH + "PS5_Triangle.png",
		BUTTON_LB: PS5_PATH + "PS5_L1.png",
		BUTTON_RB: PS5_PATH + "PS5_R1.png",
		BUTTON_LT: PS5_PATH + "PS5_L2.png",
		BUTTON_RT: PS5_PATH + "PS5_R2.png",
		BUTTON_BACK: PS5_PATH + "PS5_Share.png",
		BUTTON_START: PS5_PATH + "PS5_Options.png",
		BUTTON_L3: PS5_PATH + "PS5_Left_Stick_Click.png",
		BUTTON_R3: PS5_PATH + "PS5_Right_Stick_Click.png",
		DPAD_UP: PS5_PATH + "PS5_Dpad_Up.png",
		DPAD_DOWN: PS5_PATH + "PS5_Dpad_Down.png",
		DPAD_LEFT: PS5_PATH + "PS5_Dpad_Left.png",
		DPAD_RIGHT: PS5_PATH + "PS5_Dpad_Right.png",
		STICK_LEFT: PS5_PATH + "PS5_Left_Stick.png",
		STICK_RIGHT: PS5_PATH + "PS5_Right_Stick.png"
	},
	ControllerManager.ControllerType.NINTENDO: {
		BUTTON_A: SWITCH_PATH + "Switch_B.png",  # Nintendo has swapped A/B positions
		BUTTON_B: SWITCH_PATH + "Switch_A.png",
		BUTTON_X: SWITCH_PATH + "Switch_Y.png",  # Nintendo has swapped X/Y positions
		BUTTON_Y: SWITCH_PATH + "Switch_X.png",
		BUTTON_LB: SWITCH_PATH + "Switch_L.png",
		BUTTON_RB: SWITCH_PATH + "Switch_R.png",
		BUTTON_LT: SWITCH_PATH + "Switch_ZL.png",
		BUTTON_RT: SWITCH_PATH + "Switch_ZR.png",
		BUTTON_BACK: SWITCH_PATH + "Switch_Minus.png",
		BUTTON_START: SWITCH_PATH + "Switch_Plus.png",
		BUTTON_L3: SWITCH_PATH + "Switch_Left_Stick_Click.png",
		BUTTON_R3: SWITCH_PATH + "Switch_Right_Stick_Click.png",
		DPAD_UP: SWITCH_PATH + "Switch_Dpad_Up.png",
		DPAD_DOWN: SWITCH_PATH + "Switch_Dpad_Down.png",
		DPAD_LEFT: SWITCH_PATH + "Switch_Dpad_Left.png",
		DPAD_RIGHT: SWITCH_PATH + "Switch_Dpad_Right.png",
		STICK_LEFT: SWITCH_PATH + "Switch_Left_Stick.png",
		STICK_RIGHT: SWITCH_PATH + "Switch_Right_Stick.png"
	},
	ControllerManager.ControllerType.STEAM_DECK: {
		BUTTON_A: STEAM_DECK_PATH + "SteamDeck_A.png",
		BUTTON_B: STEAM_DECK_PATH + "SteamDeck_B.png",
		BUTTON_X: STEAM_DECK_PATH + "SteamDeck_X.png",
		BUTTON_Y: STEAM_DECK_PATH + "SteamDeck_Y.png",
		BUTTON_LB: STEAM_DECK_PATH + "SteamDeck_L1.png",
		BUTTON_RB: STEAM_DECK_PATH + "SteamDeck_R1.png",
		BUTTON_LT: STEAM_DECK_PATH + "SteamDeck_L2.png",
		BUTTON_RT: STEAM_DECK_PATH + "SteamDeck_R2.png",
		BUTTON_BACK: STEAM_DECK_PATH + "SteamDeck_Square.png",
		BUTTON_START: STEAM_DECK_PATH + "SteamDeck_Menu.png",
		BUTTON_L3: STEAM_DECK_PATH + "SteamDeck_Left_Stick_Click.png",
		BUTTON_R3: STEAM_DECK_PATH + "SteamDeck_Right_Stick_Click.png",
		DPAD_UP: STEAM_DECK_PATH + "SteamDeck_Dpad_Up.png",
		DPAD_DOWN: STEAM_DECK_PATH + "SteamDeck_Dpad_Down.png",
		DPAD_LEFT: STEAM_DECK_PATH + "SteamDeck_Dpad_Left.png",
		DPAD_RIGHT: STEAM_DECK_PATH + "SteamDeck_Dpad_Right.png",
		STICK_LEFT: STEAM_DECK_PATH + "SteamDeck_Left_Stick.png",
		STICK_RIGHT: STEAM_DECK_PATH + "SteamDeck_Right_Stick.png"
	}
}

## Keyboard fallback mappings
var _keyboard_mappings = {
	BUTTON_A: KEYBOARD_PATH + "Enter_Key_Dark.png",
	BUTTON_B: KEYBOARD_PATH + "Esc_Key_Dark.png",
	BUTTON_X: KEYBOARD_PATH + "Space_Key_Dark.png",
	BUTTON_Y: KEYBOARD_PATH + "E_Key_Dark.png",
	BUTTON_LB: KEYBOARD_PATH + "Q_Key_Dark.png",
	BUTTON_RB: KEYBOARD_PATH + "E_Key_Dark.png",
	BUTTON_LT: KEYBOARD_PATH + "Ctrl_Key_Dark.png",
	BUTTON_RT: KEYBOARD_PATH + "Mouse_Left_Key_Dark.png",
	BUTTON_BACK: KEYBOARD_PATH + "Tab_Key_Dark.png",
	BUTTON_START: KEYBOARD_PATH + "Esc_Key_Dark.png",
	DPAD_UP: KEYBOARD_PATH + "W_Key_Dark.png",
	DPAD_DOWN: KEYBOARD_PATH + "S_Key_Dark.png",
	DPAD_LEFT: KEYBOARD_PATH + "A_Key_Dark.png",
	DPAD_RIGHT: KEYBOARD_PATH + "D_Key_Dark.png"
}

## Action to button mappings (maps game actions to button names)
var _action_button_map = {
	"controller_accept": BUTTON_A,
	"controller_cancel": BUTTON_B,
	"controller_alt": BUTTON_X,
	"controller_menu": BUTTON_Y,
	"controller_lb": BUTTON_LB,
	"controller_rb": BUTTON_RB,
	"controller_lt": BUTTON_LT,
	"controller_rt": BUTTON_RT,
	"ui_accept": BUTTON_A,
	"ui_cancel": BUTTON_B,
	"ui_up": DPAD_UP,
	"ui_down": DPAD_DOWN,
	"ui_left": DPAD_LEFT,
	"ui_right": DPAD_RIGHT,
	"pause": BUTTON_START,
	"primary_interaction": BUTTON_RT,
	"secondary_interaction": BUTTON_LT
}

# ============================================================================
# STATE
# ============================================================================

## Current controller type for glyph display
var current_controller_type: int = ControllerManager.ControllerType.XBOX

## Cache of loaded textures
var _texture_cache: Dictionary = {}

## Whether to show keyboard glyphs when in keyboard mode
var show_keyboard_in_kb_mode: bool = true

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	# Connect to ControllerManager (with safety checks to prevent duplicate connections)
	if ControllerManager:
		if not ControllerManager.controller_type_changed.is_connected(_on_controller_type_changed):
			ControllerManager.controller_type_changed.connect(_on_controller_type_changed)
		if not ControllerManager.input_mode_changed.is_connected(_on_input_mode_changed):
			ControllerManager.input_mode_changed.connect(_on_input_mode_changed)
		current_controller_type = ControllerManager.current_controller_type

	# Create default glyph directory if it doesn't exist
	_ensure_glyph_directory()

	LogManager.write_info("InputGlyphManager initialized")


func _ensure_glyph_directory() -> void:
	# Check if glyph directory exists (glyphs are in sprites, not user_interface)
	var dir = DirAccess.open("res://assets/sprites/")
	if dir:
		if not dir.dir_exists("controller_glyphs"):
			LogManager.write_warning("InputGlyphManager: Controller glyph directory not found at res://assets/sprites/controller_glyphs/. Glyphs will use fallbacks.")

# ============================================================================
# GLYPH RETRIEVAL
# ============================================================================

## Get the texture for a button
func get_button_texture(button_name: String) -> Texture2D:
	# Check cache first
	var cache_key = str(current_controller_type) + "_" + button_name
	if _texture_cache.has(cache_key):
		return _texture_cache[cache_key]

	# Try to load the texture
	var texture = _load_button_texture(button_name)
	if texture:
		_texture_cache[cache_key] = texture

	return texture


## Get the texture for an action
func get_action_texture(action_name: String) -> Texture2D:
	var button_name = _action_button_map.get(action_name, "")
	if button_name.is_empty():
		return null

	return get_button_texture(button_name)


## Get button name for an action
func get_button_for_action(action_name: String) -> String:
	return _action_button_map.get(action_name, "")


func _load_button_texture(button_name: String) -> Texture2D:
	# Get the mapping for current controller type
	var mappings = _glyph_mappings.get(current_controller_type, {})

	# Fall back to Xbox if no mapping found
	if mappings.is_empty():
		mappings = _glyph_mappings.get(ControllerManager.ControllerType.XBOX, {})

	var filename = mappings.get(button_name, "")
	if filename.is_empty():
		return null

	var path = GLYPH_BASE_PATH + filename

	# Try to load the texture
	if ResourceLoader.exists(path):
		var texture = load(path)
		if texture:
			return texture

	# If texture doesn't exist, return null (will use text fallback)
	return null

# ============================================================================
# TEXT DISPLAY
# ============================================================================

## Get the display text for a button (used when texture is unavailable)
func get_button_text(button_name: String) -> String:
	match current_controller_type:
		ControllerManager.ControllerType.PLAYSTATION:
			return _get_playstation_text(button_name)
		ControllerManager.ControllerType.NINTENDO:
			return _get_nintendo_text(button_name)
		_:
			return _get_xbox_text(button_name)


func _get_xbox_text(button_name: String) -> String:
	match button_name:
		BUTTON_A: return "A"
		BUTTON_B: return "B"
		BUTTON_X: return "X"
		BUTTON_Y: return "Y"
		BUTTON_LB: return "LB"
		BUTTON_RB: return "RB"
		BUTTON_LT: return "LT"
		BUTTON_RT: return "RT"
		BUTTON_BACK: return "View"
		BUTTON_START: return "Menu"
		BUTTON_L3: return "L3"
		BUTTON_R3: return "R3"
		DPAD_UP: return "D-Up"
		DPAD_DOWN: return "D-Down"
		DPAD_LEFT: return "D-Left"
		DPAD_RIGHT: return "D-Right"
		STICK_LEFT: return "L-Stick"
		STICK_RIGHT: return "R-Stick"
		_: return button_name


func _get_playstation_text(button_name: String) -> String:
	match button_name:
		BUTTON_A: return "X"
		BUTTON_B: return "O"
		BUTTON_X: return "[]"
		BUTTON_Y: return "/\\"
		BUTTON_LB: return "L1"
		BUTTON_RB: return "R1"
		BUTTON_LT: return "L2"
		BUTTON_RT: return "R2"
		BUTTON_BACK: return "Share"
		BUTTON_START: return "Options"
		BUTTON_L3: return "L3"
		BUTTON_R3: return "R3"
		DPAD_UP: return "D-Up"
		DPAD_DOWN: return "D-Down"
		DPAD_LEFT: return "D-Left"
		DPAD_RIGHT: return "D-Right"
		STICK_LEFT: return "L-Stick"
		STICK_RIGHT: return "R-Stick"
		_: return button_name


func _get_nintendo_text(button_name: String) -> String:
	match button_name:
		BUTTON_A: return "B"  # Nintendo has swapped labels
		BUTTON_B: return "A"
		BUTTON_X: return "Y"
		BUTTON_Y: return "X"
		BUTTON_LB: return "L"
		BUTTON_RB: return "R"
		BUTTON_LT: return "ZL"
		BUTTON_RT: return "ZR"
		BUTTON_BACK: return "-"
		BUTTON_START: return "+"
		BUTTON_L3: return "L-Click"
		BUTTON_R3: return "R-Click"
		DPAD_UP: return "D-Up"
		DPAD_DOWN: return "D-Down"
		DPAD_LEFT: return "D-Left"
		DPAD_RIGHT: return "D-Right"
		STICK_LEFT: return "L-Stick"
		STICK_RIGHT: return "R-Stick"
		_: return button_name

# ============================================================================
# PROMPT TEXT SUBSTITUTION
# ============================================================================

## Replace button placeholders in text with appropriate glyph names
## e.g., "Press {accept} to continue" -> "Press A to continue"
func format_prompt_text(text: String) -> String:
	var result = text

	# Replace action placeholders
	for action in _action_button_map.keys():
		var placeholder = "{" + action + "}"
		if result.contains(placeholder):
			var button_name = _action_button_map[action]
			var button_text = get_button_text(button_name)
			result = result.replace(placeholder, "[" + button_text + "]")

	# Replace direct button placeholders
	for button in [BUTTON_A, BUTTON_B, BUTTON_X, BUTTON_Y, BUTTON_LB, BUTTON_RB, BUTTON_LT, BUTTON_RT]:
		var placeholder = "{" + button + "}"
		if result.contains(placeholder):
			var button_text = get_button_text(button)
			result = result.replace(placeholder, "[" + button_text + "]")

	return result

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_controller_type_changed(new_type: int) -> void:
	current_controller_type = new_type
	_texture_cache.clear()  # Clear cache to reload textures
	glyph_set_changed.emit(new_type)
	LogManager.write_info("InputGlyphManager: Controller type changed to " + ControllerManager.ControllerType.keys()[new_type])


func _on_input_mode_changed(mode: int) -> void:
	# Could switch to keyboard glyphs here if desired
	if show_keyboard_in_kb_mode and mode == ControllerManager.InputMode.KEYBOARD_MOUSE:
		# Clear cache to switch to keyboard textures
		_texture_cache.clear()
	else:
		_texture_cache.clear()

# ============================================================================
# BUTTON PROMPT HELPERS
# ============================================================================

## Get a formatted prompt string for common actions
func get_confirm_prompt() -> String:
	var button = get_button_text(BUTTON_A)
	if ControllerManager and ControllerManager.is_keyboard_mouse_mode():
		return "[Enter]"
	return "[" + button + "]"


func get_cancel_prompt() -> String:
	var button = get_button_text(BUTTON_B)
	if ControllerManager and ControllerManager.is_keyboard_mouse_mode():
		return "[Esc]"
	return "[" + button + "]"


func get_fire_prompt() -> String:
	var button = get_button_text(BUTTON_RT)
	if ControllerManager and ControllerManager.is_keyboard_mouse_mode():
		return "[Left Click]"
	return "[" + button + "]"


func get_alt_fire_prompt() -> String:
	var button = get_button_text(BUTTON_LT)
	if ControllerManager and ControllerManager.is_keyboard_mouse_mode():
		return "[Right Click]"
	return "[" + button + "]"


func get_pause_prompt() -> String:
	var button = get_button_text(BUTTON_START)
	if ControllerManager and ControllerManager.is_keyboard_mouse_mode():
		return "[Esc]"
	return "[" + button + "]"

# ============================================================================
# UI HELPER METHODS
# ============================================================================

## Get navigation hint text for menus (e.g., "A Select   B Back")
func get_menu_navigation_hint() -> String:
	if ControllerManager and ControllerManager.is_keyboard_mouse_mode():
		return ""  # Don't show hints in keyboard mode - mouse is intuitive

	var select_text = get_button_text(BUTTON_A) + " Select"
	var back_text = get_button_text(BUTTON_B) + " Back"
	return select_text + "     " + back_text


## Get dialog advancement hint
func get_dialog_advance_hint() -> String:
	if ControllerManager and ControllerManager.is_keyboard_mouse_mode():
		return "[Space] or [Click] to continue"
	return "[" + get_button_text(BUTTON_A) + "] to continue"


## Get skip hint for cutscenes/dialogs
func get_skip_hint() -> String:
	if ControllerManager and ControllerManager.is_keyboard_mouse_mode():
		return "[Esc] to skip"
	return "[" + get_button_text(BUTTON_START) + "] to skip"


## Check if currently in controller mode
func is_controller_mode() -> bool:
	return ControllerManager and ControllerManager.is_controller_mode()


## Get interact prompt based on input mode
func get_interact_prompt() -> String:
	if ControllerManager and ControllerManager.is_keyboard_mouse_mode():
		return "Click"
	return "Press " + get_fire_prompt()


## Get drag prompt based on input mode
func get_drag_prompt() -> String:
	if ControllerManager and ControllerManager.is_keyboard_mouse_mode():
		return "Drag"
	return "Use stick and " + get_confirm_prompt() + " to grab"


# ============================================================================
# DEBUG
# ============================================================================

func get_debug_info() -> Dictionary:
	return {
		"current_controller_type": ControllerManager.ControllerType.keys()[current_controller_type],
		"cached_textures": _texture_cache.size(),
		"action_mappings": _action_button_map.size()
	}
