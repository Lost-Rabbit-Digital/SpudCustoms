extends Control

@onready var difficulty_option_button = $VBoxContainer/DifficultyControl/OptionButton
var language_codes = []

func _ready():
	# Populate language dropdown
	var language_dropdown = %LanguageDropdown

	for code in LocalizationManager.available_languages:
		var language_name = LocalizationManager.available_languages[code]
		language_dropdown.add_item(language_name)
		language_codes.append(code) # Store code corresponding to the added item

	# Set current language
	var current_lang = LocalizationManager.current_language
	for i in range(language_codes.size()):
		if language_codes[i] == current_lang:
			language_dropdown.select(i)
			break
	
	%LanguageDropdown.item_selected.connect(_on_language_dropdown_item_selected)



	# Set up the difficulty option button
	if difficulty_option_button:
		# Clear any existing items
		difficulty_option_button.clear()
		
		# Add difficulty options
		difficulty_option_button.add_item("Easy")
		difficulty_option_button.add_item("Normal")
		difficulty_option_button.add_item("Expert")
		
		# Set current selection based on Global setting
		match Global.difficulty_level:
			"Easy":
				difficulty_option_button.select(0)
			"Normal":
				difficulty_option_button.select(1)
			"Expert":
				difficulty_option_button.select(2)
		
		# Connect signal
		difficulty_option_button.item_selected.connect(_on_difficulty_changed)

func _on_difficulty_changed(index):
	var difficulty = difficulty_option_button.get_item_text(index)
	Global.set_difficulty(difficulty)
	print("Difficulty changed to: ", difficulty)

func _on_language_dropdown_item_selected(index):
	var lang_code = language_codes[index]
	LocalizationManager.set_language(lang_code)

func _on_ResetGameControl_reset_confirmed():
	GlobalState.reset()
	
func _on_ResetProgressButton_pressed():
	var confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.dialog_text = "Are you sure you want to reset story progress? This cannot be undone."
	confirmation_dialog.get_ok_button().text = "Reset"
	confirmation_dialog.get_cancel_button().text = "Cancel"
	add_child(confirmation_dialog)
	confirmation_dialog.popup_centered()
	confirmation_dialog.connect("confirmed", Callable(self, "_reset_story_progress"))

func _on_ResetHighScoresButton_pressed():
	var confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.dialog_text = "Are you sure you want to reset all high scores? This cannot be undone."
	confirmation_dialog.get_ok_button().text = "Reset"
	confirmation_dialog.get_cancel_button().text = "Cancel"
	add_child(confirmation_dialog)
	confirmation_dialog.popup_centered()
	confirmation_dialog.connect("confirmed", Callable(self, "_reset_high_scores"))

func _reset_story_progress():
	# Reset story progress but keep high scores
	GlobalState.reset()
	Global.reset_game_state(true)
	Global.current_story_state = 0
	GlobalState.save()

func _reset_high_scores():
	# Reset only high scores
	Global.high_scores = {
	"level_highscores": {
		"1": {  # Level ID as string
			"Easy": 800,
			"Normal": 800,
			"Expert": 800
		},
		"2": {
			"Easy": 800,
			"Normal": 800,
			"Expert": 800
		}
	},
	"global_highscores": {
		"Easy": 900,
		"Normal": 900,
		"Expert": 900
	}
}
	# Clear level-specific high scores
	var game_state = GameState.get_game_state()
	game_state.level_highscores = {}
	GlobalState.save()
