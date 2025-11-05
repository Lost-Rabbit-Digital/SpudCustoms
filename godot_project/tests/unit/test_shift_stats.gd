extends GutTest

# Unit tests for ShiftStats.gd
# Tests bonus calculation methods and stat tracking

var shift_stats: ShiftStats


func before_each():
	shift_stats = ShiftStats.new()


func after_each():
	shift_stats = null


# Test missile bonus calculation
func test_get_missile_bonus_with_no_perfect_hits():
	shift_stats.perfect_hits = 0
	assert_eq(shift_stats.get_missile_bonus(), 0, "Missile bonus should be 0 with no perfect hits")


func test_get_missile_bonus_with_one_perfect_hit():
	shift_stats.perfect_hits = 1
	assert_eq(
		shift_stats.get_missile_bonus(), 150, "Missile bonus should be 150 with 1 perfect hit"
	)


func test_get_missile_bonus_with_multiple_perfect_hits():
	shift_stats.perfect_hits = 5
	assert_eq(
		shift_stats.get_missile_bonus(),
		750,
		"Missile bonus should be 750 with 5 perfect hits (5 * 150)"
	)


# Test accuracy bonus calculation
func test_get_accuracy_bonus_with_no_stamps():
	shift_stats.total_stamps = 0
	shift_stats.perfect_stamps = 0
	assert_eq(shift_stats.get_accuracy_bonus(), 0, "Accuracy bonus should be 0 with no stamps")


func test_get_accuracy_bonus_with_perfect_stamps():
	shift_stats.total_stamps = 5
	shift_stats.perfect_stamps = 3
	assert_eq(
		shift_stats.get_accuracy_bonus(),
		600,
		"Accuracy bonus should be 600 with 3 perfect stamps (3 * 200)"
	)


func test_get_accuracy_bonus_all_perfect():
	shift_stats.total_stamps = 10
	shift_stats.perfect_stamps = 10
	assert_eq(
		shift_stats.get_accuracy_bonus(),
		2000,
		"Accuracy bonus should be 2000 with 10 perfect stamps"
	)


# Test speed bonus calculation
func test_get_speed_bonus_with_no_time_left():
	shift_stats.processing_time_left = 0
	assert_eq(shift_stats.get_speed_bonus(), 0, "Speed bonus should be 0 with no time remaining")


func test_get_speed_bonus_with_time_remaining():
	shift_stats.processing_time_left = 5.0
	assert_eq(
		shift_stats.get_speed_bonus(),
		500,
		"Speed bonus should be 500 with 5 seconds remaining (5 * 100)"
	)


func test_get_speed_bonus_with_partial_second():
	shift_stats.processing_time_left = 3.7
	assert_eq(
		shift_stats.get_speed_bonus(), 370, "Speed bonus should be 370 with 3.7 seconds remaining"
	)


func test_get_speed_bonus_with_negative_time():
	shift_stats.processing_time_left = -5.0
	assert_eq(shift_stats.get_speed_bonus(), 0, "Speed bonus should be 0 with negative time")


# Test total bonus calculation
func test_get_total_bonus_combines_all_bonuses():
	shift_stats.perfect_hits = 2  # 300 points
	shift_stats.total_stamps = 5
	shift_stats.perfect_stamps = 3  # 600 points
	shift_stats.processing_time_left = 4.0  # 400 points

	var expected_total = 300 + 600 + 400
	assert_eq(
		shift_stats.get_total_bonus(), expected_total, "Total bonus should sum all bonuses: 1300"
	)


func test_get_total_bonus_with_zero_bonuses():
	shift_stats.perfect_hits = 0
	shift_stats.total_stamps = 0
	shift_stats.processing_time_left = 0
	assert_eq(shift_stats.get_total_bonus(), 0, "Total bonus should be 0 when all bonuses are 0")


# Test reset functionality
func test_reset_clears_all_stats():
	# Set some values
	shift_stats.shift_number = 5
	shift_stats.total_stamps = 10
	shift_stats.potatoes_approved = 8
	shift_stats.potatoes_rejected = 2
	shift_stats.missiles_fired = 5
	shift_stats.perfect_hits = 3
	shift_stats.perfect_stamps = 7
	shift_stats.final_score = 5000

	# Reset
	shift_stats.reset()

	# Verify all values are 0
	assert_eq(shift_stats.shift_number, 0, "Shift number should be 0 after reset")
	assert_eq(shift_stats.total_stamps, 0, "Total stamps should be 0 after reset")
	assert_eq(shift_stats.potatoes_approved, 0, "Potatoes approved should be 0 after reset")
	assert_eq(shift_stats.potatoes_rejected, 0, "Potatoes rejected should be 0 after reset")
	assert_eq(shift_stats.missiles_fired, 0, "Missiles fired should be 0 after reset")
	assert_eq(shift_stats.perfect_hits, 0, "Perfect hits should be 0 after reset")
	assert_eq(shift_stats.perfect_stamps, 0, "Perfect stamps should be 0 after reset")
	assert_eq(shift_stats.final_score, 0, "Final score should be 0 after reset")


# Test edge cases
func test_missile_bonus_with_large_number():
	shift_stats.perfect_hits = 1000
	assert_eq(
		shift_stats.get_missile_bonus(),
		150000,
		"Missile bonus should handle large numbers correctly"
	)


func test_accuracy_bonus_edge_case_one_stamp():
	shift_stats.total_stamps = 1
	shift_stats.perfect_stamps = 1
	assert_eq(shift_stats.get_accuracy_bonus(), 200, "Accuracy bonus should work with single stamp")
