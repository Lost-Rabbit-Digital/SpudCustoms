class_name MinigameLauncher
extends Node
## Manages launching and tracking minigames.
##
## Add this to your game scene to easily launch minigames.
## Listens to EventBus.minigame_launch_requested and handles the rest.
##
## Usage:
##   # In mainGame.gd or wherever:
##   EventBus.minigame_launch_requested.emit("document_scanner", {"elements_to_find": 5})
##
##   # Or use the launcher directly:
##   minigame_launcher.launch("document_scanner")

## Preloaded minigame scenes
const MINIGAMES = {
	"document_scanner": preload("res://scenes/minigames/games/document_scanner/document_scanner.tscn"),
	"stamp_sorting": preload("res://scenes/minigames/games/stamp_sorting/stamp_sorting.tscn"),
	"fingerprint_match": preload("res://scenes/minigames/games/fingerprint_match/fingerprint_match.tscn"),
	"code_breaker": preload("res://scenes/minigames/games/code_breaker/code_breaker.tscn"),
	"border_chase": preload("res://scenes/minigames/games/border_chase/border_chase.tscn"),
}

## Shift requirements to unlock each minigame
const MINIGAME_UNLOCK_SHIFTS = {
	"document_scanner": 1,  # Available from the start
	"stamp_sorting": 2,     # Unlocks at Shift 2
	"fingerprint_match": 3, # Unlocks at Shift 3
	"code_breaker": 4,      # Unlocks at Shift 4
	"border_chase": 5,      # Unlocks at Shift 5
}

## Currently active minigame instance
var _active_minigame: MinigameContainer = null

## Queue of minigames to launch (for chaining)
var _minigame_queue: Array[Dictionary] = []

## Audio player for minigame sounds
var _audio_player: AudioStreamPlayer = null

## Preloaded minigame sounds
var _launch_sounds = [
	preload("res://assets/audio/ui_feedback/slide whistle 1.wav"),
	preload("res://assets/audio/ui_feedback/motion_straight_air.wav"),
]
var _complete_sounds = [
	preload("res://assets/audio/ui_feedback/Task Complete Ensemble 001.wav"),
	preload("res://assets/audio/ui_feedback/Task Complete Ensemble 002.wav"),
]
var _skip_sound = preload("res://assets/audio/ui_feedback/zipper 1.wav")


func _ready() -> void:
	# Setup audio player
	_audio_player = AudioStreamPlayer.new()
	_audio_player.bus = "SFX"
	_audio_player.volume_db = -6.0
	add_child(_audio_player)
	# Connect to EventBus
	if EventBus:
		EventBus.minigame_launch_requested.connect(_on_minigame_launch_requested)


## Launch a minigame by type
func launch(minigame_type: String, config: Dictionary = {}) -> bool:
	if not MINIGAMES.has(minigame_type):
		push_error("[MinigameLauncher] Unknown minigame type: ", minigame_type)
		return false

	# If a minigame is already active, queue this one
	if _active_minigame:
		_minigame_queue.append({"type": minigame_type, "config": config})
		print("[MinigameLauncher] Queued minigame: ", minigame_type)
		return true

	# Instantiate and launch
	var minigame_scene = MINIGAMES[minigame_type]
	_active_minigame = minigame_scene.instantiate()

	# Connect signals
	_active_minigame.minigame_completed.connect(_on_minigame_completed)
	_active_minigame.minigame_skipped.connect(_on_minigame_skipped)

	# Add to scene tree
	get_tree().root.add_child(_active_minigame)

	# Play launch sound
	_play_launch_sound()

	# Start the minigame
	_active_minigame.start(config)

	print("[MinigameLauncher] Launched minigame: ", minigame_type)
	return true


## Check if a minigame is currently active
func is_minigame_active() -> bool:
	return _active_minigame != null


## Get the active minigame type (or empty string if none)
func get_active_minigame_type() -> String:
	if _active_minigame:
		return _active_minigame.minigame_type
	return ""


