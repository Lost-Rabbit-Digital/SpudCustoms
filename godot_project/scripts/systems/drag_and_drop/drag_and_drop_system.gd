extends Node
## Core system for handling drag and drop interactions.
##
## Manages the low-level drag and drop functionality including item selection,
## mouse movement tracking, drop zone identification, and visual feedback.
## Handles physics and animation aspects of the drag and drop interaction.
class_name DragAndDropSystem

# Signals
## Emitted when an item starts being dragged.
## @param item The Node2D being dragged.
signal item_dragged(item)

## Emitted when an item is dropped.
## @param item The Node2D being dropped.
## @param drop_zone The zone identifier where the item was dropped.
signal item_dropped(item, drop_zone)

## Emitted when an item is opened.
## @param item The Node2D being opened.
signal item_opened(item)

## Emitted when an item is closed.
## @param item The Node2D being closed.
signal item_closed(item)

## Emitted when a passport is returned to the suspect.
## @param item The passport Node2D.
signal passport_returned(item)

# Configuration
## Z-index for passport documents in normal state.
const PASSPORT_Z_INDEX = 3

## Z-index for items being actively dragged (higher than normal).
const DEFAULT_Z_INDEX = 3
const OPEN_DRAGGING_Z_INDEX = 3
const CLOSED_DRAGGING_Z_INDEX = 25

## Duration in seconds for the return animation when dropping outside valid zones.
const RETURN_TWEEN_DURATION = 0.3

# TODO: Check if this actually works, the offset seems different
## Buffer distance in pixels from table edge when determining valid drop positions.
const TABLE_EDGE_BUFFER = 16

# State tracking
## Array of Node2D instances that can be dragged.
var draggable_items = []

## Reference to the currently dragged item, or null if no item is being dragged.
var dragged_item = null

## Offset from mouse position to item origin during dragging.
var drag_offset = Vector2()

## Flag indicating if the document was closed during the current drag operation.
var is_document_closed = false

## Stores the original z-index of the dragged item to restore after dropping.
var original_z_index: int

## Reference to the item currently being hovered over.
var hovered_item = null

# Drop zone references
## Reference to the inspection table node where documents can be examined.
var inspection_table: Node2D

## Reference to the suspect panel area.
var suspect_panel: Node2D

## Reference to the suspect mugshot node.
var suspect: Node2D

# Sound state tracking
## Flag to track if close sound has already been played to prevent duplicates.
var close_sound_played = false

## Flag to track if open sound has already been played to prevent duplicates.
var open_sound_played = false

# Audio
## Reference to the audio player for document interaction sounds.
var audio_player: AudioStreamPlayer2D

# Stamp System
## Reference to the stamp bar controller for stamp button interaction.
var _stamp_bar_controller = null

## Reference to the stamp system manager for handling document stamping.
var stamp_system_manager: StampSystemManager

# Cursor Manager reference
## Reference to the cursor manager for handling cursor changes.
var cursor_manager = null

# Office Shutter reference
var office_shutter: Node = null

## Initializes the drag and drop system with necessary references.
##
## Sets up references to scene nodes and registers draggable items.
## @param config Dictionary containing configuration parameters.
func initialize(config: Dictionary):
	# Set references from configuration
	inspection_table = config.get("inspection_table")
	suspect_panel = config.get("suspect_panel")  
	suspect = config.get("suspect")
	audio_player = config.get("audio_player")
	office_shutter = config.get("office_shutter")
	
	# Get stamp bar controller reference if provided
	_stamp_bar_controller = config.get("stamp_bar_controller")
	
	# Register draggable items
	register_draggable_items(config.get("draggable_items", []))
	
	# Get reference to cursor manager autoload
	cursor_manager = get_node_or_null("/root/CursorManager")
	if not cursor_manager:
		push_warning("CursorManager autoload is null. Cursor visuals will not display as intended.")

