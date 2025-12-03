class_name DraggableDocument
extends Node2D
## Controller for individual draggable document instances.
##
## Manages the state and appearance of a document, including its open/close
## state, content visibility, and animations. Handles document-specific
## behavior when interacting with the drag and drop system.

# Document textures
## Texture displayed when the document is closed.
@export var closed_texture: Texture2D

## Texture displayed when the document is open.
@export var open_texture: Texture2D

# Document components
## Node containing content to display when document is closed.
@export var closed_content_node: Node

## Node containing content to display when document is open.
@export var open_content_node: Node

# Optional animation parameters
## Duration in seconds for open/close animations.
@export var animation_duration: float = 0.3

# References
## Reference to the sprite that represents the document visually.
var document_sprite: Sprite2D

# States
## Flag indicating if the document is currently open.
var is_open = false


## Called when the node is added to the scene.
##
## Gets parent sprite reference and initializes document state.
func _ready():
	document_sprite = get_parent() as Sprite2D

	# Set initial state
	close(false)


## Opens the document, changing its texture and showing appropriate content.
##
## @param animate Whether to animate the transition (true) or change immediately (false).
func open(animate: bool = true):
	if is_open:
		return

	is_open = true

	# Update texture
	if document_sprite and open_texture:
		document_sprite.texture = open_texture

	# Show/hide appropriate content
	if closed_content_node:
		closed_content_node.visible = false
	if open_content_node:
		open_content_node.visible = true

	# Optional animation
	if animate:
		# Simple fade-in animation
		modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, animation_duration)

	# Trigger tutorial action for passport opened
	if document_sprite and document_sprite.name == "Passport" and TutorialManager:
		TutorialManager.trigger_tutorial_action("passport_opened")


## Closes the document, changing its texture and showing appropriate content.
##
## @param animate Whether to animate the transition (true) or change immediately (false).
func close(animate: bool = true):
	# Check if it's already closed
	if !is_open:
		return

	is_open = false

	# Update texture
	if document_sprite and closed_texture:
		document_sprite.texture = closed_texture

	# Show/hide appropriate content
	if closed_content_node:
		closed_content_node.visible = true
	if open_content_node:
		open_content_node.visible = false

	# Optional animation
	if animate:
		# Simple fade-in animation
		modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, animation_duration)


## Centers the document at the specified position.
##
## Adjusts the position to center the document sprite at the given coordinates.
## @param position The global position to center at.
func center_at_position(center_position: Vector2):
	if document_sprite:
		var rect = document_sprite.get_rect()
		var offset = rect.size / 2
		document_sprite.global_position = center_position - offset


## Checks if the document is currently in the open state.
##
## @return True if the document is open, false otherwise.
func is_document_open() -> bool:
	return is_open


## Called when the document starts being dragged.
##
## Ensures proper visibility during drag operations.
func on_drag_start():
	# Save current state
	var was_open = is_open

	# If document is open, make sure it stays visible during drag
	if was_open:
		# Add code here to ensure the document stays visible during drag
		# This might involve adjusting visibility or z-index
		if open_content_node:
			open_content_node.visible = true
		if document_sprite:
			document_sprite.modulate.a = 1.0


## Called when the document is dropped.
##
## Handles document state based on the drop zone.
## @param drop_zone String identifying where the document was dropped.
func on_drop(drop_zone: String):
	# If dropped outside the inspection table, make sure it's closed
	if drop_zone != "inspection_table":
		close(false)  # Close without animation
		return

	# Otherwise, maintain current state
	if is_open:
		if closed_content_node:
			closed_content_node.visible = false
		if open_content_node:
			open_content_node.visible = true
		if document_sprite and open_texture:
			document_sprite.texture = open_texture
	else:
		if closed_content_node:
			closed_content_node.visible = true
		if open_content_node:
			open_content_node.visible = false
		if document_sprite and closed_texture:
			document_sprite.texture = closed_texture
