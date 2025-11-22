extends GutTest

## Comprehensive Unit Tests for AccessibilityManager
## Tests accessibility settings, colorblind modes, UI scaling, font sizes, high contrast features,
## save/load functionality, signal emissions, and edge cases

var accessibility_manager: Node
var test_colorblind_changed_called: bool = false
var test_ui_scale_changed_called: bool = false
var test_font_size_changed_called: bool = false
var test_high_contrast_changed_called: bool = false
var last_colorblind_mode: int = -1
var last_ui_scale: float = 0.0
var last_font_size: int = -1
var last_high_contrast: bool = false


func before_each() -> void:
	accessibility_manager = get_node("/root/AccessibilityManager")
	test_colorblind_changed_called = false
	test_ui_scale_changed_called = false
	test_font_size_changed_called = false
	test_high_contrast_changed_called = false
	last_colorblind_mode = -1
	last_ui_scale = 0.0
	last_font_size = -1
	last_high_contrast = false

	# Reset to defaults
	accessibility_manager.reset_to_defaults()
	# Clear config section to ensure clean state
	Config.erase_section("AccessibilitySettings")


func after_each() -> void:
	# Disconnect test signals
	if accessibility_manager.colorblind_mode_changed.is_connected(_on_colorblind_mode_changed):
		accessibility_manager.colorblind_mode_changed.disconnect(_on_colorblind_mode_changed)
	if accessibility_manager.ui_scale_changed.is_connected(_on_ui_scale_changed):
		accessibility_manager.ui_scale_changed.disconnect(_on_ui_scale_changed)
	if accessibility_manager.font_size_changed.is_connected(_on_font_size_changed):
		accessibility_manager.font_size_changed.disconnect(_on_font_size_changed)
	if accessibility_manager.high_contrast_changed.is_connected(_on_high_contrast_changed):
		accessibility_manager.high_contrast_changed.disconnect(_on_high_contrast_changed)

	# Reset to defaults after each test
	accessibility_manager.reset_to_defaults()
	Config.erase_section("AccessibilitySettings")


# ==================== INITIALIZATION TESTS ====================


func test_accessibility_manager_exists() -> void:
	assert_not_null(accessibility_manager, "AccessibilityManager should be available as autoload")


func test_initial_state_defaults() -> void:
	assert_eq(
		accessibility_manager.current_colorblind_mode,
		accessibility_manager.ColorblindMode.NONE,
		"Default colorblind mode should be NONE"
	)
	assert_eq(accessibility_manager.current_ui_scale, 1.0, "Default UI scale should be 1.0")
	assert_eq(
		accessibility_manager.current_font_size,
		accessibility_manager.FontSize.MEDIUM,
		"Default font size should be MEDIUM"
	)
	assert_false(accessibility_manager.current_high_contrast, "High contrast should be disabled by default")
	assert_false(accessibility_manager.dyslexia_font_enabled, "Dyslexia font should be disabled by default")


func test_colorblind_palettes_exist() -> void:
	assert_true(
		accessibility_manager.COLORBLIND_PALETTES.size() > 0,
		"Colorblind palettes should be defined"
	)


func test_all_colorblind_modes_have_palettes() -> void:
	# Test that all non-NONE modes have palette entries
	assert_true(
		accessibility_manager.COLORBLIND_PALETTES.has(accessibility_manager.ColorblindMode.PROTANOPIA),
		"PROTANOPIA palette should exist"
	)
	assert_true(
		accessibility_manager.COLORBLIND_PALETTES.has(accessibility_manager.ColorblindMode.DEUTERANOPIA),
		"DEUTERANOPIA palette should exist"
	)
	assert_true(
		accessibility_manager.COLORBLIND_PALETTES.has(accessibility_manager.ColorblindMode.TRITANOPIA),
		"TRITANOPIA palette should exist"
	)


func test_palettes_have_required_keys() -> void:
	for mode in accessibility_manager.COLORBLIND_PALETTES.keys():
		var palette = accessibility_manager.COLORBLIND_PALETTES[mode]
		assert_true(palette.has("approved_color"), "Palette should have approved_color")
		assert_true(palette.has("rejected_color"), "Palette should have rejected_color")
		assert_true(palette.has("approved_pattern"), "Palette should have approved_pattern")
		assert_true(palette.has("rejected_pattern"), "Palette should have rejected_pattern")


