class_name BubbleDialogueBox
extends Sprite2D

# File path to your JSON file
const MESSAGES_FILE = "res://scripts/systems/bubble_dialogue/bubble_dialogue_messages.json"

# Store loaded messages
var messages = {
	"spud_being_called": [],
	"spud_in_office": [],
	"warnings": [],
	"misc": [],
	"document_interaction": [],
}

var customs_officer_sounds = [
	preload("res://assets/audio/talking/froggy_phrase_1.wav"),
	preload("res://assets/audio/talking/froggy_phrase_2.wav"),
	preload("res://assets/audio/talking/froggy_phrase_3.wav"),
	preload("res://assets/audio/talking/froggy_phrase_4.wav"),
	preload("res://assets/audio/talking/froggy_phrase_5.wav"),
	preload("res://assets/audio/talking/froggy_phrase_6.wav"),
	preload("res://assets/audio/talking/froggy_phrase_7.wav"),
]

@onready var bubble_text = $BubbleText


func _ready():
	# Load messages from JSON
	load_messages()


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

		if queue_messages.has("document_interaction"):
			messages["document_interaction"] = queue_messages["document_interaction"]

# Set a random message from a specific category
func set_random_message_from_category(category_str: String) -> void:
	var category_messages = []
	self.visible = true
	play_random_officer_sound()
	
	# Create a mapping of categories to their translation key prefixes
	var category_prefixes = {
		"spud_being_called": "dialogue_spud_being_called_",
		"spud_in_office": "dialogue_spud_in_office_",
		"warnings": "dialogue_warnings_",
		"misc": "dialogue_misc_",
		"document_interaction": "dialogue_document_interaction_"
	}
	
	# Get the correct prefix for this category
	if category_prefixes.has(category_str):
		var prefix = category_prefixes[category_str]
		var message_count = 0
		
		# Determine how many messages are in this category
		match category_str:
			"spud_being_called": message_count = 10
			"spud_in_office": message_count = 12
			"warnings": message_count = 11
			"misc": message_count = 11
			"document_interaction": message_count = 2
		
		# Select a random message number
		var random_index = (randi() % message_count) + 1
		
		# Create the translation key and set the text
		var translation_key = prefix + str(random_index)
		bubble_text.text = tr(translation_key)
	else:
		push_warning("Unknown message category: " + category_str)
		bubble_text.text = "No messages available."


func play_random_officer_sound():
	# Play potato customs officer sound
	if !%SFXPool.is_playing():
		%SFXPool.stream = customs_officer_sounds.pick_random()
		%SFXPool.play()
