class_name CitationNoteManager
extends CanvasLayer
## Manages citation notes from Supervisor Russet when strikes are given.
##
## Citation notes must be manually dismissed by dragging them to the Trash zone.
## This provides a more tangible consequence for mistakes and gives players
## a moment to read and understand their error.

signal citation_dismissed(reason: String)
signal all_citations_dismissed

## The container for active citation notes
var notes_container: Control = null

## The trash zone for dismissing citations
var trash_zone: Control = null

## Active citation notes
var _active_notes: Array[Control] = []

## Whether any citation is currently being dragged
var _is_dragging: bool = false

## The note currently being dragged
var _dragged_note: Control = null

## Drag offset from note origin
var _drag_offset: Vector2 = Vector2.ZERO

## Preloaded supervisor portrait for notes
const RUSSET_PORTRAIT = preload("res://assets/narrative/supervisor_portrait.png")


func _ready() -> void:
	layer = 95  # Above game, below dialogue
	_setup_ui()
	_connect_signals()


func _setup_ui() -> void:
	"""Create the UI elements for citation notes."""
	# Create main container
	var main_container = Control.new()
	main_container.name = "CitationContainer"
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(main_container)

	# Notes container (center-ish)
	notes_container = Control.new()
	notes_container.name = "NotesContainer"
	notes_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	notes_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_container.add_child(notes_container)

	# Trash zone (lower right)
	_create_trash_zone(main_container)


func _create_trash_zone(parent: Control) -> void:
	"""Create the trash zone where citations are dismissed."""
	trash_zone = Panel.new()
	trash_zone.name = "TrashZone"
	trash_zone.custom_minimum_size = Vector2(100, 80)
	trash_zone.visible = false  # Hidden when no citations

	# Position in lower right
	trash_zone.anchor_left = 1.0
	trash_zone.anchor_right = 1.0
	trash_zone.anchor_top = 1.0
	trash_zone.anchor_bottom = 1.0
	trash_zone.offset_left = -120
	trash_zone.offset_right = -20
	trash_zone.offset_top = -100
	trash_zone.offset_bottom = -20

	# Style the trash zone
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.4, 0.2, 0.5, 0.8)  # Purple background
	style.border_color = Color(0.6, 0.3, 0.7)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	trash_zone.add_theme_stylebox_override("panel", style)

	# Add label
	var label = Label.new()
	label.text = "TRASH"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 14)
	trash_zone.add_child(label)

	parent.add_child(trash_zone)


func _connect_signals() -> void:
	"""Connect to relevant events."""
	if EventBus:
		EventBus.strike_changed.connect(_on_strike_changed)


func _on_strike_changed(new_strikes: int, reason: String) -> void:
	"""Handle strike change events - show citation note."""
	if new_strikes > 0 and not reason.is_empty():
		show_citation(reason)


func show_citation(reason: String) -> void:
	"""Display a citation note that must be dismissed."""
	var note = _create_citation_note(reason)
	notes_container.add_child(note)
	_active_notes.append(note)

	# Show trash zone
	trash_zone.visible = true

	# Animate note appearing
	note.modulate.a = 0.0
	note.scale = Vector2(0.8, 0.8)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(note, "modulate:a", 1.0, 0.3)
	tween.tween_property(note, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _create_citation_note(reason: String) -> Control:
	"""Create a draggable citation note."""
	var note = PanelContainer.new()
	note.name = "CitationNote"
	note.custom_minimum_size = Vector2(280, 160)

	# Position note in center of screen with slight random offset
	var viewport_size = get_viewport().get_visible_rect().size
	note.position = Vector2(
		viewport_size.x / 2 - 140 + randf_range(-30, 30),
		viewport_size.y / 2 - 80 + randf_range(-20, 20)
	)

	# Style the note
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.92, 0.85)  # Cream/paper color
	style.border_color = Color(0.6, 0.5, 0.4)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 5
	style.shadow_offset = Vector2(3, 3)
	note.add_theme_stylebox_override("panel", style)

	# Content container
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)

	# Header
	var header = Label.new()
	header.text = "OFFICIAL CITATION"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_color_override("font_color", Color(0.6, 0.1, 0.1))
	header.add_theme_font_size_override("font_size", 16)
	content.add_child(header)

	# Separator
	var sep = HSeparator.new()
	content.add_child(sep)

	# From line
	var from_line = Label.new()
	from_line.text = "From: Supervisor Russet"
	from_line.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
	from_line.add_theme_font_size_override("font_size", 12)
	content.add_child(from_line)

	# Reason
	var reason_label = Label.new()
	reason_label.text = reason
	reason_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reason_label.custom_minimum_size = Vector2(260, 60)
	reason_label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	reason_label.add_theme_font_size_override("font_size", 13)
	content.add_child(reason_label)

	# Instruction
	var instruction = Label.new()
	instruction.text = "[Drag to Trash to dismiss]"
	instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	instruction.add_theme_font_size_override("font_size", 10)
	content.add_child(instruction)

	note.add_child(content)

	# Store reason in metadata
	note.set_meta("reason", reason)

	return note