## Sets the stamp system manager reference.
##
## @param manager The stamp system manager instance.
func set_stamp_system_manager(manager: StampSystemManager):
	stamp_system_manager = manager
	#print("StampSystemManager successfully set in drag_and_drop_system")

## Registers multiple items as draggable.
##
## Sets initial z-index for items if not already set.
## @param items Array of Node2D instances to register as draggable.
func register_draggable_items(items: Array):
	draggable_items = items
	# Set initial z-index for all items if not already set
	for item in draggable_items:
		if is_instance_valid(item):
			if item.z_index == 0:  # Only set if not already set
				push_warning("Draggable Item is missing z-index: %s", item)
				item.z_index = PASSPORT_Z_INDEX
		else:
			push_warning("Invalid draggable item provided")

## Registers a single item as draggable.
##
## Sets initial z-index for the item if not already set.
## @param item The Node2D instance to register as draggable.
func register_draggable_item(item: Node2D):
	if is_instance_valid(item):
		draggable_items.append(item)
		if item.z_index == 0:  # Only set if not already set
			item.z_index = PASSPORT_Z_INDEX
	else:
		push_warning("Invalid draggable item provided")
		
## Removes a draggable item from the registry.
##
## @param item The Node2D instance to unregister.
func unregister_draggable_item(item: Node2D):
	if item in draggable_items:
		draggable_items.erase(item)

# TODO: Update this to work with input interactions instead of MOUSE_BUTTONS
## Handles input events for drag and drop interaction.
##
## Processes mouse button and motion events to handle dragging.
## @param event The input event to process.
## @param mouse_pos The current mouse position in global coordinates.
## @return True if the event was handled, false otherwise.
func handle_input_event(event: InputEvent, mouse_pos: Vector2) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				return _handle_mouse_press(mouse_pos)
			else:
				return _handle_mouse_release(mouse_pos)
	elif event is InputEventMouseMotion:
		# Always check for hover even if not dragging
		_handle_mouse_motion(mouse_pos)
		
		if dragged_item:
			_update_dragged_item_position(mouse_pos)
			return true
			
	return false

# TODO: This is where we would fix the bug: when you let go the cursor doesn't update for the 
# item under the mouse, only when you move the mouse off and then back onto the item
## Handles mouse motion for hover effects.
##
## Updates cursor and hover state based on what item is under the cursor.
## @param mouse_pos The current mouse position in global coordinates.
func _handle_mouse_motion(mouse_pos: Vector2) -> void:
	if dragged_item:
		# Don't change cursor while dragging
		return
		
	# Find item under cursor
	var item_under_cursor = find_topmost_item_at(mouse_pos)
	
	# If the shutter is closed and we're over the suspect panel or suspect area, don't show hover effects
	var is_over_suspect_area = identify_drop_zone(mouse_pos) == "suspect" or identify_drop_zone(mouse_pos) == "suspect_panel"
	var is_shutter_closed = office_shutter.active_shutter_state and office_shutter.shutter_state.CLOSED
	
	if is_over_suspect_area and is_shutter_closed:
		# Reset cursor if previously hovering
		if cursor_manager and hovered_item != null:
			cursor_manager.update_cursor("default")
			
		# Clear hover state
		hovered_item = null
		return
	
	# Normal hover behavior for other cases
	if item_under_cursor != hovered_item:
		if item_under_cursor:
			# Set hover cursor if hovering over a draggable document
			if cursor_manager and is_openable_document(item_under_cursor):
				cursor_manager.update_cursor("hover_1")
		else:
			# Reset cursor if not hovering over any document
			if cursor_manager and hovered_item != null:
				cursor_manager.update_cursor("default")
				
		# Update hover state
		hovered_item = item_under_cursor

## Gets the document controller attached to an item.
##
## @param item The Node2D to check for a document controller.
## @return The DraggableDocument controller or null if not found.
func get_document_controller(item: Node2D) -> DraggableDocument:
	if item and item.has_node("DocumentController"):
		return item.get_node("DocumentController") as DraggableDocument
	return null

