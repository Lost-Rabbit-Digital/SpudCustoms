extends HBoxContainer
## Language selector component for main menu

@onready var language_label: Label = $LanguageLabel
@onready var language_dropdown: OptionButton = $LanguageDropdown

# Map index to language code for selection
var _language_codes: Array[String] = []


func _ready():
	_populate_language_dropdown()
	_select_current_language()

	# Connect to localization changes
	if LocalizationManager:
		LocalizationManager.language_changed.connect(_on_language_changed)

	# Update the label
	_update_label()


func _populate_language_dropdown():
	"""Fill the dropdown with available languages"""
	language_dropdown.clear()
	_language_codes.clear()

	if not LocalizationManager:
		return

	# Sort languages alphabetically by their native names
	var languages = LocalizationManager.available_languages.duplicate()
	var sorted_codes: Array = languages.keys()
	sorted_codes.sort_custom(func(a, b): return languages[a] < languages[b])

	for code in sorted_codes:
		var native_name = languages[code]
		language_dropdown.add_item(native_name)
		_language_codes.append(code)


func _select_current_language():
	"""Select the current language in the dropdown"""
	if not LocalizationManager:
		return

	var current_code = LocalizationManager.get_current_language()
	var index = _language_codes.find(current_code)
	if index >= 0:
		language_dropdown.select(index)


func _update_label():
	"""Update the language label with translated text"""
	if language_label:
		language_label.text = tr("select_language") + ":"


func _on_language_changed(_locale: String):
	"""Handle language change from external sources"""
	_select_current_language()
	_update_label()


func _on_language_dropdown_item_selected(index: int):
	"""Handle language selection from dropdown"""
	if index < 0 or index >= _language_codes.size():
		return

	var selected_code = _language_codes[index]
	if LocalizationManager:
		LocalizationManager.set_language(selected_code)
