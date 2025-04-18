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
	1: "shift1_end", 3: "shift3_end", 5: "shift5_end", 7: "shift7_end", 9: "shift9_end", 10: "final_confrontation"
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

func _ready():
	# Skip initialization in score attack mode
	if Global.game_mode == "score_attack":
		return
	# Initialize dialogic and load dialogue for appropriate shift
	start_level_dialogue(Global.shift)
	# Make it impossible to pause the narrative manager
	process_mode = Node.PROCESS_MODE_ALWAYS


func start_level_dialogue(level_id: int):
	if Global.game_mode == "score_attack":
		return
	# Return if already in dialogue
	if dialogue_active:
		return
		
	# Skip in score attack mode
	print("Game mode is:", Global.game_mode)
	if Global.game_mode == "score_attack":
		print("score_attack detected")
		#_on_skip_button_pressed()
		pass

	dialogue_active = true
	var skip_button_layer = create_skip_button()

	var timeline_name = LEVEL_DIALOGUES.get(level_id, "generic_shift_start")

	var timeline = Dialogic.start(timeline_name)
	add_child(timeline)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_shift_dialogue_finished)
	
func start_level_end_dialogue(level_id: int):
	if Global.get("game_mode") == "score_attack":
		return
	
	print("Attempting to start dialogue: ", level_id, " -> ", LEVEL_END_DIALOGUES.get(level_id, "unknown"))
	if dialogue_active:
		return

	# Only proceed if the level has an end dialogue
	if not level_id in LEVEL_END_DIALOGUES:
		emit_signal("end_dialogue_finished")
		return

	dialogue_active = true
	var skip_button_layer = create_skip_button()
	var timeline_name = LEVEL_END_DIALOGUES.get(level_id, "generic_shift_start")

	var timeline = Dialogic.start(timeline_name)
	timeline.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(timeline)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_end_dialogue_finished)


func _on_end_dialogue_finished():
	print("End dialogue finished, calling cleanup")
	dialogue_active = false
	cleanup_skip_buttons()
	emit_signal("end_dialogue_finished")


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

	# Set the dialogue to not active - this is crucial
	dialogue_active = false
	emit_signal("dialogue_finished")


func _on_dialogic_signal(argument):
	if argument == "credits_ready":
		get_tree().change_scene_to_file("res://scenes/end_credits/end_credits.tscn")
	if argument == "born_diplomat":
		Steam.setAchievement(ACHIEVEMENTS.BORN_DIPLOMAT)
	if argument == "tater_of_justice":
		Steam.setAchievement(ACHIEVEMENTS.TATER_OF_JUSTICE)
	if argument == "best_served_hot":
		Steam.setAchievement(ACHIEVEMENTS.BEST_SERVED_HOT)
	if argument == "down_with_the_tatriarchy":
		Steam.setAchievement(ACHIEVEMENTS.DOWN_WITH_THE_TATRIARCHY)


func start_final_confrontation():
	if dialogue_active:
		return

	dialogue_active = true
	var timeline = Dialogic.start("final_confrontation")
	add_child(timeline)
	timeline.finished.connect(_on_final_dialogue_finished)


func _on_intro_dialogue_finished():
	dialogue_active = false
	Global.advance_story_state()  # Will set to INTRO_COMPLETE
	cleanup_skip_buttons()
	emit_signal("intro_dialogue_finished")


func _on_shift_dialogue_finished():
	print("Shift dialogue finished, calling cleanup")
	
	dialogue_active = false
	current_shift += 1
	Global.advance_story_state()
	cleanup_skip_buttons()
	emit_signal("dialogue_finished")


func _on_final_dialogue_finished():
	dialogue_active = false
	Global.advance_story_state()  # Will set to COMPLETED
	cleanup_skip_buttons()
	emit_signal("dialogue_finished")


func is_dialogue_active() -> bool:
	return dialogue_active


# New method to show day transition
func show_day_transition(current_day: int, next_day: int):
	dialogue_active = true

	# Get viewport size
	var screen_size = get_viewport().get_visible_rect().size

	# Create a transition screen
	var transition_layer = CanvasLayer.new()
	transition_layer.layer = 100
	add_child(transition_layer)

	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0)
	background.size = screen_size
	transition_layer.add_child(background)

	var label = Label.new()
	label.text = "Day %d Complete\nStarting Day %d" % [current_day, next_day]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = screen_size
	label.modulate = Color(1, 1, 1, 0)
	transition_layer.add_child(label)

	# Animate
	var tween = create_tween()
	tween.tween_property(background, "color", Color(0, 0, 0, 0.9), 1.0)
	tween.parallel().tween_property(label, "modulate", Color(1, 1, 1, 1), 1.0)
	tween.tween_interval(2.0)
	tween.tween_property(label, "modulate", Color(1, 1, 1, 0), 1.0)
	tween.parallel().tween_property(background, "color", Color(0, 0, 0, 0), 1.0)

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
	tween.tween_callback(func():
		callback.call()
		# If fading in, we keep the fade layer for the callback to handle
		if not fade_in:
			fade_layer.queue_free()
	)