## Handles mouse press events for drag initiation.
##
## Finds the item under the cursor and initiates the drag operation.
## @param mouse_position The mouse position when the press occurred.
## @return True if an item was found and dragging initiated, false otherwise.
func _handle_mouse_press(mouse_position: Vector2) -> bool:
	if dragged_item == null:
		dragged_item = find_topmost_item_at(mouse_position)
		if dragged_item:
			# Reset document_was_closed flag for new drag
			is_document_closed = false
			
			# Store original z-index and set to higher value while dragging
			#original_z_index = dragged_item.z_index
			original_z_index = DEFAULT_Z_INDEX
			dragged_item.z_index = OPEN_DRAGGING_Z_INDEX
			
			# Get current drop zone
			var current_zone = identify_drop_zone(mouse_position)
			
			# Calculate drag offset - from mouse to item position
			drag_offset = dragged_item.global_position - mouse_position
			
			# Get document controller and call on_drag_start if available
			var doc_controller = get_document_controller(dragged_item)
			if doc_controller:
				doc_controller.on_drag_start()
			
			# Only close the document if it's NOT on the inspection table
			if current_zone != "inspection_table" and is_openable_document(dragged_item):
				emit_signal("item_closed", dragged_item)
			
			emit_signal("item_dragged", dragged_item)
			
			# Update cursor to "grab" when starting to drag
			if cursor_manager:
				cursor_manager.update_cursor("grab")
				
			return true
	return false

## Creates a paper crunch visual effect at the specified position.
##
## Spawns particle effects and plays sound to simulate paper crunching.
## @param position The global position to spawn the effect.
## @param intensity The intensity factor for the effect (1.0 is normal).
func spawn_paper_crunch_effect(position: Vector2, intensity: float = 1.0):
	# Load the PaperCrunchEffect scene or create it if using the singleton approach
	var effect = PaperCrunchEffect.new()
	get_tree().root.add_child(effect)
	
	# Adjust parameters based on intensity (how hard the document was dropped)
	effect.num_bits = int(15 * intensity)
	effect.max_initial_velocity = 90.0 * intensity
	effect.arc_height_factor = 60.0 * intensity
	
	# Spawn at position
	effect.spawn_at(position)
	
	# Play appropriate sound effect if available
	audio_player = AudioStreamPlayer2D.new()
	audio_player.volume_db = 5.0  # Adjust volume as needed
	audio_player.bus = "SFX"
	audio_player.autoplay = true
	add_child(audio_player)
		
	# Auto-cleanup after playing
	audio_player.finished.connect(audio_player.queue_free)
	if audio_player:
		var paper_crunch_sounds = [
			preload("res://assets/audio/paper/paper_fold_1.mp3"),
			preload("res://assets/audio/paper/paper_fold_2.mp3"),
			preload("res://assets/audio/paper/paper_fold_3.mp3"),
			preload("res://assets/audio/paper/paper_fold_4.mp3"),
			preload("res://assets/audio/paper/paper_fold_5.mp3"),
			preload("res://assets/audio/paper/paper_fold_6.mp3")
		]
		if paper_crunch_sounds.size() > 0:
			audio_player.stream = paper_crunch_sounds[randi() % paper_crunch_sounds.size()]
			audio_player.pitch_scale = randf_range(0.9, 1.1)  # Slight pitch variation
			audio_player.play()

