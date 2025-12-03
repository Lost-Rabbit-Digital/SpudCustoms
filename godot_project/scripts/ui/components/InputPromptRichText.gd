@tool
extends RichTextLabel
class_name InputPromptRichText
## InputPromptRichText - Rich text label with automatic controller glyph substitution
##
## Allows text with placeholders like "{ui_accept}" or "{primary_interaction}"
## that get replaced with appropriate button text or inline images.

# ============================================================================
# EXPORTS
# ============================================================================

## The template text with action placeholders
## Use {action_name} syntax, e.g., "Press {ui_accept} to continue"
@export_multiline var prompt_template: String = "":
	set(value):
		prompt_template = value
		_update_text()

## Whether to use images when available (vs always text)
@export var use_images: bool = true

## Size of inline glyph images
@export var glyph_size: int = 24

# ============================================================================
# LIFECYCLE
# ============================================================================

func _ready() -> void:
	bbcode_enabled = true
	fit_content = true
	_connect_signals()
	_update_text()


func _connect_signals() -> void:
	if Engine.is_editor_hint():
		return

	if InputGlyphManager:
		if not InputGlyphManager.glyph_set_changed.is_connected(_on_glyph_set_changed):
			InputGlyphManager.glyph_set_changed.connect(_on_glyph_set_changed)

	if ControllerManager:
		if not ControllerManager.input_mode_changed.is_connected(_on_input_mode_changed):
			ControllerManager.input_mode_changed.connect(_on_input_mode_changed)

# ============================================================================
# TEXT PROCESSING
# ============================================================================

func _update_text() -> void:
	if prompt_template.is_empty():
		text = ""
		return

	var result = prompt_template

	# Find all {action} placeholders
	var regex = RegEx.new()
	regex.compile("\\{([a-z_]+)\\}")

	var matches = regex.search_all(prompt_template)
	for match_result in matches:
		var full_match = match_result.get_string(0)  # e.g., "{ui_accept}"
		var action_name = match_result.get_string(1)  # e.g., "ui_accept"
		var replacement = _get_action_display(action_name)
		result = result.replace(full_match, replacement)

	text = result


func _get_action_display(action_name: String) -> String:
	if Engine.is_editor_hint():
		return "[" + action_name + "]"

	# Try to get texture path for inline image
	if use_images and InputGlyphManager:
		var texture = InputGlyphManager.get_action_texture(action_name)
		if texture:
			var path = texture.resource_path
			if not path.is_empty():
				return "[img=" + str(glyph_size) + "]" + path + "[/img]"

	# Fall back to text
	return _get_text_for_action(action_name)


func _get_text_for_action(action_name: String) -> String:
	var button_text := ""

	if InputGlyphManager:
		var button_name = InputGlyphManager.get_button_for_action(action_name)
		if not button_name.is_empty():
			button_text = InputGlyphManager.get_button_text(button_name)
		else:
			# Check for common action patterns
			button_text = _get_fallback_text(action_name)
	else:
		button_text = _get_fallback_text(action_name)

	return "[" + button_text + "]"


func _get_fallback_text(action_name: String) -> String:
	# Check if we're in controller mode
	var is_controller = false
	if ControllerManager:
		is_controller = ControllerManager.is_controller_mode()

	if is_controller:
		match action_name:
			"ui_accept": return "A"
			"ui_cancel": return "B"
			"primary_interaction": return "RT"
			"secondary_interaction": return "LT"
			"pause": return "Menu"
			_: return action_name.replace("_", " ").to_upper()
	else:
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
	_update_text()


func _on_input_mode_changed(_mode: int) -> void:
	_update_text()

# ============================================================================
# PUBLIC API
# ============================================================================

## Update the template and refresh
func set_template(new_template: String) -> void:
	prompt_template = new_template


## Force refresh
func refresh() -> void:
	_update_text()
