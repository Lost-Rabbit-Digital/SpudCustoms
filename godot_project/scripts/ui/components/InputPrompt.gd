@tool
extends HBoxContainer
class_name InputPrompt
## InputPrompt - A reusable UI component that displays controller/keyboard glyphs
##
## Shows the appropriate button icon or text based on current input mode.
## Automatically updates when the player switches between controller and keyboard.

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when the prompt display updates
signal prompt_updated()

# ============================================================================
# EXPORTS
# ============================================================================

## The action to display (e.g., "ui_accept", "primary_interaction")
@export var action: String = "ui_accept":
	set(value):
		action = value
		_update_display()

## Optional text to show after the glyph (e.g., "to confirm")
@export var label_text: String = "":
	set(value):
		label_text = value
		_update_label()

## Size of the glyph icon
@export var glyph_size: Vector2 = Vector2(32, 32):
	set(value):
		glyph_size = value
		_update_display()

## Whether to show text fallback in brackets when no texture available
@export var show_text_in_brackets: bool = true

## Font size for text fallback
@export var text_font_size: int = 16

# ============================================================================
# NODES
# ============================================================================

var _glyph_texture: TextureRect
var _text_label: Label
var _description_label: Label

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	_setup_nodes()
	_connect_signals()
	_update_display()


func _setup_nodes() -> void:
	# Create glyph texture rect
	_glyph_texture = TextureRect.new()
	_glyph_texture.name = "GlyphTexture"
	_glyph_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_glyph_texture.custom_minimum_size = glyph_size
	_glyph_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(_glyph_texture)

	# Create text fallback label (shown when no texture)
	_text_label = Label.new()
	_text_label.name = "TextLabel"
	_text_label.add_theme_font_size_override("font_size", text_font_size)
	_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_text_label)

	# Create description label
	_description_label = Label.new()
	_description_label.name = "DescriptionLabel"
	_description_label.add_theme_font_size_override("font_size", text_font_size)
	_description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_description_label)

	# Set container properties
	add_theme_constant_override("separation", 8)


func _connect_signals() -> void:
	if Engine.is_editor_hint():
		return

	# Connect to InputGlyphManager for updates
	if InputGlyphManager:
		if not InputGlyphManager.glyph_set_changed.is_connected(_on_glyph_set_changed):
			InputGlyphManager.glyph_set_changed.connect(_on_glyph_set_changed)

	# Connect to ControllerManager for input mode changes
	if ControllerManager:
		if not ControllerManager.input_mode_changed.is_connected(_on_input_mode_changed):
			ControllerManager.input_mode_changed.connect(_on_input_mode_changed)

# ============================================================================
# DISPLAY UPDATE
# ============================================================================

func _update_display() -> void:
	if not is_instance_valid(_glyph_texture) or not is_instance_valid(_text_label):
		return

	# Update glyph size
	_glyph_texture.custom_minimum_size = glyph_size

	if Engine.is_editor_hint():
		_show_editor_preview()
		return

	# Try to get texture from InputGlyphManager
	var texture: Texture2D = null
	if InputGlyphManager:
		texture = InputGlyphManager.get_action_texture(action)

	if texture:
		# Show texture
		_glyph_texture.texture = texture
		_glyph_texture.visible = true
		_text_label.visible = false
	else:
		# Show text fallback
		_glyph_texture.visible = false
		_text_label.visible = true
		_text_label.text = _get_text_prompt()

	_update_label()
	prompt_updated.emit()


func _show_editor_preview() -> void:
	# Show placeholder in editor
	_glyph_texture.visible = false
	_text_label.visible = true
	_text_label.text = "[" + action + "]"
	_update_label()


func _update_label() -> void:
	if is_instance_valid(_description_label):
		_description_label.text = label_text
		_description_label.visible = not label_text.is_empty()


func _get_text_prompt() -> String:
	var button_text := ""

	if InputGlyphManager:
		var button_name = InputGlyphManager.get_button_for_action(action)
		if not button_name.is_empty():
			button_text = InputGlyphManager.get_button_text(button_name)

	# Fallback to action name if nothing found
	if button_text.is_empty():
		button_text = _action_to_readable(action)

	if show_text_in_brackets:
		return "[" + button_text + "]"
	return button_text


func _action_to_readable(action_name: String) -> String:
	# Convert action name to readable text
	match action_name:
		"ui_accept": return "Enter"
		"ui_cancel": return "Esc"
		"primary_interaction": return "LMB"
		"secondary_interaction": return "RMB"
		"pause": return "Esc"
		_: return action_name.replace("_", " ").capitalize()

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_glyph_set_changed(_controller_type: int) -> void:
	_update_display()


func _on_input_mode_changed(_mode: int) -> void:
	_update_display()

# ============================================================================
# PUBLIC API
# ============================================================================

## Force a display refresh
func refresh() -> void:
	_update_display()


## Set action and label in one call
func set_prompt(new_action: String, new_label: String = "") -> void:
	action = new_action
	label_text = new_label