## Handles mouse release events for drag completion.
##
## Identifies the drop zone and handles the appropriate drop action.
## @param mouse_pos The mouse position when the release occurred.
## @return True if an item was being dragged and was dropped, false otherwise.
func _handle_mouse_release(mouse_pos: Vector2) -> bool:
	if dragged_item:
		var drop_zone = identify_drop_zone(mouse_pos)
		emit_signal("item_dropped", dragged_item, drop_zone)
		
		# Reset document_was_closed flag
		is_document_closed = true
		
		# Get document controller
		var doc_controller = get_document_controller(dragged_item)
		
		# First check if the user is trying to drop on the suspect/panel without stamping
		if (drop_zone == "suspect" or drop_zone == "suspect_panel") and stamp_system_manager.passport_stampable.get_decision() == "":
					# Shutter is closed - can't drop here, return to table
			if doc_controller and doc_controller.is_document_open():
				doc_controller.close()
			
			# Maybe play a "blocked" sound effect
			if audio_player:
				audio_player.stream = preload("res://assets/audio/passport_sfx/close_passport_audio.mp3")
				audio_player.play()
			
			# Return to table
			_return_item_to_table(dragged_item)
			
			# Clear the dragged item after return animation starts
			var item = dragged_item
			dragged_item = null
			
			# Reset cursor immediately
			if cursor_manager:
				cursor_manager.update_cursor("default")
			
			return true
		# Next check if trying to drop on suspect/panel with closed shutter
		elif (drop_zone == "suspect" or drop_zone == "suspect_panel") and office_shutter.active_shutter_state == office_shutter.shutter_state.CLOSED:
			# Shutter is closed - can't drop here, return to table
			if doc_controller and doc_controller.is_document_open():
				doc_controller.close()
			
			# Maybe play a "blocked" sound effect
			if audio_player:
				audio_player.stream = preload("res://assets/audio/passport_sfx/close_passport_audio.mp3")
				audio_player.play()
			
			# Return to table
			_return_item_to_table(dragged_item)
			
			# Clear the dragged item after return animation starts
			var item = dragged_item
			dragged_item = null
			
			# Reset cursor immediately
			if cursor_manager:
				cursor_manager.update_cursor("default")
			
			return true
		# Otherwise check normal valid drop zones
		elif drop_zone == "inspection_table" or drop_zone == "suspect_panel" or drop_zone == "suspect":
			# Valid drop zone
			if doc_controller:
				doc_controller.on_drop(drop_zone)
			
			# Handle specific item drop logic
			if dragged_item.name == "Passport":
				_handle_passport_drop(mouse_pos)
			elif dragged_item.name == "LawReceipt":
				_handle_receipt_drop(mouse_pos)
			
			# Restore original z-index for valid drop zones
			dragged_item.z_index = original_z_index
		else:
			# Invalid drop zone - ensure document is closed
			if doc_controller and doc_controller.is_document_open():
				doc_controller.close()
				
			# Return to nearest valid position on table
			_return_item_to_table(dragged_item)
			
			# Clear the dragged item after return animation starts
			var item = dragged_item
			dragged_item = null
			
			# Reset cursor immediately
			if cursor_manager:
				cursor_manager.update_cursor("default")
			
			return true
		
		# Reset cursor after releasing the item
		if cursor_manager:
			cursor_manager.update_cursor("default")
		
		# Clear dragged item reference
		dragged_item = null
		
		# Re-check for hover
		_handle_mouse_motion(mouse_pos)
		return true
	return false

## Updates the position of the item being dragged.
##
## Handles document state changes when moving between drop zones.
## @param mouse_pos The current mouse position in global coordinates.
func _update_dragged_item_position(mouse_pos: Vector2):
	if dragged_item:
		# Store previous position
		var previous_position = dragged_item.global_position
		var drop_zone = identify_drop_zone(mouse_pos)
		
		# Check if we would be moving over suspect area with closed shutter
		var target_zone = identify_drop_zone(mouse_pos + drag_offset)
		
		# Update position using the drag_offset
		dragged_item.global_position = mouse_pos + drag_offset
		
		# If document was on table but no longer is, close it (only once)
		if drop_zone != "inspection_table" and !is_document_closed and is_openable_document(dragged_item):
			emit_signal("item_closed", dragged_item)
			is_document_closed = true

