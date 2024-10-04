extends Node2D 

var current_point: int = 0
var target_point: int = 0

func move_toward(target: Vector2, speed: float):
	position = position.move_toward(target, speed)
