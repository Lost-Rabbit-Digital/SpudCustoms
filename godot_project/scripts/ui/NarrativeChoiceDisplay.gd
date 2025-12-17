## Displays narrative choices in a collapsible, color-coded format.
##
## Shows path indicators at the top and organizes choices by shift
## with human-readable descriptions. Used in Continue dialog and Level Select.
class_name NarrativeChoiceDisplay
extends Control

## Colors for different choice alignments
const COLOR_RESISTANCE: Color = Color(0.4, 0.7, 1.0)  # Blue - pro-resistance/Sasha
const COLOR_LOYALIST: Color = Color(1.0, 0.85, 0.4)   # Gold - loyalist/system
const COLOR_CHAOS: Color = Color(1.0, 0.4, 0.4)       # Red - chaos agent
const COLOR_NEUTRAL: Color = Color(0.9, 0.9, 0.9)     # White - neutral choices
const COLOR_QTE_PASS: Color = Color(0.4, 1.0, 0.5)    # Green - QTE passed
const COLOR_QTE_FAIL: Color = Color(1.0, 0.5, 0.4)    # Red - QTE failed

## Shift names for headers
const SHIFT_NAMES: Dictionary = {
	1: "First Day on the Job",
	2: "Meeting Sasha & Murphy",
	3: "The Missing Wife",
	4: "Root Reserve Trucks",
	5: "Loyalty Screening",
	6: "RealityScan",
	7: "Resistance Meeting",
	8: "Sasha's Capture",
	9: "The Attack",
	10: "The Final Countdown"
}

