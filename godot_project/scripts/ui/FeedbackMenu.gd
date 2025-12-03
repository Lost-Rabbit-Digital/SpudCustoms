class_name FeedbackMenu
extends VBoxContainer
## Feedback menu for collecting player feedback and sending it to Discord webhook
##
## Displays a feedback form with text input, validation, and system information.
## Sends feedback to a Discord webhook when submitted.

# UI References
@onready var title_label: Label = $TitleLabel
@onready var tip_label: Label = $TipLabel
@onready var feedback_text_edit: TextEdit = $FeedbackTextEdit
@onready var char_count_label: Label = $CharCountLabel
@onready var back_button: Button = $ButtonContainer/BackButton
@onready var submit_button: Button = $ButtonContainer/SubmitButton
@onready var status_label: Label = $StatusLabel

# Configuration
const MIN_CHARACTERS = 10
const MAX_CHARACTERS = 2000
const DISCORD_WEBHOOK_URL = ""  # TODO: Add your Discord webhook URL here

# System info
var game_version: String = ""
var playtime: float = 0.0
var steam_user_id: String = ""

signal feedback_submitted
signal back_pressed


func _ready():
	# Setup UI
	title_label.text = "Send Feedback"
	tip_label.text = "Share your thoughts, report bugs, or suggest features! (Minimum %d characters)" % MIN_CHARACTERS
	feedback_text_edit.placeholder_text = "Enter your feedback here..."
	char_count_label.text = "0 / %d characters" % MAX_CHARACTERS
	status_label.text = ""
	status_label.hide()

	# Note: TextEdit doesn't have max_length property, enforce via text_changed callback

	# Connect signals
	feedback_text_edit.text_changed.connect(_on_feedback_text_changed)
	back_button.pressed.connect(_on_back_button_pressed)
	submit_button.pressed.connect(_on_submit_button_pressed)

	# Initialize system information
	_collect_system_information()

	# Disable submit button initially
	submit_button.disabled = true


func _collect_system_information():
	"""Collect system information for the feedback report"""
	# Get game version from project settings
	game_version = ProjectSettings.get_setting("application/config/version", "Unknown")

	# Get playtime from GameStateManager
	# REFACTORED: Use GameStateManager
	if GameStateManager:
		playtime = GameStateManager.get_total_playtime()
	else:
		playtime = 0.0

	# Get Steam user ID if Steam is running
	if Steam.isSteamRunning():
		var steam_id = Steam.getSteamID()
		steam_user_id = str(steam_id) if steam_id > 0 else "Unknown"
	else:
		steam_user_id = "Steam Disabled"


func _on_feedback_text_changed():
	"""Update character count and validate input"""
	var text = feedback_text_edit.text
	var char_count = text.length()

	# Enforce max length by truncating if necessary
	if char_count > MAX_CHARACTERS:
		feedback_text_edit.text = text.substr(0, MAX_CHARACTERS)
		# Move cursor to end after truncation
		feedback_text_edit.set_caret_column(MAX_CHARACTERS)
		char_count = MAX_CHARACTERS

	# Update character count label
	char_count_label.text = "%d / %d characters" % [char_count, MAX_CHARACTERS]

	# Enable/disable submit button based on minimum characters
	submit_button.disabled = char_count < MIN_CHARACTERS

	# Update label color
	if char_count < MIN_CHARACTERS:
		char_count_label.add_theme_color_override("font_color", Color.ORANGE_RED)
	elif char_count >= MAX_CHARACTERS:
		char_count_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		char_count_label.add_theme_color_override("font_color", Color.GREEN)


func _on_back_button_pressed():
	"""Handle back button press"""
	back_pressed.emit()
	hide()


func _on_submit_button_pressed():
	"""Handle submit button press - send feedback to Discord webhook"""
	var feedback_text = feedback_text_edit.text.strip_edges()

	# Validate feedback length
	if feedback_text.length() < MIN_CHARACTERS:
		_show_status("Feedback must be at least %d characters long!" % MIN_CHARACTERS, false)
		return

	# Check if webhook URL is configured
	if DISCORD_WEBHOOK_URL.is_empty():
		_show_status("Feedback system not configured. Please contact support directly.", false)
		return

	# Disable submit button to prevent double submission
	submit_button.disabled = true
	submit_button.text = "Sending..."

	# Send feedback
	_send_feedback_to_discord(feedback_text)


func _send_feedback_to_discord(feedback_text: String):
	"""Send feedback to Discord webhook"""
	# Format playtime
	var hours = int(playtime / 3600)
	var minutes = int((playtime - hours * 3600) / 60)
	var playtime_formatted = "%dh %dm" % [hours, minutes]

	# Build the Discord embed message
	var embed = {
		"title": "New Feedback from Spud Customs",
		"description": feedback_text,
		"color": 0x5865F2,  # Discord blue color
		"fields": [
			{
				"name": "Version",
				"value": game_version,
				"inline": true
			},
			{
				"name": "Playtime",
				"value": playtime_formatted,
				"inline": true
			},
			{
				"name": "Steam",
				"value": steam_user_id,
				"inline": true
			}
		],
		"timestamp": Time.get_datetime_string_from_system(true)
	}

	# Create the full webhook payload
	var payload = {
		"embeds": [embed]
	}

	# Convert to JSON
	var json = JSON.stringify(payload)

	# Create HTTP request
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	# Set headers for JSON
	var headers = ["Content-Type: application/json"]

	# Send the request
	var error = http_request.request(DISCORD_WEBHOOK_URL, headers, HTTPClient.METHOD_POST, json)

	if error != OK:
		_show_status("Failed to send feedback. Error code: %d" % error, false)
		submit_button.disabled = false
		submit_button.text = "Submit"
		http_request.queue_free()


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	"""Handle HTTP request completion"""
	if response_code >= 200 and response_code < 300:
		# Success
		_show_status("Thank you! Your feedback has been sent successfully.", true)
		feedback_text_edit.text = ""
		submit_button.text = "Submit"

		# Emit signal
		feedback_submitted.emit()

		# Hide feedback menu after a short delay
		await get_tree().create_timer(2.0).timeout
		hide()
	else:
		# Error
		_show_status("Failed to send feedback. Please try again later. (Error: %d)" % response_code, false)
		submit_button.disabled = false
		submit_button.text = "Submit"


func _show_status(message: String, is_success: bool):
	"""Display status message to user"""
	status_label.text = message
	status_label.show()

	if is_success:
		status_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		status_label.add_theme_color_override("font_color", Color.ORANGE_RED)