func _input(event: InputEvent) -> void:
	if _active_notes.is_empty():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_try_start_drag(event.position)
			else:
				_end_drag()

	elif event is InputEventMouseMotion and _is_dragging:
		_update_drag(event.position)


func _try_start_drag(mouse_pos: Vector2) -> void:
	"""Try to start dragging a note at the given position."""
	for note in _active_notes:
		var note_rect = Rect2(note.global_position, note.size)
		if note_rect.has_point(mouse_pos):
			_is_dragging = true
			_dragged_note = note
			_drag_offset = note.position - mouse_pos
			note.z_index = 10  # Bring to front
			break


func _update_drag(mouse_pos: Vector2) -> void:
	"""Update the position of the dragged note."""
	if _dragged_note:
		_dragged_note.position = mouse_pos + _drag_offset

		# Highlight trash zone when hovering
		if _is_over_trash(mouse_pos):
			_highlight_trash_zone(true)
		else:
			_highlight_trash_zone(false)


func _end_drag() -> void:
	"""End dragging and check if note was dropped on trash."""
	if not _is_dragging or not _dragged_note:
		_is_dragging = false
		_dragged_note = null
		return

	var mouse_pos = get_viewport().get_mouse_position()

	if _is_over_trash(mouse_pos):
		_dismiss_note(_dragged_note)
	else:
		_dragged_note.z_index = 0

	_highlight_trash_zone(false)
	_is_dragging = false
	_dragged_note = null


func _is_over_trash(pos: Vector2) -> bool:
	"""Check if position is over the trash zone."""
	if not trash_zone or not trash_zone.visible:
		return false

	var trash_rect = Rect2(trash_zone.global_position, trash_zone.size)
	return trash_rect.has_point(pos)


func _highlight_trash_zone(highlight: bool) -> void:
	"""Highlight or unhighlight the trash zone."""
	if not trash_zone:
		return

	var style = trash_zone.get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		var new_style = style.duplicate()
		if highlight:
			new_style.bg_color = Color(0.6, 0.3, 0.7, 0.9)
			new_style.border_color = Color.WHITE
		else:
			new_style.bg_color = Color(0.4, 0.2, 0.5, 0.8)
			new_style.border_color = Color(0.6, 0.3, 0.7)
		trash_zone.add_theme_stylebox_override("panel", new_style)


func _dismiss_note(note: Control) -> void:
	"""Dismiss a citation note with animation."""
	var reason = note.get_meta("reason", "Unknown")

	# Remove from active notes
	_active_notes.erase(note)

	# Animate dismissal
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(note, "modulate:a", 0.0, 0.2)
	tween.tween_property(note, "scale", Vector2(0.5, 0.5), 0.2)
	tween.chain().tween_callback(note.queue_free)

	# Play sound
	_play_dismiss_sound()

	# Emit signal
	citation_dismissed.emit(reason)

	# Hide trash zone if no more notes
	if _active_notes.is_empty():
		trash_zone.visible = false
		all_citations_dismissed.emit()


func _play_dismiss_sound() -> void:
	"""Play a paper crumpling sound when dismissing citation."""
	var audio = AudioStreamPlayer.new()
	audio.stream = preload("res://assets/audio/paper/paper 1.wav")
	audio.volume_db = -5.0
	audio.bus = "SFX"
	add_child(audio)
	audio.play()
	audio.finished.connect(audio.queue_free)


## Check if any citations are active (blocking game progress)
func has_active_citations() -> bool:
	return not _active_notes.is_empty()


## Force dismiss all citations (for debug/skip)
func dismiss_all() -> void:
	for note in _active_notes.duplicate():
		_dismiss_note(note)
