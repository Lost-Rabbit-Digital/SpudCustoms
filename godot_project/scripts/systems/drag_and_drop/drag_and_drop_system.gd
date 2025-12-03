class_name DragAndDropSystem
extends Node
## Core system for handling drag and drop interactions.
##
## Manages the low-level drag and drop functionality including item selection,
## mouse movement tracking, drop zone identification, and visual feedback.
## Handles physics and animation aspects of the drag and drop interaction.

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

## Duration in seconds for the return animation when dropping outside valid zones.
const RETURN_TWEEN_DURATION = 0.3

# TODO: Check if this actually works, the offset seems different
## Buffer distance in pixels from table edge when determining valid drop positions.
const TABLE_EDGE_BUFFER = 16

# Cursor Manager reference
## Reference to the cursor manager for handling cursor changes.
var cursor_manager = null

# Office Shutter reference
var office_shutter: Node = null

## Reference to the stamp system manager for handling document stamping.
var stamp_system_manager: StampSystemManager

# State tracking
## Array of Node2D instances that can be dragged.
var draggable_items = []

## Reference to the currently dragged item, or null if no item is being dragged.
var dragged_item = null

## Offset from mouse position to item origin during dragging.
var drag_offset = Vector2()

## Flag indicating if the document was closed during the current drag operation.
var is_document_closed = false

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
var block_sound_played = false

## Flag to track if open sound has already been played to prevent duplicates.
var open_sound_played = false

# Audio
## Reference to the audio player for document interaction sounds.
var audio_player: AudioStreamPlayer2D

# Stamp System
## Reference to the stamp bar controller for stamp button interaction.
var _stamp_bar_controller = null

# NEW: Document interaction sounds
var document_grab_sound = preload("res://assets/audio/document_sfx/document_grab.mp3")
var document_whoosh_sound = preload("res://assets/audio/document_sfx/document_whoosh.mp3")
var document_return_sound = preload("res://assets/audio/document_sfx/document_return.mp3")
var document_blocked_sound = preload("res://assets/audio/document_sfx/document_blocked.mp3")


## Gets the rect of a node, handling different node types.
## Returns a Rect2 for the node's bounds in local coordinates.
## @param node The node to get the rect from.
## @return The bounding Rect2 of the node.
func _get_node_rect(node: Node) -> Rect2:
	if not is_instance_valid(node):
		return Rect2()

	# Check if node has get_rect method
	if node.has_method("get_rect"):
		return node.get_rect()

	# Handle Sprite2D nodes
	if node is Sprite2D:
		var sprite := node as Sprite2D
		if sprite.texture:
			var size = sprite.texture.get_size() * sprite.scale
			var pos = Vector2.ZERO
			if sprite.centered:
				pos = -size / 2
			return Rect2(pos, size)
		return Rect2()

	# Handle Control nodes
	if node is Control:
		var control := node as Control
		return Rect2(Vector2.ZERO, control.size)

	# Handle CollisionShape2D nodes
	if node is CollisionShape2D:
		var collision := node as CollisionShape2D
		if collision.shape:
			return collision.shape.get_rect()
		return Rect2()

	# Fallback: try to find a child Sprite2D or use a default size
	for child in node.get_children():
		if child is Sprite2D and child.texture:
			var sprite := child as Sprite2D
			var size = sprite.texture.get_size() * sprite.scale
			var pos = child.position
			if sprite.centered:
				pos -= size / 2
			return Rect2(pos, size)

	# Default fallback - use a reasonable default size
	return Rect2(-50, -50, 100, 100)


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

	# REFACTORED: Direct reference to CursorManager autoload
	cursor_manager = CursorManager
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
			if item.z_index != ConstantZIndexes.Z_INDEX.IDLE_DOCUMENT:  # Only set if not already set
				push_warning("Draggable Item is missing z-index: %s", item)
		else:
			push_warning("Invalid draggable item provided")


## Handles input events for drag and drop interaction.
## Supports both mouse input and input actions for controller/remapping support.
##
## @param event The input event to process.
## @param mouse_pos The current mouse position in global coordinates.
## @return True if the event was handled, false otherwise.
func handle_input_event(event: InputEvent, mouse_pos: Vector2) -> bool:
	# Handle primary interaction via input action (supports remapping and controllers)
	if event.is_action_pressed("primary_interaction"):
		return _handle_mouse_press(mouse_pos)
	elif event.is_action_released("primary_interaction"):
		return _handle_mouse_release(mouse_pos)

	# Fallback: Handle raw mouse button for compatibility
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				return _handle_mouse_press(mouse_pos)
			else:
				return _handle_mouse_release(mouse_pos)

	# Handle mouse motion for dragging and hover effects
	if event is InputEventMouseMotion:
		# Always check for hover even if not dragging
		_handle_mouse_motion(mouse_pos)

		if dragged_item:
			_update_dragged_item_position(mouse_pos)
			return true

	return false