## Choice descriptions organized by shift
## Format: {variable_name: {value: {text: "description", alignment: "resistance/loyalist/chaos/neutral"}}}
const CHOICE_DESCRIPTIONS: Dictionary = {
	# Shift 1 - Introduction
	"initial_response": {
		"eager": {"text": "Showed enthusiasm for Spud", "alignment": "loyalist"},
		"questioning": {"text": "Questioned the system", "alignment": "resistance"}
	},
	"note_reaction": {
		"investigate": {"text": "Chose to investigate the note", "alignment": "resistance"},
		"destroy": {"text": "Destroyed the mysterious note", "alignment": "loyalist"},
		"report": {"text": "Reported the note to authorities", "alignment": "loyalist"}
	},
	"kept_note": {
		"yes": {"text": "Kept the mysterious note", "alignment": "resistance"},
		"no": {"text": "Discarded the note", "alignment": "neutral"}
	},
	"reported_note": {
		"yes": {"text": "Reported the note", "alignment": "loyalist"}
	},

	# Shift 2 - Meeting Sasha & Murphy
	"murphy_trust": {
		"open": {"text": "Opened up to Murphy", "alignment": "resistance"},
		"guarded": {"text": "Stayed guarded with Murphy", "alignment": "neutral"}
	},
	"eat_reserve": {
		"ate": {"text": "Ate the reserve rations", "alignment": "neutral"},
		"refused": {"text": "Refused the reserve rations", "alignment": "resistance"}
	},

	# Shift 3 - Missing Wife
	"scanner_response": {
		"loyal": {"text": "Showed loyalty during scanner test", "alignment": "loyalist"},
		"questioning": {"text": "Questioned the scanner's purpose", "alignment": "resistance"}
	},
	"family_response": {
		"refuse": {"text": "Refused to help find the wife", "alignment": "loyalist"},
		"help": {"text": "Agreed to help find the missing wife", "alignment": "resistance"}
	},
	"has_wife_photo": {
		"yes": {"text": "Obtained photo of the missing wife", "alignment": "resistance"}
	},
	"reveal_reaction": {
		"shocked": {"text": "Was shocked by the revelation", "alignment": "neutral"},
		"cautious": {"text": "Reacted cautiously to the revelation", "alignment": "neutral"}
	},

	# Shift 4 - Root Reserve Trucks
	"cafeteria_response": {
		"serious": {"text": "Took cafeteria rumors seriously", "alignment": "resistance"},
		"avoid": {"text": "Avoided cafeteria discussions", "alignment": "loyalist"}
	},
	"murphy_alliance": {
		"ally": {"text": "Allied with Murphy", "alignment": "resistance"},
		"cautious": {"text": "Stayed cautious with Murphy", "alignment": "neutral"},
		"skeptical": {"text": "Remained skeptical of Murphy", "alignment": "loyalist"}
	},
	"sasha_trust_level": {
		"committed": {"text": "Fully committed to trusting Sasha", "alignment": "resistance"},
		"cautious": {"text": "Remained cautious about Sasha", "alignment": "neutral"}
	},

	# Shift 5 - Loyalty Screening & Heist
	"sasha_investigation": {
		"committed": {"text": "Committed to Sasha's investigation", "alignment": "resistance"},
		"hesitant": {"text": "Hesitant about the investigation", "alignment": "neutral"}
	},
	"loyalty_response": {
		"patriotic": {"text": "Gave patriotic responses", "alignment": "loyalist"},
		"idealistic": {"text": "Expressed idealistic views", "alignment": "resistance"}
	},
	"hide_choice": {
		"desk": {"text": "Hid behind the desk", "alignment": "neutral"},
		"window": {"text": "Hid by the window", "alignment": "neutral"}
	},
	"evidence_choice": {
		"hand_over": {"text": "Handed over the evidence", "alignment": "loyalist"},
		"keep": {"text": "Kept the evidence hidden", "alignment": "resistance"},
		"lie": {"text": "Lied about the evidence", "alignment": "resistance"},
		"chaos": {"text": "Used evidence to cause chaos", "alignment": "chaos"}
	},
	"viktor_wife_discovery": {
		"yes": {"text": "Discovered Viktor's wife on manifest", "alignment": "resistance"}
	},

	# Shift 6 - RealityScan
	"fellow_officer_response": {
		"cautious": {"text": "Was cautious with fellow officer", "alignment": "neutral"},
		"sympathetic": {"text": "Showed sympathy to fellow officer", "alignment": "resistance"},
		"loyal": {"text": "Remained loyal around fellow officer", "alignment": "loyalist"}
	},
	"interrogation_response": {
		"lie": {"text": "Lied during interrogation", "alignment": "resistance"},
		"legal": {"text": "Gave legal responses", "alignment": "loyalist"}
	},
	"viktor_conversation": {
		"tell_truth": {"text": "Told Viktor the truth", "alignment": "resistance"},
		"lie_protect": {"text": "Lied to protect Viktor", "alignment": "resistance"}
	},
	"scanner_choice": {
		"help": {"text": "Helped sabotage the scanner", "alignment": "resistance"},
		"scan": {"text": "Operated scanner normally", "alignment": "loyalist"}
	},
	"helped_operative": {
		"yes": {"text": "Helped the resistance operative", "alignment": "resistance"},
		"no": {"text": "Refused to help the operative", "alignment": "loyalist"}
	},
	"viktor_allied": {
		"yes": {"text": "Formed alliance with Viktor", "alignment": "resistance"}
	},
	"betrayed_resistance": {
		"yes": {"text": "Betrayed the resistance", "alignment": "loyalist"}
	},
	"sasha_plan_response": {
		"committed": {"text": "Committed to Sasha's plan", "alignment": "resistance"},
		"nervous": {"text": "Was nervous about the plan", "alignment": "neutral"}
	},
	"malfunction_excuse": {
		"technical": {"text": "Blamed technical malfunction", "alignment": "neutral"},
		"innocent": {"text": "Played innocent", "alignment": "neutral"}
	},

	# Shift 7 - Resistance Meeting
	"resistance_mission": {
		"committed": {"text": "Committed to resistance mission", "alignment": "resistance"},
		"hesitant": {"text": "Hesitant about the mission", "alignment": "neutral"},
		"cautious": {"text": "Approached mission cautiously", "alignment": "neutral"}
	},
	"final_decision": {
		"help": {"text": "Decided to help the resistance", "alignment": "resistance"},
		"passive": {"text": "Remained passive", "alignment": "neutral"},
		"undecided": {"text": "Stayed undecided", "alignment": "neutral"}
	},
	"yellow_badge_response": {
		"help": {"text": "Helped yellow badge holders", "alignment": "resistance"},
		"betray": {"text": "Betrayed yellow badge holders", "alignment": "loyalist"}
	},
	"follow_trucks": {
		"volunteer": {"text": "Volunteered to follow trucks", "alignment": "resistance"},
		"hesitant": {"text": "Hesitant to follow trucks", "alignment": "neutral"}
	},
	"found_facility": {
		"yes": {"text": "Found the Root Reserve facility", "alignment": "resistance"}
	},

	# Shift 8 - Sasha's Capture
	"sasha_response": {
		"cautious": {"text": "Was cautious about Sasha's situation", "alignment": "neutral"},
		"concerned": {"text": "Showed concern for Sasha", "alignment": "resistance"}
	},
	"interrogation_choice": {
		"deny": {"text": "Denied knowledge under interrogation", "alignment": "resistance"},
		"betray": {"text": "Betrayed others under interrogation", "alignment": "loyalist"}
	},
	"sasha_arrest_reaction": {
		"intervene": {"text": "Intervened in Sasha's arrest", "alignment": "resistance"},
		"hide": {"text": "Hid during Sasha's arrest", "alignment": "neutral"},
		"promise": {"text": "Made a promise to Sasha", "alignment": "resistance"}
	},
	"player_wanted": {
		"yes": {"text": "Became wanted by authorities", "alignment": "resistance"}
	},
	"player_captured": {
		"yes": {"text": "Was captured by authorities", "alignment": "neutral"}
	},
	"has_keycard": {
		"yes": {"text": "Obtained security keycard", "alignment": "resistance"}
	},
	"murphy_final_alliance": {
		"committed": {"text": "Fully committed to Murphy's alliance", "alignment": "resistance"},
		"hesitant": {"text": "Hesitant about final alliance", "alignment": "neutral"}
	},

	# Shift 9 - The Attack
	"critical_choice": {
		"help": {"text": "Helped during the critical moment", "alignment": "resistance"},
		"betray": {"text": "Betrayed at the critical moment", "alignment": "loyalist"}
	},
	"stay_or_go": {
		"stay": {"text": "Stayed to fight", "alignment": "resistance"},
		"go": {"text": "Chose to escape", "alignment": "neutral"}
	},
	"sasha_rescue_reaction": {
		"angry": {"text": "Reacted with anger to rescue", "alignment": "neutral"},
		"disgusted": {"text": "Was disgusted by events", "alignment": "neutral"},
		"relieved": {"text": "Felt relieved after rescue", "alignment": "resistance"}
	},

	# Shift 10 & Endings
	"fellow_officer_response_2": {
		"cautious": {"text": "Remained cautious with colleagues", "alignment": "neutral"},
		"sympathetic": {"text": "Showed sympathy to colleagues", "alignment": "resistance"}
	},
	"final_mission_response": {
		"determined": {"text": "Determined to complete final mission", "alignment": "resistance"},
		"cautious": {"text": "Cautious about final mission", "alignment": "neutral"}
	},
	"resistance_trust": {
		"diplomatic": {"text": "Took diplomatic approach with resistance", "alignment": "neutral"},
		"committed": {"text": "Fully committed to the resistance", "alignment": "resistance"}
	},
	"ending_choice": {
		"diplomatic": {"text": "Chose diplomatic ending", "alignment": "neutral"},
		"justice": {"text": "Chose justice ending", "alignment": "resistance"},
		"vengeance": {"text": "Chose vengeance ending", "alignment": "chaos"},
		"dismantle": {"text": "Chose to dismantle the system", "alignment": "resistance"}
	},

	# Loyalist Ending
	"accept_medal": {
		"accept": {"text": "Accepted the medal with pride", "alignment": "loyalist"},
		"reluctant": {"text": "Reluctantly accepted the medal", "alignment": "neutral"}
	},
	"eat_final": {
		"eat": {"text": "Ate the final offering", "alignment": "loyalist"},
		"refuse": {"text": "Refused the final offering", "alignment": "resistance"}
	},
	"final_loyalist_choice": {
		"report": {"text": "Reported dissenters", "alignment": "loyalist"},
		"ignore": {"text": "Ignored the dissenters", "alignment": "neutral"},
		"hope": {"text": "Held onto hope for change", "alignment": "resistance"}
	},

	# QTE Results
	"qte_rescue_result": {
		"pass": {"text": "Succeeded in rescue attempt", "alignment": "qte_pass"},
		"fail": {"text": "Failed rescue attempt", "alignment": "qte_fail"}
	},
	"qte_confrontation_result": {
		"pass": {"text": "Won the confrontation", "alignment": "qte_pass"},
		"fail": {"text": "Lost the confrontation", "alignment": "qte_fail"}
	},
	"qte_escape_result": {
		"pass": {"text": "Escaped successfully", "alignment": "qte_pass"},
		"fail": {"text": "Failed to escape", "alignment": "qte_fail"}
	},
	"qte_infiltration_result": {
		"pass": {"text": "Infiltration successful", "alignment": "qte_pass"},
		"fail": {"text": "Infiltration failed", "alignment": "qte_fail"}
	},
	"qte_scanner_result": {
		"pass": {"text": "Scanner sabotage successful", "alignment": "qte_pass"},
		"fail": {"text": "Scanner sabotage failed", "alignment": "qte_fail"}
	},
	"qte_surveillance_result": {
		"pass": {"text": "Avoided surveillance", "alignment": "qte_pass"},
		"fail": {"text": "Caught by surveillance", "alignment": "qte_fail"}
	},
	"qte_suppression_result": {
		"pass": {"text": "Resisted suppression", "alignment": "qte_pass"},
		"fail": {"text": "Succumbed to suppression", "alignment": "qte_fail"}
	}
}

