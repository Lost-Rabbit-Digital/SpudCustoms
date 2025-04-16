# Updated ShiftStats.gd
class_name ShiftStats
extends RefCounted

# Basic stats
var final_score: int = 0
var shift_number: int = 0
var total_stamps: int = 0
var potatoes_approved: int = 0
var potatoes_rejected: int = 0
var missiles_fired: int = 0
var missiles_hit: int = 0
var perfect_hits: int = 0
var perfect_stamps: int = 0
var hit_rate: float = 0.0
var time_taken: float = 0.0
var processing_time_left: float = 0.0

# Bonus stats
var processing_speed_bonus: int = 0
var accuracy_bonus: int = 0
var perfect_hit_bonus: int = 0

# Runner stats
var runner_attempts: int = 0


func reset():
	shift_number = 0
	total_stamps = 0
	potatoes_approved = 0
	potatoes_rejected = 0
	missiles_fired = 0
	missiles_hit = 0
	perfect_hits = 0
	perfect_stamps = 0
	hit_rate = 0.0
	time_taken = 0.0
	processing_time_left = 0.0
	processing_speed_bonus = 0
	accuracy_bonus = 0
	perfect_hit_bonus = 0
	runner_attempts = 0
	final_score = 0


func get_missile_bonus() -> int:
	return perfect_hits * 150  # 150 points per perfect hit


func get_accuracy_bonus() -> int:
	if total_stamps > 0:
		return perfect_stamps * 200  # 200 points per perfect stamp
	return 0


func get_speed_bonus() -> int:
	# Bonus based on remaining processing time
	if processing_time_left > 0:
		return int(processing_time_left * 100)  # 100 points per second left
	return 0


func get_total_bonus() -> int:
	return get_missile_bonus() + get_accuracy_bonus() + get_speed_bonus()
