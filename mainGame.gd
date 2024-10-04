# Main.gd (Main scene script)
extends Node2D

var current_potato
var score = 0
var time_left = 10  # seconds per decision

func _ready():
	new_potato()

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
	conditions = ["Fresh", "Slightly Sprouted", "Rotten"]
	return conditions[randi() % conditions.size()]

func _on_button_welcome_button_pressed() -> void:
	process_decision(true)

func _on_button_no_entry_button_pressed() -> void:
	process_decision(false)

func process_decision(decision):
	# Here you would implement the logic to determine if the decision was correct
	# For now, let's just add a point if we allow entry
	print(decision)
	
	if not decision and "Rotten" in current_potato.condition:
		score += 1
		$"Label (JudgementInfo)".text = "You rejected a rotten potato. Million will live. Point granted."
		
	if decision and not "Rotten" in current_potato.condition:
		score += 1
		$"Label (JudgementInfo)".text = "You allowed in an innocent potato. They will live. Point granted."
		
	if decision and "Rotten" in current_potato.condition:
		score -= 1
		$"Label (JudgementInfo)".text = "You allowed in a Rotten potato, millions will die. Point taken."
	
	if not decision and not "Rotten" in current_potato.condition: 
		score -= 1
		$"Label (JudgementInfo)".text = "You rejected an innocent potato. They will die. Point taken."
		
	$"Label (ScoreLabel)".text = "Score: " + str(score)
	new_potato()

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
