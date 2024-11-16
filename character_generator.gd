extends Node2D

@export var hair: AnimatedSprite2D
@export var face: AnimatedSprite2D
@export var torso: AnimatedSprite2D

var gender: String = "M"  # Default to male, can be "M" or "F"

func _ready():
	randomize()  # Initialize random seed
	randomise_character()

func set_gender(new_gender: String):
	gender = new_gender
	update_sprite_animations()
	randomise_character()

func update_sprite_animations():
	# Update each sprite's animation based on gender
	if hair and hair.sprite_frames:
		hair.play("Russel_" + gender + "_Hair")
	if face and face.sprite_frames:
		face.play("Russel_" + gender + "_Face")
	if torso and torso.sprite_frames:
		torso.play("Russel_" + gender + "_Body")

func randomise_character():
	# Use correct animation names with gender prefix
	if hair and hair.sprite_frames:
		var anim_name = "Russel_" + gender + "_Hair"
		var frame_count = hair.sprite_frames.get_frame_count(anim_name)
		if frame_count > 0:
			hair.frame = randi_range(0, frame_count - 1)
			
	if face and face.sprite_frames:
		var anim_name = "Russel_" + gender + "_Face"
		var frame_count = face.sprite_frames.get_frame_count(anim_name)
		if frame_count > 0:
			face.frame = randi_range(0, frame_count - 1)
			
	if torso and torso.sprite_frames:
		var anim_name = "Russel_" + gender + "_Body"
		var frame_count = torso.sprite_frames.get_frame_count(anim_name)
		if frame_count > 0:
			torso.frame = randi_range(0, frame_count - 1)

func _input(event):
	if event.is_action_pressed("ui_up"):  # Space bar
		randomise_character()
	elif event.is_action_pressed("ui_down"):  # Add this in Project Settings > Input Map
		gender = "F" if gender == "M" else "M"
		update_sprite_animations()
		randomise_character()

# Optional function to directly set gender
func toggle_gender():
	gender = "F" if gender == "M" else "M"
	update_sprite_animations()
	randomise_character()
