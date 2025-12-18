extends MainMenu

@export var level_select_packed_scene: PackedScene

var level_select_scene
var animation_state_machine: AnimationNodeStateMachinePlayback
var confirmation_dialog: ConfirmationDialog
var tutorial_choice_dialog: AcceptDialog
var load_confirmation_dialog: Window
var narrative_choice_display: NarrativeChoiceDisplay
var feedback_menu: Control
@onready var version_label = %VersionLabel
@onready var bgm_player = $BackgroundMusicPlayer


func _ready():
	load_tracks()
	# Play with original pitch by default
	next_track_with_random_pitch()
	super._ready()
	_setup_level_select()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")
	_setup_confirmation_dialog()
	_setup_tutorial_choice_dialog()
	_setup_load_confirmation_dialog()
	_setup_feedback_menu()
	# Check for demo version - hide score attack in demo builds
	if GameStateManager and GameStateManager.get_build_type() == "Demo Release":
		# Hide score attack button
		%EndlessButton.visible = false


func load_game_scene():
	GameState.start_game()
	SceneLoader.load_scene(story_game_scene_path)


func new_game():
	# Instead of immediately resetting data, show the confirmation dialog
	confirmation_dialog.popup_centered()


func _on_new_game_confirmed():
	await JuicyButtons.setup_button(%NewGameButton)
	# Show tutorial choice dialog
	tutorial_choice_dialog.popup_centered()


func _on_endless_button_pressed():
	await JuicyButtons.setup_button(%EndlessButton)
	# REFACTORED: Use GameStateManager and EventBus
	if GameStateManager:
		GameStateManager.switch_game_mode("score_attack")
	# Reset game state but keep high scores
	EventBus.shift_stats_reset.emit()
	# Now load the score attack scene instead
	SceneLoader.load_scene("res://scenes/game_scene/score_attack_ui.tscn")


func _setup_confirmation_dialog():
	confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.title = tr("Start New Game")
	confirmation_dialog.dialog_text = tr("Starting a new game will reset your progress. Are you sure you want to continue?")
	confirmation_dialog.min_size = Vector2(400, 100)
	confirmation_dialog.dialog_hide_on_ok = true
	confirmation_dialog.get_ok_button().text = tr("new_game_confirm_button")
	var dialog_theme = load("res://assets/styles/confirmation_dialog_theme.tres")
	if dialog_theme:
		confirmation_dialog.theme = dialog_theme
	add_child(confirmation_dialog)

	# Add juicy hover effects to dialog buttons
	_setup_dialog_button_effects.call_deferred(confirmation_dialog)

	# Connect confirmation signals
	confirmation_dialog.confirmed.connect(_on_new_game_confirmed)


func _setup_tutorial_choice_dialog():
	tutorial_choice_dialog = AcceptDialog.new()
	tutorial_choice_dialog.title = tr("tutorial_dialog_title")
	tutorial_choice_dialog.dialog_text = tr("tutorial_dialog_text")
	tutorial_choice_dialog.min_size = Vector2(450, 150)
	tutorial_choice_dialog.dialog_hide_on_ok = true

	# Rename OK button to "Play Tutorial"
	tutorial_choice_dialog.get_ok_button().text = tr("tutorial_choice_play")

	# Add "Skip Tutorial" button
	var skip_button = tutorial_choice_dialog.add_button(tr("tutorial_choice_skip"), true, "skip_tutorial")

	# Apply consistent brown/gold theme
	var dialog_theme = load("res://assets/styles/confirmation_dialog_theme.tres")
	if dialog_theme:
		tutorial_choice_dialog.theme = dialog_theme

	add_child(tutorial_choice_dialog)

	# Add juicy hover effects to dialog buttons
	_setup_dialog_button_effects.call_deferred(tutorial_choice_dialog)

	# Connect signals
	tutorial_choice_dialog.confirmed.connect(_on_start_with_tutorial)
	tutorial_choice_dialog.custom_action.connect(_on_tutorial_dialog_action)


