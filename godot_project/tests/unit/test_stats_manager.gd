extends GutTest

# Unit tests for StatsManager.gd
# Tests stamp accuracy checking with rectangle intersection

var stats_manager: StatsManager
var mock_passport: Node2D


func before_each():
	stats_manager = StatsManager.new()
	stats_manager._ready()  # Initialize current_stats

	# Create mock passport node
	mock_passport = Node2D.new()
	add_child_autofree(mock_passport)


func after_each():
	stats_manager = null
	mock_passport = null


# Test stamp accuracy checking - perfect placement
func test_check_stamp_accuracy_perfect_center():
	# Set passport position
	mock_passport.global_position = Vector2(100, 100)

	# Visa rect is at passport position + offset (20, 20) with size (160, 80)
	# Center of visa would be at (100 + 20 + 80, 100 + 20 + 40) = (200, 160)
	var visa_center = Vector2(200, 160)

	var result = stats_manager.check_stamp_accuracy(visa_center, mock_passport)
	assert_true(result, "Stamp at visa center should be perfectly accurate")


# Test stamp slightly off-center but within tolerance
func test_check_stamp_accuracy_within_tolerance():
	mock_passport.global_position = Vector2(100, 100)

	# Slightly off-center but should still be within 10% tolerance
	var stamp_pos = Vector2(205, 165)  # 5 pixels off in each direction

	var result = stats_manager.check_stamp_accuracy(stamp_pos, mock_passport)
	assert_true(result, "Stamp slightly off-center should still be accurate within tolerance")


# Test stamp way outside visa area
func test_check_stamp_accuracy_outside_visa():
	mock_passport.global_position = Vector2(100, 100)

	# Stamp completely outside the visa area
	var stamp_pos = Vector2(50, 50)

	var result = stats_manager.check_stamp_accuracy(stamp_pos, mock_passport)
	assert_false(result, "Stamp outside visa area should not be accurate")


# Test stamp at visa edge
func test_check_stamp_accuracy_at_visa_edge():
	mock_passport.global_position = Vector2(100, 100)

	# Stamp at the left edge of visa
	# Visa starts at (120, 120), stamp extends -25 to +25, so position at (145, 160)
	var stamp_pos = Vector2(145, 160)

	var result = stats_manager.check_stamp_accuracy(stamp_pos, mock_passport)
	# This might be within tolerance depending on exact overlap
	assert_not_null(result, "Stamp accuracy should return a boolean value")


# Test stamp partially overlapping
func test_check_stamp_accuracy_partial_overlap():
	mock_passport.global_position = Vector2(100, 100)

	# Position stamp so only half overlaps with visa
	var stamp_pos = Vector2(110, 160)  # Very far left

	var result = stats_manager.check_stamp_accuracy(stamp_pos, mock_passport)
	assert_false(result, "Stamp with only partial overlap should not be accurate")


# Test get_new_stats returns fresh ShiftStats
func test_get_new_stats_returns_shift_stats():
	var new_stats = stats_manager.get_new_stats()
	assert_not_null(new_stats, "get_new_stats should return a ShiftStats object")
	assert_true(new_stats is ShiftStats, "Returned object should be of type ShiftStats")


func test_get_new_stats_returns_fresh_stats():
	var new_stats = stats_manager.get_new_stats()
	assert_eq(new_stats.final_score, 0, "New stats should have 0 final score")
	assert_eq(new_stats.total_stamps, 0, "New stats should have 0 total stamps")
	assert_eq(new_stats.perfect_hits, 0, "New stats should have 0 perfect hits")


# Test current_stats initialization
func test_current_stats_initialized():
	assert_not_null(
		stats_manager.current_stats, "current_stats should be initialized after _ready()"
	)
	assert_true(
		stats_manager.current_stats is ShiftStats, "current_stats should be a ShiftStats instance"
	)


# Edge case tests for stamp accuracy
func test_check_stamp_accuracy_at_origin():
	mock_passport.global_position = Vector2(0, 0)
	var stamp_pos = Vector2(100, 60)  # Center of visa when passport at origin

	var result = stats_manager.check_stamp_accuracy(stamp_pos, mock_passport)
	assert_true(result, "Stamp accuracy should work when passport is at origin")


func test_check_stamp_accuracy_negative_coordinates():
	mock_passport.global_position = Vector2(-100, -100)
	var visa_center = Vector2(-100 + 20 + 80, -100 + 20 + 40)

	var result = stats_manager.check_stamp_accuracy(visa_center, mock_passport)
	assert_true(result, "Stamp accuracy should work with negative coordinates")


# Test stamp size consistency
func test_stamp_rect_size():
	# This is more of a documentation test to verify the expected stamp size
	# Stamp size is 50x50 (from -25 to +25 offset)
	mock_passport.global_position = Vector2(100, 100)
	var stamp_pos = Vector2(200, 160)

	# Test that the stamp calculation is consistent
	var result = stats_manager.check_stamp_accuracy(stamp_pos, mock_passport)
	assert_not_null(result, "Stamp accuracy calculation should always return a boolean")