# FIXED: Now calls _handle_mouse_motion after releasing to check hover state
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

	# If the shutter is closed and we're over the suspect panel or suspect area,
	# don't show hover effects
	var is_over_suspect_area = (
		identify_drop_zone(mouse_pos) == "suspect"
		or identify_drop_zone(mouse_pos) == "suspect_panel"
	)
	var is_shutter_closed = (
		office_shutter.active_shutter_state and office_shutter.ShutterState.CLOSED
	)

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

			# Set the dragged_item z_index higher while it's being dragged
			dragged_item.z_index = ConstantZIndexes.Z_INDEX.OPEN_DRAGGED_DOCUMENT

			# Get current drop zone
			var current_zone = identify_drop_zone(mouse_position)

			drag_offset = dragged_item.global_position - mouse_position

			# Get document controller and call on_drag_start if available
			var doc_controller = get_document_controller(dragged_item)
			if doc_controller:
				doc_controller.on_drag_start()

			# Only close the document if it's NOT on the inspection table
			if current_zone != "inspection_table" and is_openable_document(dragged_item):
				emit_signal("item_closed", dragged_item)

			emit_signal("item_dragged", dragged_item)

			# Clear hovered_item so cursor updates properly after release
			hovered_item = null

			# Update cursor to "grab" when starting to drag
			if cursor_manager:
				cursor_manager.update_cursor("grab")
			
			# NEW: Play grab sound
			if audio_player:
				audio_player.stream = document_grab_sound
				audio_player.pitch_scale = randf_range(0.95, 1.05)
				audio_player.play()

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
		if (
			(drop_zone == "suspect" or drop_zone == "suspect_panel")
			and stamp_system_manager.passport_stampable.get_decision() == ""
		):
			# Shutter is closed - can't drop here, return to table
			if doc_controller and doc_controller.is_document_open():
				doc_controller.close()

			# Maybe play a "blocked" sound effect
			# NEW: Use new blocked sound
			if audio_player:
				audio_player.stream = document_blocked_sound
				audio_player.pitch_scale = randf_range(0.95, 1.05)
				audio_player.play()

			# Return to table
			_return_item_to_table(dragged_item)
			dragged_item.z_index = ConstantZIndexes.Z_INDEX.IDLE_DOCUMENT

			# Clear the dragged item after return animation starts
			var item = dragged_item
			dragged_item = null

			# Reset cursor and re-check for hover
			if cursor_manager:
				cursor_manager.update_cursor("default")
			_handle_mouse_motion(mouse_pos)

			return true
		# Next check if trying to drop on suspect/panel with closed shutter
		elif (
			(drop_zone == "suspect" or drop_zone == "suspect_panel")
			and office_shutter.active_shutter_state == office_shutter.ShutterState.CLOSED
		):
			# Shutter is closed - can't drop here, return to table
			if doc_controller and doc_controller.is_document_open():
				doc_controller.close()

			# Play a "blocked" sound effect
			# NEW: Use new blocked sound
			if audio_player:
				audio_player.stream = document_blocked_sound
				audio_player.pitch_scale = randf_range(0.95, 1.05)
				audio_player.play()

			# Return to table
			_return_item_to_table(dragged_item)
			dragged_item.z_index = ConstantZIndexes.Z_INDEX.IDLE_DOCUMENT

			# Clear the dragged item after return animation starts
			var item = dragged_item
			dragged_item = null

			# Reset cursor and re-check for hover
			if cursor_manager:
				cursor_manager.update_cursor("default")
			_handle_mouse_motion(mouse_pos)

			return true
		# Otherwise check normal valid drop zones
		elif (
			drop_zone == "inspection_table"
			or drop_zone == "suspect_panel"
			or drop_zone == "suspect"
		):
			# Valid drop zone
			if doc_controller:
				doc_controller.on_drop(drop_zone)

			# Handle specific item drop logic
			_handle_document_drop(mouse_pos)
		else:
			# Invalid drop zone - ensure document is closed
			if doc_controller and doc_controller.is_document_open():
				doc_controller.close()

			# Return to nearest valid position on table
			_return_item_to_table(dragged_item)

			# Clear the dragged item after return animation starts
			var item = dragged_item
			dragged_item = null

			# Reset cursor and re-check for hover
			if cursor_manager:
				cursor_manager.update_cursor("default")
			_handle_mouse_motion(mouse_pos)

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
		# TODO: If the document is open, use the offset, if the document is closed, center

		# Store previous position
		var previous_position = dragged_item.global_position
		var drop_zone = identify_drop_zone(mouse_pos)

		# Check if we would be moving over suspect area with closed shutter
		var target_zone = identify_drop_zone(mouse_pos + drag_offset)

		# Update position - center to cursor when closed
		if drop_zone == "inspection_table" and !is_document_closed:
			# When open on table, use the drag_offset
			dragged_item.global_position = mouse_pos + drag_offset
		else:
			# When closed, center it to the cursor
			var size = get_item_size(dragged_item)
			dragged_item.global_position = mouse_pos

		# If document was on table but no longer is, close it (only once)
		if (
			drop_zone != "inspection_table"
			and !is_document_closed
			and is_openable_document(dragged_item)
		):
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
	var table_rect = Rect2(inspection_table.global_position, _get_node_rect(inspection_table).size)

	# Add buffer to account for document size
	var buffered_rect = Rect2(
		table_rect.position + Vector2(TABLE_EDGE_BUFFER, TABLE_EDGE_BUFFER),
		table_rect.size - Vector2(TABLE_EDGE_BUFFER * 2, TABLE_EDGE_BUFFER * 2) - item_size
	)

	# If the buffered rect is invalid (too small), use table rect with minimum buffer
	if buffered_rect.size.x <= 0 or buffered_rect.size.y <= 0:
		buffered_rect = Rect2(
			table_rect.position + Vector2(5, 5), table_rect.size - Vector2(10, 10) - item_size
		)

	# Find the nearest valid position
	var target_pos = Vector2(
		clamp(
			item_position.x,
			buffered_rect.position.x,
			buffered_rect.position.x + buffered_rect.size.x
		),
		clamp(
			item_position.y,
			buffered_rect.position.y,
			buffered_rect.position.y + buffered_rect.size.y
		)
	)

	return target_pos