func _on_start_with_tutorial():
	"""Start the game with tutorial (shift 0)"""
	GlobalState.reset()
	# Reset shift stats (score, strikes, quota) before starting new game
	EventBus.shift_stats_reset.emit()
	if GameStateManager:
		GameStateManager.switch_game_mode("story")
		GameStateManager.set_shift(0)  # Start at tutorial shift
		GameStateManager.set_tutorial_mode(true)  # Enable tutorial mode
	if TutorialManager:
		TutorialManager.reset_all_tutorials()  # Ensure tutorials will play
	load_game_scene()


func _on_tutorial_dialog_action(action: StringName):
	"""Handle custom button actions in tutorial dialog"""
	if action == "skip_tutorial":
		tutorial_choice_dialog.hide()
		_on_skip_tutorial()


func _on_skip_tutorial():
	"""Start the game skipping tutorial (shift 1)"""
	GlobalState.reset()
	# Reset shift stats (score, strikes, quota) before starting new game
	EventBus.shift_stats_reset.emit()
	if GameStateManager:
		GameStateManager.switch_game_mode("story")
		GameStateManager.set_shift(1)  # Start at shift 1
		GameStateManager.set_tutorial_mode(false)  # Disable tutorial mode
	if TutorialManager:
		# Mark all shift 1 tutorials as completed so they don't play
		TutorialManager.mark_tutorial_completed("welcome")
		TutorialManager.mark_tutorial_completed("gate_control")
		TutorialManager.mark_tutorial_completed("megaphone_call")
		TutorialManager.mark_tutorial_completed("document_inspection")
		TutorialManager.mark_tutorial_completed("rules_checking")
		TutorialManager.mark_tutorial_completed("stamp_usage")
		TutorialManager.mark_tutorial_completed("strikes_and_quota")
	load_game_scene()


func _setup_load_confirmation_dialog():
	# Create custom window for continue dialog with narrative choices
	load_confirmation_dialog = Window.new()
	load_confirmation_dialog.title = tr("continue_game_title")
	load_confirmation_dialog.size = Vector2i(500, 450)
	load_confirmation_dialog.unresizable = true
	load_confirmation_dialog.transient = true
	load_confirmation_dialog.exclusive = true
	load_confirmation_dialog.wrap_controls = true

	# Apply consistent brown/gold theme
	var dialog_theme = load("res://assets/styles/confirmation_dialog_theme.tres")
	if dialog_theme:
		load_confirmation_dialog.theme = dialog_theme

	# Create main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 10)

	# Add margin around content
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 15)
	margin.add_theme_constant_override("margin_right", 15)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_bottom", 15)
	margin.add_child(main_container)

	# Header label showing save info
	var header_label = Label.new()
	header_label.name = "HeaderLabel"
	header_label.text = tr("continue_dialog_header")
	header_label.add_theme_font_size_override("font_size", 18)
	header_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.6))
	main_container.add_child(header_label)

	# Day label
	var day_label = Label.new()
	day_label.name = "DayLabel"
	day_label.text = tr("continue_dialog_day").format({"day": 1})
	main_container.add_child(day_label)

	# Separator
	var sep = HSeparator.new()
	main_container.add_child(sep)

	# Narrative choice display component
	var choice_display_scene = load("res://scenes/ui/narrative_choice_display.tscn")
	if choice_display_scene:
		narrative_choice_display = choice_display_scene.instantiate()
		narrative_choice_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
		main_container.add_child(narrative_choice_display)

	# Button container
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_theme_constant_override("separation", 20)

	var continue_button = Button.new()
	continue_button.name = "ContinueButton"
	continue_button.text = tr("continue_dialog_continue")
	continue_button.custom_minimum_size = Vector2(120, 40)
	continue_button.pressed.connect(_on_load_game_confirmed)

	var cancel_button = Button.new()
	cancel_button.name = "CancelButton"
	cancel_button.text = tr("continue_dialog_cancel")
	cancel_button.custom_minimum_size = Vector2(120, 40)
	cancel_button.pressed.connect(_on_load_dialog_cancelled)

	button_container.add_child(continue_button)
	button_container.add_child(cancel_button)
	main_container.add_child(button_container)

	load_confirmation_dialog.add_child(margin)
	add_child(load_confirmation_dialog)

	# Hide the popup initially - Windows are visible by default in Godot 4
	load_confirmation_dialog.hide()

	# Add juicy hover effects to buttons
	_setup_continue_dialog_button_effects.call_deferred()

	# Connect close request
	load_confirmation_dialog.close_requested.connect(_on_load_dialog_cancelled)


