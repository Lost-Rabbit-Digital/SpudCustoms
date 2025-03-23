extends Node2D
class_name CharacterGenerator

# Export node references for both mugshot and passport sprites
@export_group("Character Sprites")
@export var head: AnimatedSprite2D  # Changed from hair to head
@export var face: AnimatedSprite2D
@export var torso: AnimatedSprite2D
@export var foreground_shadow: Sprite2D

# Track current character state
@export_group("Generation Settings")
@export var race: String = "Russet"  # Default to Russet
@export var current_head_frame: int = 0  # Changed from current_hair_frame
@export var current_face_frame: int = 0
@export var current_body_frame: int = 0  # Changed from current_torso_frame

func _ready():
	# Initialize with default state
	randomize()
	
	# Make sure we're using the correct animations initially
	update_sprite_animations()
	
	# You might want to trigger a randomization at the start
	randomise_character()

func set_race(new_race: String):
	race = new_race
	update_sprite_animations()

func update_sprite_animations():
	# Update visuals based on the current race
	if head and head.sprite_frames:  # Changed from hair to head
		var head_anim = race + "_Head"
		if head.sprite_frames.has_animation(head_anim):
			head.animation = head_anim
			head.frame = current_head_frame
			head.pause()  # Ensure animation doesn't play
	
	if face and face.sprite_frames:
		var face_anim = race + "_Face"
		if face.sprite_frames.has_animation(face_anim):
			face.animation = face_anim
			face.frame = current_face_frame
			face.pause()  # Ensure animation doesn't play
	
	if torso and torso.sprite_frames:
		var torso_anim = race + "_Body"
		if torso.sprite_frames.has_animation(torso_anim):
			torso.animation = torso_anim
			torso.frame = current_body_frame
			torso.pause()  # Ensure animation doesn't play

func randomise_character():
	# These counts should match your actual sprite atlas frame counts
	var frame_counts = {
		"Russet": {
			"head": head.sprite_frames.get_frame_count("russet_head"),
			"face": face.sprite_frames.get_frame_count("russet_face"),
			"body": torso.sprite_frames.get_frame_count("russet_body")
		},
		"Purple Majesty": {
			"head": head.sprite_frames.get_frame_count("purple_majesty_head"),
			"face": face.sprite_frames.get_frame_count("purple_majesty_face"),
			"body": torso.sprite_frames.get_frame_count("purple_majesty_body")
		},
		"Sweet Potato": {
			"head": head.sprite_frames.get_frame_count("sweet_potato_head"),
			"face": face.sprite_frames.get_frame_count("sweet_potato_face"),
			"body": torso.sprite_frames.get_frame_count("sweet_potato_body")
		},
		"Yukon Gold": {
			"head": head.sprite_frames.get_frame_count("yukon_gold_head"),
			"face": face.sprite_frames.get_frame_count("yukon_gold_face"),
			"body": torso.sprite_frames.get_frame_count("yukon_gold_body")
		}
	}
	
	# Pick a random race
	var races = frame_counts.keys()
	race = races[randi() % races.size()]
	
	# Get the correct counts for the chosen race
	var counts = frame_counts[race]
	
	# Generate random frames
	current_head_frame = randi() % max(1, counts.head)  # Avoid division by zero
	current_face_frame = randi() % max(1, counts.face)
	current_body_frame = randi() % max(1, counts.body)
	
	# Update the sprites
	update_sprite_animations()

# Function to get current character data
func get_character_data() -> Dictionary:
	return {
		"race": race,
		"head_frame": current_head_frame,  # Changed from hair_frame
		"face_frame": current_face_frame,
		"body_frame": current_body_frame   # Changed from torso_frame
	}

# Function to set character data directly
func set_character_data(data: Dictionary) -> void:
	if data.has("race"):
		race = data.race
	if data.has("head_frame"):  # Changed from hair_frame
		current_head_frame = data.head_frame
	if data.has("face_frame"):
		current_face_frame = data.face_frame
	if data.has("body_frame"):  # Changed from torso_frame
		current_body_frame = data.body_frame
	update_sprite_animations()
	
func fade_out_foreground_shadow(duration: float = 1.5):
	# Set it to opaque black
	foreground_shadow.modulate = Color(0, 0, 0, 1.0)
	
	# Get reference to the foreground shadow node
	if not foreground_shadow:
		push_error("ForegroundShadow is not assigned in the inspector")
		return
		
	# Store the initial color with full alpha
	var initial_color = foreground_shadow.modulate
	var transparent_color = Color(initial_color.r, initial_color.g, initial_color.b, 0.0)
	
	# Create tween for fading the shadow
	var tween = create_tween()
	
	# Fade out the shadow by modifying the alpha channel
	tween.tween_property(
		foreground_shadow, 
		"modulate", 
		transparent_color, 
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func fade_in_foreground_shadow(duration: float = 1.5):
	# Get reference to the foreground shadow node
	if not foreground_shadow:
		push_error("ForegroundShadow is not assigned in the inspector")
		return
	
	# Store the initial color with full alpha
	var initial_color = foreground_shadow.modulate
	var opaque_color = Color(initial_color.r, initial_color.g, initial_color.b, 1.0)
	
	# Create tween for fading the shadow
	var tween = create_tween()
	
	# Fade out the shadow by modifying the alpha channel
	tween.tween_property(
		foreground_shadow, 
		"modulate", 
		opaque_color, 
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
