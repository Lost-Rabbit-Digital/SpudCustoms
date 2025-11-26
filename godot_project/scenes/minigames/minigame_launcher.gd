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
	# Add more minigames here:
	# "stamp_sorting": preload("res://scenes/minigames/games/stamp_sorting/stamp_sorting.tscn"),
	# "fingerprint_match": preload("res://scenes/minigames/games/fingerprint_match/fingerprint_match.tscn"),
}

## Currently active minigame instance
var _active_minigame: MinigameContainer = null

## Queue of minigames to launch (for chaining)
var _minigame_queue: Array[Dictionary] = []


func _ready() -> void:
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


func _on_minigame_launch_requested(minigame_type: String, config: Dictionary) -> void:
	launch(minigame_type, config)


func _on_minigame_completed(result: Dictionary) -> void:
	print("[MinigameLauncher] Minigame completed: ", result)

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


## Launch a random minigame (good for bonus rounds)
func launch_random(config: Dictionary = {}) -> bool:
	var types = MINIGAMES.keys()
	if types.is_empty():
		return false

	var random_type = types[randi() % types.size()]
	return launch(random_type, config)


## Cancel any active minigame
func cancel_active() -> void:
	if _active_minigame:
		_active_minigame._on_skip_pressed()
