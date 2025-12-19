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

## Shift name translation keys for headers
const SHIFT_NAME_KEYS: Dictionary = {
	1: "shift_name_1",
	2: "shift_name_2",
	3: "shift_name_3",
	4: "shift_name_4",
	5: "shift_name_5",
	6: "shift_name_6",
	7: "shift_name_7",
	8: "shift_name_8",
	9: "shift_name_9",
	10: "shift_name_10"
}


## Gets the translated shift name for a given shift number
func get_shift_name(shift: int) -> String:
	if SHIFT_NAME_KEYS.has(shift):
		return tr(SHIFT_NAME_KEYS[shift])
	return tr("shift_name_unknown")

## Choice alignments organized by variable name and value
## Format: {variable_name: {value: alignment}}
## Text is looked up via translation keys: choice_{variable_name}_{value}
const CHOICE_ALIGNMENTS: Dictionary = {
	# Shift 1 - Introduction
	"initial_response": {"eager": "loyalist", "questioning": "resistance"},
	"note_reaction": {"investigate": "resistance", "destroy": "loyalist", "report": "loyalist"},
	"kept_note": {"yes": "resistance", "no": "neutral"},
	"reported_note": {"yes": "loyalist"},

	# Shift 2 - Meeting Sasha & Murphy
	"murphy_trust": {"open": "resistance", "guarded": "neutral"},
	"eat_reserve": {"ate": "neutral", "refused": "resistance"},

	# Shift 3 - Missing Wife
	"scanner_response": {"loyal": "loyalist", "questioning": "resistance"},
	"family_response": {"refuse": "loyalist", "help": "resistance"},
	"has_wife_photo": {"yes": "resistance"},
	"reveal_reaction": {"shocked": "neutral", "cautious": "neutral"},

	# Shift 4 - Root Reserve Trucks
	"cafeteria_response": {"serious": "resistance", "avoid": "loyalist"},
	"murphy_alliance": {"ally": "resistance", "cautious": "neutral", "skeptical": "loyalist"},
	"sasha_trust_level": {"committed": "resistance", "cautious": "neutral"},

	# Shift 5 - Loyalty Screening & Heist
	"sasha_investigation": {"committed": "resistance", "hesitant": "neutral"},
	"loyalty_response": {"patriotic": "loyalist", "idealistic": "resistance"},
	"hide_choice": {"desk": "neutral", "window": "neutral"},
	"evidence_choice": {"hand_over": "loyalist", "keep": "resistance", "lie": "resistance", "chaos": "chaos"},
	"viktor_wife_discovery": {"yes": "resistance"},

	# Shift 6 - RealityScan
	"fellow_officer_response": {"cautious": "neutral", "sympathetic": "resistance", "loyal": "loyalist"},
	"interrogation_response": {"lie": "resistance", "legal": "loyalist"},
	"viktor_conversation": {"tell_truth": "resistance", "lie_protect": "resistance", "curious": "neutral"},
	"scanner_choice": {"help": "resistance", "scan": "loyalist", "viktor": "resistance"},
	"helped_operative": {"yes": "resistance", "no": "loyalist"},
	"viktor_allied": {"yes": "resistance"},
	"betrayed_resistance": {"yes": "loyalist"},
	"sasha_plan_response": {"committed": "resistance", "nervous": "neutral"},
	"malfunction_excuse": {"technical": "neutral", "innocent": "neutral"},

	# Shift 7 - Resistance Meeting
	"resistance_mission": {"committed": "resistance", "hesitant": "neutral", "cautious": "neutral"},
	"final_decision": {"help": "resistance", "passive": "neutral", "undecided": "neutral"},
	"yellow_badge_response": {"help": "resistance", "betray": "loyalist"},
	"follow_trucks": {"volunteer": "resistance", "hesitant": "neutral"},
	"found_facility": {"yes": "resistance"},

	# Shift 8 - Sasha's Capture
	"sasha_response": {"cautious": "neutral", "concerned": "resistance"},
	"interrogation_choice": {"deny": "resistance", "betray": "loyalist"},
	"sasha_arrest_reaction": {"intervene": "resistance", "hide": "neutral", "promise": "resistance"},
	"player_wanted": {"yes": "resistance"},
	"player_captured": {"yes": "neutral"},
	"has_keycard": {"yes": "resistance"},
	"murphy_final_alliance": {"committed": "resistance", "hesitant": "neutral"},

	# Shift 9 - The Attack
	"critical_choice": {"help": "resistance", "betray": "loyalist"},
	"stay_or_go": {"stay": "resistance", "go": "neutral"},
	"sasha_rescue_reaction": {"angry": "neutral", "disgusted": "neutral", "relieved": "resistance"},

	# Shift 10 & Endings
	"fellow_officer_response_2": {"cautious": "neutral", "sympathetic": "resistance"},
	"final_mission_response": {"determined": "resistance", "cautious": "neutral"},
	"resistance_trust": {"diplomatic": "neutral", "committed": "resistance"},
	"ending_choice": {"diplomatic": "neutral", "justice": "resistance", "vengeance": "chaos", "dismantle": "resistance"},

	# Loyalist Ending
	"accept_medal": {"accept": "loyalist", "reluctant": "neutral"},
	"eat_final": {"eat": "loyalist", "refuse": "resistance"},
	"final_loyalist_choice": {"report": "loyalist", "ignore": "neutral", "hope": "resistance"},

	# QTE Results
	"qte_rescue_result": {"pass": "qte_pass", "fail": "qte_fail"},
	"qte_confrontation_result": {"pass": "qte_pass", "fail": "qte_fail"},
	"qte_escape_result": {"pass": "qte_pass", "fail": "qte_fail"},
	"qte_infiltration_result": {"pass": "qte_pass", "fail": "qte_fail"},
	"qte_scanner_result": {"pass": "qte_pass", "fail": "qte_fail"},
	"qte_surveillance_result": {"pass": "qte_pass", "fail": "qte_fail"},
	"qte_suppression_result": {"pass": "qte_pass", "fail": "qte_fail"}
}


