extends Node

signal dialogue_finished
signal intro_dialogue_finished
signal end_dialogue_finished

# Map level IDs to dialogue files
const LEVEL_DIALOGUES: Dictionary[int, String] = {
	0: "tutorial",
	1: "shift1_intro",
	2: "shift2_intro",
	3: "shift3_intro",
	4: "shift4_intro",
	5: "shift5_intro",
	6: "shift6_intro",
	7: "shift7_intro",
	8: "shift8_intro",
	9: "shift9_intro",
	10: "shift10_intro",
	11: "shift11_intro",
	12: "shift12_intro",
	13: "shift13_intro"
}

const LEVEL_END_DIALOGUES: Dictionary[int, String] = {
	1: "shift1_end",
	2: "shift2_end",
	3: "shift3_end",
	4: "shift4_end",
	5: "shift5_end",
	6: "shift6_end",
	7: "shift7_end",
	8: "shift8_end",
	9: "shift9_end",
	10: "final_confrontation"
}

# Achievement IDs - All narrative achievements
# Resistance Path Endings (4)
const ACHIEVEMENTS: Dictionary[String, String] = {
	"BORN_DIPLOMAT": "born_diplomat",
	"TATER_OF_JUSTICE": "tater_of_justice",
	"BEST_SERVED_HOT": "best_served_hot",
	"DOWN_WITH_THE_TATRIARCHY": "down_with_the_tatriarchy",
	# Loyalist Path Endings (3)
	"HEART_OF_STONE": "heart_of_stone",
	"SURVIVOR": "survivor",
	"LATE_BLOOMER": "late_bloomer",
	# Special Ending (1)
	"SAVIOR_OF_SPUD": "savior_of_spud",
	# Character Arc Achievements (3)
	"TOMMYS_LEGACY": "tommys_legacy",
	"ELENAS_MEMORY": "elenas_memory",
	"THE_NOTE": "the_note",
	# Discovery Achievements (2)
	"ROOT_OF_EVIL": "root_of_evil",
	"CHAOS_ARCHITECT": "chaos_architect"
}

var current_shift: int = 1
var dialogic_timeline: Node
var dialogue_active: bool = false
var current_skip_button_layer: CanvasLayer = null
var cutscene_post_processing: CanvasLayer = null
var history_panel_open: bool = false
var cutscene_bloom_pulse: CutsceneBloomPulse = null

# Track the currently active narrative QTE for result handling
var _active_narrative_qte: String = ""

# Mapping of QTE signal names to their Dialogic result variable names
const QTE_RESULT_VARIABLES: Dictionary = {
	"qte_rescue": "qte_rescue_result",
	"qte_confrontation": "qte_confrontation_result",
	"qte_escape": "qte_escape_result",
	"qte_infiltration": "qte_infiltration_result",
	"qte_scanner_fake": "qte_scanner_result",
	"qte_surveillance": "qte_surveillance_result",
	"qte_suppression": "qte_suppression_result"
}

# Preloaded resources for cutscene post-processing
var cutscene_environment: Environment = preload("res://assets/styles/cutscene_environment.tres")
var vignette_material: Material = preload("res://assets/shaders/vignette_material.tres")


func _ready():
	# Connect to EventBus events
	_connect_to_event_bus()

	# Connect to Dialogic history events to handle skip button visibility
	if Dialogic and Dialogic.History:
		Dialogic.History.open_requested.connect(_on_history_opened)
		Dialogic.History.close_requested.connect(_on_history_closed)

	# Skip initialization in score attack mode
	if not GameStateManager:
		push_error("NarrativeManager: GameStateManager not available")
		return

	var game_mode = GameStateManager.get_game_mode()
	if game_mode == "score_attack":
		return

	# Clear history from any previous sessions
	clear_dialogic_history()

	# Initialize dialogic and load dialogue for appropriate shift
	var shift = GameStateManager.get_shift()
	start_level_dialogue(shift)
	# Make it impossible to pause the narrative manager
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	# Allow any keypress or gamepad button to advance dialogue
	if not dialogue_active or history_panel_open:
		return

	# Handle keyboard input - any key press advances dialogue
	if event is InputEventKey and event.pressed and not event.echo:
		# Ignore modifier keys
		if event.keycode in [KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META]:
			return
		# Ignore escape (used for menu/skip)
		if event.keycode == KEY_ESCAPE:
			return
		# Trigger dialogic advance
		if Dialogic and Dialogic.Inputs:
			Dialogic.Inputs.dialogic_action.emit()
			get_viewport().set_input_as_handled()
			return

	# Handle gamepad button input
	if event is InputEventJoypadButton and event.pressed:
		# Ignore start/select buttons
		if event.button_index in [JOY_BUTTON_START, JOY_BUTTON_BACK]:
			return
		if Dialogic and Dialogic.Inputs:
			Dialogic.Inputs.dialogic_action.emit()
			get_viewport().set_input_as_handled()


