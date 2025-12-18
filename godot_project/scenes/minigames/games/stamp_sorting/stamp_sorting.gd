class_name StampSortingMinigame
extends MinigameContainer
## Fast-paced stamp sorting minigame!
##
## Stamps fall from the top - drag them to the correct bin (APPROVED/DENIED).
## Quick and satisfying, rewards fast decisions.
##
## Unlocks: Shift 2+

# Audio assets
var _snd_grab = preload("res://assets/audio/minigames/stamp_sorting_grab.mp3")
var _snd_drop = preload("res://assets/audio/minigames/stamp_sorting_drop.mp3")
var _snd_correct = preload("res://assets/audio/minigames/stamp_sorting_correct.mp3")
var _snd_wrong = preload("res://assets/audio/minigames/stamp_sorting_wrong.mp3")
var _snd_falling = preload("res://assets/audio/minigames/stamp_sorting_falling.mp3")

# Texture assets (preloaded for future use)
var _tex_approved_stamp = preload("res://assets/minigames/textures/stamp_sorting_approved_stamp.png")
var _tex_denied_stamp = preload("res://assets/minigames/textures/stamp_sorting_denied_stamp.png")
var _tex_bins = preload("res://assets/minigames/textures/stamp_sorting_bins.png")
var _tex_desk_background = preload("res://assets/minigames/textures/stamp_sorting_desk_background.png")
var _tex_falling_animation = preload("res://assets/minigames/textures/stamp_sorting_falling_animation.png")
var _tex_falling_animation_2 = preload("res://assets/minigames/textures/stamp_sorting_falling_animation_2.png")

## Number of stamps to sort
@export var stamps_to_sort: int = 8

## Points per correct sort
@export var points_per_correct: int = 30

## Bonus for perfect accuracy
@export var perfect_bonus: int = 150

## Speed stamps fall (pixels per second)
@export var fall_speed: float = 80.0

# Internal state
var _stamps_sorted: int = 0
var _correct_sorts: int = 0
var _current_stamp: Node2D = null
var _stamp_type: String = ""  # "approved" or "denied"
var _is_dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

# Bins
var _approved_bin: Rect2
var _denied_bin: Rect2


func _play_sound(sound: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.volume_db = volume_db
		audio_player.pitch_scale = pitch
		audio_player.play()


func _ready() -> void:
	super._ready()
	minigame_type = "stamp_sorting"
	time_limit = 20.0
	skippable = true
	reward_multiplier = 1.0

	if title_label:
		title_label.text = tr("sorting_title")
	if instruction_label:
		instruction_label.text = tr("sorting_instruction")


func _on_minigame_start(config: Dictionary) -> void:
	_stamps_sorted = 0
	_correct_sorts = 0
	_current_stamp = null

	if config.has("stamps_to_sort"):
		stamps_to_sort = config.stamps_to_sort

	_setup_minigame_scene()
	_spawn_next_stamp()


func _setup_minigame_scene() -> void:
	for child in subviewport.get_children():
		child.queue_free()

	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.15, 0.12, 0.1)
	bg.size = subviewport.size
	subviewport.add_child(bg)

	# Create bins
	var bin_width = 200
	var bin_height = 120
	var bin_y = subviewport.size.y - bin_height - 20

	# Approved bin (left, green)
	_approved_bin = Rect2(80, bin_y, bin_width, bin_height)
	var approved_visual = ColorRect.new()
	approved_visual.color = Color(0.2, 0.5, 0.2)
	approved_visual.position = _approved_bin.position
	approved_visual.size = _approved_bin.size
	subviewport.add_child(approved_visual)

	var approved_label = Label.new()
	approved_label.text = tr("sorting_approved")
	approved_label.add_theme_font_size_override("font_size", 24)
	approved_label.position = _approved_bin.position + Vector2(40, 45)
	subviewport.add_child(approved_label)

	# Denied bin (right, red)
	_denied_bin = Rect2(subviewport.size.x - bin_width - 80, bin_y, bin_width, bin_height)
	var denied_visual = ColorRect.new()
	denied_visual.color = Color(0.5, 0.2, 0.2)
	denied_visual.position = _denied_bin.position
	denied_visual.size = _denied_bin.size
	subviewport.add_child(denied_visual)

	var denied_label = Label.new()
	denied_label.text = tr("sorting_denied")
	denied_label.add_theme_font_size_override("font_size", 24)
	denied_label.position = _denied_bin.position + Vector2(55, 45)
	subviewport.add_child(denied_label)

	# Progress label
	var progress = Label.new()
	progress.name = "Progress"
	progress.add_theme_font_size_override("font_size", 20)
	progress.position = Vector2(subviewport.size.x / 2 - 50, 20)
	_update_progress_label(progress)
	subviewport.add_child(progress)


