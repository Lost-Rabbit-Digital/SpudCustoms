# Main.gd (Main scene script)
extends Node2D

var current_potato
var score = 0
var time_left = 5  # seconds per decision
var current_rules = []
var queue_manager: Node2D

func generate_rules():
	current_rules = [
		"Purple Majesty always welcome",
		"We need more eyes!",
		"No Russet potatoes allowed",
		"All potatoes must be Fresh",
		"Peeled potatoes BANNED today!"
	]
	# Randomly select 2-3 rules
	current_rules.shuffle()
	current_rules = current_rules.slice(0, randi() % 2 + 2)
	update_rules_display()

func update_rules_display():
	$"Label (RulesLabel)".text = "Current Rules:\n" + "\n".join(current_rules)
	
func is_potato_valid(potato_info: Dictionary) -> bool:
	for rule in current_rules:
		if rule == "Purple Majesty always welcome" and potato_info.type == "Purple Majesty":
			return true
		elif rule == "We need more eyes!" and potato_info.condition == "Extra Eyes":
			return true
		elif rule == "No Russet potatoes allowed" and potato_info.type == "Russet Burbank":
			return false
		elif rule == "All potatoes must be Fresh" and potato_info.condition != "Fresh":
			return false
		elif rule == "Peeled potatoes BANNED today!" and potato_info.condition == "Peeled":
			return false
	return true

func _ready():
	queue_manager = $"Node2D (QueueManager)"  # Make sure to add QueueManager as a child of Main
	generate_rules()
	new_potato()
	

func _process(delta):
	$"Label (TimeLabel)".text = "Time: " + str(int($Timer.time_left))

func new_potato():
	var potato_info = {
		"name": get_random_name(),
		"type": get_random_type(),
		"condition": get_random_condition(),
	}
	queue_manager.add_potato(potato_info)
	update_potato_info_display(potato_info)
	update_potato_texture(potato_info.type)
	$Timer.start(time_left)
	
func update_potato_info_display(potato_info: Dictionary):
	$"Label (PotatoInfo)".text = "Name: %s\nType: %s\nCondition: %s" % [potato_info.name, potato_info.type, potato_info.condition]	

func generate_potato():
	# Generate random potato characteristics
	var potato = {
		"name": get_random_name(),
		"type": get_random_type(),
		"condition": get_random_condition(),
	}
	potato.description = "Name: %s\nType: %s\nCondition: %s" % [potato.name, potato.type, potato.condition]
	return potato

func get_random_name():
	var first_names = ["Spud", "Tater", "Mash", "Spudnik", "Tater Tot", "Mr. Potato", "Chip", "Murph", "Yam", "Tato", "Spuddy", "Tuber"]
	var last_names = ["Ouwiw", "Sehi", "Sig", "Heechou", "Oufug", "Azej", "Ekepa", "Nuz", "Chegee", "Kusee", "Houf", "Fito", "Mog", "Urife"]
	return "%s %s" % [first_names[randi() % first_names.size()], last_names[randi() % last_names.size()]]

func get_random_type():
	var types = ["Russet Burbank", "Yukon Gold", "Sweet Potato", "Purple Majesty", "Red Bliss"]
	return types[randi() % types.size()]

func get_random_condition():
	var conditions = ["Fresh", "Slightly Sprouted", "Extra Eyes", "Peeled", "Rotten", "Sprouted", "Mashed", "Baked", "Fried", "Boiled", "Dehydrated", "Frozen"]
	return conditions[randi() % conditions.size()]


func _on_button_welcome_button_pressed() -> void:
	process_decision(true)

func _on_button_no_entry_button_pressed() -> void:
	process_decision(false)

func process_decision(allowed):
	var potato_info = queue_manager.remove_potato()
	var correct_decision = is_potato_valid(potato_info)
	
	if (allowed and correct_decision) or (!allowed and !correct_decision):
		score += 1
		$"Label (JudgementInfo)".text = "You made the right choice, officer."
	else:
		$"Label (JudgementInfo)".text = "You have caused unnecessary suffering, officer..."
		score -= 1
	
	$"Label (ScoreLabel)".text = "Score: " + str(score)
	new_potato()
	
	if randi() % 5 == 0:  # 20% chance to change rules
		generate_rules()

func peek_front_potato():
	var front_potato_info = queue_manager.get_front_potato_info()
	# Use front_potato_info as needed

func _on_timer_timeout():
	# Player ran out of time, count as wrong decision
	score += 0
	$"Label (JudgementInfo)".text = "You run out of time and another customs officer beckons the spud over."
	$"Label (ScoreLabel)".text = "Score: " + str(score)
	new_potato()

func update_potato_texture(potato_type: String):
	var texture_path = ""
	match potato_type:
		"Purple Majesty":
			texture_path = "res://potatoes/heads/purple_majesty_head.png"
		"Red Bliss":
			texture_path = "res://potatoes/heads/red_bliss_head.png"
		"Russet Burbank":
			texture_path = "res://potatoes/heads/russet_burbank_head.png"
		"Sweet Potato":
			texture_path = "res://potatoes/heads/sweet_potato_head.png"
		"Yukon Gold":
			texture_path = "res://potatoes/heads/yukon_gold_head.png"
	
	if texture_path != "":
		$"Sprite2D (PotatoMugshot)".texture = load(texture_path)