func _connect_to_event_bus() -> void:
	"""Subscribe to EventBus events."""
	if not EventBus:
		return

	# Subscribe to narrative-related events
	EventBus.narrative_choices_load_requested.connect(_on_load_narrative_choices_requested)
	EventBus.narrative_choices_save_requested.connect(_on_save_narrative_choices_requested)

	# Subscribe to minigame completion for QTE result handling
	EventBus.minigame_completed.connect(_on_minigame_completed)


func _on_load_narrative_choices_requested(choices: Dictionary) -> void:
	load_narrative_choices(choices)


func _on_save_narrative_choices_requested() -> void:
	# This is a no-op signal that Global uses to know NarrativeManager is available
	# The actual saving is done when Global calls save_narrative_choices() directly
	pass


func start_level_dialogue(level_id: int):
	# Check game mode
	if not GameStateManager:
		push_error("NarrativeManager: GameStateManager not available")
		return

	var game_mode = GameStateManager.get_game_mode()
	if game_mode == "score_attack":
		return

	# Return if already in dialogue
	if dialogue_active:
		return

	dialogue_active = true
	var skip_button_layer = create_skip_button()
	create_cutscene_post_processing()

	var timeline_name = LEVEL_DIALOGUES.get(level_id, "generic_shift_start")

	# Initialize shift-specific variables with defaults before timeline starts
	# This prevents "Invalid named index" errors from uninitialized variables
	_initialize_shift_variables(level_id)

	# REFACTORED: Emit dialogue started event
	if EventBus:
		EventBus.dialogue_started.emit(timeline_name)

	# Note: Dialogic.start() returns the layout node and automatically adds it to the
	# scene tree via call_deferred. Do NOT call add_child on the returned node as this
	# creates a race condition where the node ends up with two parents.
	Dialogic.start(timeline_name)
	# Connect signals safely - check if already connected to avoid duplicate connections
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)
	if not Dialogic.timeline_ended.is_connected(_on_shift_dialogue_finished):
		Dialogic.timeline_ended.connect(_on_shift_dialogue_finished)


func start_level_end_dialogue(level_id: int):
	# Check game mode
	if not GameStateManager:
		push_error("NarrativeManager: GameStateManager not available")
		return

	var game_mode = GameStateManager.get_game_mode()
	if game_mode == "score_attack":
		return

	print(
		"Attempting to start dialogue: ",
		level_id,
		" -> ",
		LEVEL_END_DIALOGUES.get(level_id, "unknown")
	)
	if dialogue_active:
		return

	# Only proceed if the level has an end dialogue
	if not level_id in LEVEL_END_DIALOGUES:
		emit_signal("end_dialogue_finished")
		return

	dialogue_active = true
	var skip_button_layer = create_skip_button()
	create_cutscene_post_processing()
	var timeline_name = LEVEL_END_DIALOGUES.get(level_id, "generic_shift_start")

	# Initialize shift-specific variables with defaults before timeline starts
	# This prevents "Invalid named index" errors from uninitialized variables
	_initialize_shift_variables(level_id)

	# REFACTORED: Emit dialogue started event
	if EventBus:
		EventBus.dialogue_started.emit(timeline_name)

	# Note: Dialogic.start() returns the layout node and automatically adds it to the
	# scene tree via call_deferred. Do NOT call add_child on the returned node as this
	# creates a race condition where the node ends up with two parents.
	var layout = Dialogic.start(timeline_name)
	if layout:
		layout.process_mode = Node.PROCESS_MODE_ALWAYS
	# Connect signals safely - check if already connected to avoid duplicate connections
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)
	if not Dialogic.timeline_ended.is_connected(_on_end_dialogue_finished):
		Dialogic.timeline_ended.connect(_on_end_dialogue_finished)


func _on_end_dialogue_finished():
	print("End dialogue finished, calling cleanup")
	dialogue_active = false

	# Disconnect signals to prevent duplicate connections on next dialogue
	_disconnect_dialogic_signals()

	cleanup_skip_buttons()
	cleanup_cutscene_post_processing()

	# REFACTORED: Emit dialogue ended event
	if EventBus:
		EventBus.dialogue_ended.emit("end_dialogue")
		EventBus.save_game_requested.emit()

	emit_signal("end_dialogue_finished")


