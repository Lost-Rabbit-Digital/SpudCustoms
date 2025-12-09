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

# Achievement IDs
const ACHIEVEMENTS: Dictionary[String, String] = {
	"BORN_DIPLOMAT": "born_diplomat",
	"TATER_OF_JUSTICE": "tater_of_justice",
	"BEST_SERVED_HOT": "best_served_hot",
	"DOWN_WITH_THE_TATRIARCHY": "down_with_the_tatriarchy"
}

var current_shift: int = 1
var dialogic_timeline: Node
var dialogue_active: bool = false
var current_skip_button_layer: CanvasLayer = null
var cutscene_post_processing: CanvasLayer = null
var history_panel_open: bool = false
var cutscene_bloom_pulse: CutsceneBloomPulse = null

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

	# REFACTORED: Emit dialogue started event
	if EventBus:
		EventBus.dialogue_started.emit(timeline_name)

	var timeline = Dialogic.start(timeline_name)
	# Only add as child if it doesn't already have a parent
	if timeline and not timeline.get_parent():
		add_child(timeline)
	Dialogic.signal_event.connect(_on_dialogic_signal)
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

	# REFACTORED: Emit dialogue started event
	if EventBus:
		EventBus.dialogue_started.emit(timeline_name)

	var timeline = Dialogic.start(timeline_name)
	if timeline:
		timeline.process_mode = Node.PROCESS_MODE_ALWAYS
		# Only add as child if it doesn't already have a parent
		if not timeline.get_parent():
			add_child(timeline)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_end_dialogue_finished)


func _on_end_dialogue_finished():
	print("End dialogue finished, calling cleanup")
	dialogue_active = false

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
	if argument == "qte_infiltration":
		_launch_qte("Infiltrate the facility!", 5, 2.0)
	elif argument == "qte_escape":
		_launch_qte("Escape the guards!", 6, 1.8)
	elif argument == "qte_confrontation":
		_launch_qte("Stand your ground!", 4, 2.5)
	# New QTEs for enhanced narrative
	elif argument == "qte_scanner_fake":
		_launch_qte("Fake the malfunction!", 4, 2.2)
	elif argument == "qte_surveillance":
		_launch_qte("Stay hidden! Follow the trucks!", 5, 2.0)
	elif argument == "qte_rescue":
		_launch_qte("Race to save Sasha!", 5, 1.8)
	elif argument == "qte_suppression":
		_launch_qte("Suppress the attack!", 4, 2.5)

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
	if argument == "born_diplomat":
		Steam.setAchievement(ACHIEVEMENTS.BORN_DIPLOMAT)
		if EventBus:
			EventBus.achievement_unlocked.emit(ACHIEVEMENTS.BORN_DIPLOMAT)
	if argument == "tater_of_justice":
		Steam.setAchievement(ACHIEVEMENTS.TATER_OF_JUSTICE)
		if EventBus:
			EventBus.achievement_unlocked.emit(ACHIEVEMENTS.TATER_OF_JUSTICE)
	if argument == "best_served_hot":
		Steam.setAchievement(ACHIEVEMENTS.BEST_SERVED_HOT)
		if EventBus:
			EventBus.achievement_unlocked.emit(ACHIEVEMENTS.BEST_SERVED_HOT)
	if argument == "down_with_the_tatriarchy":
		Steam.setAchievement(ACHIEVEMENTS.DOWN_WITH_THE_TATRIARCHY)
		if EventBus:
			EventBus.achievement_unlocked.emit(ACHIEVEMENTS.DOWN_WITH_THE_TATRIARCHY)


func _launch_qte(context: String, prompt_count: int, time_per_prompt: float) -> void:
	"""Launch a QTE minigame during narrative sequences."""
	if EventBus:
		EventBus.minigame_launch_requested.emit("quick_time_event", {
			"narrative_context": context,
			"prompt_count": prompt_count,
			"time_per_prompt": time_per_prompt,
			"force_launch": true  # Allow QTE even if not normally unlocked
		})


func start_final_confrontation():
	if dialogue_active:
		return

	dialogue_active = true
	create_cutscene_post_processing()
	var timeline = Dialogic.start("final_confrontation")
	add_child(timeline)
	timeline.finished.connect(_on_final_dialogue_finished)


func _on_intro_dialogue_finished():
	dialogue_active = false

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
		"critical_choice",           # help, betray
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
