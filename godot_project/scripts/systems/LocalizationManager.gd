
extends Node

signal language_changed(language_code)

var available_languages = {
	"bg": "български",       # Bulgarian
	"cs": "Čeština",         # Czech
	"da": "Dansk",           # Danish
	"de": "Deutsch",         # German
	"el": "Ελληνικά",        # Greek
	"en": "English",         # English
	"es": "Español",         # Spanish (Spain)
	"fi": "Suomi",           # Finnish
	"fr": "Français",        # French
	"hu": "Magyar",          # Hungarian
	"id": "Bahasa Indonesia", # Indonesian
	"it": "Italiano",        # Italian
	"ja": "日本語",           # Japanese - Test font support
	"ko": "한국어",           # Korean - Test font support
	"nl": "Nederlands",      # Dutch
	"no": "Norsk",           # Norwegian
	"pl": "Polski",          # Polish
	"pt": "Português",       # Portuguese (Portugal)
	"ro": "Română",          # Romanian
	"ru": "Русский",         # Russian
	"sk": "Slovenčina",      # Slovak
	"sv": "Svenska",         # Swedish
	"th": "ไทย",             # Thai - Test font support
	"tr": "Türkçe",          # Turkish
	"uk": "Українська",      # Ukrainian
	"vi": "Tiếng Việt",      # Vietnamese
	"zh-CN": "简体中文",      # Chinese (Simplified) - Test font support
}

var current_language = "es"

func _ready():
	# Set initial language (maybe from a saved setting)
	var saved_lang = Config.get_config("GameSettings", "Language", "es")
	#set_language(saved_lang)
	set_language("ko")

func set_language(language_code):
	if language_code in available_languages:
		TranslationServer.set_locale(language_code)
		current_language = language_code
		
		# Save the language preference
		Config.set_config("GameSettings", "Language", language_code)
		
		# Notify the system that language has changed
		emit_signal("language_changed", language_code)
		
		# Reload current scene to apply translations immediately
		# You might want a more elegant solution in production
		if get_tree() and get_tree().current_scene:
			var current_scene_path = get_tree().current_scene.scene_file_path
			if SceneLoader:
				SceneLoader.reload_current_scene()
	else:
		push_error("Unsupported language code: " + language_code)

func get_current_language() -> String:
	return current_language

func get_language_name(code: String = "") -> String:
	if code == "":
		code = current_language
	return available_languages.get(code, "Unknown")
