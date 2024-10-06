extends Node2D

var score = 0

func _ready():
	$ScoreLabel.text = """Game Over

You caused too much suffering and have been removed from your post.

Your final score was:   """ + str(score)
