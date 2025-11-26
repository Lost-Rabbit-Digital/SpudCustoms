extends Node

signal language_changed(language_code)

var available_languages = {
	"cs": "Čeština",  # Czech
	"da": "Dansk",  # Danish
	"de": "Deutsch",  # German
	"en": "English",  # English
	"es": "Español",  # Spanish (Spain)
	"fi": "Suomi",  # Finnish
	"fr": "Français",  # French
	"hu": "Magyar",  # Hungarian
	"id": "Bahasa Indonesia",  # Indonesian
	"it": "Italiano",  # Italian
	"nl": "Nederlands",  # Dutch
	"no": "Norsk",  # Norwegian
	"pl": "Polski",  # Polish
	"pt": "Português",  # Portuguese (Portugal)
	"ro": "Română",  # Romanian
	"sk": "Slovenčina",  # Slovak
	"sv": "Svenska",  # Swedish
	"tr": "Türkçe",  # Turkish
	"vi": "Tiếng Việt",  # Vietnamese
}

var current_language = "en"


func _ready():
	# Set initial language (maybe from a saved setting)
	var saved_lang = Config.get_config("GameSettings", "Language", "en")
	set_language(saved_lang)
	#set_language("fr")


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