func _spawn_next_stamp() -> void:
	if _stamps_sorted >= stamps_to_sort:
		_check_completion()
		return

	# Random stamp type
	_stamp_type = "approved" if randf() > 0.5 else "denied"

	# Create stamp visual
	_current_stamp = Node2D.new()
	_current_stamp.name = "Stamp"
	_current_stamp.position = Vector2(subviewport.size.x / 2, 80)

	var stamp_rect = ColorRect.new()
	stamp_rect.size = Vector2(100, 60)
	stamp_rect.position = Vector2(-50, -30)
	stamp_rect.color = Color(0.3, 0.6, 0.3) if _stamp_type == "approved" else Color(0.6, 0.3, 0.3)
	_current_stamp.add_child(stamp_rect)

	var stamp_label = Label.new()
	stamp_label.text = tr("sorting_approved") if _stamp_type == "approved" else tr("sorting_denied")
	stamp_label.add_theme_font_size_override("font_size", 14)
	stamp_label.position = Vector2(-40, -10)
	_current_stamp.add_child(stamp_label)

	subviewport.add_child(_current_stamp)


func _process(delta: float) -> void:
	super._process(delta)

	if not _is_active or not _current_stamp or _is_dragging:
		return

	# Stamp falls slowly
	_current_stamp.position.y += fall_speed * delta

	# If stamp falls off screen, count as wrong
	if _current_stamp.position.y > subviewport.size.y + 50:
		_sort_stamp(false)


func _input(event: InputEvent) -> void:
	if not _is_active or not _current_stamp:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = _get_subviewport_mouse_pos()

		if event.pressed:
			# Check if clicking on stamp
			var stamp_rect = Rect2(_current_stamp.position - Vector2(50, 30), Vector2(100, 60))
			if stamp_rect.has_point(local_pos):
				_is_dragging = true
				_drag_offset = _current_stamp.position - local_pos
				_play_sound(_snd_grab, -5.0, randf_range(0.95, 1.05))
		else:
			if _is_dragging:
				_is_dragging = false
				_play_sound(_snd_drop, -5.0, randf_range(0.95, 1.05))
				_check_drop(local_pos)

	elif event is InputEventMouseMotion and _is_dragging:
		var local_pos = _get_subviewport_mouse_pos()
		_current_stamp.position = local_pos + _drag_offset


func _get_subviewport_mouse_pos() -> Vector2:
	var screen_pos = get_viewport().get_mouse_position()
	var container_rect = subviewport_container.get_global_rect()
	var relative_pos = (screen_pos - container_rect.position) / container_rect.size
	return relative_pos * Vector2(subviewport.size)


func _check_drop(pos: Vector2) -> void:
	var stamp_center = _current_stamp.position

	if _approved_bin.has_point(stamp_center):
		_sort_stamp(_stamp_type == "approved")
	elif _denied_bin.has_point(stamp_center):
		_sort_stamp(_stamp_type == "denied")
	# If dropped elsewhere, stamp stays where it is


func _sort_stamp(correct: bool) -> void:
	_stamps_sorted += 1
	if correct:
		_correct_sorts += 1
		# Quick feedback
		if _current_stamp:
			_current_stamp.modulate = Color.GREEN
		_play_sound(_snd_correct, 0.0, randf_range(0.98, 1.02))
	else:
		if _current_stamp:
			_current_stamp.modulate = Color.RED
		_play_sound(_snd_wrong, 0.0, randf_range(0.98, 1.02))

	# Update progress
	var progress = subviewport.get_node_or_null("Progress")
	if progress:
		_update_progress_label(progress)

	# Remove stamp after brief delay
	if _current_stamp:
		var stamp = _current_stamp
		_current_stamp = null
		await get_tree().create_timer(0.2).timeout
		if is_instance_valid(stamp):
			stamp.queue_free()

	# Spawn next or complete
	if _stamps_sorted < stamps_to_sort:
		_spawn_next_stamp()
	else:
		_check_completion()


func _update_progress_label(label: Label) -> void:
	label.text = tr("sorting_progress").format({"sorted": _stamps_sorted, "total": stamps_to_sort, "correct": _correct_sorts})


func _check_completion() -> void:
	var accuracy = float(_correct_sorts) / float(stamps_to_sort) if stamps_to_sort > 0 else 0
	var base_score = _correct_sorts * points_per_correct
	var bonus = perfect_bonus if _correct_sorts == stamps_to_sort else 0
	var total = base_score + bonus

	if instruction_label:
		if _correct_sorts == stamps_to_sort:
			instruction_label.text = tr("sorting_perfect").format({"points": total})
		else:
			instruction_label.text = tr("sorting_partial").format({"correct": _correct_sorts, "total": stamps_to_sort, "points": total})

	complete_success(total, {
		"correct": _correct_sorts,
		"total": stamps_to_sort,
		"accuracy": accuracy,
		"perfect": _correct_sorts == stamps_to_sort
	})