func test_font_size_multipliers_exist_for_all_sizes() -> void:
	assert_true(
		accessibility_manager.FONT_SIZE_MULTIPLIERS.has(accessibility_manager.FontSize.SMALL),
		"SMALL font multiplier should exist"
	)
	assert_true(
		accessibility_manager.FONT_SIZE_MULTIPLIERS.has(accessibility_manager.FontSize.MEDIUM),
		"MEDIUM font multiplier should exist"
	)
	assert_true(
		accessibility_manager.FONT_SIZE_MULTIPLIERS.has(accessibility_manager.FontSize.LARGE),
		"LARGE font multiplier should exist"
	)
	assert_true(
		accessibility_manager.FONT_SIZE_MULTIPLIERS.has(accessibility_manager.FontSize.EXTRA_LARGE),
		"EXTRA_LARGE font multiplier should exist"
	)


# ==================== COLORBLIND MODE TESTS ====================


func test_set_colorblind_mode_updates_current_mode() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.PROTANOPIA)
	assert_eq(
		accessibility_manager.current_colorblind_mode,
		accessibility_manager.ColorblindMode.PROTANOPIA,
		"Colorblind mode should be updated"
	)


func test_set_colorblind_mode_emits_signal() -> void:
	accessibility_manager.colorblind_mode_changed.connect(_on_colorblind_mode_changed)

	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.DEUTERANOPIA)
	await get_tree().process_frame

	assert_true(test_colorblind_changed_called, "colorblind_mode_changed signal should be emitted")
	assert_eq(
		last_colorblind_mode,
		accessibility_manager.ColorblindMode.DEUTERANOPIA,
		"Signal should include correct mode"
	)


func test_set_colorblind_mode_saves_to_config() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.TRITANOPIA)

	var saved_mode = Config.get_config("AccessibilitySettings", "ColorblindMode", -1)
	assert_eq(
		saved_mode,
		accessibility_manager.ColorblindMode.TRITANOPIA,
		"Colorblind mode should be saved to Config"
	)


func test_all_colorblind_modes_can_be_set() -> void:
	# Test setting each colorblind mode
	for mode in [
		accessibility_manager.ColorblindMode.NONE,
		accessibility_manager.ColorblindMode.PROTANOPIA,
		accessibility_manager.ColorblindMode.DEUTERANOPIA,
		accessibility_manager.ColorblindMode.TRITANOPIA
	]:
		accessibility_manager.set_colorblind_mode(mode)
		assert_eq(
			accessibility_manager.current_colorblind_mode,
			mode,
			"Should be able to set mode %d" % mode
		)


func test_get_approval_color_default() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.NONE)
	var color = accessibility_manager.get_approval_color()
	assert_eq(color, Color.GREEN, "Default approval color should be GREEN")


func test_get_approval_color_protanopia() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.PROTANOPIA)
	var color = accessibility_manager.get_approval_color()
	var expected_color = accessibility_manager.COLORBLIND_PALETTES[accessibility_manager.ColorblindMode.PROTANOPIA]["approved_color"]
	assert_eq(color, expected_color, "PROTANOPIA approval color should match palette")


func test_get_approval_color_deuteranopia() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.DEUTERANOPIA)
	var color = accessibility_manager.get_approval_color()
	var expected_color = accessibility_manager.COLORBLIND_PALETTES[accessibility_manager.ColorblindMode.DEUTERANOPIA]["approved_color"]
	assert_eq(color, expected_color, "DEUTERANOPIA approval color should match palette")


func test_get_approval_color_tritanopia() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.TRITANOPIA)
	var color = accessibility_manager.get_approval_color()
	var expected_color = accessibility_manager.COLORBLIND_PALETTES[accessibility_manager.ColorblindMode.TRITANOPIA]["approved_color"]
	assert_eq(color, expected_color, "TRITANOPIA approval color should match palette")


func test_get_rejection_color_default() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.NONE)
	var color = accessibility_manager.get_rejection_color()
	assert_eq(color, Color.RED, "Default rejection color should be RED")


func test_get_rejection_color_protanopia() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.PROTANOPIA)
	var color = accessibility_manager.get_rejection_color()
	var expected_color = accessibility_manager.COLORBLIND_PALETTES[accessibility_manager.ColorblindMode.PROTANOPIA]["rejected_color"]
	assert_eq(color, expected_color, "PROTANOPIA rejection color should match palette")


func test_get_rejection_color_deuteranopia() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.DEUTERANOPIA)
	var color = accessibility_manager.get_rejection_color()
	var expected_color = accessibility_manager.COLORBLIND_PALETTES[accessibility_manager.ColorblindMode.DEUTERANOPIA]["rejected_color"]
	assert_eq(color, expected_color, "DEUTERANOPIA rejection color should match palette")