## Apply juicy hover effects to all buttons in a dialog
func _setup_dialog_button_effects(dialog: AcceptDialog) -> void:
	# Configuration for dialog button hover effects - subtle wiggle
	var hover_config = {
		"hover_scale": Vector2(1.03, 1.03),
		"hover_time": 0.1,
		"float_height": 2.0,  # Subtle float
		"float_duration": 0.8,
		"bounce_factor": 0.8,
		"damping": 0.85,
		"wiggle_enabled": true,
		"wiggle_angle": 1.5,  # Subtle wiggle angle
		"wiggle_speed": 10.0
	}

	# Apply effects to OK button
	var ok_button = dialog.get_ok_button()
	if ok_button:
		JuicyButtons.setup_hover(ok_button, hover_config)

	# Apply effects to Cancel button (if it's a ConfirmationDialog)
	if dialog is ConfirmationDialog:
		var cancel_button = dialog.get_cancel_button()
		if cancel_button:
			JuicyButtons.setup_hover(cancel_button, hover_config)

	# Apply effects to any custom buttons
	for child in dialog.get_children():
		if child is Button and child != ok_button:
			if dialog is ConfirmationDialog and child == dialog.get_cancel_button():
				continue  # Already handled
			JuicyButtons.setup_hover(child, hover_config)


func _show_load_confirmation():
	# Get save data to display
	var save_data = {}
	if SaveManager:
		save_data = SaveManager.load_game_state()

	if save_data.is_empty():
		# No save data, just load directly
		load_game_scene()
		return

	var shift = save_data.get("shift", 1)
	var narrative_choices = save_data.get("narrative_choices", {})

	# Update the day label
	var margin = load_confirmation_dialog.get_child(0)
	var main_container = margin.get_child(0)
	var day_label = main_container.get_node("DayLabel")
	if day_label:
		day_label.text = tr("continue_dialog_day").format({"day": shift})

	# Update the narrative choice display
	if narrative_choice_display:
		narrative_choice_display.display_choices(narrative_choices, shift)

	# Show the dialog centered
	load_confirmation_dialog.popup_centered()


## Setup juicy hover effects for continue dialog buttons
func _setup_continue_dialog_button_effects() -> void:
	var hover_config = {
		"hover_scale": Vector2(1.03, 1.03),
		"hover_time": 0.1,
		"float_height": 2.0,
		"float_duration": 0.8,
		"bounce_factor": 0.8,
		"damping": 0.85,
		"wiggle_enabled": true,
		"wiggle_angle": 1.5,
		"wiggle_speed": 10.0
	}

	var margin = load_confirmation_dialog.get_child(0)
	if not margin:
		return
	var main_container = margin.get_child(0)
	if not main_container:
		return

	var continue_btn = main_container.get_node_or_null("ContinueButton")
	var cancel_btn = main_container.get_node_or_null("CancelButton")

	# Buttons are in a button container at the end
	for child in main_container.get_children():
		if child is HBoxContainer:
			for button in child.get_children():
				if button is Button:
					JuicyButtons.setup_hover(button, hover_config)


## Handle cancel button or window close
func _on_load_dialog_cancelled() -> void:
	load_confirmation_dialog.hide()


func _on_load_game_confirmed():
	load_confirmation_dialog.hide()
	if GameStateManager:
		GameStateManager.switch_game_mode("story")
	load_game_scene()


