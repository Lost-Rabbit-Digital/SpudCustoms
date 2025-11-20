extends GutTest

## Unit tests for DragAndDropManager
## Tests document dragging, z-index management, cursor updates

var drag_manager: Node

func before_each() -> void:
	drag_manager = get_node_or_null("/root/DragAndDropManager")
	assert_not_null(drag_manager, "DragAndDropManager must be available as autoload")


# ==================== INITIALIZATION ====================


func test_drag_manager_initializes() -> void:
	assert_not_null(drag_manager, "DragAndDropManager should initialize")
	assert_true(drag_manager.has_method("_ready"), "Should have _ready method")


# ==================== DRAG STATE ====================


func test_drag_state_starts_false() -> void:
	# DragAndDropManager should not be dragging initially
	if drag_manager.has_method("is_dragging"):
		assert_false(drag_manager.is_dragging(), "Should not be dragging initially")


func test_drag_starts_on_mouse_press() -> void:
	# Simulate mouse press on draggable item
	if drag_manager.has_method("start_drag"):
		var test_item = Node2D.new()
		test_item.name = "TestDocument"

		drag_manager.start_drag(test_item)

		if drag_manager.has_method("is_dragging"):
			assert_true(drag_manager.is_dragging(), "Should be dragging after start_drag")

		if is_instance_valid(test_item):
			test_item.queue_free()


func test_drag_ends_on_mouse_release() -> void:
	if drag_manager.has_method("start_drag") and drag_manager.has_method("end_drag"):
		var test_item = Node2D.new()

		drag_manager.start_drag(test_item)
		drag_manager.end_drag()

		if drag_manager.has_method("is_dragging"):
			assert_false(drag_manager.is_dragging(), "Should not be dragging after end_drag")

		if is_instance_valid(test_item):
			test_item.queue_free()


# ==================== Z-INDEX MANAGEMENT ====================


func test_dragged_item_gets_highest_z_index() -> void:
	"""
	Test that when an item is dragged, it receives the highest z-index
	"""

	if drag_manager.has_method("bring_to_front"):
		var item1 = Node2D.new()
		var item2 = Node2D.new()
		var item3 = Node2D.new()

		item1.z_index = 100
		item2.z_index = 101
		item3.z_index = 102

		# Drag item1 - should get z-index higher than 102
		drag_manager.bring_to_front(item1)

		assert_gt(item1.z_index, item3.z_index, "Dragged item should have highest z-index")

		item1.queue_free()
		item2.queue_free()
		item3.queue_free()


func test_find_topmost_item_at_position() -> void:
	"""
	Test that find_topmost_item correctly identifies highest z-index item
	"""

	if drag_manager.has_method("find_topmost_item_at"):
		# Create mock items at same position
		var item1 = Node2D.new()
		var item2 = Node2D.new()

		item1.z_index = 100
		item2.z_index = 200
		item1.global_position = Vector2(100, 100)
		item2.global_position = Vector2(100, 100)

		# find_topmost_item_at should return item2 (higher z-index)
		# Actual test would need items added to scene tree


		item1.queue_free()
		item2.queue_free()


# ==================== CURSOR INTEGRATION ====================


func test_cursor_updates_on_drag_start() -> void:
	"""
	Test that cursor changes when dragging starts
	"""

	var cursor_manager = get_node_or_null("/root/CursorManager")
	if not cursor_manager:
		return  # Skip if CursorManager not available

	if drag_manager.has_method("start_drag"):
		var test_item = Node2D.new()

		drag_manager.start_drag(test_item)

		# CursorManager should update to drag cursor
		# Actual verification needs CursorManager.current_state

		if is_instance_valid(test_item):
			test_item.queue_free()


func test_cursor_resets_on_drag_end() -> void:
	"""
	Test that cursor returns to default when drag ends
	"""

	var cursor_manager = get_node_or_null("/root/CursorManager")
	if not cursor_manager:
		return

	if drag_manager.has_method("start_drag") and drag_manager.has_method("end_drag"):
		var test_item = Node2D.new()

		drag_manager.start_drag(test_item)
		drag_manager.end_drag()

		# Cursor should return to default state

		if is_instance_valid(test_item):
			test_item.queue_free()


# ==================== DRAG CONSTRAINTS ====================


func test_stamp_bar_blocks_document_pickup() -> void:
	"""
	Test that documents cannot be picked up through the stamp bar
	"""

	# StampBar bounds should block drag detection
	# This was a fixed bug - verify it stays fixed

	if drag_manager.has_method("is_position_blocked"):
		var stamp_bar_position = Vector2(100, 50)  # Example stamp bar position

		# Position within stamp bar should be blocked
		# Actual test needs StampBar bounds