## Finds the nearest valid position on the inspection table for an item.
##
## Calculates a position that keeps the item within table bounds with a buffer.
## @param item_position The current global position of the item.
## @param item_size The size of the item in pixels.
## @return The nearest valid global position on the table.
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

## Returns an item to the nearest valid position on the inspection table.
##
## Creates and plays an animation to move the item back to a valid position.
## @param item The Node2D to return to the table.
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
	
	target_position.y += randi_range(-75, 75)
	target_position.x += randi_range(-75, 75)
	
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
		
		# Open the document when it returns to the table
		#if is_openable_document(item):
			#emit_signal("item_opened", item)
	)

	# Play a return sound
	if audio_player:
		audio_player.stream = preload("res://assets/audio/passport_sfx/close_passport_audio.mp3")
		audio_player.play()
		
## Gets the size of a node, handling different node types.
##
## Attempts to determine the size of the item based on its type.
## @param item The Node2D to get the size of.
## @return The size of the item in pixels, scaled by the item's scale.
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

## Checks if an item is a document that can be opened/closed.
##
## @param item The Node2D to check.
## @return True if the item is an openable document, false otherwise.
func is_openable_document(item: Node2D) -> bool:
	return item and (item.name == "Passport" or item.name == "LawReceipt")

## Finds the topmost draggable item at the given position.
##
## Handles z-index ordering and UI element prioritization.
## @param pos The global position to check.
## @return The topmost draggable item at the position, or null if none found.
func find_topmost_item_at(pos: Vector2) -> Node2D:
	# First check if we're over any stamp buttons - if so, don't consider it a draggable item
	# This check needs to happen before the regular draggable item check
	
	# Find stamp bar controller reference if not already cached
	if not is_instance_valid(_stamp_bar_controller):
		_stamp_bar_controller = get_stamp_bar_controller()
	
	# Check if mouse is over approval or rejection stamp button
	if is_instance_valid(_stamp_bar_controller) and _stamp_bar_controller.is_visible:
		var approval_stamp = _stamp_bar_controller.get_node_or_null("StampBar/ApprovalStamp/TextureButton")
		var rejection_stamp = _stamp_bar_controller.get_node_or_null("StampBar/RejectionStamp/TextureButton")
		
		# Check for approval stamp hit
		if is_instance_valid(approval_stamp) and approval_stamp.visible:
			if approval_stamp.get_global_rect().has_point(pos):
				return null  # Mouse is over approval stamp, don't consider it draggable
		
		# Check for rejection stamp hit
		if is_instance_valid(rejection_stamp) and rejection_stamp.visible:
			if rejection_stamp.get_global_rect().has_point(pos):
				return null  # Mouse is over rejection stamp, don't consider it draggable
	
	# Regular draggable item finding logic
	var topmost_item = null
	var highest_z = -1
	
	for item in draggable_items:
		if item.visible and item.get_rect().has_point(item.to_local(pos)):
			if item.z_index > highest_z:
				highest_z = item.z_index
				topmost_item = item
	
	return topmost_item

## Finds and returns the stamp bar controller in the scene tree.
##
## @return The stamp bar controller node, or null if not found.
func get_stamp_bar_controller() -> Node:
	# Try to find in the scene tree
	var scene_root = get_tree().current_scene
	
	# Direct search from root
	var controller = scene_root.find_child("StampBarController", true, false)
	if controller:
		return controller
		
	# Look in Gameplay path if not found directly
	var gameplay = scene_root.get_node_or_null("Gameplay/InteractiveElements")
	if gameplay:
		controller = gameplay.get_node_or_null("StampBarController")
		if controller:
			return controller
			
	return null

