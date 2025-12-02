extends Node
## Debug Command Manager for testing minigames, narrative, and shift progression.
##
## Hotkeys (only active when DEBUG_ENABLED is true):
##   F1 - Launch Document Scanner minigame
##   F2 - Launch Stamp Sorting minigame
##   F3 - Launch Fingerprint Match minigame
##   F4 - Launch Code Breaker minigame
##   F5 - Launch Border Chase minigame
##   F6 - End shift successfully (quota met)
##   F7 - End shift with failure (game over)
##   F8 - Skip to next shift instantly
##   F9 - Skip current dialogue/narrative
##   F10 - Fill quota instantly
##   F11 - Clear all strikes
##   F12 - Toggle debug info overlay
##
## Usage: Set DEBUG_ENABLED = true to enable debug commands

## Enable/disable debug commands - SET TO FALSE FOR RELEASE BUILDS
const DEBUG_ENABLED: bool = true

## Minigame type mapping for F1-F5 keys
const MINIGAME_KEYS: Dictionary = {
	KEY_F1: "document_scanner",
	KEY_F2: "stamp_sorting",
	KEY_F3: "fingerprint_match",
	KEY_F4: "code_breaker",
	KEY_F5: "border_chase",
}

## Debug overlay for showing current game state
var debug_overlay: CanvasLayer = null
var debug_label: Label = null
var show_debug_overlay: bool = false

## Reference to current main game scene (if available)
var main_game: Node = null


func _ready() -> void:
	if not DEBUG_ENABLED:
		set_process_input(false)
		return

	# Create debug overlay
	_create_debug_overlay()

	# Print debug commands help on startup
	print_debug_help()


func _input(event: InputEvent) -> void:
	if not DEBUG_ENABLED:
		return

	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	# Handle minigame keys F1-F5
	if key_event.keycode in MINIGAME_KEYS:
		_launch_minigame(MINIGAME_KEYS[key_event.keycode])
		return

	# Handle other debug keys
	match key_event.keycode:
		KEY_F6:
			_end_shift_success()
		KEY_F7:
			_end_shift_failure()
		KEY_F8:
			_skip_to_next_shift()
		KEY_F9:
			_skip_dialogue()
		KEY_F10:
			_fill_quota()
		KEY_F11:
			_clear_strikes()
		KEY_F12:
			_toggle_debug_overlay()


func _process(_delta: float) -> void:
	if show_debug_overlay and debug_label:
		_update_debug_overlay()


## Launch a specific minigame by type
func _launch_minigame(minigame_type: String) -> void:
	print("[DEBUG] Launching minigame: ", minigame_type)

	# Use EventBus to request minigame launch with force_launch to bypass unlock checks
	if EventBus:
		EventBus.minigame_launch_requested.emit(minigame_type, {"force_launch": true})
		_show_debug_message("Launched: " + minigame_type.replace("_", " ").capitalize())
	else:
		push_warning("[DEBUG] EventBus not available for minigame launch")


## End current shift successfully
func _end_shift_success() -> void:
	print("[DEBUG] Ending shift successfully")

	var game = _get_main_game()
	if game and game.has_method("end_shift"):
		# First ensure quota is met
		Global.quota_met = Global.quota_target
		game.end_shift(true)
		_show_debug_message("Shift ended (SUCCESS)")
	else:
		push_warning("[DEBUG] MainGame not found or doesn't have end_shift method")
		_show_debug_message("ERROR: Not in game scene")


## End current shift with failure
func _end_shift_failure() -> void:
	print("[DEBUG] Ending shift with failure")

	var game = _get_main_game()
	if game and game.has_method("end_shift"):
		game.end_shift(false)
		_show_debug_message("Shift ended (FAILURE)")
	else:
		push_warning("[DEBUG] MainGame not found")
		_show_debug_message("ERROR: Not in game scene")


## Skip to the next shift instantly
func _skip_to_next_shift() -> void:
	print("[DEBUG] Skipping to next shift")

	# First skip any active dialogue
	_skip_dialogue()

	# Advance the shift
	if GameStateManager:
		var current = GameStateManager.get_shift()
		var next_shift = current + 1
		GameStateManager.set_shift(next_shift)

		# Also update Global for consistency
		Global.shift = next_shift
		Global.advance_shift()

		_show_debug_message("Skipped to Shift " + str(next_shift))

		# Reload the scene to apply the new shift
		if SceneLoader:
			SceneLoader.reload_current_scene()
	else:
		push_warning("[DEBUG] GameStateManager not available")


## Skip current dialogue/narrative
func _skip_dialogue() -> void:
	print("[DEBUG] Skipping dialogue")

	# Check if Dialogic has an active timeline
	if Dialogic and Dialogic.current_timeline:
		Dialogic.Audio.stop_all_channels()
		Dialogic.Audio.stop_all_one_shot_sounds()
		Dialogic.end_timeline()
		_show_debug_message("Dialogue skipped")
	else:
		_show_debug_message("No active dialogue")

	# Also cleanup any skip buttons that may be lingering
	var skip_buttons = get_tree().get_nodes_in_group("DialogueSkipButtons")
	for button_layer in skip_buttons:
		if is_instance_valid(button_layer):
			button_layer.free()


## Fill quota to target instantly
func _fill_quota() -> void:
	print("[DEBUG] Filling quota")

	if GameStateManager:
		var target = GameStateManager.get_quota_target()
		GameStateManager.set_quota_met(target)
		Global.quota_met = target
		_show_debug_message("Quota filled: " + str(target) + "/" + str(target))

		# Update UI via EventBus
		if EventBus:
			EventBus.quota_updated.emit(target, target)
	else:
		push_warning("[DEBUG] GameStateManager not available")


