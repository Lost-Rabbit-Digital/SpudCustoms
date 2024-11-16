extends Node2D

@export var head: AnimatedSprite2D
@export var face: AnimatedSprite2D
@export var torso: AnimatedSprite2D

func _ready():
	# Only randomize once when scene starts
	randomize()
	randomise_character()

# Remove _process since we don't want to randomize every frame
# func _process would make it change rapidly

func randomise_character():
	# Use correct animation names for each sprite
	if head and head.sprite_frames:
		var frame_count = head.sprite_frames.get_frame_count("head")
		if frame_count > 0:
			head.frame = randi_range(0, frame_count - 1)
			
	if face and face.sprite_frames:
		var frame_count = face.sprite_frames.get_frame_count("face")
		if frame_count > 0:
			face.frame = randi_range(0, frame_count - 1)
			
	if torso and torso.sprite_frames:
		var frame_count = torso.sprite_frames.get_frame_count("torso")
		if frame_count > 0:
			torso.frame = randi_range(0, frame_count - 1)

# Optional: Add input to randomize when pressing space
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Space bar
		randomise_character()
