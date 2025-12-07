extends Node

signal language_changed(language_code)

# All Steam-supported languages (31 total)
# Sorted alphabetically by native name for the language selector
var available_languages = {
	"ar": "العربية",  # Arabic
	"bg": "Български",  # Bulgarian
	"cs": "Čeština",  # Czech
	"da": "Dansk",  # Danish
	"de": "Deutsch",  # German
	"el": "Ελληνικά",  # Greek
	"en": "English",  # English
	"es": "Español",  # Spanish (Spain)
	"es-419": "Español (Latinoamérica)",  # Spanish (Latin America)
	"fi": "Suomi",  # Finnish
	"fr": "Français",  # French
	"hu": "Magyar",  # Hungarian
	"id": "Bahasa Indonesia",  # Indonesian
	"it": "Italiano",  # Italian
	"ja": "日本語",  # Japanese
	"ko": "한국어",  # Korean
	"nl": "Nederlands",  # Dutch
	"no": "Norsk",  # Norwegian
	"pl": "Polski",  # Polish
	"pt": "Português",  # Portuguese (Portugal)
	"pt-BR": "Português (Brasil)",  # Portuguese (Brazil)
	"ro": "Română",  # Romanian
	"ru": "Русский",  # Russian
	"sk": "Slovenčina",  # Slovak
	"sv": "Svenska",  # Swedish
	"th": "ไทย",  # Thai
	"tr": "Türkçe",  # Turkish
	"uk": "Українська",  # Ukrainian
	"vi": "Tiếng Việt",  # Vietnamese
	"zh-CN": "简体中文",  # Chinese (Simplified)
	"zh-TW": "繁體中文",  # Chinese (Traditional)
}

var current_language = "en"
var _initialized = false


func _ready():
	# Set initial language (maybe from a saved setting)
	var saved_lang = Config.get_config("GameSettings", "Language", "en")
	set_language(saved_lang)
	_initialized = true
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
		# Only reload if already initialized (not during _ready) to avoid tree busy errors
		# Use call_deferred to avoid removing children while tree is busy
		if _initialized and get_tree() and get_tree().current_scene:
			if SceneLoader:
				SceneLoader.reload_current_scene.call_deferred()
	else:
		push_error("Unsupported language code: " + language_code)


func get_current_language() -> String:
	return current_language


func get_language_name(code: String = "") -> String:
	if code == "":
		code = current_language
	return available_languages.get(code, "Unknown")


func get_sorted_language_codes() -> Array:
	"""Return language codes sorted by their native names for UI display."""
	var codes = available_languages.keys()
	codes.sort_custom(func(a, b): return available_languages[a] < available_languages[b])
	return codes