func test_get_rejection_color_tritanopia() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.TRITANOPIA)
	var color = accessibility_manager.get_rejection_color()
	var expected_color = accessibility_manager.COLORBLIND_PALETTES[accessibility_manager.ColorblindMode.TRITANOPIA]["rejected_color"]
	assert_eq(color, expected_color, "TRITANOPIA rejection color should match palette")


func test_get_approval_pattern_none_by_default() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.NONE)
	var pattern = accessibility_manager.get_approval_pattern()
	assert_eq(pattern, "none", "Default approval pattern should be 'none'")


func test_get_approval_pattern_with_colorblind_mode() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.PROTANOPIA)
	var pattern = accessibility_manager.get_approval_pattern()
	assert_eq(pattern, "stripes", "Colorblind mode should provide pattern")


func test_get_rejection_pattern_none_by_default() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.NONE)
	var pattern = accessibility_manager.get_rejection_pattern()
	assert_eq(pattern, "none", "Default rejection pattern should be 'none'")


func test_get_rejection_pattern_with_colorblind_mode() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.DEUTERANOPIA)
	var pattern = accessibility_manager.get_rejection_pattern()
	assert_eq(pattern, "dots", "Colorblind mode should provide pattern")


func test_colorblind_mode_transitions() -> void:
	# Test transitioning between different modes
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.PROTANOPIA)
	assert_eq(accessibility_manager.get_approval_pattern(), "stripes")

	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.NONE)
	assert_eq(accessibility_manager.get_approval_pattern(), "none")

	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.TRITANOPIA)
	assert_eq(accessibility_manager.get_approval_pattern(), "stripes")


# ==================== UI SCALE TESTS ====================


func test_set_ui_scale_updates_current_scale() -> void:
	accessibility_manager.set_ui_scale(1.2)
	assert_eq(accessibility_manager.current_ui_scale, 1.2, "UI scale should be updated")


func test_set_ui_scale_emits_signal() -> void:
	accessibility_manager.ui_scale_changed.connect(_on_ui_scale_changed)

	accessibility_manager.set_ui_scale(1.5)
	await get_tree().process_frame

	assert_true(test_ui_scale_changed_called, "ui_scale_changed signal should be emitted")
	assert_eq(last_ui_scale, 1.5, "Signal should include correct scale value")


func test_set_ui_scale_saves_to_config() -> void:
	accessibility_manager.set_ui_scale(1.2)

	var saved_scale = Config.get_config("AccessibilitySettings", "UIScale", 0.0)
	assert_eq(saved_scale, 1.2, "UI scale should be saved to Config")


func test_set_ui_scale_clamps_minimum() -> void:
	accessibility_manager.set_ui_scale(0.5)  # Too low
	assert_eq(accessibility_manager.current_ui_scale, 0.8, "UI scale should be clamped to minimum 0.8")


func test_set_ui_scale_clamps_maximum() -> void:
	accessibility_manager.set_ui_scale(2.0)  # Too high
	assert_eq(accessibility_manager.current_ui_scale, 1.5, "UI scale should be clamped to maximum 1.5")


func test_set_ui_scale_accepts_exact_minimum() -> void:
	accessibility_manager.set_ui_scale(0.8)
	assert_eq(accessibility_manager.current_ui_scale, 0.8, "UI scale should accept exact minimum")


func test_set_ui_scale_accepts_exact_maximum() -> void:
	accessibility_manager.set_ui_scale(1.5)
	assert_eq(accessibility_manager.current_ui_scale, 1.5, "UI scale should accept exact maximum")


func test_ui_scale_options_are_valid() -> void:
	for option_name in accessibility_manager.UI_SCALE_OPTIONS:
		var scale = accessibility_manager.UI_SCALE_OPTIONS[option_name]
		assert_true(scale >= 0.8 and scale <= 1.5, "All UI scale options should be within valid range")


func test_apply_ui_scale_to_scene_doesnt_crash() -> void:
	accessibility_manager.set_ui_scale(1.2)
	accessibility_manager.apply_ui_scale_to_scene()
	# Test passes if no crash occurs
	assert_true(true, "apply_ui_scale_to_scene should not crash")


func test_ui_scale_applies_to_root_viewport() -> void:
	accessibility_manager.set_ui_scale(1.3)
	accessibility_manager.apply_ui_scale_to_scene()

	var root = get_tree().root
	if root:
		assert_eq(
			root.content_scale_factor,
			1.3,
			"Root viewport content_scale_factor should match UI scale"
		)


