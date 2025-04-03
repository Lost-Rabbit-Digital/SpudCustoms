extends MainMenu

@export var level_select_packed_scene: PackedScene

var level_select_scene
var animation_state_machine : AnimationNodeStateMachinePlayback
@onready var version_label = $VersionMargin/VersionContainer/VersionLabel
@onready var bgm_player = $BackgroundMusicPlayer


func load_game_scene():
	GameState.start_game()
	SceneLoader.load_scene(story_game_scene_path)

func new_game():
	await JuicyButtons.setup_button(%NewGameButton)
	GlobalState.reset()
	load_game_scene()

func load_endless_scene():
	SceneLoader.load_scene(endless_game_scene_path)

func new_endless_game():
	load_endless_scene()

func intro_done():
	animation_state_machine.travel("OpenMainMenu")

func _is_in_intro():
	return animation_state_machine.get_current_node() == "Intro"

func _event_is_mouse_button_released(event : InputEvent):
	return event is InputEventMouseButton and not event.is_pressed()

func _event_skips_intro(event : InputEvent):
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel") or \
		_event_is_mouse_button_released(event)

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
	"original": 1.0,        # Original pitch
	"major_third_down": 0.8, # More somber
	"major_third_up": 1.25,  # Brighter feel
	"fifth_down": 0.67,      # Much darker
	"fifth_up": 1.5          # Brighter, heroic
}

# Current tracks
var bgm_tracks = []
var current_track_index = 0

func _ready():
	load_tracks()
	# Play with original pitch by default
	next_track_with_random_pitch()
	#play_with_pitch_variation("original")
	super._ready()
	_setup_level_select()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")
	
func _setup_game_buttons():
	super._setup_game_buttons()
	if GameState.has_game_state():
		%ContinueGameButton.show()
		if level_select_packed_scene != null and GameState.get_max_level_reached() > 0:
			%LevelSelectButton.show()

func _on_continue_game_button_pressed():
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
