# Main.gd (Main scene script)
extends Node2D

var current_potato
var score = 0
var time_left = 10  # seconds per decision
var current_rules = []

func generate_rules():
	current_rules = [
		"No Russet potatoes allowed",
		"All potatoes must be Fresh",
		"Purple Majesty potatoes always welcome",
		"Peeled potatoes require extra scrutiny"
	]
	# Randomly select 2-3 rules
	current_rules.shuffle()
	current_rules = current_rules.slice(0, randi() % 2 + 2)
	update_rules_display()

func update_rules_display():
	$"Label (RulesLabel)".text = "Current Rules:\n" + "\n".join(current_rules)
	
func is_potato_valid(potato):
	for rule in current_rules:
		if rule == "No Russet potatoes allowed" and potato.type == "Russet":
			return false
		elif rule == "All potatoes must be Fresh" and potato.condition != "Fresh":
			return false
		elif rule == "Peeled potatoes BANNED today!" and potato.condition == "Peeled":
			return false
		elif rule == "Purple Majesty always welcome" and potato.type == "Purple Majesty":
			return true
		elif rule == "We need more eyes!" and potato.condition == "Extra Eyes":
			return true
	return true

func _ready():
	new_potato()
	generate_rules()

func _process(delta):
	$"Label (TimeLabel)".text = "Time: " + str(int($Timer.time_left))

func new_potato():
	current_potato = generate_potato()
	$"Label (PotatoInfo)".text = current_potato.description
	$Timer.start(time_left)
	
func generate_potato():
	# Generate random potato characteristics
	var potato = {
		"name": get_random_name(),
		"type": get_random_type(),
		"condition": get_random_condition(),
	}
	potato.description = "%s\nType: %s\nCondition: %s" % [potato.name, potato.type, potato.condition]
	return potato

func get_random_name():
	var names = ["Spud", "Tater", "Mash", "Spudnik", "Tater Tot", "Mr. Potato", "Chip", "Murph", "Yam", "Tato", "Spuddy", "Tuber"]
	return names[randi() % names.size()]

func get_random_type():
	var types = ["Russet", "Yukon Gold", "Sweet Potato", "Purple Majesty", "Red Bliss", "Fingerling", "Kennebec", "Maris Piper", "Idaho Potato", "Katahdin"]
	return types[randi() % types.size()]

func get_random_condition():
	var conditions = ["Fresh", "Slightly Sprouted", "Extra Eyes", "Peeled", "Rotten", "Sprouted", "Mashed", "Baked", "Fried", "Boiled", "Dehydrated", "Frozen"]
	conditions = ["Fresh", "Slightly Sprouted", "Rotten", "Peeled"]
	return conditions[randi() % conditions.size()]


func _on_button_welcome_button_pressed() -> void:
	process_decision(true)

func _on_button_no_entry_button_pressed() -> void:
	process_decision(false)

func process_decision(allowed):
	var correct_decision = is_potato_valid(current_potato)
	if (allowed and correct_decision) or (!allowed and !correct_decision):
		score += 1
	else:
		score -= 1
	$"Label (ScoreLabel)".text = "Score: " + str(score)
	new_potato()
	if randi() % 5 == 0:  # 20% chance to change rules
		generate_rules()

func _on_timer_timeout():
	# Player ran out of time, count as wrong decision
	score -= 1
	$"Label (JudgementInfo)".text = "You run out of time and another customs officer beckons the spud over. Point taken."
	$"Label (ScoreLabel)".text = "Score: " + str(score)
	new_potato()

# Main.tscn (Main scene structure)
# - Node2D (root)
#   - Label (PotatoInfo)
#   - Button (WelcomeButton)
#   - Button (NoEntryButton)
#   - Label (ScoreLabel)
#   - Label (TimeLabel)
#   - Timer
