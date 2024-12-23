# StampBarController.gd
extends Node2D

signal stamp_requested(stamp_type: String, stamp_texture: Texture2D)

# Constants for positioning and animation
const HIDDEN_X = -625  # Position when bar is hidden
const SHOWN_X = -10    # Position when bar is visible
const TWEEN_DURATION = 0.5

# Node references
@onready var stamp_bar = $StampBar
@onready var fold_out_button = $FoldOutButton
@onready var hide_button = $StampBar/HideButton
@export var stamp_system: Node  # Reference to StampCrossbarSystem

# State tracking
var is_visible = false
var is_animating = false

func _ready():
	# Set initial position (hidden)
	stamp_bar.position.x = HIDDEN_X
	
	# Connect button signals
	fold_out_button.pressed.connect(_on_fold_out_pressed)
	hide_button.pressed.connect(_on_hide_pressed)
	
	$StampBar/ApprovalStamp/TextureButton.pressed.connect(func():
		emit_signal("stamp_requested", "approve", $StampBar/ApprovalStamp/TextureButton.texture_normal)
		)
	
	$StampBar/RejectionStamp/TextureButton.pressed.connect(func():
		emit_signal("stamp_requested", "reject", $StampBar/RejectionStamp/TextureButton.texture_normal)
		)
	
	# Show the fold-out button initially
	fold_out_button.visible = true
	fold_out_button.modulate.a = 1.0

func _on_fold_out_pressed():
	if !is_animating and !is_visible:
		show_stamp_bar()

func _on_hide_pressed():
	if !is_animating and is_visible:
		hide_stamp_bar()

func _on_stamp_pressed(stamp_type: String, stamp_texture: Texture2D):
	emit_signal("stamp_requested", stamp_type, stamp_texture)

func show_stamp_bar():
	is_animating = true
	
	# Create tween for showing stamp bar
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move stamp bar in
	tween.tween_property(stamp_bar, "position:x", SHOWN_X, TWEEN_DURATION)\
		 .set_trans(Tween.TRANS_CUBIC)\
		 .set_ease(Tween.EASE_OUT)
	
	# Fade out fold button
	tween.tween_property(fold_out_button, "modulate:a", 0.0, TWEEN_DURATION/2)
	
	# When complete
	tween.chain().tween_callback(func():
		fold_out_button.visible = false
		is_animating = false
		is_visible = true
	)

func hide_stamp_bar():
	is_animating = true
	
	# Create tween for hiding stamp bar
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move stamp bar out
	tween.tween_property(stamp_bar, "position:x", HIDDEN_X, TWEEN_DURATION)\
		 .set_trans(Tween.TRANS_CUBIC)\
		 .set_ease(Tween.EASE_OUT)
	
	# Show fold button
	fold_out_button.visible = true
	tween.tween_property(fold_out_button, "modulate:a", 1.0, TWEEN_DURATION/2)\
		 .set_delay(TWEEN_DURATION/2)
	
	# When complete
	tween.chain().tween_callback(func():
		is_animating = false
		is_visible = false
	)

# Call this from game logic to force-hide the stamp bar
func force_hide():
	if is_visible and !is_animating:
		hide_stamp_bar()