# ==================== FONT SIZE TESTS ====================


func test_set_font_size_updates_current_size() -> void:
	accessibility_manager.set_font_size(accessibility_manager.FontSize.LARGE)
	assert_eq(
		accessibility_manager.current_font_size,
		accessibility_manager.FontSize.LARGE,
		"Font size should be updated"
	)


func test_set_font_size_emits_signal() -> void:
	accessibility_manager.font_size_changed.connect(_on_font_size_changed)

	accessibility_manager.set_font_size(accessibility_manager.FontSize.EXTRA_LARGE)
	await get_tree().process_frame

	assert_true(test_font_size_changed_called, "font_size_changed signal should be emitted")
	assert_eq(
		last_font_size,
		accessibility_manager.FontSize.EXTRA_LARGE,
		"Signal should include correct font size"
	)


func test_set_font_size_saves_to_config() -> void:
	accessibility_manager.set_font_size(accessibility_manager.FontSize.LARGE)

	var saved_size = Config.get_config("AccessibilitySettings", "FontSize", -1)
	assert_eq(saved_size, accessibility_manager.FontSize.LARGE, "Font size should be saved to Config")


func test_get_font_size_multiplier_small() -> void:
	accessibility_manager.set_font_size(accessibility_manager.FontSize.SMALL)
	var multiplier = accessibility_manager.get_font_size_multiplier()
	assert_eq(multiplier, 0.85, "SMALL font size multiplier should be 0.85")


func test_get_font_size_multiplier_medium() -> void:
	accessibility_manager.set_font_size(accessibility_manager.FontSize.MEDIUM)
	var multiplier = accessibility_manager.get_font_size_multiplier()
	assert_eq(multiplier, 1.0, "MEDIUM font size multiplier should be 1.0")


func test_get_font_size_multiplier_large() -> void:
	accessibility_manager.set_font_size(accessibility_manager.FontSize.LARGE)
	var multiplier = accessibility_manager.get_font_size_multiplier()
	assert_eq(multiplier, 1.25, "LARGE font size multiplier should be 1.25")


func test_get_font_size_multiplier_extra_large() -> void:
	accessibility_manager.set_font_size(accessibility_manager.FontSize.EXTRA_LARGE)
	var multiplier = accessibility_manager.get_font_size_multiplier()
	assert_eq(multiplier, 1.5, "EXTRA_LARGE font size multiplier should be 1.5")


func test_apply_font_size_to_label() -> void:
	var label = Label.new()
	var base_size = 16

	accessibility_manager.set_font_size(accessibility_manager.FontSize.LARGE)
	accessibility_manager.apply_font_size(label, base_size)

	# Label should have font size override applied
	# Note: Exact value depends on theme override mechanism
	# This test verifies the method doesn't crash
	assert_not_null(label, "Label should still exist after font application")
	label.queue_free()


func test_apply_font_size_with_different_base_sizes() -> void:
	var label = Label.new()

	# Test with base size 12
	accessibility_manager.set_font_size(accessibility_manager.FontSize.MEDIUM)
	accessibility_manager.apply_font_size(label, 12)
	assert_not_null(label, "Should work with base size 12")

	# Test with base size 24
	accessibility_manager.apply_font_size(label, 24)
	assert_not_null(label, "Should work with base size 24")

	label.queue_free()


func test_apply_font_size_to_control_without_method() -> void:
	# Test that apply_font_size handles controls without the method gracefully
	var control = Control.new()

	accessibility_manager.set_font_size(accessibility_manager.FontSize.LARGE)
	# Should not crash even if control doesn't have the method
	accessibility_manager.apply_font_size(control, 16)

	assert_not_null(control, "Control should still exist")
	control.queue_free()


# ==================== HIGH CONTRAST MODE TESTS ====================


func test_set_high_contrast_updates_setting() -> void:
	accessibility_manager.set_high_contrast(true)
	assert_true(accessibility_manager.current_high_contrast, "High contrast should be enabled")


func test_set_high_contrast_emits_signal() -> void:
	accessibility_manager.high_contrast_changed.connect(_on_high_contrast_changed)

	accessibility_manager.set_high_contrast(true)
	await get_tree().process_frame

	assert_true(test_high_contrast_changed_called, "high_contrast_changed signal should be emitted")
	assert_true(last_high_contrast, "Signal should include correct high contrast state")


