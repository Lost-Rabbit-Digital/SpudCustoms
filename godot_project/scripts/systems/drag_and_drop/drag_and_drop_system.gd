extends Node
class_name DragAndDropSystem

# Signals
signal item_dragged(item)
signal item_dropped(item, drop_zone)
signal item_opened(item)
signal item_closed(item)

# Configuration
const PASSPORT_Z_INDEX = 0

# State tracking
var draggable_items = []
var dragged_item = null
var drag_offset = Vector2()
var document_was_closed = false

# Drop zone references
var inspection_table: Node2D
var suspect_panel: Node2D
var suspect: Node2D

# Sound state tracking
var close_sound_played = false
var open_sound_played = false

# Audio
var audio_player: AudioStreamPlayer2D

# Custom cursor references
var default_cursor_texture = preload("res://assets/cursor/cursor_default.png")
var hover_cursor_texture = preload("res://assets/cursor/cursor_hover.png")
var grab_cursor_texture = preload("res://assets/cursor/cursor_grab.png")
var click_cursor_texture = preload("res://assets/cursor/cursor_click.png")
var target_cursor_texture = preload("res://assets/cursor/cursor_target.png")

# Initialize the system
func initialize(config: Dictionary):
	# Set references from configuration
	inspection_table = config.get("inspection_table")
	suspect_panel = config.get("suspect_panel")
	suspect = config.get("suspect")
	audio_player = config.get("audio_player")
	
	# Register draggable items
	register_draggable_items(config.get("draggable_items", []))

# Register draggable items
func register_draggable_items(items: Array):
	draggable_items = items
	# Set initial z-index for all items
	for item in draggable_items:
		if is_instance_valid(item):
			item.z_index = PASSPORT_Z_INDEX
		else:
			push_warning("Invalid draggable item provided")

# Register a single draggable item
func register_draggable_item(item: Node2D):
	if is_instance_valid(item):
		draggable_items.append(item)
		item.z_index = PASSPORT_Z_INDEX
	else:
		push_warning("Invalid draggable item provided")

# Remove a draggable item
func unregister_draggable_item(item: Node2D):
	if item in draggable_items:
		draggable_items.erase(item)

# Handle mouse input events
func handle_input_event(event: InputEvent, mouse_pos: Vector2) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				return _handle_mouse_press(mouse_pos)
			else:
				return _handle_mouse_release(mouse_pos)
	elif event is InputEventMouseMotion and dragged_item:
		_update_dragged_item_position(mouse_pos)
		return true
		
	return false

# Handle mouse press
func _handle_mouse_press(mouse_pos: Vector2) -> bool:
	if dragged_item == null:
		dragged_item = find_topmost_item_at(mouse_pos)
		if dragged_item:
			# Reset document_was_closed flag for new drag
			document_was_closed = false
			
			drag_offset = mouse_pos - dragged_item.global_position
			
			# Get drop zone before starting drag
			var current_zone = identify_drop_zone(mouse_pos)
			
			# If document is being picked up from inspection table, close it
			if current_zone == "inspection_table" and is_openable_document(dragged_item):
				emit_signal("item_closed", dragged_item)
				
			emit_signal("item_dragged", dragged_item)
			return true
	return false

# Handle mouse release
func _handle_mouse_release(mouse_pos: Vector2) -> bool:
	if dragged_item:
		var drop_zone = identify_drop_zone(mouse_pos)
		emit_signal("item_dropped", dragged_item, drop_zone)
		
		# Reset document_was_closed flag
		document_was_closed = false
		
		# Handle specific item drop logic
		if dragged_item.name == "Passport":
			_handle_passport_drop(mouse_pos)
		elif dragged_item.name == "Guide":
			_handle_guide_drop(mouse_pos)
		elif dragged_item.name == "LawReceipt":
			_handle_receipt_drop(mouse_pos)
			
		dragged_item = null
		return true
	return false

func _update_dragged_item_position(mouse_pos: Vector2):
	if dragged_item:
		# Store previous position to check if we're leaving the table
		var previous_position = dragged_item.global_position
		var was_on_table = inspection_table and inspection_table.get_rect().has_point(inspection_table.to_local(previous_position))
		
		# Update position
		dragged_item.global_position = mouse_pos - drag_offset
		
		# Check if document is leaving the inspection table
		var is_on_table = inspection_table and inspection_table.get_rect().has_point(inspection_table.to_local(dragged_item.global_position))
		
		# If document was on table but no longer is, close it (only once)
		if was_on_table and !is_on_table and !document_was_closed and is_openable_document(dragged_item):
			emit_signal("item_closed", dragged_item)
			document_was_closed = true

