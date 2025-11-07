extends MainMenu

@export var level_select_packed_scene: PackedScene

var level_select_scene
var animation_state_machine: AnimationNodeStateMachinePlayback
var confirmation_dialog: ConfirmationDialog
var feedback_menu: Control
var feedback_button: Button
@onready var version_label = $VersionMargin/VersionContainer/VersionLabel
@onready var bgm_player = $BackgroundMusicPlayer


func _ready():
	load_tracks()
	# Play with original pitch by default
	next_track_with_random_pitch()
	#play_with_pitch_variation("original")
	super._ready()
	_setup_level_select()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")
	_setup_confirmation_dialog()
	_setup_feedback_menu()
	# Check for demo version
	if Global.build_type == "Demo Release":
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
	Global.switch_game_mode("story")
	GlobalState.reset()
	load_game_scene()


func _on_endless_button_pressed():
	await JuicyButtons.setup_button(%EndlessButton)
	print("Sending call to update game mode in Global")
	Global.switch_game_mode("score_attack")
	# Reset game state but keep high scores
	Global.reset_shift_stats()
	# Now load the score attack scene instead
	SceneLoader.load_scene("res://scenes/game_scene/score_attack_ui.tscn")


func _setup_confirmation_dialog():
	confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.title = "Start New Game"
	confirmation_dialog.dialog_text = "Starting a new game will reset your progress. Are you sure you want to continue?"
	confirmation_dialog.min_size = Vector2(400, 100)
	confirmation_dialog.dialog_hide_on_ok = true
	confirmation_dialog.get_ok_button().text = "Yes, Start New Game"
	add_child(confirmation_dialog)

	# Connect confirmation signals
	confirmation_dialog.confirmed.connect(_on_new_game_confirmed)


func _setup_feedback_menu():
	"""Setup the feedback menu and button"""
	# Load the feedback menu scene
	var feedback_scene = load("res://scenes/menus/main_menu/feedback_menu.tscn")
	if feedback_scene:
		feedback_menu = feedback_scene.instantiate()
		add_child(feedback_menu)
		feedback_menu.z_index = 100  # Ensure it's on top

		# Connect signals
		feedback_menu.back_pressed.connect(_on_feedback_back_pressed)
		feedback_menu.feedback_submitted.connect(_on_feedback_submitted)

	# Create the feedback button and add it to the menu
	feedback_button = Button.new()
	feedback_button.text = "Feedback"
	feedback_button.custom_minimum_size = Vector2(128, 40)
	feedback_button.pressed.connect(_on_feedback_button_pressed)

	# Add button to the menu buttons container (after Credits, before Exit)
	var menu_buttons = $MenuContainer/MenuButtonsMargin/MenuButtonsContainer/MenuButtonsBoxContainer
	if menu_buttons:
		# Insert before the exit button (last button)
		menu_buttons.add_child(feedback_button)
		menu_buttons.move_child(feedback_button, menu_buttons.get_child_count() - 2)


func _on_feedback_button_pressed():
	"""Show the feedback menu"""
	if feedback_menu:
		feedback_menu.show()
		# Optionally hide menu buttons while showing feedback
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


func _on_continue_game_button_pressed():
	Global.switch_game_mode("story")
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

	print("Music initiated: Interval [", interval_name.to_upper(), "] / Pitch [", pitch, "]")


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
			print("Now playing: ", bgm_tracks[current_track_index])
		else:
			print("Failed to load track: ", bgm_tracks[current_track_index])
