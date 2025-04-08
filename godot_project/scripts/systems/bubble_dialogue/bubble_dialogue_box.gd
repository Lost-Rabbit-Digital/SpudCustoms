extends Sprite2D
class_name BubbleDialogueBox

@onready var bubble_text = $BubbleText

# File path to your JSON file
const MESSAGES_FILE = "res://scripts/systems/bubble_dialogue/bubble_dialogue_messages.json"

# Message categories
enum MessageCategory {
	SPUD_BEING_CALLED,
	SPUD_IN_OFFICE,
	WARNINGS,
	MISC
}

# Store loaded messages
var messages = {
	"spud_being_called": [],
	"spud_in_office": [],
	"warnings": [],
	"misc": [],
	"document_interaction": [],
}

func _ready():
	# Load messages from JSON
	load_messages()
	
	# Set initial random message
	set_random_message()

func load_messages():
	# Check if file exists
	if not FileAccess.file_exists(MESSAGES_FILE):
		push_error("Message file not found: " + MESSAGES_FILE)
		return
	
	# Open and read the file
	var file = FileAccess.open(MESSAGES_FILE, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	# Parse JSON
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		push_error("JSON parse error: " + json.get_error_message())
		return
	
	var data = json.get_data()
	
	# Extract messages
	if data.has("queue_messages"):
		var queue_messages = data["queue_messages"]
		
		if queue_messages.has("spud_being_called"):
			messages["spud_being_called"] = queue_messages["spud_being_called"]
		
		if queue_messages.has("spud_in_office"):
			messages["spud_in_office"] = queue_messages["spud_in_office"]
		
		if queue_messages.has("warnings"):
			messages["warnings"] = queue_messages["warnings"]
		
		if queue_messages.has("misc"):
			messages["misc"] = queue_messages["misc"]

# Set a random message from a specific category
func set_random_message_from_category(category):
	var category_messages = []
	
	match category:
		MessageCategory.SPUD_BEING_CALLED:
			category_messages = messages["spud_being_called"]
		MessageCategory.SPUD_IN_OFFICE:
			category_messages = messages["spud_in_office"]
		MessageCategory.WARNINGS:
			category_messages = messages["warnings"]
		MessageCategory.MISC:
			category_messages = messages["misc"]
	
	if category_messages.size() > 0:
		var random_index = randi() % category_messages.size()
		bubble_text.text = category_messages[random_index]
	else:
		bubble_text.text = "No messages available."

# Set a completely random message from any category
func set_random_message():
	# Get all categories that have messages
	var available_categories = []
	
	if messages["spud_being_called"].size() > 0:
		available_categories.append(MessageCategory.SPUD_BEING_CALLED)
	
	if messages["spud_in_office"].size() > 0:
		available_categories.append(MessageCategory.SPUD_IN_OFFICE)
	
	if messages["warnings"].size() > 0:
		available_categories.append(MessageCategory.WARNINGS)
	
	if messages["misc"].size() > 0:
		available_categories.append(MessageCategory.MISC)
	
	if available_categories.size() > 0:
		var random_category = available_categories[randi() % available_categories.size()]
		set_random_message_from_category(random_category)
	else:
		bubble_text.text = "No messages available."

# Call this function to cycle to the next random message
func next_message():
	set_random_message()
	play_random_officer_sound()
	self.visible = true

func play_random_officer_sound():
	# WARNING: This will load all of these sounds into memory every time 
	# this function is called, so probably want to introduce some type of
	# resource management into this.
	var customs_officer_sounds = [
		preload("res://assets/audio/talking/froggy_phrase_1.wav"),
		preload("res://assets/audio/talking/froggy_phrase_2.wav"),
		preload("res://assets/audio/talking/froggy_phrase_3.wav"),
		preload("res://assets/audio/talking/froggy_phrase_4.wav"),
		preload("res://assets/audio/talking/froggy_phrase_5.wav"),
		preload("res://assets/audio/talking/froggy_phrase_6.wav"),
		preload("res://assets/audio/talking/froggy_phrase_7.wav")
	]
	# Play potato customs officer sound
	if !%SFXPool.is_playing():
		%SFXPool.stream = customs_officer_sounds.pick_random()
		%SFXPool.play()
