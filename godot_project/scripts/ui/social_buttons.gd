extends HBoxContainer
## Social buttons component for main menu with Discord, Steam, and Twitch links

const DISCORD_URL = "https://discord.gg/Y7caBf7gBj"
const STEAM_URL = "https://store.steampowered.com/developer/lostrabbitdigital"

@onready var discord_button: TextureButton = $DiscordButton
@onready var steam_button: TextureButton = $SteamButton
@onready var twitch_button: TextureButton = $TwitchButton


func _ready():
	# Connect to localization changes
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_on_language_changed)

	# Set initial tooltips
	_update_tooltips()

	# Setup JuicyButtons hover effects
	_setup_juicy_buttons()


func _setup_juicy_buttons():
	"""Apply JuicyButtons hover effects to social buttons"""
	if JuicyButtons:
		var hover_config = {
			"hover_scale": Vector2(1.05, 1.05),
			"hover_time": 0.1,
			"hover_sfx_path": "res://assets/user_interface/audio/hover_sound.mp3",
			"volume_db": -6.0
		}
		JuicyButtons.enhance_all_buttons(self, hover_config)


func _update_tooltips():
	"""Update button tooltips with current language"""
	if discord_button:
		discord_button.tooltip_text = tr("social_discord_tooltip")
	if steam_button:
		steam_button.tooltip_text = tr("social_steam_tooltip")
	if twitch_button:
		twitch_button.tooltip_text = tr("social_twitch_tooltip")


func _on_language_changed(_locale: String):
	"""Update tooltips when language changes"""
	_update_tooltips()


func _on_discord_button_pressed() -> void:
	"""Open Discord invite link with JuicyButtons animation"""
	if JuicyButtons:
		await JuicyButtons.setup_button(discord_button, DISCORD_URL)
	else:
		OS.shell_open(DISCORD_URL)


func _on_steam_button_pressed() -> void:
	"""Open Steam developer page with JuicyButtons animation"""
	if JuicyButtons:
		await JuicyButtons.setup_button(steam_button, STEAM_URL)
	else:
		OS.shell_open(STEAM_URL)


func _on_twitch_button_pressed() -> void:
	"""Open Twitch configuration panel"""
	if JuicyButtons:
		await JuicyButtons.setup_button(twitch_button, "")

	# Open the Twitch config panel via TwitchIntegrationManager
	if TwitchIntegrationManager:
		TwitchIntegrationManager.show_config_panel()