func _setup_feedback_menu():
	"""Setup the feedback menu"""
	# Load the feedback menu scene
	var feedback_scene = load("res://scenes/menus/main_menu/feedback_menu.tscn")
	if feedback_scene:
		feedback_menu = feedback_scene.instantiate()
		add_child(feedback_menu)
		feedback_menu.z_index = 100  # Ensure it's on top

		# Connect signals
		feedback_menu.back_pressed.connect(_on_feedback_back_pressed)
		feedback_menu.feedback_submitted.connect(_on_feedback_submitted)


func _on_feedback_button_pressed():
	"""Show the feedback menu"""
	await JuicyButtons.setup_button(%FeedbackButton2)
	if feedback_menu:
		feedback_menu.show()
		# Hide menu buttons while showing feedback
		$MenuContainer/MenuButtonsMargin.hide()


func _on_feedback_back_pressed():
	"""Hide the feedback menu and show main menu buttons"""
	if feedback_menu:
		feedback_menu.hide()
	$MenuContainer/MenuButtonsMargin.show()


func _on_feedback_submitted():
	"""Handle successful feedback submission"""
	# Feedback menu will auto-hide after 2 seconds, just show menu buttons
	await get_tree().create_timer(2.0).timeout
	$MenuContainer/MenuButtonsMargin.show()


func intro_done():
	animation_state_machine.travel("OpenMainMenu")


func _is_in_intro():
	return animation_state_machine.get_current_node() == "Intro"


func _event_is_mouse_button_released(event: InputEvent):
	return event is InputEventMouseButton and not event.is_pressed()


func _event_skips_intro(event: InputEvent):
	return (
		event.is_action_released("ui_accept")
		or event.is_action_released("ui_select")
		or event.is_action_released("ui_cancel")
		or _event_is_mouse_button_released(event)
	)


func _open_sub_menu(menu):
	super._open_sub_menu(menu)
	animation_state_machine.travel("OpenSubMenu")


func _close_sub_menu():
	super._close_sub_menu()
	animation_state_machine.travel("OpenMainMenu")


func _setup_level_select():
	if level_select_packed_scene != null:
		level_select_scene = level_select_packed_scene.instantiate()
		level_select_scene.hide()
		%LevelSelectContainer.call_deferred("add_child", level_select_scene)
		if level_select_scene.has_signal("level_selected"):
			level_select_scene.connect("level_selected", load_game_scene)
		if level_select_scene.has_signal("back_pressed"):
			level_select_scene.connect("back_pressed", _close_sub_menu)


func _input(event):
	if _is_in_intro() and _event_skips_intro(event):
		intro_done()
		return
	super._input(event)


# Musical intervals (simplified selection)
var musical_intervals = {
	"original": 1.0,  # Original pitch
	"major_third_down": 0.8,  # More somber
	"major_third_up": 1.25,  # Brighter feel
	"fifth_down": 0.67,  # Much darker
	"fifth_up": 1.5  # Brighter, heroic
}

# Current tracks
var bgm_tracks = []
var current_track_index = 0


func _setup_game_buttons():
	super._setup_game_buttons()
	# Show continue only if there's a game state and player has progressed past Day 0
	if GameState.has_game_state() and GameState.get_current_level() > 0:
		%ContinueGameButton.show()
	# Always show level select if the scene is available
	if level_select_packed_scene != null:
		%LevelSelectButton.show()


