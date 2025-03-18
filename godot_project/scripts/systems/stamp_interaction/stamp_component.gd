extends Node
class_name StampComponent

# Stamp properties
var stamp_type: String = ""  # "approve" or "reject"
var stamp_texture: Texture2D
var applied_position: Vector2 = Vector2.ZERO
var applied_to: Node = null
var is_perfect: bool = false  # For perfect stamp placement

# Animation properties
var animation_progress: float = 0.0  # 0.0 to 1.0
var start_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO

func _init(type: String, texture: Texture2D):
	stamp_type = type
	stamp_texture = texture

# Get stamp approval status as bool
func is_approval() -> bool:
	return stamp_type == "approve"

# Calculate score based on stamp quality
func calculate_score() -> int:
	var base_score = 50
	if is_perfect:
		return base_score * 2  # Double for perfect placement
	return base_score
