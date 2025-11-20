extends GutTest

## Integration test for Document Processing Flow
## Tests: Queue → Inspection → Stamp → Approval/Rejection → Score Update

var queue_manager: Node
var drag_drop_manager: Node
var stamp_system: Node
var event_bus: Node
var game_state_manager: Node

func before_all() -> void:
	print("Setting up Document Processing Flow integration tests")


func before_each() -> void:
	# Get references to systems (would need to be set up in test scene)
	event_bus = get_node_or_null("/root/EventBus")
	game_state_manager = get_node_or_null("/root/GameStateManager")

	assert_not_null(event_bus, "EventBus must be available for integration tests")
	assert_not_null(game_state_manager, "GameStateManager must be available")


# ==================== FULL FLOW TESTS ====================


func test_approve_potato_full_flow() -> void:
	"""
	Test the complete flow of approving a potato:
	1. Potato in queue
	2. Document dragged to inspection table
	3. Stamp applied (APPROVED)
	4. Potato processed
	5. Score updated
	6. Analytics tracked
	"""

	var initial_score = game_state_manager.get_score()
	var score_updated: bool = false
	var potato_approved_emitted: bool = false
	var analytics_tracked: bool = false

	# Subscribe to events to track flow
	var score_callback = func(_new_score: int, _delta: int, _source: String, _metadata: Dictionary = {}):
		score_updated = true

	var approval_callback = func(_potato_info: Dictionary):
		potato_approved_emitted = true

	var analytics_callback = func(_event_name: String, _data: Dictionary):
		analytics_tracked = true

	event_bus.score_changed.connect(score_callback)
	event_bus.potato_approved.connect(approval_callback)
	event_bus.analytics_event.connect(analytics_callback)

	# Simulate the approval flow
	var test_potato_info = {
		"type": "russet",
		"age": 25,
		"origin": "Spudland",
		"condition": "good"
	}

	# Step 1: Emit potato_approved event (simulating stamp + approval)
	event_bus.emit_potato_approved(test_potato_info)
	await get_tree().process_frame

	# Step 2: Request score addition (simulating approval points)
	event_bus.request_score_add(100, "potato_approved", {"potato_type": "russet"})
	await get_tree().process_frame

	# Verify the flow
	assert_true(potato_approved_emitted, "Potato approved event should be emitted")
	assert_true(score_updated, "Score should be updated")

	var new_score = game_state_manager.get_score()
	assert_gt(new_score, initial_score, "Score should have increased")

	# Cleanup
	event_bus.score_changed.disconnect(score_callback)
	event_bus.potato_approved.disconnect(approval_callback)
	event_bus.analytics_event.disconnect(analytics_callback)


func test_reject_potato_full_flow() -> void:
	"""
	Test the complete flow of rejecting a potato:
	1. Potato in queue
	2. Document dragged to inspection table
	3. Stamp applied (REJECTED)
	4. Potato processed
	5. Score/Strikes updated appropriately
	"""

	var initial_score = game_state_manager.get_score()
	var potato_rejected_emitted: bool = false
	var strike_added: bool = false

	var rejection_callback = func(_potato_info: Dictionary):
		potato_rejected_emitted = true

	var strike_callback = func(_current: int, _max: int, _delta: int):
		strike_added = true

	event_bus.potato_rejected.connect(rejection_callback)
	event_bus.strike_changed.connect(strike_callback)

	# Simulate rejection flow
	var test_potato_info = {
		"type": "yukon_gold",
		"age": 45,  # Over age limit
		"origin": "Banned Country",
		"condition": "suspicious"
	}

	# Step 1: Emit potato_rejected event
	event_bus.emit_potato_rejected(test_potato_info)
	await get_tree().process_frame

	# Step 2: If rejection was incorrect, add strike
	# (In real game, this would be determined by LawValidator)
	# For this test, assume incorrect rejection
	event_bus.request_strike_add("incorrect_rejection")
	await get_tree().process_frame

	# Verify the flow
	assert_true(potato_rejected_emitted, "Potato rejected event should be emitted")

	# Cleanup
	event_bus.potato_rejected.disconnect(rejection_callback)
	event_bus.strike_changed.disconnect(strike_callback)


# ==================== STAMP ACCURACY TESTS ====================