## Returns an item to the nearest valid position on the inspection table.
##
## Creates and plays an animation to move the item back to a valid position.
## @param item The Node2D to return to the table.
func _return_item_to_table(item: Node2D):
	if not item or not inspection_table:
		if item:
			item.scale = item.scale  # Ensure scale is normalized
			dragged_item = null
		return

	# Keep the high z-index during the return animation
	# Save original scale to restore exactly the same value
	var original_scale = Vector2(item.scale)

	# Get item size using the utility method
	var item_size = get_item_size(item)

	# FIXED: Apply random variation BEFORE clamping to ensure position stays within bounds
	# Add some randomness to the drop position for visual variety
	var varied_position = item.global_position + Vector2(
		randf_range(-40, 40),
		randf_range(-40, 40)
	)

	# Find the nearest valid position (this will clamp to table bounds)
	var target_position = find_nearest_table_position(varied_position, item_size)

	# Create a tween for position
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)  # Back easing for overshoot effect
	tween.tween_property(item, "global_position", target_position, RETURN_TWEEN_DURATION)

	# Create a separate tween for scale animation
	var scale_tween = create_tween()

	# Squish on impact
	scale_tween.tween_property(
		item,
		"scale",
		Vector2(original_scale.x * 1.1, original_scale.y * 0.9),
		RETURN_TWEEN_DURATION * 0.6
	)

	# Then bounce back
	scale_tween.tween_property(
		item,
		"scale",
		Vector2(original_scale.x * 0.95, original_scale.y * 1.05),
		RETURN_TWEEN_DURATION * 0.15
	)

	# Ensure exact original scale is restored at the end
	scale_tween.tween_property(item, "scale", original_scale, RETURN_TWEEN_DURATION * 0.25)

	# Make sure original scale is properly restored in tween callback
	tween.tween_callback(
		func():
			# Force exact scale restoration
			item.scale = original_scale
			# FIXED: Reset cursor after return animation completes
			if cursor_manager:
				cursor_manager.update_cursor("default")
			# Open the document when it returns to the table
			#if is_openable_document(item):
			#emit_signal("item_opened", item)
	)

	# Play a return sound
	# NEW: Use new return sound
	if audio_player:
		audio_player.stream = document_return_sound
		audio_player.pitch_scale = randf_range(0.95, 1.05)
		audio_player.play()


