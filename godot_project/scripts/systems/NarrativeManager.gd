extends Node

signal dialogue_finished

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
	# Initialize dialogic timeline
	start_level_dialogue(Global.shift)
	#if Global.get_story_state() == Global.StoryState.NOT_STARTED:
		#start_intro_sequence()

# Function to start dialogue for a specific level
func start_level_dialogue(level_id: int):
	if dialogue_active:
		return
		
	dialogue_active = true
	var timeline_name = LEVEL_DIALOGUES.get(level_id, "generic_shift_start")
	
	var timeline = Dialogic.start(timeline_name)
	add_child(timeline)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_shift_dialogue_finished)

	
# Function to start end dialogue for a level
func start_level_end_dialogue(level_id: int):
	if dialogue_active:
		return
		
	dialogue_active = true
	var timeline_name = LEVEL_END_DIALOGUES.get(level_id, "generic_shift_start")
	
	var timeline = Dialogic.start(timeline_name)
	add_child(timeline)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_shift_dialogue_finished)

#func start_intro_sequence():
	#if dialogue_active:
		#return
		#
	#dialogue_active = true
	#var timeline = Dialogic.start("res://assets/narrative/generic_shift_start.dtl")
	#add_child(timeline)
	#Dialogic.timeline_ended.connect(_on_intro_dialogue_finished)
	
#func start_shift_dialogue():
	#if dialogue_active:
		#return
		#
	#dialogue_active = true
	#var timeline
	#
	#match current_shift:
		#1:
			## Debugging Purposes
			##timeline = Dialogic.start("final_confrontation")
			#timeline = Dialogic.start("shift1_intro") 
		#2: 
			#timeline = Dialogic.start("shift2_intro")
		#3:
			#timeline = Dialogic.start("shift3_intro")
		#_:
			#timeline = Dialogic.start("final_confrontation")
			#
	#add_child(timeline)
	#Dialogic.signal_event.connect(_on_dialogic_signal)
	#Dialogic.timeline_ended.connect(_on_shift_dialogue_finished)

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
	emit_signal("dialogue_finished")

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