## Variables organized by the shift they first appear in
const VARIABLES_BY_SHIFT: Dictionary = {
	1: ["initial_response", "note_reaction", "kept_note", "reported_note"],
	2: ["murphy_trust", "eat_reserve"],
	3: ["scanner_response", "family_response", "has_wife_photo", "reveal_reaction"],
	4: ["cafeteria_response", "murphy_alliance", "sasha_trust_level"],
	5: ["sasha_investigation", "loyalty_response", "hide_choice", "evidence_choice", "viktor_wife_discovery"],
	6: ["fellow_officer_response", "interrogation_response", "viktor_conversation", "scanner_choice",
		"helped_operative", "viktor_allied", "betrayed_resistance", "sasha_plan_response", "malfunction_excuse"],
	7: ["resistance_mission", "final_decision", "yellow_badge_response", "follow_trucks", "found_facility"],
	8: ["sasha_response", "interrogation_choice", "sasha_arrest_reaction", "player_wanted",
		"player_captured", "has_keycard", "murphy_final_alliance"],
	9: ["critical_choice", "stay_or_go", "sasha_rescue_reaction", "qte_rescue_result",
		"qte_confrontation_result", "qte_escape_result"],
	10: ["fellow_officer_response_2", "final_mission_response", "resistance_trust", "ending_choice",
		 "accept_medal", "eat_final", "final_loyalist_choice", "qte_infiltration_result",
		 "qte_scanner_result", "qte_surveillance_result", "qte_suppression_result"]
}

