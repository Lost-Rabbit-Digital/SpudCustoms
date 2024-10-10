extends Node

@onready var bgm_player = $"AudioStreamPlayer2D (BGM)"

const DEFAULT_VOLUME_PERCENT = 40.0

var bgm_tracks = [
	"res://assets/music/ambient_nothingness_main_ovani_sound.mp3",
	"res://assets/music/ambient_vol3_defeat_main_ovani_sound.mp3",
	"res://assets/music/ambient_vol3_peace_main_ovani_sound.mp3",
	"res://assets/music/horror_fog_main_ovani_sound.mp3"
]

func _ready():
	set_bgm_volume(DEFAULT_VOLUME_PERCENT)
	play_random_bgm()

func set_bgm_volume(percent):
	# Convert percentage to decibels
	var volume_db = linear_to_db(percent / 100.0)
	bgm_player.volume_db = volume_db
	print("BGM volume set to ", percent, "% (", volume_db, " dB)")

func play_random_bgm():
	# select random track from bgm_tracks
	var random_track = bgm_tracks[randi() % bgm_tracks.size()]
	
	# load and set audio
	var audio_stream = load(random_track)
	if audio_stream: 
		bgm_player.stream = audio_stream
		bgm_player.play()
		print("Now playing: ", random_track)
	else: 
		print("Failed to load audio", random_track)
	
func _on_AudioStreamPlayer2D_BGM_finished():
	play_random_bgm()
