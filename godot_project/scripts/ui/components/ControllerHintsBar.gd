@tool
extends HBoxContainer
class_name ControllerHintsBar
## ControllerHintsBar - Shows controller button hints at bottom of menus
##
## Automatically shows/hides based on input mode.
## Displays common navigation hints like "A Select   B Back"

# ============================================================================
# EXPORTS
# ============================================================================

## Whether to show select hint
@export var show_select_hint: bool = true

## Whether to show back/cancel hint
@export var show_back_hint: bool = true

## Whether to show pause/menu hint
@export var show_menu_hint: bool = false

## Custom additional hints (format: [{action: "action_name", label: "Label"}])
@export var custom_hints: Array[Dictionary] = []

## Font size for hint text
@export var font_size: int = 14

## Spacing between hint groups
@export var hint_spacing: int = 32

# ============================================================================
# STATE
# ============================================================================

var _hint_labels: Array[Control] = []

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	# Set container properties
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", hint_spacing)

	_connect_signals()
	_rebuild_hints()


func _connect_signals() -> void:
	if Engine.is_editor_hint():
		return

	if ControllerManager:
		if not ControllerManager.input_mode_changed.is_connected(_on_input_mode_changed):
			ControllerManager.input_mode_changed.connect(_on_input_mode_changed)

	if InputGlyphManager:
		if not InputGlyphManager.glyph_set_changed.is_connected(_on_glyph_set_changed):
			InputGlyphManager.glyph_set_changed.connect(_on_glyph_set_changed)

# ============================================================================
# HINT BUILDING
# ============================================================================

func _rebuild_hints() -> void:
	# Clear existing hints
	for hint in _hint_labels:
		if is_instance_valid(hint):
			hint.queue_free()
	_hint_labels.clear()

	# Check if we should show hints
	if not _should_show_hints():
		visible = false
		return

	visible = true

	# Build hints
	if show_select_hint:
		_add_hint("controller_accept", "Select")

	if show_back_hint:
		_add_hint("controller_cancel", "Back")

	if show_menu_hint:
		_add_hint("pause", "Menu")

	# Add custom hints
	for hint_def in custom_hints:
		if hint_def.has("action") and hint_def.has("label"):
			_add_hint(hint_def["action"], hint_def["label"])


func _add_hint(action: String, label_text: String) -> void:
	var hint_container = HBoxContainer.new()
	hint_container.add_theme_constant_override("separation", 6)

	# Try to add glyph texture
	var texture_added = false
	if not Engine.is_editor_hint() and InputGlyphManager:
		var texture = InputGlyphManager.get_action_texture(action)
		if texture:
			var tex_rect = TextureRect.new()
			tex_rect.texture = texture
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.custom_minimum_size = Vector2(24, 24)
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			hint_container.add_child(tex_rect)
			texture_added = true

	# Add text label (button name + action)
	var text_label = Label.new()
	if not texture_added:
		# Show button text if no texture
		var button_text = _get_button_text_for_action(action)
		text_label.text = "[" + button_text + "] " + label_text
	else:
		text_label.text = label_text

	text_label.add_theme_font_size_override("font_size", font_size)
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_container.add_child(text_label)

	add_child(hint_container)
	_hint_labels.append(hint_container)


func _get_button_text_for_action(action: String) -> String:
	if not Engine.is_editor_hint() and InputGlyphManager:
		var button_name = InputGlyphManager.get_button_for_action(action)
		if not button_name.is_empty():
			return InputGlyphManager.get_button_text(button_name)

	# Fallback
	match action:
		"controller_accept", "ui_accept": return "A"
		"controller_cancel", "ui_cancel": return "B"
		"pause": return "Menu"
		_: return action


func _should_show_hints() -> bool:
	if Engine.is_editor_hint():
		return true  # Show in editor for preview

	# Only show when using controller
	return ControllerManager and ControllerManager.is_controller_mode()

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_input_mode_changed(_mode: int) -> void:
	_rebuild_hints()


func _on_glyph_set_changed(_controller_type: int) -> void:
	_rebuild_hints()

# ============================================================================
# PUBLIC API
# ============================================================================

## Force rebuild of hints
func refresh() -> void:
	_rebuild_hints()


## Add a custom hint at runtime
func add_custom_hint(action: String, label: String) -> void:
	custom_hints.append({"action": action, "label": label})
	_rebuild_hints()


## Clear all custom hints
func clear_custom_hints() -> void:
	custom_hints.clear()
	_rebuild_hints()
