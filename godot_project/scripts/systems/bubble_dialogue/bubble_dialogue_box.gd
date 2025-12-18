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

# Contextual dialogue configuration
# Maps EventBus triggers to dialogue categories and message keys
const CONTEXTUAL_TRIGGERS: Dictionary = {
	"perfect_stamp": {
		"category": "perfect_stamp",
		"chance": 0.7,  # 70% chance to trigger
	},
	"runner_stopped": {
		"category": "runner_stopped",
		"chance": 0.6,
	},
	"runner_escaped": {
		"category": "runner_escaped",
		"chance": 0.8,
	},
	"wrong_stamp": {
		"category": "wrong_stamp",
		"chance": 0.5,
	},
	"strike_received": {
		"category": "strike_received",
		"chance": 0.9,
	},
}

# Contextual message counts (for translation keys)
const CONTEXTUAL_MESSAGE_COUNTS: Dictionary = {
	"perfect_stamp": 5,
	"runner_stopped": 5,
	"runner_escaped": 5,
	"wrong_stamp": 4,
	"strike_received": 4,
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

# Cooldown to prevent dialogue spam
var _dialogue_cooldown: float = 0.0
const DIALOGUE_COOLDOWN_TIME: float = 2.0

@onready var bubble_text = $BubbleText


func _ready():
	# Load messages from JSON
	load_messages()
	# Connect to EventBus for contextual dialogue
	_connect_eventbus_signals()


func _process(delta: float) -> void:
	# Update cooldown
	if _dialogue_cooldown > 0:
		_dialogue_cooldown -= delta


func _connect_eventbus_signals() -> void:
	if EventBus:
		EventBus.bubble_dialogue_requested.connect(_on_bubble_dialogue_requested)
		EventBus.runner_stopped.connect(_on_runner_stopped)
		EventBus.runner_escaped.connect(_on_runner_escaped)
		EventBus.strike_changed.connect(_on_strike_changed)


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
			"spud_being_called":
				message_count = 10
			"spud_in_office":
				message_count = 12
			"warnings":
				message_count = 11
			"misc":
				message_count = 11
			"document_interaction":
				message_count = 2

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


# ============================================================================
# CONTEXTUAL DIALOGUE SYSTEM
# ============================================================================

## Trigger contextual dialogue based on game events
## @param category: The dialogue category to use
## @param context: Additional context data (optional)
func trigger_contextual_dialogue(category: String, _context: Dictionary = {}) -> void:
	# Check cooldown
	if _dialogue_cooldown > 0:
		return

	# Check if this category has a chance to trigger
	if CONTEXTUAL_TRIGGERS.has(category):
		var trigger_config = CONTEXTUAL_TRIGGERS[category]
		if randf() > trigger_config.chance:
			return  # Chance check failed

	# Set a random contextual message
	set_contextual_message(category)

	# Start cooldown
	_dialogue_cooldown = DIALOGUE_COOLDOWN_TIME


## Set a contextual message from a specific category
func set_contextual_message(category: String) -> void:
	# Check if we have message count for this category
	if not CONTEXTUAL_MESSAGE_COUNTS.has(category):
		push_warning("Unknown contextual dialogue category: " + category)
		return

	var message_count = CONTEXTUAL_MESSAGE_COUNTS[category]
	if message_count <= 0:
		return

	# Show bubble and play sound
	self.visible = true
	play_random_officer_sound()

	# Build translation key: dialogue_[category]_[number]
	var random_index = (randi() % message_count) + 1
	var translation_key = "dialogue_" + category + "_" + str(random_index)

	# Set the text using translation
	var translated_text = tr(translation_key)

	# If translation not found (returns the key), use a fallback
	if translated_text == translation_key:
		# Fallback messages for untranslated categories
		translated_text = _get_fallback_message(category)

	bubble_text.text = translated_text

	# Auto-hide after a delay
	_auto_hide_bubble(3.0)


func _get_fallback_message(category: String) -> String:
	# Fallback messages in case translations aren't available yet
	match category:
		"perfect_stamp":
			var messages_list = [
				"Excellent work!",
				"Now THAT'S how you stamp!",
				"Precision at its finest!",
				"The stamp gods smile upon you!",
				"Textbook technique!",
			]
			return messages_list[randi() % messages_list.size()]
		"runner_stopped":
			var messages_list = [
				"GOTCHA!",
				"Not on MY watch!",
				"Justice served, hot and fresh!",
				"That's what happens to runners!",
				"Target eliminated!",
			]
			return messages_list[randi() % messages_list.size()]
		"runner_escaped":
			var messages_list = [
				"Blast! They got away!",
				"Curses! Too slow!",
				"That one slipped through...",
				"The paperwork for this...",
				"Not my finest moment.",
			]
			return messages_list[randi() % messages_list.size()]
		"wrong_stamp":
			var messages_list = [
				"Wait, that's not right...",
				"Hmm, did I mean to do that?",
				"The ink... it betrays me!",
				"Oops.",
			]
			return messages_list[randi() % messages_list.size()]
		"strike_received":
			var messages_list = [
				"That'll go on my record...",
				"The Ministry won't like this.",
				"One step closer to mashing...",
				"Strike! But not the good kind.",
			]
			return messages_list[randi() % messages_list.size()]
		_:
			return "..."


func _auto_hide_bubble(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	self.visible = false


# ============================================================================
# EVENTBUS HANDLERS
# ============================================================================

func _on_bubble_dialogue_requested(category: String, context: Dictionary) -> void:
	trigger_contextual_dialogue(category, context)


func _on_runner_stopped(runner_data: Dictionary) -> void:
	trigger_contextual_dialogue("runner_stopped", runner_data)


func _on_runner_escaped(runner_data: Dictionary) -> void:
	trigger_contextual_dialogue("runner_escaped", runner_data)


func _on_strike_changed(current: int, _max_val: int, delta: int) -> void:
	# Only trigger on strike added (delta > 0)
	if delta > 0:
		trigger_contextual_dialogue("strike_received", {"current_strikes": current})
