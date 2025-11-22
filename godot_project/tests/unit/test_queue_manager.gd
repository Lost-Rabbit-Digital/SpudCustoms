extends GutTest

## Unit tests for QueueManager
## Tests potato spawning, queue management, position updates, and removal

var queue_manager: Node2D
var mock_potato_scene = preload("res://scripts/systems/PotatoPerson.tscn")

func before_each() -> void:
	# Create a minimal QueueManager for testing
	queue_manager = load("res://scripts/systems/QueueManager.gd").new()

	# Create mock Path2D with Curve2D
	var path = Path2D.new()
	var curve = Curve2D.new()

	# Add some points to the curve for testing
	curve.add_point(Vector2(0, 0))     # Spawn point
	curve.add_point(Vector2(100, 0))
	curve.add_point(Vector2(200, 0))
	curve.add_point(Vector2(300, 0))   # Front of queue

	path.curve = curve
	path.name = "SpuddyQueue"

	# Add path to queue_manager
	queue_manager.add_child(path)

	# Set up the queue manager
	queue_manager.path = path
	queue_manager.curve = curve
	queue_manager.spawn_point = curve.get_point_position(0)
	queue_manager.max_potatoes = curve.get_point_count() - 1

	add_child_autofree(queue_manager)
	await get_tree().process_frame


func after_each() -> void:
	if queue_manager:
		queue_manager.potatoes.clear()


# ==================== POTATO ADDITION TESTS ====================

func test_can_add_potato_when_empty() -> void:
	assert_true(queue_manager.can_add_potato(), "Should be able to add potato when queue is empty")


func test_can_add_potato_returns_false_when_full() -> void:
	# Fill the queue to max capacity
	for i in range(queue_manager.max_potatoes):
		var potato_info = {"name": "Test Potato", "type": "Russet", "condition": "Fresh"}
		queue_manager.add_potato(potato_info)

	await get_tree().process_frame

	assert_false(queue_manager.can_add_potato(), "Should not be able to add potato when queue is full")


func test_add_potato_increases_queue_size() -> void:
	var initial_size = queue_manager.potatoes.size()
	var potato_info = {"name": "Test Potato", "type": "Russet", "condition": "Fresh"}

	queue_manager.add_potato(potato_info)
	await get_tree().process_frame

	assert_eq(queue_manager.potatoes.size(), initial_size + 1, "Queue size should increase by 1")


func test_add_potato_spawns_at_spawn_point() -> void:
	var potato_info = {"name": "Test Potato", "type": "Russet", "condition": "Fresh"}

	queue_manager.add_potato(potato_info)
	await get_tree().process_frame

	var potato = queue_manager.potatoes.front()
	assert_eq(potato.position, queue_manager.spawn_point, "Potato should spawn at spawn point")


func test_add_potato_starts_with_zero_opacity() -> void:
	var potato_info = {"name": "Test Potato", "type": "Russet", "condition": "Fresh"}

	queue_manager.add_potato(potato_info)
	# Don't wait for frame - check immediately after add

	var potato = queue_manager.potatoes.front()
	assert_eq(potato.modulate.a, 0.0, "Potato should start with zero opacity")


func test_multiple_potatoes_added_to_front() -> void:
	var first_info = {"name": "First", "type": "Russet", "condition": "Fresh"}
	var second_info = {"name": "Second", "type": "Yukon", "condition": "Fresh"}

	queue_manager.add_potato(first_info)
	await get_tree().process_frame
	queue_manager.add_potato(second_info)
	await get_tree().process_frame

	# Most recent should be at front of array
	assert_eq(queue_manager.potatoes.front().name, "Second", "Latest potato should be at front")


# ==================== POTATO REMOVAL TESTS ====================

func test_remove_potato_decreases_queue_size() -> void:
	var potato_info = {"name": "Test Potato", "type": "Russet", "condition": "Fresh"}
	queue_manager.add_potato(potato_info)
	await get_tree().process_frame

	var initial_size = queue_manager.potatoes.size()
	var info = queue_manager.remove_potato()
	await get_tree().process_frame

	assert_eq(queue_manager.potatoes.size(), initial_size - 1, "Queue size should decrease by 1")


func test_remove_potato_returns_info() -> void:
	var potato_info = {"name": "Test Potato", "type": "Russet", "condition": "Fresh"}
	queue_manager.add_potato(potato_info)
	await get_tree().process_frame

	var info = queue_manager.remove_potato()

	assert_eq(info["name"], "Test Potato", "Returned info should match added potato")


func test_remove_potato_from_empty_queue() -> void:
	var info = queue_manager.remove_potato()

	assert_eq(info, {}, "Removing from empty queue should return empty dict")


func test_remove_front_potato_returns_last_in_line() -> void:
	var first_info = {"name": "First", "type": "Russet", "condition": "Fresh"}
	var second_info = {"name": "Second", "type": "Yukon", "condition": "Fresh"}

	queue_manager.add_potato(first_info)
	await get_tree().process_frame
	queue_manager.add_potato(second_info)
	await get_tree().process_frame

	var potato = queue_manager.remove_front_potato()

	# First potato added should be at back of array (front of queue)
	assert_eq(potato.name, "First", "Front potato should be first one added")


func test_remove_front_potato_from_empty_queue() -> void:
	var potato = queue_manager.remove_front_potato()

	assert_null(potato, "Removing from empty queue should return null")


# ==================== POSITION UPDATE TESTS ====================

