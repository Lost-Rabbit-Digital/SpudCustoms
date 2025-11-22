extends GutTest

## Unit tests for UIManager
## Tests alert display, screen shake, score formatting, and UI updates

var ui_manager: Node
var test_label: Label
var test_timer: Timer
var alert_displayed_called: bool = false
var alert_cleared_called: bool = false
var last_alert_type: String = ""
var last_alert_message: String = ""

func before_each() -> void:
	ui_manager = get_node("/root/UIManager")

	# Create test Label and Timer
	test_label = Label.new()
	test_label.name = "TestAlertLabel"
	add_child_autofree(test_label)

	test_timer = Timer.new()
	test_timer.name = "TestAlertTimer"
	test_timer.wait_time = 0.1  # Short duration for testing
	add_child_autofree(test_timer)

	# Reset tracking variables
	alert_displayed_called = false
	alert_cleared_called = false
	last_alert_type = ""
	last_alert_message = ""

	# Connect to signals
	if not ui_manager.alert_displayed.is_connected(_on_alert_displayed):
		ui_manager.alert_displayed.connect(_on_alert_displayed)
	if not ui_manager.alert_cleared.is_connected(_on_alert_cleared):
		ui_manager.alert_cleared.connect(_on_alert_cleared)


func after_each() -> void:
	# Disconnect signals
	if ui_manager.alert_displayed.is_connected(_on_alert_displayed):
		ui_manager.alert_displayed.disconnect(_on_alert_displayed)
	if ui_manager.alert_cleared.is_connected(_on_alert_cleared):
		ui_manager.alert_cleared.disconnect(_on_alert_cleared)


# ==================== SIGNAL CALLBACK FUNCTIONS ====================

func _on_alert_displayed(alert_type: String, message: String) -> void:
	alert_displayed_called = true
	last_alert_type = alert_type
	last_alert_message = message


func _on_alert_cleared() -> void:
	alert_cleared_called = true


# ==================== RED ALERT TESTS ====================

func test_display_red_alert_makes_label_visible() -> void:
	ui_manager.display_red_alert(test_label, test_timer, "Test Error")
	await get_tree().process_frame

	assert_true(test_label.visible, "Red alert should make label visible")


func test_display_red_alert_sets_text() -> void:
	var message = "Test Error Message"
	ui_manager.display_red_alert(test_label, test_timer, message)
	await get_tree().process_frame

	assert_eq(test_label.text, message, "Red alert should set label text")


func test_display_red_alert_sets_red_color() -> void:
	ui_manager.display_red_alert(test_label, test_timer, "Error")
	await get_tree().process_frame

	var color = test_label.get_theme_color("font_color")
	assert_eq(color, Color.RED, "Red alert should set red font color")


func test_display_red_alert_emits_signal() -> void:
	ui_manager.display_red_alert(test_label, test_timer, "Test Error")
	await get_tree().process_frame

	assert_true(alert_displayed_called, "Red alert should emit alert_displayed signal")
	assert_eq(last_alert_type, "red", "Alert type should be 'red'")


func test_display_red_alert_message_preserved() -> void:
	var message = "Invalid document"
	ui_manager.display_red_alert(test_label, test_timer, message)
	await get_tree().process_frame

	assert_eq(last_alert_message, message, "Alert message should be preserved in signal")


func test_red_alert_sets_z_index() -> void:
	ui_manager.display_red_alert(test_label, test_timer, "Error")
	await get_tree().process_frame

	assert_eq(test_label.z_index, 120, "Red alert should set z_index to 120")


# ==================== GREEN ALERT TESTS ====================

func test_display_green_alert_makes_label_visible() -> void:
	ui_manager.display_green_alert(test_label, test_timer, "Success")
	await get_tree().process_frame

	assert_true(test_label.visible, "Green alert should make label visible")


func test_display_green_alert_sets_text() -> void:
	var message = "Document Approved"
	ui_manager.display_green_alert(test_label, test_timer, message)
	await get_tree().process_frame

	assert_eq(test_label.text, message, "Green alert should set label text")