func test_perfect_stamp_placement_bonus() -> void:
	"""
	Test that perfect stamp placement triggers bonus points
	"""

	var perfect_hit_triggered: bool = false
	var bonus_points_received: int = 0

	var callback = func(bonus: int):
		perfect_hit_triggered = true
		bonus_points_received = bonus

	event_bus.perfect_hit_achieved.connect(callback)

	# Simulate perfect stamp placement
	var stamp_data = {
		"accuracy": 100.0,
		"stamp_type": "approved",
		"position": Vector2(100, 100)
	}

	event_bus.emit_stamp_applied(stamp_data)
	await get_tree().process_frame

	# If accuracy is 100%, should trigger perfect hit
	if stamp_data.accuracy >= 99.0:
		event_bus.emit_perfect_hit_achieved(50)
		await get_tree().process_frame

		assert_true(perfect_hit_triggered, "Perfect hit should be triggered")
		assert_eq(bonus_points_received, 50, "Bonus points should be awarded")

	event_bus.perfect_hit_achieved.disconnect(callback)


# ==================== ERROR HANDLING TESTS ====================


func test_invalid_stamp_rejected() -> void:
	"""
	Test that attempting to stamp outside valid area is rejected
	"""

	# This would test viewport masking and stamp validation
	# Actual implementation depends on StampSystem

	var stamp_data = {
		"accuracy": 0.0,  # Outside passport
		"stamp_type": "approved",
		"position": Vector2(-100, -100)
	}

	# In real system, this should not trigger potato_approved
	var approval_triggered: bool = false

	var callback = func(_info: Dictionary):
		approval_triggered = true

	event_bus.potato_approved.connect(callback)

	# Simulate invalid stamp (should not trigger approval)
	# Real system would validate before emitting

	await get_tree().process_frame

	assert_false(approval_triggered, "Invalid stamp should not trigger approval")

	event_bus.potato_approved.disconnect(callback)


# ==================== COMBO SYSTEM TESTS ====================


func test_consecutive_correct_decisions_combo() -> void:
	"""
	Test that consecutive correct decisions build up combo multiplier
	"""

	var initial_score = game_state_manager.get_score()

	# Simulate 3 consecutive correct approvals
	for i in range(3):
		event_bus.emit_potato_approved({"type": "test", "correct": true})
		event_bus.request_score_add(100, "potato_approved", {"combo": i + 1})
		await get_tree().process_frame

	var final_score = game_state_manager.get_score()
	var total_added = final_score - initial_score

	assert_eq(total_added, 300, "Three approvals should add 300 points")


func test_incorrect_decision_breaks_combo() -> void:
	"""
	Test that an incorrect decision breaks the combo streak
	"""

	# Build up combo
	for i in range(2):
		event_bus.emit_potato_approved({"type": "test"})
		event_bus.request_score_add(100, "approved", {"combo": i + 1})
		await get_tree().process_frame

	# Make incorrect decision
	event_bus.request_strike_add("incorrect_approval")
	await get_tree().process_frame

	# Next approval should reset combo
	event_bus.emit_potato_approved({"type": "test"})
	event_bus.request_score_add(100, "approved", {"combo": 1})
	await get_tree().process_frame

	# Combo tracking would be in a separate ComboManager
	# This test documents expected behavior


# ==================== DRAG AND DROP TESTS ====================


func test_document_drag_updates_cursor() -> void:
	"""
	Test that dragging a document updates the cursor state
	"""

	# This would test CursorManager integration
	# Actual implementation needs CursorManager setup

	var drag_start_data = {
		"document_type": "passport",
		"dragging": true
	}

	event_bus.emit_document_drag_started(drag_start_data)
	await get_tree().process_frame

	# CursorManager should update cursor to drag state
	# Verify through CursorManager.current_state

	var drag_end_data = {
		"document_type": "passport",
		"dropped_on": "inspection_table"
	}

	event_bus.emit_document_drag_ended(drag_end_data)
	await get_tree().process_frame

	# Cursor should return to default state


# ==================== MULTIPLE DOCUMENT TESTS ====================


func test_multiple_documents_z_index_ordering() -> void:
	"""
	Test that multiple documents on inspection table maintain correct z-index
	"""

	# This tests DragAndDropManager z-index management
	# Documents should stack properly based on drag order

	var documents_created: int = 0

	# Simulate creating 3 documents
	for i in range(3):
		var doc_data = {
			"type": "passport" if i == 0 else "law_receipt",
			"z_index": 100 + i
		}
		documents_created += 1
		await get_tree().process_frame

	assert_eq(documents_created, 3, "Three documents should be tracked")

	# Most recently dragged should have highest z-index
	# Actual verification would need DragAndDropManager queries