func _setup_keyboard_navigation():
	# Override for two-row button layout
	var top_row = get_node_or_null("MenuContainer/MenuButtonsMargin/MenuButtonsContainer/MenuButtonsBoxContainer/TopRowContainer")
	var bottom_row = get_node_or_null("%BottomRowContainer")

	if not top_row or not bottom_row:
		super._setup_keyboard_navigation()
		return

	# Get visible buttons from each row
	var top_buttons: Array[Button] = []
	var bottom_buttons: Array[Button] = []

	for child in top_row.get_children():
		if child is Button and child.visible:
			top_buttons.append(child)
			child.focus_mode = Control.FOCUS_ALL

	for child in bottom_row.get_children():
		if child is Button and child.visible:
			bottom_buttons.append(child)
			child.focus_mode = Control.FOCUS_ALL

	# Setup navigation for top row
	for i in top_buttons.size():
		var button = top_buttons[i]
		# Left/Right within row (wrap around)
		var prev_idx = i - 1 if i > 0 else top_buttons.size() - 1
		var next_idx = i + 1 if i < top_buttons.size() - 1 else 0
		button.focus_neighbor_left = top_buttons[prev_idx].get_path()
		button.focus_neighbor_right = top_buttons[next_idx].get_path()
		# Up wraps to bottom row, Down goes to bottom row
		var corresponding_bottom = mini(i, bottom_buttons.size() - 1)
		button.focus_neighbor_top = bottom_buttons[corresponding_bottom].get_path()
		button.focus_neighbor_bottom = bottom_buttons[corresponding_bottom].get_path()

	# Setup navigation for bottom row
	for i in bottom_buttons.size():
		var button = bottom_buttons[i]
		# Left/Right within row (wrap around)
		var prev_idx = i - 1 if i > 0 else bottom_buttons.size() - 1
		var next_idx = i + 1 if i < bottom_buttons.size() - 1 else 0
		button.focus_neighbor_left = bottom_buttons[prev_idx].get_path()
		button.focus_neighbor_right = bottom_buttons[next_idx].get_path()
		# Up goes to top row, Down wraps to top row
		var corresponding_top = mini(i, top_buttons.size() - 1)
		button.focus_neighbor_top = top_buttons[corresponding_top].get_path()
		button.focus_neighbor_bottom = top_buttons[corresponding_top].get_path()

	# Set initial focus to first visible button
	if top_buttons.size() > 0:
		_set_initial_focus.call_deferred(top_buttons[0])


func _set_initial_focus(button: Button):
	if get_viewport().gui_get_focus_owner() == null:
		button.grab_focus()


func _on_continue_game_button_pressed():
	# Show confirmation dialog with save info before loading
	_show_load_confirmation()


func _on_level_select_button_pressed():
	_open_sub_menu(level_select_scene)
	# Hide the parent's back button since level select has its own centered back button
	%BackButton.hide()


func _on_steam_button_pressed() -> void:
	await JuicyButtons.setup_button(%SteamButton, "https://store.steampowered.com/developer/lostrabbitdigital")


func _on_twitch_button_pressed() -> void:
	await JuicyButtons.setup_button(%TwitchButton, "")
	# Open the Twitch config panel via TwitchIntegrationManager
	if TwitchIntegrationManager:
		TwitchIntegrationManager.show_config_panel()


func load_tracks():
	# Replace with your actual music tracks
	bgm_tracks = [
		"res://assets/music/ambient_3_eternal_main.mp3",
		"res://assets/music/ambient_concern_main.mp3",
		"res://assets/music/ambient_faded_defeat_main_menu.mp3",
		"res://assets/music/ambient_nothingness_main.mp3",
		"res://assets/music/ambient_sadness_main.mp3"
	]


func play_with_pitch_variation(interval_name: String = "original"):
	# Default to original if invalid interval name provided
	if !musical_intervals.has(interval_name):
		interval_name = "original"

	var pitch = musical_intervals[interval_name]

	# Apply pitch shift
	bgm_player.pitch_scale = pitch

	# Adjust volume to maintain perceived loudness (optional)
	bgm_player.volume_db = -3 * log(pitch) / log(2)

	# If not already playing, start playback
	if !bgm_player.playing:
		play_current_track()



func play_random_pitch_variation():
	# Select a random interval
	var keys = musical_intervals.keys()
	var random_interval = keys[randi() % keys.size()]
	play_with_pitch_variation(random_interval)


func next_track_with_random_pitch():
	# Move to next track
	current_track_index = (current_track_index + 1) % bgm_tracks.size()

	# Play with random pitch variation
	play_random_pitch_variation()


func play_current_track():
	if bgm_tracks.size() > 0:
		var track = load(bgm_tracks[current_track_index])
		if track:
			bgm_player.stream = track
			bgm_player.play()
