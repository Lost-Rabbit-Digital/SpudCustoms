# ShiftStats.gd
class_name ShiftStats
extends RefCounted

var total_stamps: int = 0
var perfect_stamps: int = 0
var potatoes_approved: int = 0
var potatoes_rejected: int = 0
var missiles_fired: int = 0
var missiles_hit: int = 0
var perfect_hits: int = 0
var hit_rate: float = 0.0
var time_taken: float = 0.0
var processing_time_left: float = 0.0

func reset():
	total_stamps = 0
	perfect_stamps = 0
	potatoes_approved = 0
	potatoes_rejected = 0
	missiles_fired = 0
	missiles_hit = 0
	perfect_hits = 0
	time_taken = 0.0
	processing_time_left = 0.0

func get_accuracy_bonus() -> int:
	return perfect_stamps * 100  # 100 points per perfect stamp
	
func get_missile_bonus() -> int:
	return perfect_hits * 150  # 150 points per perfect hit
