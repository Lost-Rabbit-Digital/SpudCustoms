extends Node2D

@export var passport: Node2D
@export var stats_manager: Node

const FOLDED_X_POS = -200  
const UNFOLDED_X_POS = 100
const STAMP_BAR_Y = 100    
const STAMP_SPACING = 200  
const STAMP_ANIM_DURATION = 0.3

var stamps_visible = false
var is_stamping = false
var stamp_cooldown = 1.0
var current_stamp_texture: Texture2D
var current_stamp_type: String
var last_mouse_position: Vector2

@onready var sfx_player = $"../../../SystemManagers/AudioManager/SFXPool"
@onready var approval_button = $"../StampBarController/StampBar/ApprovalStamp/TextureButton"
@onready var rejection_button = $"../StampBarController/StampBar/RejectionStamp/TextureButton"

func _ready():
	if not passport:
		push_error("Passport reference not set in StampCrossbarSystem!")
	if not stats_manager:
		push_error("StatsManager reference not set in StampCrossbarSystem!")

func _input(event):
	if event is InputEventMouseMotion:
		last_mouse_position = event.global_position

func play_random_stamp_sound():
	var stamp_sounds = [
		preload("res://assets/audio/stamp_sound_1.mp3"),
		preload("res://assets/audio/stamp_sound_2.mp3"),
		preload("res://assets/audio/stamp_sound_3.mp3"),
		preload("res://assets/audio/stamp_sound_4.mp3"),
		preload("res://assets/audio/stamp_sound_5.mp3")
	]
	if sfx_player and !sfx_player.playing:
		sfx_player.stream = stamp_sounds.pick_random()
		sfx_player.play()

func get_stamp_origin() -> Vector2:
	# Get the position of the appropriate stamp in the crossbar
	var stamp_button = approval_button if current_stamp_type == "approve" else rejection_button
	var origin = stamp_button.global_position
	
	# Adjust to be at the bottom center of the stamp
	origin.y += stamp_button.size.y / 2
	origin.x += stamp_button.size.x / 2
	return origin

func on_stamp_requested(stamp_type: String, stamp_texture: Texture2D):
	current_stamp_texture = stamp_texture
	current_stamp_type = stamp_type
	apply_stamp(stamp_type)

func apply_stamp(stamp_type: String):
	if not passport or not current_stamp_texture:
		return
		
	is_stamping = true
	play_random_stamp_sound()
	
	# Create temporary stamp for animation
	var temp_stamp = Sprite2D.new()
	temp_stamp.texture = current_stamp_texture
	temp_stamp.z_index = 20  # Ensure stamp appears above passport during animation
	
	# Start from the actual stamp position
	var start_pos = get_stamp_origin()
	temp_stamp.global_position = start_pos
	
	# Target position is where the mouse is
	var target_position = last_mouse_position
	
	add_child(temp_stamp)
	
	# Animate stamp movement
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move horizontally to target x position
	tween.tween_property(temp_stamp, "global_position:x", target_position.x, STAMP_ANIM_DURATION/2)
	
	# Move down to target y position
	tween.tween_property(temp_stamp, "global_position:y", target_position.y, STAMP_ANIM_DURATION/2)
	
	# Apply final stamp to passport
	create_final_stamp(stamp_type, target_position)
	
	# Return stamp to original position
	var return_tween = create_tween()
	return_tween.set_parallel(true)
	return_tween.tween_property(temp_stamp, "global_position", start_pos, STAMP_ANIM_DURATION/2)
	return_tween.chain().tween_callback(func():
		temp_stamp.queue_free()
		await get_tree().create_timer(stamp_cooldown).timeout
		is_stamping = false
	)

func create_final_stamp(stamp_type: String, pos: Vector2):
	var final_stamp = Sprite2D.new()
	var texture_path = "res://assets/stamps/approved_stamp.png" if stamp_type == "approve" \
					  else "res://assets/stamps/denied_stamp.png"
	final_stamp.texture = load(texture_path)
	final_stamp.position = passport.to_local(pos)
	final_stamp.modulate.a = 0
	final_stamp.z_index = 1  # Ensure stamp appears above passport background
	passport.add_child(final_stamp)
	
	# Update stats
	if stats_manager:
		stats_manager.current_stats.total_stamps += 1
		var is_perfect = stats_manager.check_stamp_accuracy(
			final_stamp.global_position,
			passport
		)
		if is_perfect:
			stats_manager.current_stats.perfect_stamps += 1
			Global.add_score(100)  # Bonus for perfect stamp
	
	# Fade in the stamp
	var tween = create_tween()
	tween.tween_property(final_stamp, "modulate:a", 1.0, 0.1)\
		 .set_delay(STAMP_ANIM_DURATION/2)