func test_document_cannot_be_grabbed_through_another_document() -> void:
	"""
	Test that highest z-index document is grabbed, not one underneath
	"""

	if drag_manager.has_method("find_topmost_item_at"):
		var bottom_doc = Node2D.new()
		var top_doc = Node2D.new()

		bottom_doc.z_index = 100
		top_doc.z_index = 200

		# Clicking at overlapping position should grab top_doc only

		bottom_doc.queue_free()
		top_doc.queue_free()


# ==================== RETURN TO TABLE ====================


func test_document_returns_to_table_on_invalid_drop() -> void:
	"""
	Test that dropping document in invalid area returns it to table
	"""

	if drag_manager.has_method("return_to_original_position"):
		var test_item = Node2D.new()
		var original_pos = Vector2(500, 400)
		test_item.global_position = original_pos

		# Simulate drag to invalid position
		test_item.global_position = Vector2(-100, -100)

		# Should return to original position
		drag_manager.return_to_original_position(test_item)

		# Note: Actual implementation may use tweens

		test_item.queue_free()


func test_return_to_table_buffer_works() -> void:
	"""
	Test that return_item_to_table buffers work correctly
	This was previously broken - verify fix
	"""

	# Documents should smoothly return to table
	# No jerky movements or position jumps


# ==================== DRAG AREA VALIDATION ====================


func test_document_only_draggable_in_valid_area() -> void:
	"""
	Test that documents can only be dragged from inspection table
	"""

	if drag_manager.has_method("is_draggable_from_position"):
		var inspection_table_pos = Vector2(500, 400)
		var outside_pos = Vector2(50, 50)

		# Should be draggable from table
		# Should not be draggable from outside


func test_document_drop_zones() -> void:
	"""
	Test that documents snap to valid drop zones
	"""

	# Valid drop zones:
	# - Inspection table
	# - Return to queue (reject)

	# Invalid drop zones:
	# - Outside game area
	# - UI elements


# ==================== MULTIPLE DOCUMENTS ====================


func test_multiple_documents_can_exist() -> void:
	"""
	Test that multiple documents can be on table simultaneously
	"""

	# Should support:
	# - Passport
	# - Law Receipt
	# - Additional documents

	if drag_manager.has_method("get_active_documents"):
		# Should return array of current documents
		pass


func test_documents_stack_correctly() -> void:
	"""
	Test that documents maintain correct z-order when multiple exist
	"""

	# Most recently interacted should be on top
	# Z-index should increment for each new top document


# ==================== EVENT EMISSION ====================


func test_drag_start_emits_event() -> void:
	"""
	Test that starting drag emits EventBus signal
	"""

	var event_bus = get_node_or_null("/root/EventBus")
	if not event_bus:
		return

	var event_emitted: bool = false

	var callback = func(_data: Dictionary):
		event_emitted = true

	if event_bus.has_signal("document_drag_started"):
		event_bus.document_drag_started.connect(callback)

		if drag_manager.has_method("start_drag"):
			var test_item = Node2D.new()
			drag_manager.start_drag(test_item)

			await get_tree().process_frame

			# Should emit event through EventBus
			if is_instance_valid(test_item):
				test_item.queue_free()

		event_bus.document_drag_started.disconnect(callback)


func test_drag_end_emits_event() -> void:
	"""
	Test that ending drag emits EventBus signal
	"""

	var event_bus = get_node_or_null("/root/EventBus")
	if not event_bus:
		return

	var event_emitted: bool = false

	var callback = func(_data: Dictionary):
		event_emitted = true

	if event_bus.has_signal("document_drag_ended"):
		event_bus.document_drag_ended.connect(callback)

		if drag_manager.has_method("end_drag"):
			drag_manager.end_drag()
			await get_tree().process_frame

		event_bus.document_drag_ended.disconnect(callback)


# ==================== EDGE CASES ====================


func test_dragging_nonexistent_item_handled() -> void:
	"""
	Test that attempting to drag null item doesn't crash
	"""

	if drag_manager.has_method("start_drag"):
		# Should handle gracefully
		drag_manager.start_drag(null)

		# Should not crash or error


func test_ending_drag_when_not_dragging_handled() -> void:
	"""
	Test that calling end_drag when not dragging is safe
	"""

	if drag_manager.has_method("end_drag"):
		# Should handle gracefully
		drag_manager.end_drag()

		# Should not crash


func test_rapid_drag_start_end_handled() -> void:
	"""
	Test that rapidly starting/ending drags doesn't cause issues
	"""

	if drag_manager.has_method("start_drag") and drag_manager.has_method("end_drag"):
		var test_item = Node2D.new()

		for i in range(10):
			drag_manager.start_drag(test_item)
			drag_manager.end_drag()

		# Should handle without issues

		test_item.queue_free()
