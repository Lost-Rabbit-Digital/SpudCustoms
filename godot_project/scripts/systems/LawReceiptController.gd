extends Node2D

# Constants for positioning and animation
const HIDDEN_Y = 800  # Position when receipt is hidden
const SHOWN_Y = 600   # Position when receipt is visible
const TWEEN_DURATION = 0.5

# Node references
@onready var law_receipt = $LawReceipt
@onready var fold_out_button = $FoldOutButton
@onready var hide_button = $LawReceipt/HideButton

# State tracking
var is_visible = false
var is_animating = false

func _ready():
	# Set initial position (hidden)
	law_receipt.position.y = HIDDEN_Y
	
	# Connect button signals
	fold_out_button.pressed.connect(_on_fold_out_pressed)
	hide_button.pressed.connect(_on_hide_pressed)
	
	# Show the fold-out button initially
	fold_out_button.visible = true
	fold_out_button.modulate.a = 1.0

func _on_fold_out_pressed():
	if !is_animating and !is_visible:
		show_law_receipt()

func _on_hide_pressed():
	if !is_animating and is_visible:
		hide_law_receipt()

func show_law_receipt():
	is_animating = true
	
	# Create tween for showing receipt
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move receipt up
	tween.tween_property(law_receipt, "position:y", SHOWN_Y, TWEEN_DURATION)\
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

func hide_law_receipt():
	is_animating = true
	
	# Create tween for hiding receipt
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move receipt down
	tween.tween_property(law_receipt, "position:y", HIDDEN_Y, TWEEN_DURATION)\
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

# Force-hide the receipt (called externally)
func force_hide():
	if is_visible and !is_animating:
		hide_law_receipt()
		
# Update the content of the receipt
func update_content(new_text: String):
	var receipt_note = $LawReceipt/ReceiptNote
	if receipt_note:
		receipt_note.text = new_text