## Node references
@onready var path_indicator_label: RichTextLabel = %PathIndicatorLabel
@onready var sasha_trust_bar: ProgressBar = %SashaTrustBar
@onready var sasha_trust_label: Label = %SashaTrustLabel
@onready var chaos_indicator: Label = %ChaosIndicator
@onready var shifts_container: VBoxContainer = %ShiftsContainer

## Currently expanded shift section
var expanded_shift: int = -1

## Stores section references for toggling
var shift_sections: Dictionary = {}


func _ready() -> void:
	# Initialize with empty state
	clear_display()


## Clears all displayed choices
func clear_display() -> void:
	if shifts_container:
		for child in shifts_container.get_children():
			child.queue_free()
	shift_sections.clear()
	expanded_shift = -1


## Updates the display with narrative choices up to a specific shift
## If max_shift is -1, shows all available choices
func display_choices(choices: Dictionary, max_shift: int = -1) -> void:
	clear_display()

	if choices.is_empty():
		_show_no_choices_message()
		return

	# Update path indicators
	_update_path_indicators(choices)

	# Create sections for each shift that has choices
	for shift in range(1, 11):
		if max_shift > 0 and shift > max_shift:
			break

		var shift_choices = _get_choices_for_shift(choices, shift)
		if not shift_choices.is_empty():
			_create_shift_section(shift, shift_choices)

	# Auto-expand the most recent shift with choices
	if not shift_sections.is_empty():
		var latest_shift = shift_sections.keys().max()
		_toggle_shift_section(latest_shift)