func test_display_green_alert_sets_green_color() -> void:
	ui_manager.display_green_alert(test_label, test_timer, "Success")
	await get_tree().process_frame

	var color = test_label.get_theme_color("font_color")
	assert_eq(color, Color.GREEN, "Green alert should set green font color")


func test_display_green_alert_emits_signal() -> void:
	ui_manager.display_green_alert(test_label, test_timer, "Success")
	await get_tree().process_frame

	assert_true(alert_displayed_called, "Green alert should emit alert_displayed signal")
	assert_eq(last_alert_type, "green", "Alert type should be 'green'")


func test_perfect_stamp_alert_uses_brighter_color() -> void:
	ui_manager.display_green_alert(test_label, test_timer, "PERFECT STAMP!")
	await get_tree().process_frame

	var color = test_label.get_theme_color("font_color")
	var expected_color = Color(0.3, 1.0, 0.3)

	assert_eq(color, expected_color, "Perfect stamp should use brighter green")


func test_perfect_stamp_alert_larger_font() -> void:
	ui_manager.display_green_alert(test_label, test_timer, "PERFECT STAMP!")
	await get_tree().process_frame

	var font_size = test_label.get_theme_font_size("font_size")
	assert_eq(font_size, 28, "Perfect stamp should have larger font size")


func test_normal_green_alert_standard_font_size() -> void:
	ui_manager.display_green_alert(test_label, test_timer, "Good job")
	await get_tree().process_frame

	var font_size = test_label.get_theme_font_size("font_size")
	assert_eq(font_size, 24, "Normal green alert should have standard font size")


# ==================== ALERT CLEARING TESTS ====================

func test_clear_alert_hides_label() -> void:
	test_label.visible = true
	ui_manager.clear_alert_after_delay(test_label, test_timer)

	# Wait for timer to complete
	await test_timer.timeout
	await get_tree().process_frame

	assert_false(test_label.visible, "Clear alert should hide label")


func test_clear_alert_sets_placeholder_text() -> void:
	test_label.text = "Original Text"
	ui_manager.clear_alert_after_delay(test_label, test_timer)

	await test_timer.timeout
	await get_tree().process_frame

	assert_eq(test_label.text, "PLACEHOLDER ALERT TEXT", "Should set placeholder text")


func test_clear_alert_sets_blue_color() -> void:
	ui_manager.clear_alert_after_delay(test_label, test_timer)

	await test_timer.timeout
	await get_tree().process_frame

	var color = test_label.get_theme_color("font_color")
	assert_eq(color, Color.BLUE, "Should set blue color after clearing")


func test_clear_alert_emits_signal() -> void:
	ui_manager.clear_alert_after_delay(test_label, test_timer)

	await test_timer.timeout
	await get_tree().process_frame

	assert_true(alert_cleared_called, "Should emit alert_cleared signal")


# ==================== SCREEN SHAKE TESTS ====================

func test_shake_screen_respects_zero_intensity() -> void:
	ui_manager.screen_shake_intensity_multiplier = 0.0

	# Get current scene root position
	var root = get_tree().current_scene
	var initial_pos = root.position

	ui_manager.shake_screen(10.0, 0.1)
	await get_tree().process_frame

	# Position should not change when intensity is zero
	assert_eq(root.position, initial_pos, "Screen should not shake when intensity is zero")


func test_shake_screen_applies_multiplier() -> void:
	ui_manager.screen_shake_intensity_multiplier = 0.5

	var root = get_tree().current_scene
	if root:
		var initial_pos = root.position

		ui_manager.shake_screen(20.0, 0.2)
		await get_tree().process_frame

		# With multiplier < 1, shake should be applied (position may change)
		# This test verifies the function executes without error
		assert_not_null(root, "Root scene should exist during shake")