func create_cutscene_post_processing() -> void:
	"""Create stronger post-processing effects for cutscenes."""
	if cutscene_post_processing != null:
		return

	cutscene_post_processing = CanvasLayer.new()
	cutscene_post_processing.name = "CutscenePostProcessing"
	cutscene_post_processing.layer = 50  # Below skip button but above game content

	# Add vignette overlay with stronger settings for cutscenes
	var vignette_rect = ColorRect.new()
	vignette_rect.name = "CutsceneVignette"
	vignette_rect.material = vignette_material.duplicate()
	vignette_rect.material.set_shader_parameter("vignette_intensity", 0.2)
	vignette_rect.material.set_shader_parameter("vignette_opacity", 0.5)
	vignette_rect.material.set_shader_parameter("vignette_softness", 0.4)
	vignette_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	cutscene_post_processing.add_child(vignette_rect)
	add_child(cutscene_post_processing)

	# Add animated bloom pulse effect for visual interest
	_create_bloom_pulse()


func cleanup_cutscene_post_processing() -> void:
	"""Remove cutscene post-processing effects."""
	if cutscene_post_processing != null:
		cutscene_post_processing.queue_free()
		cutscene_post_processing = null

	_cleanup_bloom_pulse()


func _disconnect_dialogic_signals() -> void:
	"""Disconnect Dialogic signals to prevent duplicate connections on next dialogue."""
	if Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.disconnect(_on_dialogic_signal)
	if Dialogic.timeline_ended.is_connected(_on_shift_dialogue_finished):
		Dialogic.timeline_ended.disconnect(_on_shift_dialogue_finished)
	if Dialogic.timeline_ended.is_connected(_on_end_dialogue_finished):
		Dialogic.timeline_ended.disconnect(_on_end_dialogue_finished)
	if Dialogic.timeline_ended.is_connected(_on_final_dialogue_finished):
		Dialogic.timeline_ended.disconnect(_on_final_dialogue_finished)


func _create_bloom_pulse() -> void:
	"""Create animated bloom effect for cutscenes."""
	if cutscene_bloom_pulse != null:
		return

	cutscene_bloom_pulse = CutsceneBloomPulse.new()
	cutscene_bloom_pulse.name = "CutsceneBloomPulse"

	# Configure the pulse for soft ethereal cinematic glow
	cutscene_bloom_pulse.base_glow_intensity = 0.25
	cutscene_bloom_pulse.pulse_amplitude = 0.12
	cutscene_bloom_pulse.pulse_speed = 0.3  # Slow, gentle pulse
	cutscene_bloom_pulse.secondary_amplitude = 0.04
	cutscene_bloom_pulse.secondary_speed = 0.12  # Even slower secondary wave
	cutscene_bloom_pulse.glow_bloom = 0.12
	cutscene_bloom_pulse.glow_hdr_threshold = 0.75
	cutscene_bloom_pulse.smoothing = 0.85

	add_child(cutscene_bloom_pulse)


func _cleanup_bloom_pulse() -> void:
	"""Remove animated bloom effect."""
	if cutscene_bloom_pulse != null:
		cutscene_bloom_pulse.queue_free()
		cutscene_bloom_pulse = null


func create_skip_button():
	var canvas = CanvasLayer.new()
	canvas.name = "SkipButtonLayer"
	canvas.layer = 100  # Put it above everything else

	var skip_button = Button.new()
	skip_button.text = "Skip"
	skip_button.custom_minimum_size = Vector2(50, 30)
	skip_button.position = Vector2(1150, 8)  # Top-right corner

	skip_button.connect("pressed", Callable(self, "_on_skip_button_pressed"))

	canvas.add_child(skip_button)
	add_child(canvas)

	# Add to a dedicated group for easy finding/removal
	canvas.add_to_group("DialogueSkipButtons")
	print("Skip button added to group: DialogueSkipButtons")
	print("Group count: ", get_tree().get_nodes_in_group("DialogueSkipButtons").size())

	return canvas


func cleanup_skip_buttons():
	var skip_buttons = get_tree().get_nodes_in_group("DialogueSkipButtons")
	print("Cleaning up skip buttons, found: ", skip_buttons.size())

	for button_layer in skip_buttons:
		if is_instance_valid(button_layer):
			print("Removing skip button: ", button_layer.name)
			button_layer.free()
		else:
			print("Skip button instance not valid")


func _on_skip_button_pressed():
	Dialogic.Audio.stop_all_channels()
	Dialogic.Audio.stop_all_one_shot_sounds()
	# End the current timeline
	Dialogic.end_timeline()

	# Disconnect signals to prevent duplicate connections on next dialogue
	_disconnect_dialogic_signals()

	# Find and remove the skip button
	cleanup_skip_buttons()
	cleanup_cutscene_post_processing()

	# Set the dialogue to not active - this is crucial
	dialogue_active = false
	emit_signal("dialogue_finished")


