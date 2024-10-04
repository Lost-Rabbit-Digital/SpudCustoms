extends Node2D  # or whatever node type you're using

var target_position: Vector2

func move_toward(target: Vector2, speed: float):
	position = position.move_toward(target, speed)
