extends Node

## AccessibilityManager
## Manages accessibility settings including colorblind modes, UI scaling, font sizes, and high contrast mode
## Integrates with SaveManager and Config for persistent settings

# Signals for accessibility setting changes
signal colorblind_mode_changed(mode: ColorblindMode)
signal ui_scale_changed(scale: float)
signal font_size_changed(size: FontSize)
signal high_contrast_changed(enabled: bool)

# Enums for accessibility options
enum ColorblindMode {
	NONE,
	PROTANOPIA,  # Red-green (red weak)
	DEUTERANOPIA,  # Red-green (green weak)
	TRITANOPIA  # Blue-yellow
}

enum FontSize {
	SMALL,
	MEDIUM,
	LARGE,
	EXTRA_LARGE
}

# Current settings
var current_colorblind_mode: ColorblindMode = ColorblindMode.NONE
var current_ui_scale: float = 1.0
var current_font_size: FontSize = FontSize.MEDIUM
var current_high_contrast: bool = false
var dyslexia_font_enabled: bool = false

# QTE Accessibility settings
var qte_auto_complete: bool = false  # Automatically succeed all QTEs
var qte_time_multiplier: float = 1.0  # Time given for each QTE prompt (1.0 = normal, 2.0 = double)
var qte_reduced_prompts: bool = false  # Reduce number of QTE prompts

# QTE difficulty presets
enum QTEDifficulty {
	STANDARD,  # Normal timing and prompts
	RELAXED,   # 50% more time
	ASSISTED,  # Double time, fewer prompts
	AUTO       # Auto-complete all QTEs
}

const QTE_DIFFICULTY_SETTINGS = {
	QTEDifficulty.STANDARD: {"time_multiplier": 1.0, "reduced_prompts": false, "auto": false},
	QTEDifficulty.RELAXED: {"time_multiplier": 1.5, "reduced_prompts": false, "auto": false},
	QTEDifficulty.ASSISTED: {"time_multiplier": 2.0, "reduced_prompts": true, "auto": false},
	QTEDifficulty.AUTO: {"time_multiplier": 1.0, "reduced_prompts": false, "auto": true}
}

# UI scale options
const UI_SCALE_OPTIONS = {
	"80%": 0.8,
	"100%": 1.0,
	"120%": 1.2,
	"150%": 1.5
}

# Font size multipliers
const FONT_SIZE_MULTIPLIERS = {
	FontSize.SMALL: 0.85,
	FontSize.MEDIUM: 1.0,
	FontSize.LARGE: 1.25,
	FontSize.EXTRA_LARGE: 1.5
}

# Colorblind mode color palettes
const COLORBLIND_PALETTES = {
	ColorblindMode.PROTANOPIA: {
		"approved_color": Color(0.2, 0.6, 1.0),  # Blue instead of green
		"rejected_color": Color(1.0, 0.6, 0.0),  # Orange instead of red
		"approved_pattern": "stripes",
		"rejected_pattern": "dots"
	},
	ColorblindMode.DEUTERANOPIA: {
		"approved_color": Color(0.3, 0.5, 1.0),  # Blue
		"rejected_color": Color(1.0, 0.5, 0.0),  # Orange
		"approved_pattern": "stripes",
		"rejected_pattern": "dots"
	},
	ColorblindMode.TRITANOPIA: {
		"approved_color": Color(0.0, 0.8, 0.6),  # Cyan
		"rejected_color": Color(0.8, 0.2, 0.4),  # Pink
		"approved_pattern": "stripes",
		"rejected_pattern": "dots"
	}
}


func _ready():
	load_settings()