## Gets the size of a node, handling different node types.
##
## Attempts to determine the size of the item based on its type.
## @param item The Node2D to get the size of.
## @return The size of the item in pixels, scaled by the item's scale.
func get_item_size(item: Node2D) -> Vector2:
	if item is Sprite2D and item.texture:
		return item.texture.get_size() * item.scale
	# Use the helper function which handles various node types
	var rect = _get_node_rect(item)
	if rect.size != Vector2.ZERO:
		return rect.size * item.scale
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

	# Check if mouse is over the stamp bar area when it's visible
	if is_instance_valid(_stamp_bar_controller) and _stamp_bar_controller.is_visible:
		# Get the stamp bar node and check if we're over it
		var stamp_bar = _stamp_bar_controller.get_node_or_null("StampBar")
		if is_instance_valid(stamp_bar):
			# Check if position is within the stamp bar's bounds
			var local_pos = stamp_bar.to_local(pos)
			if _get_node_rect(stamp_bar).has_point(local_pos):
				return null  # Mouse is over stamp bar, don't allow picking up documents

	# Regular draggable item finding logic - now properly uses z-index
	var topmost_item = null
	var highest_z = -999999  # Start with very low value

	for item in draggable_items:
		if item.visible and _get_node_rect(item).has_point(item.to_local(pos)):
			# Check if this item has a higher z-index than current topmost
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
## @return A string identifying the drop zone
## ("inspection_table", "suspect_panel", "suspect", or "none").
func identify_drop_zone(pos: Vector2) -> String:
	if inspection_table and _get_node_rect(inspection_table).has_point(inspection_table.to_local(pos)):
		return "inspection_table"
	elif suspect_panel and _get_node_rect(suspect_panel).has_point(suspect_panel.to_local(pos)):
		# If shutter is closed, don't allow suspect panel
		if office_shutter.active_shutter_state and office_shutter.ShutterState.CLOSED:
			return "none"
		return "suspect_panel"
	elif suspect and _get_node_rect(suspect).has_point(suspect.to_local(pos)):
		# If shutter is closed, don't allow suspect
		if office_shutter.active_shutter_state and office_shutter.ShutterState.CLOSED:
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


### Handles document drop logic
func _handle_document_drop(mouse_pos: Vector2):
	var drop_zone = identify_drop_zone(mouse_pos)

	# Get document controller to check current state
	var doc_controller = get_document_controller(dragged_item)
	var was_open = doc_controller and doc_controller.is_document_open()

	# If dropping on inspection table and document was already open, keep it open
	if drop_zone == "inspection_table" and was_open:
		# No need to emit open signal if document is already open
		dragged_item.z_index = ConstantZIndexes.Z_INDEX.IDLE_DOCUMENT
	# If dropping on inspection table and document was closed, open it
	elif drop_zone == "inspection_table" and !was_open:
		# Only open if it wasn't already open
		emit_signal("item_opened", dragged_item)
		# Trigger tutorial action for document placed on table
		if TutorialManager:
			TutorialManager.trigger_tutorial_action("document_placed_on_table")
	# If dropping on suspect_panel, suspect, or none
	else:
		# Always close when dropping on suspect
		emit_signal("item_closed", dragged_item)

		# If dropping on suspect, emit passport_returned signal
		if drop_zone == "suspect" and dragged_item.name == "Passport":
			emit_signal("passport_returned", dragged_item)
			# Trigger tutorial action for document returned
			if TutorialManager:
				TutorialManager.trigger_tutorial_action("document_returned")
			if stamp_system_manager:
				stamp_system_manager.clear_passport_stamps()
			else:
				push_error("Cannot clear passport stamps: StampSystemManager is null")


## Plays the open document sound.
##
## Prevents duplicate sound playing by tracking sound state.
func play_open_sound():
	if not open_sound_played and audio_player:
		audio_player.stream = preload("res://assets/audio/passport_sfx/open_passport_audio.mp3")
		# Random pitch variation for document open sound
		audio_player.pitch_scale = randf_range(0.9, 1.2)
		audio_player.play()
		open_sound_played = true
		close_sound_played = false
		block_sound_played = false


## Plays the close document sound.
##
## Prevents duplicate sound playing by tracking sound state.
func play_close_sound():
	if not close_sound_played and audio_player:
		audio_player.stream = preload("res://assets/audio/passport_sfx/close_passport_audio.mp3")
		# Random pitch variation for document close sound
		audio_player.pitch_scale = randf_range(0.9, 1.2)
		audio_player.play()
		close_sound_played = true
		open_sound_played = false
		block_sound_played = false


## Plays the close document sound.
##
## Prevents duplicate sound playing by tracking sound state.
func play_block_sound():
	if not block_sound_played and audio_player:
		audio_player.stream = preload("res://assets/audio/passport_sfx/block_passport_audio.mp3")
		# Random pitch variation for document close sound
		audio_player.pitch_scale = randf_range(0.9, 1.2)
		audio_player.play()
		block_sound_played = true


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
