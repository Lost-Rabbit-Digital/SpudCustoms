# StampCrossbarSystem.gd
extends Node2D

# Node references
@export var passport: Node2D  # Reference to the passport node
@export var stats_manager: Node  # Reference to StatsManager

# Constants for stamp bar
const FOLDED_X_POS = -200  
const UNFOLDED_X_POS = 100
const STAMP_BAR_Y = 100    
const STAMP_SPACING = 200  
const STAMP_ANIM_DURATION = 0.3

# State tracking
var stamps_visible = false
var is_stamping = false
var stamp_cooldown = 1.0

# Audio
@onready var sfx_player = $"../../../SystemManagers/AudioManager/SFXPool"

func _ready():
	# Initialize components
	if not passport:
		push_error("Passport reference not set in StampCrossbarSystem!")
	if not stats_manager:
		push_error("StatsManager reference not set in StampCrossbarSystem!")

func setup_stamps():
	$StampBar/ApprovalStamp.position = Vector2(0, 0)
	$StampBar/RejectionStamp.position = Vector2(STAMP_SPACING, 0)
	
	# Connect stamp click handlers
	$StampBar/ApprovalStamp.connect("input_event", Callable(self, "_on_stamp_clicked").bind("approve"))
	$StampBar/RejectionStamp.connect("input_event", Callable(self, "_on_stamp_clicked").bind("reject"))

func _on_fold_button_pressed():
	stamps_visible = !stamps_visible
	update_stamp_bar_visibility(stamps_visible)

func update_stamp_bar_visibility(visible: bool):
	var target_x = UNFOLDED_X_POS if visible else FOLDED_X_POS
	
	var tween = create_tween()
	tween.tween_property($StampBar, "position:x", target_x, 0.5)\
		 .set_trans(Tween.TRANS_CUBIC)\
		 .set_ease(Tween.EASE_OUT)

func _on_stamp_clicked(_viewport, event, _shape_idx, stamp_type: String):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_stamping and passport_in_range():
			apply_stamp(stamp_type)

func passport_in_range() -> bool:
	if !passport:
		return false
		
	# Check if passport is positioned under a stamp
	var stamp = $StampBar/ApprovalStamp if passport.global_position.x < $StampBar.position.x + STAMP_SPACING/2 \
							  else $StampBar/RejectionStamp
	return abs(passport.global_position.y - ($StampBar.position.y + STAMP_BAR_Y)) < 50

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

func apply_stamp(stamp_type: String):
	if not passport or not is_instance_valid(passport):
		return
		
	is_stamping = true
	play_random_stamp_sound()
	
	# Create temporary stamp for animation
	var temp_stamp = Sprite2D.new()
	var stamp_node = $StampBar/ApprovalStamp if stamp_type == "approve" else $StampBar/RejectionStamp
	temp_stamp.texture = stamp_node.texture
	temp_stamp.global_position = passport.global_position
	add_child(temp_stamp)
	
	# Animate stamp coming down
	var tween = create_tween()
	tween.tween_property(temp_stamp, "position:y", temp_stamp.position.y + 36, STAMP_ANIM_DURATION/2)
	
	# Apply final stamp to passport
	create_final_stamp(stamp_type, passport.global_position)
	
	# Return stamp and clean up
	tween.chain().tween_property(temp_stamp, "position:y", temp_stamp.position.y, STAMP_ANIM_DURATION/2)
	tween.chain().tween_callback(func():
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
	passport.add_child(final_stamp)
	
	# Update stats
	if stats_manager:
		stats_manager.shift_stats.total_stamps += 1
		# Check accuracy
		var is_perfect = stats_manager.check_stamp_accuracy(
			final_stamp.global_position,
			passport
		)
		if is_perfect:
			stats_manager.shift_stats.perfect_stamps += 1
			Global.add_score(100)  # Bonus for perfect stamp
	
	# Fade in the stamp
	var tween = create_tween()
	tween.tween_property(final_stamp, "modulate:a", 1.0, 0.1)\
		 .set_delay(STAMP_ANIM_DURATION/2)