## Load accessibility settings from config
func load_settings():
	# Load colorblind mode
	var colorblind_value = Config.get_config(
		"AccessibilitySettings", "ColorblindMode", ColorblindMode.NONE
	)
	set_colorblind_mode(colorblind_value)

	# Load UI scale
	var ui_scale_value = Config.get_config("AccessibilitySettings", "UIScale", 1.0)
	set_ui_scale(ui_scale_value)

	# Load font size
	var font_size_value = Config.get_config("AccessibilitySettings", "FontSize", FontSize.MEDIUM)
	set_font_size(font_size_value)

	# Load high contrast mode
	var high_contrast_value = Config.get_config("AccessibilitySettings", "HighContrast", false)
	set_high_contrast(high_contrast_value)

	# Load dyslexia font setting
	dyslexia_font_enabled = Config.get_config("AccessibilitySettings", "DyslexiaFont", false)

	# Load QTE accessibility settings
	qte_auto_complete = Config.get_config("AccessibilitySettings", "QTEAutoComplete", false)
	qte_time_multiplier = Config.get_config("AccessibilitySettings", "QTETimeMultiplier", 1.0)
	qte_reduced_prompts = Config.get_config("AccessibilitySettings", "QTEReducedPrompts", false)


## Save accessibility settings to config
func save_settings():
	Config.set_config("AccessibilitySettings", "ColorblindMode", current_colorblind_mode)
	Config.set_config("AccessibilitySettings", "UIScale", current_ui_scale)
	Config.set_config("AccessibilitySettings", "FontSize", current_font_size)
	Config.set_config("AccessibilitySettings", "HighContrast", current_high_contrast)
	Config.set_config("AccessibilitySettings", "DyslexiaFont", dyslexia_font_enabled)
	# QTE settings
	Config.set_config("AccessibilitySettings", "QTEAutoComplete", qte_auto_complete)
	Config.set_config("AccessibilitySettings", "QTETimeMultiplier", qte_time_multiplier)
	Config.set_config("AccessibilitySettings", "QTEReducedPrompts", qte_reduced_prompts)


## Emit current settings via EventBus for system-wide updates
func _emit_settings_changed() -> void:
	if EventBus:
		EventBus.accessibility_settings_changed.emit({
			"colorblind_mode": current_colorblind_mode,
			"ui_scale": current_ui_scale,
			"font_size": current_font_size,
			"high_contrast": current_high_contrast,
			"dyslexia_font": dyslexia_font_enabled
		})


## Set colorblind mode
func set_colorblind_mode(mode: ColorblindMode):
	current_colorblind_mode = mode
	colorblind_mode_changed.emit(mode)
	_emit_settings_changed()
	save_settings()


## Get colors for approval/rejection based on colorblind mode
func get_approval_color() -> Color:
	if current_colorblind_mode in COLORBLIND_PALETTES:
		return COLORBLIND_PALETTES[current_colorblind_mode]["approved_color"]
	return Color.GREEN  # Default


func get_rejection_color() -> Color:
	if current_colorblind_mode in COLORBLIND_PALETTES:
		return COLORBLIND_PALETTES[current_colorblind_mode]["rejected_color"]
	return Color.RED  # Default


## Get pattern type for stamps (for colorblind accessibility)
func get_approval_pattern() -> String:
	if current_colorblind_mode in COLORBLIND_PALETTES:
		return COLORBLIND_PALETTES[current_colorblind_mode]["approved_pattern"]
	return "none"


func get_rejection_pattern() -> String:
	if current_colorblind_mode in COLORBLIND_PALETTES:
		return COLORBLIND_PALETTES[current_colorblind_mode]["rejected_pattern"]
	return "none"


## Set UI scale
func set_ui_scale(scale: float):
	# Clamp scale to valid range
	scale = clamp(scale, 0.8, 1.5)
	current_ui_scale = scale

	# Apply to root viewport
	apply_ui_scale_to_scene()

	ui_scale_changed.emit(scale)
	_emit_settings_changed()
	save_settings()


## Apply UI scale to current scene
func apply_ui_scale_to_scene():
	var root = get_tree().root
	if root:
		# Scale the root canvas
		root.content_scale_factor = current_ui_scale