func _on_dialogic_signal(argument):
	if argument == "credits_ready":
		get_tree().change_scene_to_file("res://scenes/end_credits/end_credits.tscn")

	# QTE trigger signals from narrative timelines
	# Track which QTE is running so we can set the result variable on completion
	# Each QTE displays up to 3 progressive narrative images (advancing on successful key press)
	if argument == "qte_infiltration":
		_launch_qte("qte_infiltration", "Infiltrate the facility!", 5, 2.0, [
			"res://assets/narrative/qte/qte_infiltration_1.png",
			"res://assets/narrative/qte/qte_infiltration_2.png",
			"res://assets/narrative/qte/qte_infiltration_3.png",
		])
	elif argument == "qte_escape":
		_launch_qte("qte_escape", "Escape the guards!", 6, 1.8, [
			"res://assets/narrative/qte/qte_escape_1.png",
			"res://assets/narrative/qte/qte_escape_2.png",
			"res://assets/narrative/qte/qte_escape_3.png",
		])
	elif argument == "qte_confrontation":
		_launch_qte("qte_confrontation", "Stand your ground!", 4, 2.5, [
			"res://assets/narrative/qte/qte_confrontation_1.png",
			"res://assets/narrative/qte/qte_confrontation_2.png",
			"res://assets/narrative/qte/qte_confrontation_3.png",
		])
	# New QTEs for enhanced narrative
	elif argument == "qte_scanner_fake":
		_launch_qte("qte_scanner_fake", "Fake the malfunction!", 4, 2.2, [
			"res://assets/narrative/qte/qte_scanner_fake_1.png",
			"res://assets/narrative/qte/qte_scanner_fake_2.png",
			"res://assets/narrative/qte/qte_scanner_fake_3.png",
		])
	elif argument == "qte_surveillance":
		_launch_qte("qte_surveillance", "Stay hidden! Follow the trucks!", 5, 2.0, [
			"res://assets/narrative/qte/qte_surveillance_1.png",
			"res://assets/narrative/qte/qte_surveillance_2.png",
			"res://assets/narrative/qte/qte_surveillance_3.png",
		])
	elif argument == "qte_rescue":
		_launch_qte("qte_rescue", "Race to save Sasha!", 5, 1.8, [
			"res://assets/narrative/qte/qte_rescue_1.png",
			"res://assets/narrative/qte/qte_rescue_2.png",
			"res://assets/narrative/qte/qte_rescue_3.png",
		])
	elif argument == "qte_suppression":
		_launch_qte("qte_suppression", "Suppress the attack!", 4, 2.5, [
			"res://assets/narrative/qte/qte_suppression_1.png",
			"res://assets/narrative/qte/qte_suppression_2.png",
			"res://assets/narrative/qte/qte_suppression_3.png",
		])

	# Evidence destruction minigame for Shift 9
	# Replaces standard gameplay - player must clear desk before security inspection
	elif argument == "evidence_destruction":
		_launch_evidence_destruction()

	# Route to loyalist ending signal
	if argument == "route_to_loyalist_ending":
		# This would need to be handled by scene management
		pass
	elif argument == "credits_ready_loyalist":
		get_tree().change_scene_to_file("res://scenes/end_credits/end_credits.tscn")

	# Skip Steam achievements in DEV_MODE
	# REFACTORED: Use GameStateManager
	if GameStateManager and GameStateManager.is_dev_mode():
		return

	# REFACTORED: Emit achievement unlocked events
	# Resistance Path Endings
	if argument == "born_diplomat":
		_unlock_achievement(ACHIEVEMENTS.BORN_DIPLOMAT)
	if argument == "tater_of_justice":
		_unlock_achievement(ACHIEVEMENTS.TATER_OF_JUSTICE)
	if argument == "best_served_hot":
		_unlock_achievement(ACHIEVEMENTS.BEST_SERVED_HOT)
	if argument == "down_with_the_tatriarchy":
		_unlock_achievement(ACHIEVEMENTS.DOWN_WITH_THE_TATRIARCHY)

	# Loyalist Path Endings
	if argument == "achievement_complicit":
		_unlock_achievement(ACHIEVEMENTS.HEART_OF_STONE)
	if argument == "survivor":
		_unlock_achievement(ACHIEVEMENTS.SURVIVOR)
	if argument == "achievement_late_bloomer":
		_unlock_achievement(ACHIEVEMENTS.LATE_BLOOMER)

	# Special Ending - Savior of Spud (romantic ending)
	if argument == "savior_of_spud":
		_unlock_achievement(ACHIEVEMENTS.SAVIOR_OF_SPUD)

	# Discovery Achievements
	if argument == "chaos_architect":
		_unlock_achievement(ACHIEVEMENTS.CHAOS_ARCHITECT)
	if argument == "root_of_evil":
		_unlock_achievement(ACHIEVEMENTS.ROOT_OF_EVIL)

	# Character Arc Achievements - checked at specific story moments
	if argument == "tommys_legacy":
		_unlock_achievement(ACHIEVEMENTS.TOMMYS_LEGACY)
	if argument == "elenas_memory":
		_unlock_achievement(ACHIEVEMENTS.ELENAS_MEMORY)
	if argument == "the_note":
		_unlock_achievement(ACHIEVEMENTS.THE_NOTE)


