# StatsManager.gd
class_name StatsManager
extends Node

var current_stats: ShiftStats

func _ready():
	current_stats = ShiftStats.new()

func get_new_stats() -> ShiftStats:
	return ShiftStats.new()

func check_stamp_accuracy(stamp_pos: Vector2, passport: Node2D) -> bool:
	# Get the visa outline rectangle in global coordinates
	var visa_rect = Rect2(
		passport.global_position + Vector2(20, 20),  # Adjust based on your visa position
		Vector2(160, 80)  # Adjust based on your visa size
	)
	
	# Get stamp rectangle
	var stamp_rect = Rect2(
		stamp_pos - Vector2(25, 25),  # Half stamp size
		Vector2(50, 50)  # Stamp size
	)
	
	# Calculate overlap percentage
	var overlap_area = stamp_rect.intersection(visa_rect).get_area()
	var stamp_area = stamp_rect.get_area()
	
	var accuracy = overlap_area / stamp_area
	
	# Return true if within 10% of perfect placement
	return abs(1.0 - accuracy) <= 0.1
