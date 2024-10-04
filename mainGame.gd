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
	
func is_potato_valid(potato):
	for rule in current_rules:
		if rule == "Purple Majesty always welcome" and potato.type == "Purple Majesty":
			return true
		elif rule == "We need more eyes!" and potato.condition == "Extra Eyes":
			return true
		elif rule == "No Russet potatoes allowed" and potato.type == "Russet":
			return false
		elif rule == "All potatoes must be Fresh" and potato.condition != "Fresh":
			return false
		elif rule == "Peeled potatoes BANNED today!" and potato.condition == "Peeled":
			return false

	return true

func _ready():
	queue_manager = $"Node2D (QueueManager)"  # Make sure to add QueueManager as a child of Main
	generate_rules()
	new_potato()
	await get_tree().create_timer(2).timeout
	new_potato()
	await get_tree().create_timer(2).timeout
	new_potato()
	await get_tree().create_timer(2).timeout
	

func _process(delta):
	$"Label (TimeLabel)".text = "Time: " + str(int($Timer.time_left))

func new_potato():
	current_potato = generate_potato()
	$"Label (PotatoInfo)".text = current_potato.description
	$Timer.start(time_left)
	queue_manager.add_potato()
	
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
	var first_name = [
	"Spud", "Tater", "Mash", "Spudnik", "Tater Tot", "Mr. Potato", "Chip", "Murph", "Yam", "Tato", "Spuddy", "Tuber"
	]
	var last_name = [
	"Ouwiw", "Sehi", "Sig", "Heechou", "Oufug", "Azej", "Ekepa", "Nuz", "Chegee", "Kusee", "Houf", "Fito", "Mog", "Urife", 
	"Pel", "Icekee", "Vuze", "Ivaj", "Edusto", "Douki", "Gere", "Wic", "Amur", "Sup", "Wofu", "Ezew", "Guko", "Huc", "Ruho", 
	"Oukem", "Ohevo", "Epeer", "Inor", "Ileew", "Gor", "Vahu", "Ruhi", "Ecimu", "Mel", "Weechu", "Oumaze", "Tos", "Stife",
	"Kuj", "Nedou", "Uguce", "Dorou", "Fouwee", "Neej", "Itoudee", "Soka", "Afidee", "Amaj", "Cad", "Ikacho", "Zebo", "Ukidi", 
	"Osehee", "Etaje", "Wouk", "Nout", "Gic", "Houcee", "Astowa", "Feej", "Ceb", "Ogaha", "Von", "Etaf", "Cil", "Oudire", "Udeg", 
	"Cukee", "Sovi", "Chabee", "Astihi", "Icobo", "Bouve", "Ejiwa", "Wup", "Chistou", "Jouhou", "Stukee", "Inouj", "Opob", "Liz", 
	"Azab", "Couchee", "Ovucha", "Omast", "Imib", "Ipist", "Luwe", "Ivigi", "Rich", "Omucou", "Oujeet", "Arouj", "Tipou", 
	"Roufe", "Ocheesou", "Ogudou", "Fest", "Outomo", "Vicu", "Houte", "Imowee", "Behu", "Ajoj", "Ifouzu", "Miz", "Istich", 
	"Keew", "Reep", "Elus", "Chag", "Joudo", "Ijeema", "Ekeek", "Geew", "Ukuc", "Fevu", "Wape", "Cip", "Ipoun", "Ehij", 
	"Ousteeca", "Noum", "Kif", "Enoud", "Oupago", "Owapu", "Ebutee", "Mowe", "Enur", "Ikomee", "Ewoc", "Outustou", "Uwustee", 
	"Oreesti", "Ajosee", "Reenou", "Sog", "Ukop", "Cele", "Louc", "Roj", "Uchizo", "Cojee", "Bup", "Oudees", "Bucha", "Peej", 
	"Steejee", "Icefou", "Aduk", "Awubu", "Hufou", "Alaree", "Oroum", "Stoumo", "Jesa", "Ouvas", "Teeb", "Chouta", "Koh", 
	"Hufu", "Icuve", "Chadou", "Outoul", "Peba", "Oufeeze", "Teel", "Fouj", "Jus", "Doup", "Touwu", "Ouposu", "Ofum", 
	"Uvosou", "Echuchi", "Par", "Homee", "Echas", "Ruh", "Gozo", "Stog", "Zoumo", "Nag", "Ougibe", "Suw", "Noba", "Ouzeeba", 
	"Ijouv", "Zimou", "Abaci", "Gadu", "Uwast", "Ekeh", "Ofehe"
	]
	
	var full_name = "%s %s"
	
	return full_name % [first_name[randi() % first_name.size()], last_name[randi() % last_name.size()]]

func get_random_type():
	var types = ["Russet Burbank", "Yukon Gold", "Sweet Potato", "Purple Majesty", "Red Bliss"]
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
		$"Label (JudgementInfo)".text = "You made the right choice, officer."
	else:
		$"Label (JudgementInfo)".text = "You have caused unnecessary suffering, officer..."
		score -= 1
	$"Label (ScoreLabel)".text = "Score: " + str(score)
	queue_manager.remove_potato()
	if randi() % 5 == 0:  # 20% chance to change rules
		generate_rules()

func _on_timer_timeout():
	# Player ran out of time, count as wrong decision
	score += 0
	$"Label (JudgementInfo)".text = "You run out of time and another customs officer beckons the spud over."
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
