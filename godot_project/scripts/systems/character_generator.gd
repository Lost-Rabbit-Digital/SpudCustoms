extends Node2D
class_name CharacterGenerator

# Export node references for both mugshot and passport sprites
@export_group("Character Sprites")
@export var head: AnimatedSprite2D
@export var face: AnimatedSprite2D
@export var torso: AnimatedSprite2D
@export var foreground_shadow: Sprite2D

# Track current character state
@export_group("Generation Settings")
@export var race: String = "Russet"  # Default to Russet
@export var sex: String = "Male"       # Default to Male
@export var current_head_frame: int = 0
@export var current_face_frame: int = 0
@export var current_body_frame: int = 0

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
	
func set_sex(new_sex: String):
	sex = new_sex
	update_sprite_animations()

func update_sprite_animations():
	# Update visuals based on the current race and sex
	if head and head.sprite_frames:
		var head_anim = race.to_lower().replace(" ", "_") + "_head_" + sex
		if head.sprite_frames.has_animation(head_anim):
			head.animation = head_anim
			head.frame = current_head_frame
			head.pause()  # Ensure animation doesn't play
		else:
			print("Warning: Animation not found: ", head_anim)
	
	if face and face.sprite_frames:
		var face_anim = race.to_lower().replace(" ", "_") + "_face_" + sex
		if face.sprite_frames.has_animation(face_anim):
			face.animation = face_anim
			face.frame = current_face_frame
			face.pause()  # Ensure animation doesn't play
		else:
			print("Warning: Animation not found: ", face_anim)
	
	if torso and torso.sprite_frames:
		var torso_anim = race.to_lower().replace(" ", "_") + "_body_" + sex
		if torso.sprite_frames.has_animation(torso_anim):
			torso.animation = torso_anim
			torso.frame = current_body_frame
			torso.pause()  # Ensure animation doesn't play
		else:
			print("Warning: Animation not found: ", torso_anim)


func randomise_character():
	# These counts should match your actual sprite atlas frame counts for each sex variant
	var frame_counts = {
		"Russet": {
			"Male": {
				"head": head.sprite_frames.get_frame_count("russet_head_Male"),
				"face": face.sprite_frames.get_frame_count("russet_face_Male"),
				"body": torso.sprite_frames.get_frame_count("russet_body_Male")
			},
			"Female": {
				"head": head.sprite_frames.get_frame_count("russet_head_Female"),
				"face": face.sprite_frames.get_frame_count("russet_face_Female"),
				"body": torso.sprite_frames.get_frame_count("russet_body_Female")
			}
		},
		"Purple Majesty": {
			"Male": {
				"head": head.sprite_frames.get_frame_count("purple_majesty_head_Male"),
				"face": face.sprite_frames.get_frame_count("purple_majesty_face_Male"),
				"body": torso.sprite_frames.get_frame_count("purple_majesty_body_Male")
			},
			"Female": {
				"head": head.sprite_frames.get_frame_count("purple_majesty_head_Female"),
				"face": face.sprite_frames.get_frame_count("purple_majesty_face_Female"),
				"body": torso.sprite_frames.get_frame_count("purple_majesty_body_Female")
			}
		},
		"Sweet Potato": {
			"Male": {
				"head": head.sprite_frames.get_frame_count("sweet_potato_head_Male"),
				"face": face.sprite_frames.get_frame_count("sweet_potato_face_Male"),
				"body": torso.sprite_frames.get_frame_count("sweet_potato_body_Male")
			},
			"Female": {
				"head": head.sprite_frames.get_frame_count("sweet_potato_head_Female"),
				"face": face.sprite_frames.get_frame_count("sweet_potato_face_Female"),
				"body": torso.sprite_frames.get_frame_count("sweet_potato_body_Female")
			}
		},
		"Yukon Gold": {
			"Male": {
				"head": head.sprite_frames.get_frame_count("yukon_gold_head_Male"),
				"face": face.sprite_frames.get_frame_count("yukon_gold_face_Male"),
				"body": torso.sprite_frames.get_frame_count("yukon_gold_body_Male")
			},
			"Female": {
				"head": head.sprite_frames.get_frame_count("yukon_gold_head_Female"),
				"face": face.sprite_frames.get_frame_count("yukon_gold_face_Female"),
				"body": torso.sprite_frames.get_frame_count("yukon_gold_body_Female")
			}
		}
	}
	
	# Pick a random race
	var races = frame_counts.keys()
	race = races[randi() % races.size()]
	
	# Pick a random sex
	sex = ["Male", "Female"][randi() % 2]
	
	# Get the correct counts for the chosen race and sex
	var counts = frame_counts[race][sex]
	
	# Generate random frames
	current_head_frame = randi() % max(1, counts.head)  # Avoid division by zero
	current_face_frame = randi() % max(1, counts.face)
	current_body_frame = randi() % max(1, counts.body)
	
	# Add debug print to see what's being generated
	print("Randomized character:")
	print("  Race: ", race)
	print("  Sex: ", sex)
	print("  Head frame: ", current_head_frame)
	print("  Face frame: ", current_face_frame)
	print("  Body frame: ", current_body_frame)
	
	# Update the sprites
	update_sprite_animations()

# Function to get current character data
func get_character_data() -> Dictionary:
	return {
		"race": race,
		"sex": sex,
		"head_frame": current_head_frame,
		"face_frame": current_face_frame,
		"body_frame": current_body_frame
	}

# Function to set character data directly
func set_character_data(data: Dictionary) -> void:
	if data.has("race"):
		race = data.race
	if data.has("sex"):
		sex = data.sex
	if data.has("head_frame"):
		current_head_frame = data.head_frame
	if data.has("face_frame"):
		current_face_frame = data.face_frame
	if data.has("body_frame"):
		current_body_frame = data.body_frame
	update_sprite_animations()
	
func fade_out_foreground_shadow(duration: float = 1.5):
	# Get reference to the foreground shadow node
	if not foreground_shadow:
		push_error("ForegroundShadow is not assigned in the inspector")
		return
		
	# Store the initial color with full alpha
	var transparent_color = Color(0.063, 0.035, 0.071, 0.0)
	
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
	var opaque_color = Color(0.063, 0.035, 0.071, 1.0)
	
	# Create tween for fading the shadow
	var tween = create_tween()
	
	# Fade out the shadow by modifying the alpha channel
	tween.tween_property(
		foreground_shadow, 
		"modulate", 
		opaque_color, 
		duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