## Clear all strikes
func _clear_strikes() -> void:
	print("[DEBUG] Clearing strikes")

	if GameStateManager:
		GameStateManager.set_strikes(0)
		Global.strikes = 0
		_show_debug_message("Strikes cleared: 0/" + str(Global.max_strikes))
	else:
		push_warning("[DEBUG] GameStateManager not available")


## Toggle debug info overlay
func _toggle_debug_overlay() -> void:
	show_debug_overlay = not show_debug_overlay
	if debug_overlay:
		debug_overlay.visible = show_debug_overlay
	print("[DEBUG] Debug overlay: ", "ON" if show_debug_overlay else "OFF")


## Get reference to main game scene
func _get_main_game() -> Node:
	# Try to find MainGame in the current scene
	var root = get_tree().current_scene
	if root and root.name == "MainGame":
		return root

	# Search for it in the scene tree
	var main_games = get_tree().get_nodes_in_group("MainGame")
	if main_games.size() > 0:
		return main_games[0]

	# Try finding by script
	if root:
		for child in root.get_children():
			if child.get_script() and "mainGame" in child.get_script().resource_path:
				return child

	return null


## Create the debug overlay UI
func _create_debug_overlay() -> void:
	debug_overlay = CanvasLayer.new()
	debug_overlay.name = "DebugOverlay"
	debug_overlay.layer = 1000  # Above everything
	debug_overlay.visible = false

	var panel = PanelContainer.new()
	panel.position = Vector2(10, 10)

	# Create a semi-transparent background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.set_corner_radius_all(5)
	panel.add_theme_stylebox_override("panel", style)

	debug_label = Label.new()
	debug_label.text = "Debug Info"
	debug_label.add_theme_font_size_override("font_size", 12)

	panel.add_child(debug_label)
	debug_overlay.add_child(panel)
	add_child(debug_overlay)


## Update debug overlay with current game state
func _update_debug_overlay() -> void:
	if not debug_label:
		return

	var info_lines: PackedStringArray = []
	info_lines.append("=== DEBUG INFO (F12 to hide) ===")
	info_lines.append("")

	# Game state info
	if GameStateManager:
		info_lines.append("Shift: " + str(GameStateManager.get_shift()))
		info_lines.append("Score: " + str(GameStateManager.get_score()))
		info_lines.append("Strikes: " + str(GameStateManager.get_strikes()) + "/" + str(Global.max_strikes))
		info_lines.append("Quota: " + str(GameStateManager.get_quota_met()) + "/" + str(GameStateManager.get_quota_target()))
		info_lines.append("Game Mode: " + str(GameStateManager.get_game_mode()))
		info_lines.append("Difficulty: " + str(GameStateManager.get_difficulty()))

	info_lines.append("")
	info_lines.append("=== HOTKEYS ===")
	info_lines.append("F1-F5: Launch Minigames")
	info_lines.append("F6: End Shift (Success)")
	info_lines.append("F7: End Shift (Failure)")
	info_lines.append("F8: Skip to Next Shift")
	info_lines.append("F9: Skip Dialogue")
	info_lines.append("F10: Fill Quota")
	info_lines.append("F11: Clear Strikes")

	# Dialogue state
	if Dialogic:
		var dialogue_active = Dialogic.current_timeline != null
		info_lines.append("")
		info_lines.append("Dialogue Active: " + str(dialogue_active))

	debug_label.text = "\n".join(info_lines)


## Show a temporary debug message on screen
func _show_debug_message(message: String) -> void:
	print("[DEBUG] ", message)

	# Create a temporary label to show the message
	var msg_layer = CanvasLayer.new()
	msg_layer.layer = 999

	var label = Label.new()
	label.text = "[DEBUG] " + message
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.position = Vector2(10, 50)

	msg_layer.add_child(label)
	get_tree().root.add_child(msg_layer)

	# Fade out and remove after 2 seconds
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(msg_layer.queue_free)


## Print help information to console
func print_debug_help() -> void:
	print("")
	print("╔══════════════════════════════════════════════════════════════╗")
	print("║           SPUD CUSTOMS DEBUG COMMANDS ENABLED                ║")
	print("╠══════════════════════════════════════════════════════════════╣")
	print("║  MINIGAME LAUNCHERS:                                         ║")
	print("║    F1  - Document Scanner                                    ║")
	print("║    F2  - Stamp Sorting                                       ║")
	print("║    F3  - Fingerprint Match                                   ║")
	print("║    F4  - Code Breaker                                        ║")
	print("║    F5  - Border Chase                                        ║")
	print("║                                                              ║")
	print("║  SHIFT CONTROL:                                              ║")
	print("║    F6  - End Shift (Success)                                 ║")
	print("║    F7  - End Shift (Failure)                                 ║")
	print("║    F8  - Skip to Next Shift                                  ║")
	print("║                                                              ║")
	print("║  NARRATIVE/GAMEPLAY:                                         ║")
	print("║    F9  - Skip Current Dialogue                               ║")
	print("║    F10 - Fill Quota Instantly                                ║")
	print("║    F11 - Clear All Strikes                                   ║")
	print("║    F12 - Toggle Debug Overlay                                ║")
	print("╚══════════════════════════════════════════════════════════════╝")
	print("")
