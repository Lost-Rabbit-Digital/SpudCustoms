extends Node2D

# Constants for positioning and animation
const HIDDEN_Y = 800  # Position when receipt is hidden (below screen)
const SHOWN_Y = 620  # Position when receipt is visible (on screen)
const TWEEN_DURATION = 0.5

@export var main_node: Node2D

# State tracking
var is_visible = false
var is_animating = false
var daily_laws = ""

# Node references
@onready var law_receipt_sprite = $LawReceiptSprite
@onready var fold_out_button = $FoldOutButton
@onready var hide_button = $LawReceiptSprite/HideButton


func _ready():
	# Set initial position (hidden)
	if law_receipt_sprite:
		law_receipt_sprite.position.y = HIDDEN_Y
		# Make sure it's visible but off-screen
		law_receipt_sprite.visible = true
	else:
		push_error("LawReceiptSprite node not found!")

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

	# Connect to rules_updated signal from main game node
	if main_node:
		main_node.connect("rules_updated", Callable(self, "update_daily_laws"))
	else:
		push_error("Main node reference not set!")

	# Debug print viewport size and positions
	#print("Viewport size: ", get_viewport_rect().size)
	#print("Initial law receipt y: ", law_receipt_sprite.position.y if law_receipt_sprite else "NULL")


func _on_fold_out_pressed():
	#print("Fold out button pressed")
	if !is_animating and !is_visible and law_receipt_sprite:
		#print("Starting show animation")
		show_law_receipt()


func _on_hide_pressed():
	#print("Hide button pressed")
	if !is_animating and is_visible:
		hide_law_receipt()


func show_law_receipt():
	is_animating = true

	# Ensure receipt is visible
	law_receipt_sprite.visible = true

	# Debug - confirm receipt position before animation
	#print("Law receipt position before show: ", law_receipt_sprite.position)

	# Create tween for showing receipt
	var tween = create_tween()
	tween.set_parallel(true)

	# Move receipt up
	(
		tween
		. tween_property(law_receipt_sprite, "position:y", SHOWN_Y, TWEEN_DURATION)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)

	# Fade out fold button
	tween.tween_property(fold_out_button, "modulate:a", 0.0, TWEEN_DURATION / 2)

	# When complete
	tween.chain().tween_callback(
		func():
			fold_out_button.visible = false
			is_animating = false
			is_visible = true
			#print("Show animation complete, law receipt at: ", law_receipt_sprite.position)
	)


func hide_law_receipt():
	is_animating = true

	# Debug - confirm receipt position before animation
	#print("Law receipt position before hide: ", law_receipt_sprite.position)

	# Create tween for hiding receipt
	var tween = create_tween()
	tween.set_parallel(true)

	# Move receipt down
	(
		tween
		. tween_property(law_receipt_sprite, "position:y", HIDDEN_Y, TWEEN_DURATION)
		. set_trans(Tween.TRANS_CUBIC)
		. set_ease(Tween.EASE_OUT)
	)

	# Show fold button
	fold_out_button.visible = true
	tween.tween_property(fold_out_button, "modulate:a", 1.0, TWEEN_DURATION / 2).set_delay(
		TWEEN_DURATION / 2
	)

	# When complete
	tween.chain().tween_callback(
		func():
			is_animating = false
			is_visible = false
			#print("Hide animation complete, law receipt at: ", law_receipt_sprite.position)
	)


# Force-hide the receipt (called externally)
func force_hide():
	if is_visible and !is_animating:
		hide_law_receipt()


# Handle the daily laws update from the main game
func update_daily_laws(new_laws):
	daily_laws = new_laws

	# Remove the [center] tags and LAWS title from the text
	var laws_text = new_laws.split("\n")
	var receipt_text = ""

	# Skip the [center] and LAWS header by starting at index 2
	for i in range(2, laws_text.size()):
		if laws_text[i].strip_edges() != "":
			receipt_text += laws_text[i] + "\n"

	# Update the receipt text
	if law_receipt_sprite and law_receipt_sprite.has_node("OpenReceipt/ReceiptNote"):
		law_receipt_sprite.get_node("OpenReceipt/ReceiptNote").text = receipt_text
		print("Updated receipt text: " + receipt_text)
	else:
		push_error("Cannot find ReceiptNote node at path: LawReceiptSprite/OpenReceipt/ReceiptNote")
