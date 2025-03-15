extends Node2D
class_name DraggableDocument

# States
var is_open = false

# Document textures
@export var closed_texture: Texture2D
@export var open_texture: Texture2D

# Document components
@export var closed_content_node: Node
@export var open_content_node: Node

# Optional animation parameters
@export var animation_duration: float = 0.3

# References
var document_sprite: Sprite2D

func _ready():
	document_sprite = get_parent() as Sprite2D
	
	# Set initial state
	close(false)

# Open the document with optional animation
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

# Close the document with optional animation
func close(animate: bool = true):
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

# Center document at position
func center_at_position(position: Vector2):
	if document_sprite:
		var rect = document_sprite.get_rect()
		var offset = rect.size / 2
		document_sprite.global_position = position - offset

# Check if document state is open
func is_document_open() -> bool:
	return is_open

# Called when document starts being dragged
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
			
# Called when document is dropped
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