func _unlock_achievement(achievement_id: String) -> void:
	"""Helper to unlock a Steam achievement and emit the event."""
	if Steam and Steam.isSteamRunning():
		Steam.setAchievement(achievement_id)
	if EventBus:
		EventBus.achievement_unlocked.emit(achievement_id)


func _launch_qte(qte_name: String, context: String, prompt_count: int, time_per_prompt: float, image_paths: Variant = null) -> void:
	"""Launch a QTE minigame during narrative sequences.

	Args:
		qte_name: Internal identifier for this QTE (e.g., "qte_rescue")
		context: The narrative prompt text shown during the QTE
		prompt_count: Number of key prompts to show
		time_per_prompt: Seconds allowed per prompt
		image_paths: Optional - either a single image path (String) or array of image paths (Array[String])
			for progressive image display. Up to 3 images are shown, advancing on each successful key press.
	"""
	# Track which QTE is active for result handling
	_active_narrative_qte = qte_name

	if EventBus:
		var config: Dictionary = {
			"narrative_context": context,
			"prompt_count": prompt_count,
			"time_per_prompt": time_per_prompt,
			"force_launch": true  # Allow QTE even if not normally unlocked
		}
		# Handle image paths - support both single string and array formats
		if image_paths != null:
			if image_paths is Array:
				config["image_paths"] = image_paths
			elif image_paths is String and image_paths != "":
				config["image_path"] = image_paths
		EventBus.minigame_launch_requested.emit("quick_time_event", config)


func _launch_evidence_destruction() -> void:
	"""Launch the evidence destruction minigame for Shift 9.

	This minigame replaces standard customs processing in Shift 9. The player must
	examine items on their desk and decide whether to shred (destroy evidence) or
	stash (keep safe items) before a security inspection.

	The minigame sets Dialogic variables for narrative branching:
	- inspection_result: "clean", "suspicious", or "compromised"
	- evidence_found: true/false
	- evidence_found_type: ID of first evidence found (if any)
	"""
	# Initialize variables with defaults BEFORE launching minigame
	# This prevents "Invalid named index" errors if the timeline continues
	# before the minigame completes or if the minigame is skipped
	if Dialogic and Dialogic.VAR:
		Dialogic.VAR.set("inspection_result", "clean")
		Dialogic.VAR.set("evidence_found", false)
		Dialogic.VAR.set("under_suspicion", "no")
		print("[NarrativeManager] Initialized evidence destruction variables with defaults")

	if EventBus:
		var config: Dictionary = {
			"force_launch": true,  # Always launch regardless of shift unlock
			"time_limit": 180.0,   # 3 minutes to clear desk
			"items_to_show": 12,   # Number of items on desk
		}
		EventBus.minigame_launch_requested.emit("evidence_destruction", config)
		print("[NarrativeManager] Launched evidence destruction minigame")


func _on_minigame_completed(result: Dictionary) -> void:
	"""Handle minigame completion and set Dialogic variables for narrative branching.

	When a narrative minigame completes, we set the corresponding Dialogic variables
	based on the result. This enables the timeline to branch based on performance.
	"""
	var minigame_type: String = result.get("minigame_type", "")

	# Handle evidence destruction minigame (Shift 9)
	# Note: The minigame itself sets Dialogic variables, but we log and can emit events here
	if minigame_type == "evidence_destruction":
		var inspection_result: String = result.get("inspection_result", "suspicious")
		var evidence_found: Array = result.get("evidence_found", [])
		print("[NarrativeManager] Evidence destruction completed: %s (evidence found: %d)" % [
			inspection_result, evidence_found.size()
		])
		# Emit event for analytics or other systems
		if EventBus:
			EventBus.track_event("evidence_destruction_completed", {
				"result": inspection_result,
				"evidence_count": evidence_found.size(),
				"suspicion": result.get("suspicion_level", 0),
				"timed_out": result.get("timed_out", false)
			})
		return

	# QTE handling below - only process if we have an active narrative QTE
	if _active_narrative_qte.is_empty():
		return

	# Only process quick_time_event results for QTE tracking
	if minigame_type != "quick_time_event":
		return

	# Check if this QTE has a result variable mapping
	if not QTE_RESULT_VARIABLES.has(_active_narrative_qte):
		_active_narrative_qte = ""
		return

	# Determine pass/fail based on success rate (50% threshold)
	var success_rate: float = result.get("success_rate", 0.0)
	var qte_result: String = "pass" if success_rate >= 0.5 else "fail"

	# Set the Dialogic variable for narrative branching
	var var_name: String = QTE_RESULT_VARIABLES[_active_narrative_qte]
	if Dialogic and Dialogic.VAR:
		Dialogic.VAR.set(var_name, qte_result)
		print("NarrativeManager: Set %s = %s (success_rate: %.1f%%)" % [var_name, qte_result, success_rate * 100])

	# Clear the active QTE tracker
	_active_narrative_qte = ""