## Updates the path indicator header
func _update_path_indicators(choices: Dictionary) -> void:
	# Determine path alignment
	var loyalist_path = choices.get("loyalist_path", "")
	var chaos_agent = choices.get("chaos_agent", "")
	var pro_sasha = choices.get("pro_sasha_choice", 0)
	if pro_sasha is String:
		pro_sasha = int(pro_sasha) if pro_sasha.is_valid_int() else 0

	# Set path text with color
	var path_text = ""
	if chaos_agent == "yes":
		path_text = "[color=#ff6666]Chaos Agent[/color]"
	elif loyalist_path == "yes":
		path_text = "[color=#ffd966]Loyalist Path[/color]"
	elif pro_sasha >= 7:
		path_text = "[color=#66b3ff]Resistance Ally[/color]"
	elif pro_sasha >= 4:
		path_text = "[color=#e6e6e6]Questioning[/color]"
	else:
		path_text = "[color=#e6e6e6]Undetermined[/color]"

	if path_indicator_label:
		path_indicator_label.text = "[b]Path:[/b] " + path_text

	# Update Sasha trust bar
	if sasha_trust_bar:
		sasha_trust_bar.max_value = 10
		sasha_trust_bar.value = pro_sasha
		# Color the bar based on trust level
		var style = sasha_trust_bar.get_theme_stylebox("fill").duplicate()
		if style is StyleBoxFlat:
			if pro_sasha >= 7:
				style.bg_color = COLOR_RESISTANCE
			elif pro_sasha >= 4:
				style.bg_color = COLOR_NEUTRAL
			else:
				style.bg_color = Color(0.5, 0.5, 0.5)
			sasha_trust_bar.add_theme_stylebox_override("fill", style)

	if sasha_trust_label:
		sasha_trust_label.text = "Sasha Trust: %d/10" % pro_sasha

	# Update chaos indicator
	if chaos_indicator:
		var chaos_points = choices.get("chaos_points", 0)
		if chaos_points is String:
			chaos_points = int(chaos_points) if chaos_points.is_valid_int() else 0

		if chaos_agent == "yes" or chaos_points > 0:
			chaos_indicator.text = "Chaos: %d pts" % chaos_points
			chaos_indicator.add_theme_color_override("font_color", COLOR_CHAOS)
			chaos_indicator.show()
		else:
			chaos_indicator.hide()


## Gets choices relevant to a specific shift
func _get_choices_for_shift(choices: Dictionary, shift: int) -> Dictionary:
	var result: Dictionary = {}

	if not VARIABLES_BY_SHIFT.has(shift):
		return result

	for var_name in VARIABLES_BY_SHIFT[shift]:
		if choices.has(var_name) and choices[var_name] != null and choices[var_name] != "":
			result[var_name] = choices[var_name]

	return result