# Check if item is a document that can be opened/closed
func is_openable_document(item: Node2D) -> bool:
	return item and (item.name == "Passport" or 
					item.name == "Guide" or 
					item.name == "LawReceipt")

# Find the topmost draggable item at the given position
func find_topmost_item_at(pos: Vector2) -> Node2D:
	var topmost_item = null
	var highest_z = -1
	
	for item in draggable_items:
		if item.visible and item.get_rect().has_point(item.to_local(pos)):
			if item.z_index > highest_z:
				highest_z = item.z_index
				topmost_item = item
	
	return topmost_item

# Identify what drop zone the position is over
func identify_drop_zone(pos: Vector2) -> String:
	if inspection_table and inspection_table.get_rect().has_point(inspection_table.to_local(pos)):
		return "inspection_table"
	elif suspect_panel and suspect_panel.get_rect().has_point(suspect_panel.to_local(pos)):
		return "suspect_panel"
	elif suspect and suspect.get_rect().has_point(suspect.to_local(pos)):
		return "suspect"
	return "none"

# Process cursor updates
func process_cursor(mouse_pos: Vector2, border_runner_enabled: bool, missile_zone_check_callback: Callable):
	if dragged_item:
		update_cursor("grab")
	else:
		var hovered_item = find_topmost_item_at(mouse_pos)
		if hovered_item:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				update_cursor("grab")
			else:
				update_cursor("hover")
		elif border_runner_enabled and missile_zone_check_callback.call(mouse_pos):
			update_cursor("target")
		else:
			update_cursor("default")

# Update cursor appearance
func update_cursor(type: String):
	match type:
		"default":
			Input.set_custom_mouse_cursor(default_cursor_texture, Input.CURSOR_ARROW, Vector2(0, 0))
		"hover":
			Input.set_custom_mouse_cursor(hover_cursor_texture, Input.CURSOR_POINTING_HAND, Vector2(0, 0))
		"grab":
			Input.set_custom_mouse_cursor(grab_cursor_texture, Input.CURSOR_DRAG, Vector2(0, 0))
		"click":
			Input.set_custom_mouse_cursor(click_cursor_texture, Input.CURSOR_POINTING_HAND, Vector2(0, 0))
		"target":
			Input.set_custom_mouse_cursor(target_cursor_texture, Input.CURSOR_CROSS, Vector2(0, 0))

# Get the highest z-index among draggable items
func get_highest_z_index() -> int:
	var highest = 0
	for item in draggable_items:
		highest = max(highest, item.z_index)
	return highest

# === Specific item handlers ===

# Handle passport drop
func _handle_passport_drop(mouse_pos: Vector2):
	var drop_zone = identify_drop_zone(mouse_pos)
	if drop_zone == "inspection_table":
		# Logic to open passport
		emit_signal("item_opened", dragged_item)
	elif drop_zone == "suspect_panel" or drop_zone == "suspect":
		# Logic to close passport
		emit_signal("item_closed", dragged_item)

# Handle guide drop
func _handle_guide_drop(mouse_pos: Vector2):
	var drop_zone = identify_drop_zone(mouse_pos)
	if drop_zone == "inspection_table":
		# Logic to open guide
		emit_signal("item_opened", dragged_item)
	elif drop_zone == "suspect_panel" or drop_zone == "suspect":
		# Logic to close guide
		emit_signal("item_closed", dragged_item)

# Handle receipt drop
func _handle_receipt_drop(mouse_pos: Vector2):
	var drop_zone = identify_drop_zone(mouse_pos)
	if drop_zone == "inspection_table":
		# Logic to open receipt
		emit_signal("item_opened", dragged_item)
	elif drop_zone == "suspect_panel" or drop_zone == "suspect":
		# Logic to close receipt
		emit_signal("item_closed", dragged_item)

# Play the open document sound
func play_open_sound():
	if not open_sound_played and audio_player:
		audio_player.stream = preload("res://assets/audio/passport_sfx/open_passport_audio.mp3")
		audio_player.play()
		open_sound_played = true
		close_sound_played = false

# Play the close document sound
func play_close_sound():
	if not close_sound_played and audio_player:
		audio_player.stream = preload("res://assets/audio/passport_sfx/close_passport_audio.mp3")
		audio_player.play()
		close_sound_played = true
		open_sound_played = false

# Reset sound flags
func reset_sound_flags():
	close_sound_played = false
	open_sound_played = false

# Get current dragged item
func get_dragged_item() -> Node2D:
	return dragged_item

# Check if any item is being dragged
func is_dragging() -> bool:
	return dragged_item != null