## Set font size
func set_font_size(size: FontSize):
	current_font_size = size
	font_size_changed.emit(size)
	_emit_settings_changed()
	save_settings()


## Get font size multiplier for current setting
func get_font_size_multiplier() -> float:
	return FONT_SIZE_MULTIPLIERS.get(current_font_size, 1.0)


## Apply font size to a label or text element
func apply_font_size(label: Control, base_size: int = 16):
	if label.has_method("add_theme_font_size_override"):
		var scaled_size = int(base_size * get_font_size_multiplier())
		label.add_theme_font_size_override("font_size", scaled_size)


## Set high contrast mode
func set_high_contrast(enabled: bool):
	current_high_contrast = enabled
	high_contrast_changed.emit(enabled)
	_emit_settings_changed()
	save_settings()


## Get border thickness for high contrast mode
func get_border_thickness() -> int:
	return 3 if current_high_contrast else 1


## Get outline thickness for high contrast mode
func get_outline_thickness() -> int:
	return 2 if current_high_contrast else 0


## Apply high contrast outline to a control
func apply_high_contrast_outline(control: Control):
	if not current_high_contrast:
		return

	# Add outline shader or border to control
	if control.has_method("add_theme_stylebox_override"):
		var stylebox = StyleBoxFlat.new()
		stylebox.border_width_left = get_border_thickness()
		stylebox.border_width_right = get_border_thickness()
		stylebox.border_width_top = get_border_thickness()
		stylebox.border_width_bottom = get_border_thickness()
		stylebox.border_color = Color.WHITE
		control.add_theme_stylebox_override("normal", stylebox)


## Dyslexia-friendly font path
## To enable dyslexia font support, add OpenDyslexic-Regular.ttf to res://assets/fonts/
const DYSLEXIA_FONT_PATH = "res://assets/fonts/OpenDyslexic-Regular.ttf"

## Cached dyslexia font resource
var _dyslexia_font: Font = null


## Set dyslexia-friendly font
func set_dyslexia_font(enabled: bool):
	dyslexia_font_enabled = enabled
	_emit_settings_changed()
	save_settings()

	# Apply or remove dyslexia font from all text elements
	if get_tree() and get_tree().current_scene:
		_apply_dyslexia_font_to_scene(get_tree().current_scene)


## Get the dyslexia-friendly font, loading it if necessary.
## Returns null if the font file is not available.
func get_dyslexia_font() -> Font:
	if _dyslexia_font:
		return _dyslexia_font

	# Try to load the dyslexia font
	if ResourceLoader.exists(DYSLEXIA_FONT_PATH):
		_dyslexia_font = load(DYSLEXIA_FONT_PATH)
		return _dyslexia_font

	# Fallback: Use a more readable monospace font if available
	var fallback_paths = [
		"res://assets/fonts/notoSans_multilang.ttf",
		"res://assets/fonts/RobotoMono-Regular.ttf"
	]

	for path in fallback_paths:
		if ResourceLoader.exists(path):
			_dyslexia_font = load(path)
			push_warning(
				"OpenDyslexic font not found at %s. Using fallback: %s" % [DYSLEXIA_FONT_PATH, path]
			)
			return _dyslexia_font

	push_warning(
		"Dyslexia font not available. Add OpenDyslexic-Regular.ttf to res://assets/fonts/"
	)
	return null


