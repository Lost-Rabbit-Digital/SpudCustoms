extends Node

signal dialogue_finished
signal intro_dialogue_finished
signal end_dialogue_finished

var current_shift: int = 1
var dialogic_timeline: Node
var dialogue_active: bool = false

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
	3: "shift3_end",
	5: "shift5_end",
	7: "shift7_end",
	9: "shift9_end"
}

# Achievement IDs
const ACHIEVEMENTS: Dictionary[String, String] = {
	"BORN_DIPLOMAT": "born_diplomat",
	"TATER_OF_JUSTICE": "tater_of_justice",
	"BEST_SERVED_HOT": "best_served_hot",
	"DOWN_WITH_THE_TATRIARCHY": "down_with_the_tatriarchy"
}

func _ready():
	# Initialize dialogic and load dialogue for appropriate shift
	start_level_dialogue(Global.shift)

func start_level_dialogue(level_id: int):
	if dialogue_active:
		return
		
	dialogue_active = true
	var skip_button_layer = create_skip_button()
	
	var timeline_name = LEVEL_DIALOGUES.get(level_id, "generic_shift_start")
	
	var timeline = Dialogic.start(timeline_name)
	add_child(timeline)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_shift_dialogue_finished)

func start_level_end_dialogue(level_id: int):
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
	add_child(timeline)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_end_dialogue_finished)

func _on_end_dialogue_finished():
	dialogue_active = false
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
	
	return canvas

func _on_skip_button_pressed():
	# End the current timeline
	Dialogic.end_timeline()
	
	# Find and remove the SkipButtonLayer
	var skip_button_layer = get_node_or_null("SkipButtonLayer")
	if skip_button_layer:
		skip_button_layer.queue_free()
	
	# Set the dialogue to not active - this is crucial
	dialogue_active = false
	emit_signal("dialogue_finished")
		
func _on_dialogic_signal(argument):
	if argument == "credits_ready":
		get_tree().change_scene_to_file("res://main_scenes/scenes/end_credits/end_credits.tscn")
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
	Global.advance_story_state() # Will set to INTRO_COMPLETE
	emit_signal("intro_dialogue_finished")

func _on_shift_dialogue_finished():
	dialogue_active = false
	current_shift += 1
	Global.advance_story_state()
	emit_signal("dialogue_finished") 

func _on_final_dialogue_finished():
	dialogue_active = false
	Global.advance_story_state() # Will set to COMPLETED
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
	tween.tween_callback(func():
		transition_layer.queue_free()
		dialogue_active = false
		emit_signal("dialogue_finished")
	)