func start_final_confrontation():
	if dialogue_active:
		return

	dialogue_active = true
	create_cutscene_post_processing()
	# Note: Dialogic.start() returns the layout node and automatically adds it to the
	# scene tree via call_deferred. Do NOT call add_child on the returned node as this
	# creates a race condition where the node ends up with two parents.
	Dialogic.start("final_confrontation")
	# Connect signals safely - check if already connected to avoid duplicate connections
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)
	if not Dialogic.timeline_ended.is_connected(_on_final_dialogue_finished):
		Dialogic.timeline_ended.connect(_on_final_dialogue_finished)


func _on_intro_dialogue_finished():
	dialogue_active = false

	# Disconnect signals to prevent duplicate connections on next dialogue
	_disconnect_dialogic_signals()

	# Request to unlock next level via EventBus
	if EventBus and GameStateManager:
		EventBus.level_unlock_requested.emit(GameStateManager.get_shift() + 1)
		EventBus.story_state_changed.emit(GameStateManager.get_story_state())
		EventBus.dialogue_ended.emit("intro_dialogue")

	cleanup_skip_buttons()
	cleanup_cutscene_post_processing()
	emit_signal("intro_dialogue_finished")


func _on_shift_dialogue_finished():
	print("Shift dialogue finished, calling cleanup")

	dialogue_active = false
	current_shift += 1

	# Disconnect signals to prevent duplicate connections on next dialogue
	_disconnect_dialogic_signals()

	# Request to unlock next level via EventBus
	if EventBus and GameStateManager:
		EventBus.level_unlock_requested.emit(GameStateManager.get_shift() + 1)
		EventBus.story_state_changed.emit(GameStateManager.get_story_state())
		EventBus.dialogue_ended.emit("shift_dialogue")

	cleanup_skip_buttons()
	cleanup_cutscene_post_processing()
	emit_signal("dialogue_finished")


func _on_final_dialogue_finished():
	dialogue_active = false

	# Disconnect signals to prevent duplicate connections on next dialogue
	_disconnect_dialogic_signals()

	# Request to unlock next level via EventBus
	if EventBus and GameStateManager:
		EventBus.level_unlock_requested.emit(GameStateManager.get_shift() + 1)
		EventBus.story_state_changed.emit(GameStateManager.get_story_state())
		EventBus.dialogue_ended.emit("final_dialogue")

	cleanup_skip_buttons()
	cleanup_cutscene_post_processing()
	emit_signal("dialogue_finished")


func is_dialogue_active() -> bool:
	return dialogue_active


