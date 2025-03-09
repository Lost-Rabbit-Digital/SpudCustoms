extends Node
class_name DragAndDropSystem

# Signals
signal item_dragged(item)
signal item_dropped(item, drop_zone)
signal item_opened(item)
signal item_closed(item)

# Configuration
const PASSPORT_Z_INDEX = 0
const DRAGGING_Z_INDEX = 100  # Higher z-index for items being dragged
const RETURN_TWEEN_DURATION = 0.3  # Duration of return animation in seconds
const TABLE_EDGE_BUFFER = 20  # Buffer distance from table edge

# State tracking
var draggable_items = []
var dragged_item = null
var drag_offset = Vector2()
var document_was_closed = false
var original_z_index = 0



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
# Register draggable items
func register_draggable_items(items: Array):
	draggable_items = items
	# Set initial z-index for all items if not already set
	for item in draggable_items:
		if is_instance_valid(item):
			if item.z_index == 0:  # Only set if not already set
				item.z_index = PASSPORT_Z_INDEX
		else:
			push_warning("Invalid draggable item provided")

# Register a single draggable item
func register_draggable_item(item: Node2D):
	if is_instance_valid(item):
		draggable_items.append(item)
		if item.z_index == 0:  # Only set if not already set
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

# In drag_and_drop_system.gd
func _handle_mouse_press(mouse_pos: Vector2) -> bool:
	if dragged_item == null:
		dragged_item = find_topmost_item_at(mouse_pos)
		if dragged_item:
			_update_dragged_item_position(mouse_pos)
			# Reset document_was_closed flag for new drag
			document_was_closed = false
			
			# Store original z-index and set to higher value while dragging
			original_z_index = dragged_item.z_index
			dragged_item.z_index = DRAGGING_Z_INDEX  # Higher z-index while dragging
			
			# Get drop zone before starting drag
			var current_zone = identify_drop_zone(mouse_pos)
			
			# If document is being picked up from inspection table, close it
			if current_zone == "inspection_table" and is_openable_document(dragged_item):
				emit_signal("item_closed", dragged_item)
			
			# Use a zero offset to center the document on the cursor
			drag_offset = Vector2.ZERO
			
			# We'll handle centering in the next frame using call_deferred
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
		
		# Handle specific item drop logic first
		if drop_zone == "inspection_table" or drop_zone == "suspect_panel" or drop_zone == "suspect":
			if dragged_item.name == "Passport":
				_handle_passport_drop(mouse_pos)
			elif dragged_item.name == "Guide":
				_handle_guide_drop(mouse_pos)
			elif dragged_item.name == "LawReceipt":
				_handle_receipt_drop(mouse_pos)
			
			# Restore original z-index immediately for valid drop zones
			dragged_item.z_index = original_z_index
		else:
			# Item dropped in invalid location, return to nearest point on table
			_return_item_to_table(dragged_item)
			# Don't reset dragged_item here as we'll handle it after the tween completes
			return true
			
		dragged_item = null
		return true
	return false

func _update_dragged_item_position(mouse_pos: Vector2):
	if dragged_item:
		# Store previous position to check if we're leaving the table
		var previous_position = get_viewport().get_mouse_position()
		var was_on_table = inspection_table and inspection_table.get_rect().has_point(inspection_table.to_local(previous_position))
		
		# Update position using the drag_offset which is now the center of the document
		dragged_item.global_position = get_viewport().get_mouse_position()
		
		# Check if document is leaving the inspection table
		var is_on_table = inspection_table and inspection_table.get_rect().has_point(inspection_table.to_local(dragged_item.global_position))
		
		# If document was on table but no longer is, close it (only once)
		if was_on_table and !is_on_table and !document_was_closed and is_openable_document(dragged_item):
			emit_signal("item_closed", dragged_item)
			document_was_closed = true
			
			# Get updated mouse position for more accuracy
			var current_mouse_pos = get_viewport().get_mouse_position()

# Find the nearest valid position on the inspection table
func find_nearest_table_position(item_position: Vector2, item_size: Vector2) -> Vector2:
	if not inspection_table:
		return item_position
		
	# Get table rect in global coordinates
	var table_rect = Rect2(
		inspection_table.global_position, 
		inspection_table.get_rect().size
	)
	
	# Add buffer to account for document size
	var buffered_rect = Rect2(
		table_rect.position + Vector2(TABLE_EDGE_BUFFER, TABLE_EDGE_BUFFER),
		table_rect.size - Vector2(TABLE_EDGE_BUFFER * 2, TABLE_EDGE_BUFFER * 2) - item_size
	)
	
	# If the buffered rect is invalid (too small), use table rect with minimum buffer
	if buffered_rect.size.x <= 0 or buffered_rect.size.y <= 0:
		buffered_rect = Rect2(
			table_rect.position + Vector2(5, 5),
			table_rect.size - Vector2(10, 10) - item_size
		)
	
	# Find the nearest valid position
	var target_pos = Vector2(
		clamp(item_position.x, buffered_rect.position.x, buffered_rect.position.x + buffered_rect.size.x),
		clamp(item_position.y, buffered_rect.position.y, buffered_rect.position.y + buffered_rect.size.y)
	)
	
	return target_pos

# Return an item to the nearest valid position on the inspection table
# Return an item to the nearest valid position on the inspection table
# Return an item to the nearest valid position on the inspection table
func _return_item_to_table(item: Node2D):
	if not item or not inspection_table:
		if item:
			item.z_index = original_z_index
			item.scale = item.scale  # Ensure scale is normalized
			dragged_item = null
		return
	
	# Keep the high z-index during the return animation
	# Save original scale to restore exactly the same value
	var original_scale = Vector2(item.scale)
	
	# Get item size using the utility method
	var item_size = get_item_size(item)
		
	# Find the nearest valid position
	var target_position = find_nearest_table_position(item.global_position, item_size)
	
	# Create a tween for position
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)  # Back easing for overshoot effect
	tween.tween_property(item, "global_position", target_position, RETURN_TWEEN_DURATION)
	
	# Create a separate tween for scale animation
	var scale_tween = create_tween()
	
	# Squish on impact
	scale_tween.tween_property(item, "scale", Vector2(original_scale.x * 1.1, original_scale.y * 0.9), RETURN_TWEEN_DURATION * 0.6)
	
	# Then bounce back
	scale_tween.tween_property(item, "scale", Vector2(original_scale.x * 0.95, original_scale.y * 1.05), RETURN_TWEEN_DURATION * 0.15)
	
	# Ensure exact original scale is restored at the end
	scale_tween.tween_property(item, "scale", original_scale, RETURN_TWEEN_DURATION * 0.25)
	
	# Make sure original scale is properly restored in tween callback
	tween.tween_callback(func():
		# Force exact scale restoration
		item.scale = original_scale
		item.z_index = original_z_index
		dragged_item = null
		
		# Open the document when it returns to the table
		if is_openable_document(item):
			emit_signal("item_opened", item)
	)
	
	# Play a return sound
	if audio_player:
		audio_player.stream = preload("res://assets/audio/passport_sfx/close_passport_audio.mp3")
		audio_player.play()
		
# Get the size of a node, handling different node types
func get_item_size(item: Node2D) -> Vector2:
	if item is Sprite2D and item.texture:
		return item.texture.get_size() * item.scale
	elif item is Node2D:
		return item.size * item.scale
	elif item.has_method("get_rect"):
		var rect = item.get_rect()
		return rect.size * item.scale
	else:
		# Fallback to a reasonable default size
		return Vector2(100, 100) * item.scale

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
