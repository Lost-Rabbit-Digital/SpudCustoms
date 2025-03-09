extends Node2D

# Constants for positioning and animation
const HIDDEN_Y = 800  # Position when receipt is hidden (below screen)
const SHOWN_Y = 500   # Position when receipt is visible (on screen)
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
	if law_receipt:
		law_receipt.position.y = HIDDEN_Y
		# Make sure it's visible but off-screen
		law_receipt.visible = true
	else:
		push_error("LawReceipt node not found!")
	
	# Connect button signals
	if fold_out_button:
		fold_out_button.pressed.connect(_on_fold_out_pressed)
	else:
		push_error("FoldOutButton node not found!")
		
	if hide_button:
		hide_button.pressed.connect(_on_hide_pressed)
	else:
		push_error("HideButton node not found!")
	
	# Show the fold-out button initially
	if fold_out_button:
		fold_out_button.visible = true
		fold_out_button.modulate.a = 1.0
		
	# Print debug info
	print("Screen size: ", get_viewport_rect().size)
	print("Law receipt initial position: ", law_receipt.position if law_receipt else "NULL")
	print("HIDDEN_Y: ", HIDDEN_Y)
	print("SHOWN_Y: ", SHOWN_Y)

func _on_fold_out_pressed():
	print("Fold out button pressed")
	if !is_animating and !is_visible and law_receipt:
		print("Starting show animation")
		show_law_receipt()
	else:
		print("Cannot show: animating=", is_animating, " visible=", is_visible, " law_receipt=", law_receipt != null)

func _on_hide_pressed():
	print("Hide button pressed")
	if !is_animating and is_visible:
		hide_law_receipt()

func show_law_receipt():
	is_animating = true
	
	# Ensure receipt is visible
	law_receipt.visible = true
	
	# Debug - confirm receipt position before animation
	print("Law receipt position before show: ", law_receipt.position)
	
	# Create tween for showing receipt
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Move receipt up
	tween.tween_property(law_receipt, "position:y", SHOWN_Y, TWEEN_DURATION)\
		 .set_trans(Tween.TRANS_CUBIC)\
		 .set_ease(Tween.EASE_OUT)
	
	# Fade out fold button
	tween.tween_property(fold_out_button, "modulate:a", 0.0, TWEEN_DURATION/2)
	
	# Debug - trace animation
	tween.tween_callback(func(): print("Animation halfway")).set_delay(TWEEN_DURATION/2)
	
	# When complete
	tween.chain().tween_callback(func():
		fold_out_button.visible = false
		is_animating = false
		is_visible = true
		print("Show animation complete, law receipt at: ", law_receipt.position)
	)

func hide_law_receipt():
	is_animating = true
	
	# Debug - confirm receipt position before animation
	print("Law receipt position before hide: ", law_receipt.position)
	
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
		print("Hide animation complete, law receipt at: ", law_receipt.position)
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
	else:
		push_error("ReceiptNote node not found!")
