extends Node2D

# Export node references for both mugshot and passport sprites
@export_group("Character Sprites")
@export var hair: AnimatedSprite2D
@export var face: AnimatedSprite2D
@export var torso: AnimatedSprite2D

# Track current character state
@export_group("Generation Settings")
@export var gender: String = "M"  # Default to male, can be "M" or "F"
@export var current_hair_frame: int = 0
@export var current_face_frame: int = 0
@export var current_torso_frame: int = 0

func _ready():
	randomize()  # Initialize random seed
	update_sprite_animations()

func set_gender(new_gender: String):
	gender = new_gender
	update_sprite_animations()

func update_sprite_animations():
	# Instead of play(), just set the animation and frame directly
	if hair and hair.sprite_frames:
		hair.animation = "Russel_" + gender + "_Hair"
		hair.frame = current_hair_frame
		hair.pause()  # Ensure animation doesn't play
		
	if face and face.sprite_frames:
		face.animation = "Russel_" + gender + "_Face"
		face.frame = current_face_frame
		face.pause()  # Ensure animation doesn't play
		
	if torso and torso.sprite_frames:
		torso.animation = "Russel_" + gender + "_Body"
		torso.frame = current_torso_frame
		torso.pause()  # Ensure animation doesn't play


func randomise_character():
	var hair_anim = "Russel_" + gender + "_Hair"
	var face_anim = "Russel_" + gender + "_Face"
	var body_anim = "Russel_" + gender + "_Body"
	
	# Generate random frames and store them
	if hair and hair.sprite_frames:
		var frame_count = hair.sprite_frames.get_frame_count(hair_anim)
		if frame_count > 0:
			current_hair_frame = randi_range(0, frame_count - 1)
			
	if face and face.sprite_frames:
		var frame_count = face.sprite_frames.get_frame_count(face_anim)
		if frame_count > 0:
			current_face_frame = randi_range(0, frame_count - 1)
			
	if torso and torso.sprite_frames:
		var frame_count = torso.sprite_frames.get_frame_count(body_anim)
		if frame_count > 0:
			current_torso_frame = randi_range(0, frame_count - 1)
	
	# Update sprites with the new frames
	update_sprite_animations()

# Function to get current character data
func get_character_data() -> Dictionary:
	return {
		"gender": gender,
		"hair_frame": current_hair_frame,
		"face_frame": current_face_frame,
		"torso_frame": current_torso_frame
	}

# Function to set character data directly
func set_character_data(data: Dictionary) -> void:
	if data.has("gender"):
		gender = data.gender
	if data.has("hair_frame"):
		current_hair_frame = data.hair_frame
	if data.has("face_frame"):
		current_face_frame = data.face_frame
	if data.has("torso_frame"):
		current_torso_frame = data.torso_frame
	update_sprite_animations()