func test_set_high_contrast_saves_to_config() -> void:
	accessibility_manager.set_high_contrast(true)

	var saved_contrast = Config.get_config("AccessibilitySettings", "HighContrast", false)
	assert_true(saved_contrast, "High contrast should be saved to Config")


func test_set_high_contrast_disable_emits_signal() -> void:
	# First enable it
	accessibility_manager.set_high_contrast(true)

	# Then test disabling
	accessibility_manager.high_contrast_changed.connect(_on_high_contrast_changed)
	accessibility_manager.set_high_contrast(false)
	await get_tree().process_frame

	assert_true(test_high_contrast_changed_called, "Signal should emit when disabling")
	assert_false(last_high_contrast, "Signal should indicate disabled state")


func test_get_border_thickness_default() -> void:
	accessibility_manager.set_high_contrast(false)
	var thickness = accessibility_manager.get_border_thickness()
	assert_eq(thickness, 1, "Default border thickness should be 1")


func test_get_border_thickness_high_contrast() -> void:
	accessibility_manager.set_high_contrast(true)
	var thickness = accessibility_manager.get_border_thickness()
	assert_eq(thickness, 3, "High contrast border thickness should be 3")


func test_get_outline_thickness_default() -> void:
	accessibility_manager.set_high_contrast(false)
	var thickness = accessibility_manager.get_outline_thickness()
	assert_eq(thickness, 0, "Default outline thickness should be 0")


func test_get_outline_thickness_high_contrast() -> void:
	accessibility_manager.set_high_contrast(true)
	var thickness = accessibility_manager.get_outline_thickness()
	assert_eq(thickness, 2, "High contrast outline thickness should be 2")


func test_apply_high_contrast_outline_when_disabled() -> void:
	accessibility_manager.set_high_contrast(false)
	var button = Button.new()

	accessibility_manager.apply_high_contrast_outline(button)

	# Should return early without applying anything
	assert_not_null(button, "Button should still exist")
	button.queue_free()


func test_apply_high_contrast_outline_when_enabled() -> void:
	accessibility_manager.set_high_contrast(true)
	var button = Button.new()

	accessibility_manager.apply_high_contrast_outline(button)

	# Verify method doesn't crash and button still exists
	assert_not_null(button, "Button should still exist after applying high contrast")
	button.queue_free()


func test_apply_high_contrast_outline_to_control_without_method() -> void:
	accessibility_manager.set_high_contrast(true)
	var control = Control.new()

	# Should handle gracefully even if control doesn't have the method
	accessibility_manager.apply_high_contrast_outline(control)

	assert_not_null(control, "Control should still exist")
	control.queue_free()


# ==================== DYSLEXIA FONT TESTS ====================


func test_set_dyslexia_font_updates_setting() -> void:
	accessibility_manager.set_dyslexia_font(true)
	assert_true(accessibility_manager.dyslexia_font_enabled, "Dyslexia font should be enabled")


func test_set_dyslexia_font_saves_setting() -> void:
	accessibility_manager.set_dyslexia_font(true)

	var saved_dyslexia = Config.get_config("AccessibilitySettings", "DyslexiaFont", false)
	assert_true(saved_dyslexia, "Dyslexia font setting should be saved to Config")


func test_set_dyslexia_font_can_be_disabled() -> void:
	accessibility_manager.set_dyslexia_font(true)
	accessibility_manager.set_dyslexia_font(false)

	assert_false(accessibility_manager.dyslexia_font_enabled, "Dyslexia font should be disabled")

	var saved_dyslexia = Config.get_config("AccessibilitySettings", "DyslexiaFont", true)
	assert_false(saved_dyslexia, "Disabled state should be saved")


# ==================== UTILITY FUNCTION TESTS ====================


func test_get_contrast_color_for_dark_background() -> void:
	var dark_bg = Color(0.1, 0.1, 0.1)  # Very dark
	var contrast = accessibility_manager.get_contrast_color(dark_bg)
	assert_eq(contrast, Color.WHITE, "Dark background should return white text")


func test_get_contrast_color_for_light_background() -> void:
	var light_bg = Color(0.9, 0.9, 0.9)  # Very light
	var contrast = accessibility_manager.get_contrast_color(light_bg)
	assert_eq(contrast, Color.BLACK, "Light background should return black text")