# New method to show day transition with shift number fade effect
# Old shift number fades down and out, new shift number fades down from top and in
func show_day_transition(current_day: int, next_day: int):
	dialogue_active = true

	# Get viewport size
	var screen_size: Vector2 = DisplayServer.window_get_size()
	var center_y: float = screen_size.y / 2.0
	var above_center_y: float = screen_size.y * 0.25  # Start position for new day (above center)
	var below_center_y: float = screen_size.y * 0.75  # End position for old day (below center)

	# Create a transition screen
	var transition_layer: CanvasLayer = CanvasLayer.new()
	transition_layer.layer = 100
	add_child(transition_layer)

	var background: ColorRect = ColorRect.new()
	background.color = Color(0, 0, 0, 0)
	background.size = screen_size
	transition_layer.add_child(background)

	# Load font for large day numbers
	var font: Font = preload("res://assets/fonts/windows_command_prompt.ttf")
	var font_size: int = 96

	# Create old day label (starts centered)
	var old_day_label: Label = Label.new()
	old_day_label.text = "Day %d" % current_day
	old_day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	old_day_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	old_day_label.add_theme_font_override("font", font)
	old_day_label.add_theme_font_size_override("font_size", font_size)
	old_day_label.size = Vector2(screen_size.x, 150)
	old_day_label.position = Vector2(0, center_y - 75)  # Centered vertically
	old_day_label.modulate = Color(1, 1, 1, 0)
	transition_layer.add_child(old_day_label)

	# Create new day label (starts above center, invisible)
	var new_day_label: Label = Label.new()
	new_day_label.text = "Day %d" % next_day
	new_day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new_day_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	new_day_label.add_theme_font_override("font", font)
	new_day_label.add_theme_font_size_override("font_size", font_size)
	new_day_label.size = Vector2(screen_size.x, 150)
	new_day_label.position = Vector2(0, above_center_y - 75)  # Above center
	new_day_label.modulate = Color(1, 1, 1, 0)
	transition_layer.add_child(new_day_label)

	# Animation sequence
	var tween: Tween = create_tween()

	# Phase 1: Fade to black and show old day number (0.6s)
	tween.tween_property(background, "color", Color(0, 0, 0, 0.95), 0.6)
	tween.parallel().tween_property(old_day_label, "modulate", Color(1, 1, 1, 1), 0.6)

	# Phase 2: Hold old day briefly (0.5s)
	tween.tween_interval(0.5)

	# Phase 3: Old day fades down and out (0.7s)
	tween.tween_property(old_day_label, "position:y", below_center_y - 75, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(old_day_label, "modulate", Color(1, 1, 1, 0), 0.7)

	# Phase 4: Small pause between transitions (0.2s)
	tween.tween_interval(0.2)

	# Phase 5: New day fades down from top and in (0.7s)
	tween.tween_property(new_day_label, "position:y", center_y - 75, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(new_day_label, "modulate", Color(1, 1, 1, 1), 0.7)

	# Phase 6: Hold new day (1.0s)
	tween.tween_interval(1.0)

	# Phase 7: Fade out everything (0.6s)
	tween.tween_property(new_day_label, "modulate", Color(1, 1, 1, 0), 0.6)
	tween.parallel().tween_property(background, "color", Color(0, 0, 0, 0), 0.6)

	# Cleanup and emit signal when done
	tween.tween_callback(
		func():
			transition_layer.queue_free()
			dialogue_active = false
			emit_signal("dialogue_finished")
	)


func fade_transition(fade_in: bool, callback: Callable):
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1.0 if fade_in else 0.0)
	fade_rect.size = get_viewport().get_visible_rect().size
	fade_rect.z_index = 100  # Above everything

	var fade_layer = CanvasLayer.new()
	fade_layer.layer = 100
	fade_layer.add_child(fade_rect)
	add_child(fade_layer)

	var tween = create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0 if fade_in else 1.0, 0.5)
	tween.tween_callback(
		func():
			callback.call()
			# If fading in, we keep the fade layer for the callback to handle
			if not fade_in:
				fade_layer.queue_free()
	)


## Initialize shift-specific variables with safe defaults before timeline starts
## This prevents "Invalid named index" errors when timelines check variables
## that might not have been set yet (e.g., minigame results, conditional branches)
func _initialize_shift_variables(level_id: int) -> void:
	if not Dialogic or not Dialogic.VAR:
		return

	match level_id:
		9:  # Shift 9 - Evidence Destruction & Attack
			# These variables are used in shift9_intro and shift9_end
			# Initialize with "clean/no" defaults - minigame will override if played
			if not Dialogic.VAR.has("inspection_result"):
				Dialogic.VAR.set("inspection_result", "clean")
			if not Dialogic.VAR.has("evidence_found"):
				Dialogic.VAR.set("evidence_found", false)
			if not Dialogic.VAR.has("under_suspicion"):
				Dialogic.VAR.set("under_suspicion", "no")
			print("[NarrativeManager] Initialized Shift 9 variables with defaults")


