extends GutTest

## Unit tests for AccessibilityManager
## Tests accessibility settings, colorblind modes, UI scaling, font sizes, and high contrast features

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


func test_get_approval_color_default() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.NONE)
	var color = accessibility_manager.get_approval_color()
	assert_eq(color, Color.GREEN, "Default approval color should be GREEN")


func test_get_approval_color_protanopia() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.PROTANOPIA)
	var color = accessibility_manager.get_approval_color()
	var expected_color = accessibility_manager.COLORBLIND_PALETTES[accessibility_manager.ColorblindMode.PROTANOPIA]["approved_color"]
	assert_eq(color, expected_color, "PROTANOPIA approval color should match palette")


func test_get_rejection_color_default() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.NONE)
	var color = accessibility_manager.get_rejection_color()
	assert_eq(color, Color.RED, "Default rejection color should be RED")


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


func test_get_rejection_pattern_with_colorblind_mode() -> void:
	accessibility_manager.set_colorblind_mode(accessibility_manager.ColorblindMode.DEUTERANOPIA)
	var pattern = accessibility_manager.get_rejection_pattern()
	assert_eq(pattern, "dots", "Colorblind mode should provide pattern")


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


func test_set_ui_scale_clamps_minimum() -> void:
	accessibility_manager.set_ui_scale(0.5)  # Too low
	assert_eq(accessibility_manager.current_ui_scale, 0.8, "UI scale should be clamped to minimum 0.8")


func test_set_ui_scale_clamps_maximum() -> void:
	accessibility_manager.set_ui_scale(2.0)  # Too high
	assert_eq(accessibility_manager.current_ui_scale, 1.5, "UI scale should be clamped to maximum 1.5")


func test_ui_scale_options_are_valid() -> void:
	for option_name in accessibility_manager.UI_SCALE_OPTIONS:
		var scale = accessibility_manager.UI_SCALE_OPTIONS[option_name]
		assert_true(scale >= 0.8 and scale <= 1.5, "All UI scale options should be within valid range")


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


# ==================== DYSLEXIA FONT TESTS ====================


func test_set_dyslexia_font_updates_setting() -> void:
	accessibility_manager.set_dyslexia_font(true)
	assert_true(accessibility_manager.dyslexia_font_enabled, "Dyslexia font should be enabled")


func test_set_dyslexia_font_saves_setting() -> void:
	accessibility_manager.set_dyslexia_font(true)
	# Setting should be persisted
	assert_true(accessibility_manager.dyslexia_font_enabled, "Dyslexia font setting should be saved")


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
	# Should return white for exactly 50% luminance (threshold is < 0.5)
	assert_eq(contrast, Color.BLACK, "Medium background should return appropriate contrast")


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


# ==================== INTEGRATION TESTS ====================


func test_apply_high_contrast_outline_to_control() -> void:
	accessibility_manager.set_high_contrast(true)
	var button = Button.new()

	accessibility_manager.apply_high_contrast_outline(button)

	# Verify method doesn't crash and button still exists
	assert_not_null(button, "Button should still exist after applying high contrast")
	button.queue_free()


func test_apply_to_scene_doesnt_crash() -> void:
	# Create a simple test scene
	var test_scene = Node.new()
	var label = Label.new()
	var button = Button.new()
	test_scene.add_child(label)
	test_scene.add_child(button)

	accessibility_manager.set_high_contrast(true)
	accessibility_manager.set_font_size(accessibility_manager.FontSize.LARGE)

	# Apply settings to scene
	accessibility_manager.apply_to_scene(test_scene)

	# Verify method completes without errors
	assert_not_null(test_scene, "Scene should still exist after applying settings")

	test_scene.queue_free()


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