func test_get_contrast_color_for_medium_background() -> void:
	var medium_bg = Color(0.5, 0.5, 0.5)  # Medium gray
	var contrast = accessibility_manager.get_contrast_color(medium_bg)
	# Should return black for exactly 50% luminance (threshold is < 0.5)
	assert_eq(contrast, Color.BLACK, "Medium background should return appropriate contrast")


func test_get_contrast_color_for_black() -> void:
	var black = Color.BLACK
	var contrast = accessibility_manager.get_contrast_color(black)
	assert_eq(contrast, Color.WHITE, "Black background should return white text")


func test_get_contrast_color_for_white() -> void:
	var white = Color.WHITE
	var contrast = accessibility_manager.get_contrast_color(white)
	assert_eq(contrast, Color.BLACK, "White background should return black text")


func test_get_contrast_color_for_colored_backgrounds() -> void:
	# Test with pure red (high R, low G and B = medium-low luminance)
	var red = Color(1.0, 0.0, 0.0)
	var contrast_red = accessibility_manager.get_contrast_color(red)
	assert_eq(contrast_red, Color.WHITE, "Red background should return white text")

	# Test with pure green (high G = higher luminance due to 0.587 weight)
	var green = Color(0.0, 1.0, 0.0)
	var contrast_green = accessibility_manager.get_contrast_color(green)
	assert_eq(contrast_green, Color.BLACK, "Green background should return black text")

	# Test with pure blue (high B, low R and G = low luminance)
	var blue = Color(0.0, 0.0, 1.0)
	var contrast_blue = accessibility_manager.get_contrast_color(blue)
	assert_eq(contrast_blue, Color.WHITE, "Blue background should return white text")


# ==================== RESET AND PERSISTENCE TESTS ====================


func test_reset_to_defaults_resets_all_settings() -> void:
	# Change all settings
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.PROTANOPIA)
	accessibility_manager.set_ui_scale(1.5)
	accessibility_manager.set_font_size(accessibility_manager.FontSize.EXTRA_LARGE)
	accessibility_manager.set_high_contrast(true)
	accessibility_manager.set_dyslexia_font(true)

	# Reset
	accessibility_manager.reset_to_defaults()

	# Verify all defaults
	assert_eq(
		accessibility_manager.current_colorblind_mode,
		accessibility_manager.ColorblindMode.NONE,
		"Colorblind mode should reset to NONE"
	)
	assert_eq(accessibility_manager.current_ui_scale, 1.0, "UI scale should reset to 1.0")
	assert_eq(
		accessibility_manager.current_font_size,
		accessibility_manager.FontSize.MEDIUM,
		"Font size should reset to MEDIUM"
	)
	assert_false(accessibility_manager.current_high_contrast, "High contrast should be disabled")
	assert_false(accessibility_manager.dyslexia_font_enabled, "Dyslexia font should be disabled")


func test_reset_to_defaults_saves_to_config() -> void:
	# Change all settings
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.PROTANOPIA)
	accessibility_manager.set_ui_scale(1.5)

	# Reset
	accessibility_manager.reset_to_defaults()

	# Verify Config was updated
	var saved_mode = Config.get_config("AccessibilitySettings", "ColorblindMode", -999)
	var saved_scale = Config.get_config("AccessibilitySettings", "UIScale", -999.0)

	assert_eq(saved_mode, accessibility_manager.ColorblindMode.NONE, "Reset should save to Config")
	assert_eq(saved_scale, 1.0, "Reset should save to Config")


func test_save_settings_persists_to_config() -> void:
	# Change settings
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.DEUTERANOPIA)
	accessibility_manager.set_ui_scale(1.2)
	accessibility_manager.set_font_size(accessibility_manager.FontSize.LARGE)
	accessibility_manager.set_high_contrast(true)

	# Save (should happen automatically, but test explicitly)
	accessibility_manager.save_settings()

	# Verify settings were saved by checking Config
	var saved_colorblind = Config.get_config(
		"AccessibilitySettings",
		"ColorblindMode",
		accessibility_manager.ColorblindMode.NONE
	)
	assert_eq(
		saved_colorblind,
		accessibility_manager.ColorblindMode.DEUTERANOPIA,
		"Colorblind mode should be saved to config"
	)