## Gets the translated text for a choice
func get_choice_text(var_name: String, value: String) -> String:
	var key = "choice_%s_%s" % [var_name, value]
	return tr(key)

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
		path_text = "[color=#ff6666]%s[/color]" % tr("path_chaos_agent")
	elif loyalist_path == "yes":
		path_text = "[color=#ffd966]%s[/color]" % tr("path_loyalist")
	elif pro_sasha >= 7:
		path_text = "[color=#66b3ff]%s[/color]" % tr("path_resistance_ally")
	elif pro_sasha >= 4:
		path_text = "[color=#e6e6e6]%s[/color]" % tr("path_questioning")
	else:
		path_text = "[color=#e6e6e6]%s[/color]" % tr("path_undetermined")

	if path_indicator_label:
		path_indicator_label.text = "[b]%s[/b] " % tr("story_choice_path_label") + path_text

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
		sasha_trust_label.text = tr("story_choice_sasha_trust").format({"value": pro_sasha})

	# Update chaos indicator
	if chaos_indicator:
		var chaos_points = choices.get("chaos_points", 0)
		if chaos_points is String:
			chaos_points = int(chaos_points) if chaos_points.is_valid_int() else 0

		if chaos_agent == "yes" or chaos_points > 0:
			chaos_indicator.text = tr("story_choice_chaos_points").format({"value": chaos_points})
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
	header_button.text = "> %s" % tr("story_choice_day_header").format({"day": shift, "name": get_shift_name(shift)})
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
	if not CHOICE_ALIGNMENTS.has(var_name):
		return null

	var alignments = CHOICE_ALIGNMENTS[var_name]
	var value_str = str(value)

	if not alignments.has(value_str):
		return null

	var alignment = alignments[value_str]
	var text = get_choice_text(var_name, value_str)

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
		header.text = "> %s" % tr("story_choice_day_header").format({"day": shift, "name": get_shift_name(shift)})
		expanded_shift = -1
	else:
		# Collapse previously expanded
		if expanded_shift > 0 and shift_sections.has(expanded_shift):
			var prev_section = shift_sections[expanded_shift]
			var prev_content = prev_section.get_node("Content") as VBoxContainer
			var prev_header = prev_section.get_node("Header") as Button
			prev_content.visible = false
			prev_header.text = "> %s" % tr("story_choice_day_header").format({"day": expanded_shift, "name": get_shift_name(expanded_shift)})

		# Expand this one
		content.visible = true
		header.text = "v %s" % tr("story_choice_day_header").format({"day": shift, "name": get_shift_name(shift)})
		expanded_shift = shift


## Shows a message when no choices are available
func _show_no_choices_message() -> void:
	var label = Label.new()
	label.text = tr("story_choice_no_choices")
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	shifts_container.add_child(label)