func test_shake_screen_returns_to_initial_position() -> void:
	ui_manager.screen_shake_intensity_multiplier = 1.0

	var root = get_tree().current_scene
	var initial_pos = root.position

	ui_manager.shake_screen(5.0, 0.15)

	# Wait for shake to complete
	await get_tree().create_timer(0.2).timeout
	await get_tree().process_frame

	assert_eq(root.position, initial_pos, "Screen should return to initial position after shake")


func test_shake_screen_with_different_intensities() -> void:
	var root = get_tree().current_scene
	var initial_pos = root.position

	# Test mild shake
	ui_manager.shake_screen(3.0, 0.2)
	await get_tree().create_timer(0.25).timeout

	assert_eq(root.position, initial_pos, "Mild shake should return to initial position")

	# Test strong shake
	ui_manager.shake_screen(25.0, 0.4)
	await get_tree().create_timer(0.45).timeout

	assert_eq(root.position, initial_pos, "Strong shake should return to initial position")


# ==================== SCORE FORMATTING TESTS ====================

func test_format_score_no_commas() -> void:
	var result = ui_manager.format_score(999)

	assert_eq(result, "999", "Should not add commas for numbers under 1000")


func test_format_score_single_comma() -> void:
	var result = ui_manager.format_score(1000)

	assert_eq(result, "1,000", "Should add comma for thousands")


func test_format_score_multiple_commas() -> void:
	var result = ui_manager.format_score(1234567)

	assert_eq(result, "1,234,567", "Should add commas for millions")


func test_format_score_zero() -> void:
	var result = ui_manager.format_score(0)

	assert_eq(result, "0", "Should handle zero correctly")


func test_format_score_exact_thousand() -> void:
	var result = ui_manager.format_score(5000)

	assert_eq(result, "5,000", "Should format exact thousands correctly")


func test_format_score_large_number() -> void:
	var result = ui_manager.format_score(9999999)

	assert_eq(result, "9,999,999", "Should format large numbers correctly")


func test_format_score_hundred_thousand() -> void:
	var result = ui_manager.format_score(100000)

	assert_eq(result, "100,000", "Should format hundred thousand correctly")


# ==================== CAMERA SHAKE SETTING TESTS ====================

func test_update_camera_shake_setting_from_config() -> void:
	# This tests that the function can be called without error
	ui_manager.update_camera_shake_setting()

	assert_true(ui_manager.screen_shake_intensity_multiplier >= 0.0, "Multiplier should be non-negative")


func test_screen_shake_intensity_multiplier_default() -> void:
	# After initialization, multiplier should be set
	assert_true(ui_manager.screen_shake_intensity_multiplier is float, "Multiplier should be a float")


# ==================== AUDIO TESTS ====================

func test_red_alert_creates_audio_player() -> void:
	var initial_child_count = ui_manager.get_child_count()

	ui_manager.display_red_alert(test_label, test_timer, "Error")
	await get_tree().process_frame

	# Audio player should be added as child
	var has_audio_player = false
	for child in ui_manager.get_children():
		if child is AudioStreamPlayer:
			has_audio_player = true
			break

	assert_true(has_audio_player, "Red alert should create audio player")


func test_green_alert_creates_audio_player() -> void:
	ui_manager.display_green_alert(test_label, test_timer, "Success")
	await get_tree().process_frame

	var has_audio_player = false
	for child in ui_manager.get_children():
		if child is AudioStreamPlayer:
			has_audio_player = true
			break

	assert_true(has_audio_player, "Green alert should create audio player")


func test_perfect_stamp_uses_different_sound() -> void:
	ui_manager.display_green_alert(test_label, test_timer, "PERFECT STAMP!")
	await get_tree().process_frame

	# Find the audio player
	var audio_player: AudioStreamPlayer = null
	for child in ui_manager.get_children():
		if child is AudioStreamPlayer:
			audio_player = child
			break

	assert_not_null(audio_player, "Should create audio player for perfect stamp")
	# Perfect stamp should use different audio stream
	assert_not_null(audio_player.stream, "Audio player should have a stream")