# Save all Dialogic variables (narrative choices)
func save_narrative_choices() -> Dictionary:
	var choices = {}

	# List of all narrative choice variables used in the game
	# This list matches all variables used across all timeline files
	# Updated to include all new variables from enhanced narrative
	var choice_variables = [
		# Shift 1 - Introduction
		"initial_response",          # eager, questioning
		"note_reaction",             # investigate, destroy, report
		"kept_note",                 # yes, no
		"reported_note",             # yes

		# Shift 2 - Meeting Sasha & Murphy
		"murphy_trust",              # open, guarded
		"eat_reserve",               # ate, refused

		# Shift 3 - Missing Wife
		"scanner_response",          # loyal, questioning
		"family_response",           # refuse, help
		"has_wife_photo",            # yes, no
		"wife_name",                 # "Maris Piper"
		"reveal_reaction",           # shocked, cautious

		# Shift 4 - Root Reserve Trucks
		"cafeteria_response",        # serious, avoid
		"murphy_alliance",           # ally, cautious, skeptical
		"sasha_trust_level",         # committed, cautious

		# Shift 5 - Loyalty Screening & Heist
		"sasha_investigation",       # committed, hesitant
		"loyalty_response",          # patriotic, idealistic
		"hide_choice",               # desk, window
		"evidence_choice",           # hand_over, keep, lie, chaos
		"viktor_wife_discovery",     # yes (discovered Viktor's wife on manifest)

		# Shift 6 - RealityScan
		"fellow_officer_response",   # cautious, sympathetic, loyal
		"interrogation_response",    # lie, legal
		"viktor_conversation",       # tell_truth, lie_protect
		"scanner_choice",            # help, scan
		"helped_operative",          # yes, no
		"viktor_allied",             # yes
		"betrayed_resistance",       # yes
		"sasha_plan_response",       # committed, nervous
		"malfunction_excuse",        # technical, innocent

		# Shift 7 - Resistance Meeting
		"resistance_mission",        # committed, hesitant, cautious
		"final_decision",            # help, passive, undecided
		"yellow_badge_response",     # help, betray
		"follow_trucks",             # volunteer, hesitant
		"found_facility",            # yes (found Root Reserve location)

		# Shift 8 - Sasha's Capture
		"sasha_response",            # cautious, concerned
		"interrogation_choice",      # deny, betray
		"sasha_arrest_reaction",     # intervene, hide, promise
		"player_wanted",             # yes
		"player_captured",           # yes
		"has_keycard",               # yes
		"murphy_final_alliance",     # committed, hesitant

		# Shift 9 - The Attack
		"inspection_result",         # clean, suspicious, compromised (from evidence_destruction minigame)
		"evidence_found",            # true, false (from evidence_destruction minigame)
		"under_suspicion",           # yes, mild, no (set after inspection)
		"critical_choice",           # help, betray, chaos
		"stay_or_go",                # stay, go
		"sasha_rescue_reaction",     # angry, disgusted, relieved

		# Shift 10 & Endings
		"fellow_officer_response_2", # cautious, sympathetic
		"final_mission_response",    # determined, cautious
		"resistance_trust",          # diplomatic, committed
		"ending_choice",             # diplomatic, justice, vengeance, dismantle

		# Loyalist Ending
		"accept_medal",              # accept, reluctant
		"eat_final",                 # eat, refuse
		"final_loyalist_choice",     # report, ignore, hope

		# Path Tracking Variables
		"pro_sasha_choice",          # integer counter (0-10) for romantic ending
		"loyalist_path",             # yes/no
		"loyalist_points",           # integer counter
		"chaos_agent",               # yes/no (sabotage both sides)
		"chaos_points",              # integer counter (0-6)

		# QTE Result Variables (set by NarrativeManager on QTE completion)
		"qte_rescue_result",         # pass, fail
		"qte_confrontation_result",  # pass, fail
		"qte_escape_result",         # pass, fail
		"qte_infiltration_result",   # pass, fail
		"qte_scanner_result",        # pass, fail
		"qte_surveillance_result",   # pass, fail
		"qte_suppression_result",    # pass, fail

		# Additional variables from shift6_end fix
		"viktor_night_greeting",     # curious, direct (fixed: was overwriting viktor_conversation)
	]

	# Save each variable if it exists in Dialogic
	for var_name in choice_variables:
		if Dialogic.VAR.has(var_name):
			choices[var_name] = Dialogic.VAR.get(var_name)

	print("NarrativeManager saved ", choices.size(), " narrative choices: ", choices)
	return choices


# Load Dialogic variables (narrative choices)
func load_narrative_choices(choices: Dictionary) -> void:
	if choices.is_empty():
		return

	# Restore each saved variable to Dialogic
	for var_name in choices.keys():
		Dialogic.VAR.set(var_name, choices[var_name])

		# REFACTORED: Emit narrative choice made event for each restored choice
		if EventBus:
			EventBus.narrative_choice_made.emit(var_name, choices[var_name])

	print("Loaded ", choices.size(), " narrative choices")


## Clear Dialogic history - called on session restart to prevent buildup
func clear_dialogic_history() -> void:
	if not Dialogic:
		return

	# Clear simple history (used for display)
	if Dialogic.History:
		Dialogic.History.simple_history_content = []
		Dialogic.History.full_event_history_content = []
		print("NarrativeManager: Cleared Dialogic history")


## Called when history panel is opened - hide skip buttons to prevent issues
func _on_history_opened() -> void:
	history_panel_open = true
	var skip_buttons = get_tree().get_nodes_in_group("DialogueSkipButtons")
	for button_layer in skip_buttons:
		if is_instance_valid(button_layer):
			button_layer.visible = false


## Called when history panel is closed - show skip buttons again
func _on_history_closed() -> void:
	history_panel_open = false
	var skip_buttons = get_tree().get_nodes_in_group("DialogueSkipButtons")
	for button_layer in skip_buttons:
		if is_instance_valid(button_layer):
			button_layer.visible = true