## Identifies what drop zone the position is over.
##
## @param pos The global position to check.
## @return A string identifying the drop zone ("inspection_table", "suspect_panel", "suspect", or "none").
func identify_drop_zone(pos: Vector2) -> String:
	if inspection_table and inspection_table.get_rect().has_point(inspection_table.to_local(pos)):
		return "inspection_table"
	elif suspect_panel and suspect_panel.get_rect().has_point(suspect_panel.to_local(pos)):
		# If shutter is closed, don't allow suspect panel
		if office_shutter.active_shutter_state and office_shutter.shutter_state.CLOSED:
			return "none"
		return "suspect_panel"
	elif suspect and suspect.get_rect().has_point(suspect.to_local(pos)):
		# If shutter is closed, don't allow suspect
		if office_shutter.active_shutter_state and office_shutter.shutter_state.CLOSED:
			return "none"
		return "suspect"
	return "none"

## Gets the highest z-index among all draggable items.
##
## @return The highest z-index value found.
func get_highest_z_index() -> int:
	var highest = 0
	for item in draggable_items:
		highest = max(highest, item.z_index)
	return highest

# === Specific item handlers ===

## Handles passport drop logic.
##
## Manages document state based on drop zone and emits appropriate signals.
## @param mouse_pos The mouse position where the drop occurred.
func _handle_passport_drop(mouse_pos: Vector2):
	var drop_zone = identify_drop_zone(mouse_pos)
	
	# Get document controller to check current state
	var doc_controller = get_document_controller(dragged_item)
	var was_open = doc_controller and doc_controller.is_document_open()
	
	# If dropping on inspection table and document was already open, keep it open
	if drop_zone == "inspection_table" and was_open:
		# No need to emit open signal if document is already open
		pass
	# If dropping on inspection table and document was closed, open it
	elif drop_zone == "inspection_table" and !was_open:
		# Only open if it wasn't already open
		emit_signal("item_opened", dragged_item)
	# If dropping on suspect_panel, suspect, or none
	else:
		# Always close when dropping on suspect
		emit_signal("item_closed", dragged_item)
		
		# If dropping on suspect, emit passport_returned signal
		if drop_zone == "suspect":
			emit_signal("passport_returned", dragged_item)
			if stamp_system_manager:
				stamp_system_manager.clear_passport_stamps()
			else:
				push_error("Cannot clear passport stamps: StampSystemManager is null")

## Handles receipt drop logic.
##
## Manages document state based on drop zone and emits appropriate signals.
## @param mouse_pos The mouse position where the drop occurred.
func _handle_receipt_drop(mouse_pos: Vector2):
	var drop_zone = identify_drop_zone(mouse_pos)
	if drop_zone == "inspection_table":
		# Logic to open receipt
		emit_signal("item_opened", dragged_item)
	elif drop_zone == "suspect_panel" or drop_zone == "suspect":
		# Logic to close receipt
		emit_signal("item_closed", dragged_item)

## Plays the open document sound.
##
## Prevents duplicate sound playing by tracking sound state.
func play_open_sound():
	if not open_sound_played and audio_player:
		audio_player.stream = preload("res://assets/audio/passport_sfx/open_passport_audio.mp3")
		audio_player.play()
		open_sound_played = true
		close_sound_played = false

## Plays the close document sound.
##
## Prevents duplicate sound playing by tracking sound state.
func play_close_sound():
	if not close_sound_played and audio_player:
		audio_player.stream = preload("res://assets/audio/passport_sfx/close_passport_audio.mp3")
		audio_player.play()
		close_sound_played = true
		open_sound_played = false

## Resets sound playback state flags.
func reset_sound_flags():
	close_sound_played = false
	open_sound_played = false

## Gets the currently dragged item.
##
## @return The Node2D that is being dragged, or null if no item is being dragged.
func get_dragged_item() -> Node2D:
	return dragged_item

## Checks if any item is currently being dragged.
##
## @return True if an item is being dragged, false otherwise.
func is_dragging() -> bool:
	return dragged_item != null