## Apply dyslexia font setting to all text elements in a scene.
func _apply_dyslexia_font_to_scene(scene: Node):
	if not dyslexia_font_enabled:
		# Clear font overrides when disabled (let theme handle fonts)
		for label in scene.find_children("*", "Label", true, false):
			if label is Label:
				label.remove_theme_font_override("font")
		for button in scene.find_children("*", "Button", true, false):
			if button is Button:
				button.remove_theme_font_override("font")
		for rich_text in scene.find_children("*", "RichTextLabel", true, false):
			if rich_text is RichTextLabel:
				rich_text.remove_theme_font_override("normal_font")
		return

	var font = get_dyslexia_font()
	if not font:
		return

	# Apply to all Label nodes
	for label in scene.find_children("*", "Label", true, false):
		if label is Label:
			label.add_theme_font_override("font", font)

	# Apply to all Button nodes
	for button in scene.find_children("*", "Button", true, false):
		if button is Button:
			button.add_theme_font_override("font", font)

	# Apply to all RichTextLabel nodes
	for rich_text in scene.find_children("*", "RichTextLabel", true, false):
		if rich_text is RichTextLabel:
			rich_text.add_theme_font_override("normal_font", font)


## Apply all accessibility settings to a scene
func apply_to_scene(scene: Node):
	# Apply UI scale
	apply_ui_scale_to_scene()

	# Apply dyslexia font if enabled
	if dyslexia_font_enabled:
		_apply_dyslexia_font_to_scene(scene)

	# Find all labels and apply font size
	for label in scene.find_children("*", "Label", true, false):
		if label is Label:
			apply_font_size(label)

	# Apply high contrast outlines to interactive elements
	if current_high_contrast:
		for button in scene.find_children("*", "Button", true, false):
			if button is Button:
				apply_high_contrast_outline(button)


## Get readable color contrast
func get_contrast_color(background: Color) -> Color:
	# Calculate luminance
	var luminance = 0.299 * background.r + 0.587 * background.g + 0.114 * background.b

	# Return white or black depending on background brightness
	return Color.WHITE if luminance < 0.5 else Color.BLACK


## Reset all accessibility settings to defaults
func reset_to_defaults():
	set_colorblind_mode(ColorblindMode.NONE)
	set_ui_scale(1.0)
	set_font_size(FontSize.MEDIUM)
	set_high_contrast(false)
	set_dyslexia_font(false)
	set_qte_difficulty(QTEDifficulty.STANDARD)


# =====================
# QTE Accessibility Methods
# =====================

## Set QTE difficulty preset (combines auto, time, and prompt settings)
func set_qte_difficulty(difficulty: QTEDifficulty) -> void:
	var settings = QTE_DIFFICULTY_SETTINGS.get(difficulty, QTE_DIFFICULTY_SETTINGS[QTEDifficulty.STANDARD])
	qte_auto_complete = settings.auto
	qte_time_multiplier = settings.time_multiplier
	qte_reduced_prompts = settings.reduced_prompts
	_emit_settings_changed()
	save_settings()


## Set QTE auto-complete mode
func set_qte_auto_complete(enabled: bool) -> void:
	qte_auto_complete = enabled
	_emit_settings_changed()
	save_settings()


## Set QTE time multiplier (1.0 = normal, 2.0 = double time)
func set_qte_time_multiplier(multiplier: float) -> void:
	qte_time_multiplier = clamp(multiplier, 0.5, 3.0)
	_emit_settings_changed()
	save_settings()


## Set QTE reduced prompts mode
func set_qte_reduced_prompts(enabled: bool) -> void:
	qte_reduced_prompts = enabled
	_emit_settings_changed()
	save_settings()


## Get QTE settings for minigame configuration
func get_qte_settings() -> Dictionary:
	return {
		"auto_complete": qte_auto_complete,
		"time_multiplier": qte_time_multiplier,
		"reduced_prompts": qte_reduced_prompts
	}


## Check if QTE should auto-complete
func should_qte_auto_complete() -> bool:
	return qte_auto_complete


## Get adjusted time per prompt based on accessibility settings
func get_adjusted_qte_time(base_time: float) -> float:
	return base_time * qte_time_multiplier


## Get adjusted prompt count based on accessibility settings
func get_adjusted_qte_prompts(base_count: int) -> int:
	if qte_reduced_prompts:
		return max(2, int(base_count * 0.6))  # Reduce by 40%, minimum 2
	return base_count
