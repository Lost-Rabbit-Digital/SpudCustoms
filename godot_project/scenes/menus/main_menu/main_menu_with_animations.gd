extends MainMenu

@export var level_select_packed_scene: PackedScene

var level_select_scene
var animation_state_machine: AnimationNodeStateMachinePlayback
var confirmation_dialog: ConfirmationDialog
var feedback_menu: Control
@onready var version_label = $VersionMargin/VersionContainer/VersionLabel
@onready var bgm_player = $BackgroundMusicPlayer


func _ready():
	load_tracks()
	# Play with original pitch by default
	next_track_with_random_pitch()
	super._ready()
	_setup_level_select()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")
	_setup_confirmation_dialog()
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
	# REFACTORED: Use GameStateManager
	if GameStateManager:
		GameStateManager.switch_game_mode("story")
	GlobalState.reset()
	load_game_scene()


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
	confirmation_dialog.title = "Start New Game"
	confirmation_dialog.dialog_text = "Starting a new game will reset your progress. Are you sure you want to continue?"
	confirmation_dialog.min_size = Vector2(400, 100)
	confirmation_dialog.dialog_hide_on_ok = true
	confirmation_dialog.get_ok_button().text = "Yes, Start New Game"
	var dialog_theme = load("res://assets/styles/confirmation_dialog_theme.tres")
	if dialog_theme:
		confirmation_dialog.theme = dialog_theme
	add_child(confirmation_dialog)

	# Connect confirmation signals
	confirmation_dialog.confirmed.connect(_on_new_game_confirmed)


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
	if GameState.has_game_state():
		%ContinueGameButton.show()
		if level_select_packed_scene != null and GameState.get_max_level_reached() > 0:
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
	# REFACTORED: Use GameStateManager
	if GameStateManager:
		GameStateManager.switch_game_mode("story")
	load_game_scene()


func _on_level_select_button_pressed():
	_open_sub_menu(level_select_scene)


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