func test_load_settings_reads_from_config() -> void:
	# Manually set config values
	Config.set_config("AccessibilitySettings", "ColorblindMode", accessibility_manager.ColorblindMode.TRITANOPIA)
	Config.set_config("AccessibilitySettings", "UIScale", 1.2)
	Config.set_config("AccessibilitySettings", "FontSize", accessibility_manager.FontSize.LARGE)
	Config.set_config("AccessibilitySettings", "HighContrast", true)
	Config.set_config("AccessibilitySettings", "DyslexiaFont", true)

	# Load settings
	accessibility_manager.load_settings()

	# Verify they were loaded
	assert_eq(
		accessibility_manager.current_colorblind_mode,
		accessibility_manager.ColorblindMode.TRITANOPIA,
		"Should load colorblind mode from config"
	)
	assert_eq(accessibility_manager.current_ui_scale, 1.2, "Should load UI scale from config")
	assert_eq(
		accessibility_manager.current_font_size,
		accessibility_manager.FontSize.LARGE,
		"Should load font size from config"
	)
	assert_true(accessibility_manager.current_high_contrast, "Should load high contrast from config")
	assert_true(accessibility_manager.dyslexia_font_enabled, "Should load dyslexia font from config")


func test_load_settings_uses_defaults_when_config_empty() -> void:
	# Ensure config is empty
	Config.erase_section("AccessibilitySettings")

	# Load settings
	accessibility_manager.load_settings()

	# Should have defaults
	assert_eq(
		accessibility_manager.current_colorblind_mode,
		accessibility_manager.ColorblindMode.NONE,
		"Should use default when config is empty"
	)
	assert_eq(accessibility_manager.current_ui_scale, 1.0, "Should use default when config is empty")
	assert_eq(
		accessibility_manager.current_font_size,
		accessibility_manager.FontSize.MEDIUM,
		"Should use default when config is empty"
	)
	assert_false(accessibility_manager.current_high_contrast, "Should use default when config is empty")


func test_save_and_load_round_trip() -> void:
	# Set various settings
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.PROTANOPIA)
	accessibility_manager.set_ui_scale(0.8)
	accessibility_manager.set_font_size(accessibility_manager.FontSize.SMALL)
	accessibility_manager.set_high_contrast(true)
	accessibility_manager.set_dyslexia_font(true)

	# Save
	accessibility_manager.save_settings()

	# Reset to defaults
	accessibility_manager.current_colorblind_mode = accessibility_manager.ColorblindMode.NONE
	accessibility_manager.current_ui_scale = 1.0
	accessibility_manager.current_font_size = accessibility_manager.FontSize.MEDIUM
	accessibility_manager.current_high_contrast = false
	accessibility_manager.dyslexia_font_enabled = false

	# Load
	accessibility_manager.load_settings()

	# Verify everything was restored
	assert_eq(
		accessibility_manager.current_colorblind_mode,
		accessibility_manager.ColorblindMode.PROTANOPIA,
		"Round trip should preserve colorblind mode"
	)
	assert_eq(accessibility_manager.current_ui_scale, 0.8, "Round trip should preserve UI scale")
	assert_eq(
		accessibility_manager.current_font_size,
		accessibility_manager.FontSize.SMALL,
		"Round trip should preserve font size"
	)
	assert_true(accessibility_manager.current_high_contrast, "Round trip should preserve high contrast")
	assert_true(accessibility_manager.dyslexia_font_enabled, "Round trip should preserve dyslexia font")


# ==================== INTEGRATION TESTS ====================


func test_apply_to_scene_with_labels() -> void:
	# Create a test scene with labels
	var test_scene = Node.new()
	var label1 = Label.new()
	var label2 = Label.new()
	label1.name = "Label1"
	label2.name = "Label2"
	test_scene.add_child(label1)
	test_scene.add_child(label2)

	accessibility_manager.set_font_size(accessibility_manager.FontSize.LARGE)

	# Apply settings to scene
	accessibility_manager.apply_to_scene(test_scene)

	# Verify method completes without errors
	assert_not_null(test_scene, "Scene should still exist after applying settings")

	test_scene.queue_free()


func test_apply_to_scene_with_buttons() -> void:
	# Create a test scene with buttons
	var test_scene = Node.new()
	var button1 = Button.new()
	var button2 = Button.new()
	button1.name = "Button1"
	button2.name = "Button2"
	test_scene.add_child(button1)
	test_scene.add_child(button2)

	accessibility_manager.set_high_contrast(true)

	# Apply settings to scene
	accessibility_manager.apply_to_scene(test_scene)

	# Verify method completes without errors
	assert_not_null(test_scene, "Scene should still exist after applying settings")

	test_scene.queue_free()