## Creates a collapsible section for a shift
func _create_shift_section(shift: int, choices: Dictionary) -> void:
	var section_container = VBoxContainer.new()
	section_container.name = "Shift%dSection" % shift

	# Create header button
	var header_button = Button.new()
	header_button.name = "Header"
	header_button.text = "> Day %d - %s" % [shift, SHIFT_NAMES.get(shift, "Unknown")]
	header_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header_button.flat = true
	header_button.pressed.connect(_on_shift_header_pressed.bind(shift))

	# Style the header
	header_button.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	header_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 0.8))
	header_button.add_theme_font_size_override("font_size", 16)

	section_container.add_child(header_button)

	# Create content container (initially hidden)
	var content_container = VBoxContainer.new()
	content_container.name = "Content"
	content_container.visible = false

	# Add margin for indentation
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)

	var choices_list = VBoxContainer.new()
	choices_list.name = "ChoicesList"

	# Add each choice
	for var_name in choices.keys():
		var value = choices[var_name]
		var choice_label = _create_choice_label(var_name, value)
		if choice_label:
			choices_list.add_child(choice_label)

	margin.add_child(choices_list)
	content_container.add_child(margin)
	section_container.add_child(content_container)

	shifts_container.add_child(section_container)
	shift_sections[shift] = section_container


## Creates a colored label for a single choice
func _create_choice_label(var_name: String, value: Variant) -> RichTextLabel:
	if not CHOICE_DESCRIPTIONS.has(var_name):
		return null

	var descriptions = CHOICE_DESCRIPTIONS[var_name]
	var value_str = str(value)

	if not descriptions.has(value_str):
		return null

	var desc = descriptions[value_str]
	var text = desc.get("text", "")
	var alignment = desc.get("alignment", "neutral")

	# Get color based on alignment
	var color: Color
	match alignment:
		"resistance":
			color = COLOR_RESISTANCE
		"loyalist":
			color = COLOR_LOYALIST
		"chaos":
			color = COLOR_CHAOS
		"qte_pass":
			color = COLOR_QTE_PASS
		"qte_fail":
			color = COLOR_QTE_FAIL
		_:
			color = COLOR_NEUTRAL

	var label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.text = "[color=#%s]- %s[/color]" % [color.to_html(false), text]
	label.custom_minimum_size.y = 24

	return label


## Handles shift header button press
func _on_shift_header_pressed(shift: int) -> void:
	_toggle_shift_section(shift)


## Toggles a shift section expanded/collapsed
func _toggle_shift_section(shift: int) -> void:
	if not shift_sections.has(shift):
		return

	var section = shift_sections[shift]
	var header = section.get_node("Header") as Button
	var content = section.get_node("Content") as VBoxContainer

	if content.visible:
		# Collapse
		content.visible = false
		header.text = "> Day %d - %s" % [shift, SHIFT_NAMES.get(shift, "Unknown")]
		expanded_shift = -1
	else:
		# Collapse previously expanded
		if expanded_shift > 0 and shift_sections.has(expanded_shift):
			var prev_section = shift_sections[expanded_shift]
			var prev_content = prev_section.get_node("Content") as VBoxContainer
			var prev_header = prev_section.get_node("Header") as Button
			prev_content.visible = false
			prev_header.text = "> Day %d - %s" % [expanded_shift, SHIFT_NAMES.get(expanded_shift, "Unknown")]

		# Expand this one
		content.visible = true
		header.text = "v Day %d - %s" % [shift, SHIFT_NAMES.get(shift, "Unknown")]
		expanded_shift = shift


## Shows a message when no choices are available
func _show_no_choices_message() -> void:
	var label = Label.new()
	label.text = "No choices recorded yet"
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	shifts_container.add_child(label)