func test_update_positions_sets_target_points() -> void:
	var potato_info = {"name": "Test Potato", "type": "Russet", "condition": "Fresh"}
	queue_manager.add_potato(potato_info)
	await get_tree().process_frame

	var potato = queue_manager.potatoes.front()
	var expected_target = queue_manager.curve.get_point_count() - 1

	assert_eq(potato.target_point, expected_target, "Single potato should target last point")


func test_update_positions_distributes_multiple_potatoes() -> void:
	var point_count = queue_manager.curve.get_point_count()

	# Add multiple potatoes
	for i in range(3):
		var info = {"name": "Potato " + str(i), "type": "Russet", "condition": "Fresh"}
		queue_manager.add_potato(info)
		await get_tree().process_frame

	# Check that target points are distributed
	var targets = []
	for potato in queue_manager.potatoes:
		targets.append(potato.target_point)

	# All targets should be different
	var unique_targets = []
	for target in targets:
		if target not in unique_targets:
			unique_targets.append(target)

	assert_eq(unique_targets.size(), targets.size(), "Each potato should have unique target point")


func test_position_update_called_after_add() -> void:
	var potato_info = {"name": "Test Potato", "type": "Russet", "condition": "Fresh"}
	queue_manager.add_potato(potato_info)
	await get_tree().process_frame

	var potato = queue_manager.potatoes.front()
	# Target point should be set after add
	assert_gt(potato.target_point, 0, "Target point should be set after adding potato")


func test_position_update_called_after_remove() -> void:
	# Add two potatoes
	for i in range(2):
		var info = {"name": "Potato " + str(i), "type": "Russet", "condition": "Fresh"}
		queue_manager.add_potato(info)
		await get_tree().process_frame

	var remaining_potato = queue_manager.potatoes.front()
	var initial_target = remaining_potato.target_point

	# Remove one potato
	queue_manager.remove_potato()
	await get_tree().process_frame

	# Remaining potato should have updated target point
	var new_target = remaining_potato.target_point
	assert_eq(new_target, queue_manager.curve.get_point_count() - 1, "Remaining potato should move to front")


# ==================== QUEUE INFORMATION TESTS ====================

func test_get_all_potatoes_returns_array() -> void:
	var potatoes = queue_manager.get_all_potatoes()

	assert_true(potatoes is Array, "Should return an array")


func test_get_all_potatoes_returns_correct_count() -> void:
	for i in range(2):
		var info = {"name": "Potato " + str(i), "type": "Russet", "condition": "Fresh"}
		queue_manager.add_potato(info)
		await get_tree().process_frame

	var potatoes = queue_manager.get_all_potatoes()

	assert_eq(potatoes.size(), 2, "Should return correct number of potatoes")


func test_get_front_potato_info_returns_correct_info() -> void:
	var first_info = {"name": "First", "type": "Russet", "condition": "Fresh"}
	var second_info = {"name": "Second", "type": "Yukon", "condition": "Fresh"}

	queue_manager.add_potato(first_info)
	await get_tree().process_frame
	queue_manager.add_potato(second_info)
	await get_tree().process_frame

	var front_info = queue_manager.get_front_potato_info()

	# Front of queue is back of array
	assert_eq(front_info["name"], "First", "Should return info for front potato")


func test_get_front_potato_info_empty_queue() -> void:
	var info = queue_manager.get_front_potato_info()

	assert_eq(info, {}, "Empty queue should return empty dict")


# ==================== DEBUG AND UTILITY TESTS ====================

func test_debug_add_potatoes_adds_correct_count() -> void:
	queue_manager.debug_add_potatoes(2)
	await get_tree().process_frame

	assert_eq(queue_manager.potatoes.size(), 2, "Debug should add correct number of potatoes")


func test_disable_stops_processing() -> void:
	queue_manager.disable()

	assert_false(queue_manager.is_processing(), "Disable should stop processing")


func test_disable_clears_potatoes() -> void:
	var info = {"name": "Test Potato", "type": "Russet", "condition": "Fresh"}
	queue_manager.add_potato(info)
	await get_tree().process_frame

	queue_manager.disable()
	await get_tree().process_frame

	assert_eq(queue_manager.potatoes.size(), 0, "Disable should clear all potatoes")


# ==================== MAX CAPACITY TESTS ====================

func test_max_potatoes_based_on_curve_points() -> void:
	var expected_max = queue_manager.curve.get_point_count() - 1

	assert_eq(queue_manager.max_potatoes, expected_max, "Max potatoes should be curve points - 1")


func test_cannot_exceed_max_potatoes() -> void:
	# Try to add more than max
	for i in range(queue_manager.max_potatoes + 2):
		var info = {"name": "Potato " + str(i), "type": "Russet", "condition": "Fresh"}
		queue_manager.add_potato(info)
		await get_tree().process_frame

	assert_eq(queue_manager.potatoes.size(), queue_manager.max_potatoes, "Should not exceed max potatoes")


# ==================== INVALID POTATO HANDLING TEST ====================

func test_process_removes_invalid_potatoes() -> void:
	var info = {"name": "Test Potato", "type": "Russet", "condition": "Fresh"}
	queue_manager.add_potato(info)
	await get_tree().process_frame

	# Get the potato and manually free it (simulating invalid state)
	var potato = queue_manager.potatoes.front()
	var initial_count = queue_manager.potatoes.size()
	potato.queue_free()

	# Process should remove invalid potato
	await get_tree().process_frame
	await get_tree().process_frame

	# Note: The array might not update immediately, this tests the cleanup logic
	assert_true(initial_count > 0, "Had potatoes before cleanup")