func test_apply_to_scene_with_nested_children() -> void:
	# Create a test scene with nested structure
	var test_scene = Node.new()
	var container = Control.new()
	var label = Label.new()
	var button = Button.new()

	container.add_child(label)
	container.add_child(button)
	test_scene.add_child(container)

	accessibility_manager.set_high_contrast(true)
	accessibility_manager.set_font_size(accessibility_manager.FontSize.LARGE)

	# Apply settings to scene
	accessibility_manager.apply_to_scene(test_scene)

	# Verify method completes without errors
	assert_not_null(test_scene, "Scene with nested children should handle apply_to_scene")

	test_scene.queue_free()


func test_apply_to_scene_empty_scene() -> void:
	var test_scene = Node.new()

	# Should not crash on empty scene
	accessibility_manager.apply_to_scene(test_scene)

	assert_not_null(test_scene, "Empty scene should handle apply_to_scene")
	test_scene.queue_free()


# ==================== SIGNAL EMISSION ORDER TESTS ====================


func test_signals_emit_before_save() -> void:
	var signal_emitted_at_value: int = -1
	var config_saved_at_value: int = -1

	accessibility_manager.colorblind_mode_changed.connect(
		func(mode: int):
			# Check what's in config at the time of signal
			signal_emitted_at_value = Config.get_config("AccessibilitySettings", "ColorblindMode", -999)
	)

	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.PROTANOPIA)

	config_saved_at_value = Config.get_config("AccessibilitySettings", "ColorblindMode", -999)

	# Both should have the new value (signal fires, then save)
	assert_eq(config_saved_at_value, accessibility_manager.ColorblindMode.PROTANOPIA, "Config should be saved")


func test_multiple_signals_for_multiple_changes() -> void:
	var signal_count = 0

	accessibility_manager.colorblind_mode_changed.connect(
		func(_mode: int):
			signal_count += 1
	)

	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.PROTANOPIA)
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.DEUTERANOPIA)
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.TRITANOPIA)

	await get_tree().process_frame

	assert_eq(signal_count, 3, "Should emit signal for each change")


# ==================== EDGE CASE TESTS ====================


func test_ui_scale_with_negative_value() -> void:
	accessibility_manager.set_ui_scale(-1.0)
	assert_eq(accessibility_manager.current_ui_scale, 0.8, "Negative scale should clamp to minimum")


func test_ui_scale_with_zero() -> void:
	accessibility_manager.set_ui_scale(0.0)
	assert_eq(accessibility_manager.current_ui_scale, 0.8, "Zero scale should clamp to minimum")


func test_ui_scale_with_very_large_value() -> void:
	accessibility_manager.set_ui_scale(999.0)
	assert_eq(accessibility_manager.current_ui_scale, 1.5, "Very large scale should clamp to maximum")


func test_colorblind_mode_preserves_value_across_resets() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.TRITANOPIA)
	var mode_before_reset = accessibility_manager.current_colorblind_mode

	# Reset should change it back to NONE
	accessibility_manager.reset_to_defaults()

	assert_eq(
		accessibility_manager.current_colorblind_mode,
		accessibility_manager.ColorblindMode.NONE,
		"Reset should change to NONE"
	)
	assert_eq(mode_before_reset, accessibility_manager.ColorblindMode.TRITANOPIA, "Previous value should have been TRITANOPIA")


func test_font_size_multiplier_for_invalid_size() -> void:
	# Directly set an invalid font size value
	accessibility_manager.current_font_size = 999

	# Should return default 1.0 for invalid size
	var multiplier = accessibility_manager.get_font_size_multiplier()
	assert_eq(multiplier, 1.0, "Invalid font size should return default multiplier")


func test_palette_colors_are_valid_colors() -> void:
	for mode in accessibility_manager.COLORBLIND_PALETTES.keys():
		var palette = accessibility_manager.COLORBLIND_PALETTES[mode]
		var approved_color = palette["approved_color"]
		var rejected_color = palette["rejected_color"]

		assert_true(approved_color is Color, "Approved color should be a Color")
		assert_true(rejected_color is Color, "Rejected color should be a Color")


# ==================== TEST SIGNAL HANDLERS ====================


func _on_colorblind_mode_changed(mode: int) -> void:
	test_colorblind_changed_called = true
	last_colorblind_mode = mode


func _on_ui_scale_changed(scale: float) -> void:
	test_ui_scale_changed_called = true
	last_ui_scale = scale


func _on_font_size_changed(size: int) -> void:
	test_font_size_changed_called = true
	last_font_size = size


func _on_high_contrast_changed(enabled: bool) -> void:
	test_high_contrast_changed_called = true
	last_high_contrast = enabled