## Check if a minigame is unlocked based on current shift
func is_minigame_unlocked(minigame_type: String, current_shift: int = -1) -> bool:
	if not MINIGAME_UNLOCK_SHIFTS.has(minigame_type):
		return false

	# Use GameStateManager if not specified
	if current_shift < 0:
		current_shift = GameStateManager.get_shift() if GameStateManager else 1

	return current_shift >= MINIGAME_UNLOCK_SHIFTS[minigame_type]


## Get list of all unlocked minigame types
func get_unlocked_minigames(current_shift: int = -1) -> Array[String]:
	if current_shift < 0:
		current_shift = GameStateManager.get_shift() if GameStateManager else 1

	var unlocked: Array[String] = []
	for minigame_type in MINIGAMES.keys():
		if is_minigame_unlocked(minigame_type, current_shift):
			unlocked.append(minigame_type)
	return unlocked


## Get the shift required to unlock a minigame
func get_unlock_shift(minigame_type: String) -> int:
	return MINIGAME_UNLOCK_SHIFTS.get(minigame_type, 999)


func _on_minigame_launch_requested(minigame_type: String, config: Dictionary) -> void:
	# Check if minigame is unlocked (unless force_launch is set)
	if not config.get("force_launch", false):
		if not is_minigame_unlocked(minigame_type):
			print("[MinigameLauncher] Minigame '%s' is locked (requires shift %d)" % [
				minigame_type, get_unlock_shift(minigame_type)
			])
			return
	launch(minigame_type, config)


func _on_minigame_completed(result: Dictionary) -> void:
	print("[MinigameLauncher] Minigame completed: ", result)

	# Play completion sound
	_play_complete_sound()

	# Apply score bonus if any
	if result.get("score_bonus", 0) > 0 and EventBus:
		EventBus.minigame_bonus_requested.emit(
			result.score_bonus,
			"minigame_%s" % result.get("minigame_type", "unknown")
		)

	_cleanup_active_minigame()
	_try_launch_queued()


func _on_minigame_skipped() -> void:
	print("[MinigameLauncher] Minigame skipped")

	# Play skip sound
	_play_skip_sound()

	_cleanup_active_minigame()
	_try_launch_queued()


func _cleanup_active_minigame() -> void:
	if _active_minigame:
		_active_minigame.queue_free()
		_active_minigame = null


func _try_launch_queued() -> void:
	if _minigame_queue.is_empty():
		return

	var next = _minigame_queue.pop_front()
	# Small delay before launching next
	await get_tree().create_timer(0.3).timeout
	launch(next.type, next.config)


## Launch a random unlocked minigame (good for bonus rounds)
func launch_random(config: Dictionary = {}) -> bool:
	var unlocked = get_unlocked_minigames()
	if unlocked.is_empty():
		return false

	var random_type = unlocked[randi() % unlocked.size()]
	return launch(random_type, config)


## Launch a random minigame from a specific pool of types
func launch_random_from(pool: Array[String], config: Dictionary = {}) -> bool:
	# Filter to only unlocked games
	var available: Array[String] = []
	for minigame_type in pool:
		if is_minigame_unlocked(minigame_type):
			available.append(minigame_type)

	if available.is_empty():
		return false

	var random_type = available[randi() % available.size()]
	return launch(random_type, config)


## Cancel any active minigame
func cancel_active() -> void:
	if _active_minigame:
		_active_minigame._on_skip_pressed()


## Play a sound when launching a minigame
func _play_launch_sound() -> void:
	if not _audio_player:
		return
	_audio_player.stream = _launch_sounds[randi() % _launch_sounds.size()]
	_audio_player.volume_db = -8.0
	_audio_player.pitch_scale = randf_range(0.95, 1.05)
	_audio_player.play()


## Play a sound when completing a minigame
func _play_complete_sound() -> void:
	if not _audio_player:
		return
	_audio_player.stream = _complete_sounds[randi() % _complete_sounds.size()]
	_audio_player.volume_db = -6.0
	_audio_player.pitch_scale = randf_range(0.95, 1.05)
	_audio_player.play()


## Play a sound when skipping a minigame
func _play_skip_sound() -> void:
	if not _audio_player:
		return
	_audio_player.stream = _skip_sound
	_audio_player.volume_db = -10.0
	_audio_player.pitch_scale = randf_range(0.9, 1.0)
	_audio_player.play()
