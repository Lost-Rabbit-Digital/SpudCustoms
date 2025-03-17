## Container for cursor-related data and state information including texture resources.
##
## This class stores and manages information related to the cursor's current state,
## with support for a limited set of custom cursor textures.
class_name CursorData
extends RefCounted

## Current visual type of the cursor
var type: CursorTypes.Type = CursorTypes.Type.DEFAULT

## Reference to the item being interacted with (if any)
var item_reference: Object = null

## Data associated with dragging operations
var drag_data: Dictionary = {}

## Reference to the object being hovered over (if any)
var hover_target: Object = null 

## Additional contextual data for special cursor behaviors
var additional_data: Dictionary = {}

## Dictionary mapping cursor types to their texture resources
var cursor_textures: Dictionary = {}

## Cursor hotspot offset from top-left corner
var cursor_offset: Vector2 = Vector2(0, 0)

## Tracks which cursor types have custom textures
var has_custom_texture: Dictionary = {}

func _init() -> void:
	# Initialize with the limited set of cursor textures
	_load_default_textures()

## Loads the default set of cursor textures.
## Only loads textures for the specific cursor types you've mentioned.
func _load_default_textures() -> void:
	# Define paths to cursor textures - only for the types we have custom textures for
	var texture_paths = {
		CursorTypes.Type.DEFAULT: "res://assets/cursors/default.png",
		CursorTypes.Type.POINTER: "res://assets/cursors/click.png",  # "click" equivalent
		CursorTypes.Type.HAND: "res://assets/cursors/hover.png",     # "hover" equivalent
		CursorTypes.Type.GRAB: "res://assets/cursors/grab.png",
		CursorTypes.Type.CROSSHAIR: "res://assets/cursors/crosshair.png"
	}
	
	# Try to load each texture
	for cursor_type in texture_paths:
		var path = texture_paths[cursor_type]
		if ResourceLoader.exists(path):
			cursor_textures[cursor_type] = load(path)
			has_custom_texture[cursor_type] = true
		else:
			# Mark as not having a custom texture
			has_custom_texture[cursor_type] = false
			push_warning("Cursor texture not found: " + path)

## Gets the texture for a specific cursor type.
## @param cursor_type The type of cursor to get the texture for.
## @return The texture for the specified cursor type, or null if not found.
func get_texture(cursor_type: CursorTypes.Type) -> Texture2D:
	return cursor_textures.get(cursor_type)

## Checks if there's a custom texture for the specified cursor type.
## @param cursor_type The type of cursor to check.
## @return True if a custom texture exists for this cursor type.
func has_texture_for(cursor_type: CursorTypes.Type) -> bool:
	return has_custom_texture.get(cursor_type, false)

## Sets a custom texture for a specific cursor type.
## @param cursor_type The type of cursor to set the texture for.
## @param texture The texture to use for this cursor type.
func set_texture(cursor_type: CursorTypes.Type, texture: Texture2D) -> void:
	cursor_textures[cursor_type] = texture
	has_custom_texture[cursor_type] = true

## Sets multiple cursor textures at once from a dictionary.
## @param textures Dictionary mapping cursor types to textures.
func set_textures(textures: Dictionary) -> void:
	for cursor_type in textures:
		set_texture(cursor_type, textures[cursor_type])

## Updates cursor data properties from a dictionary.
## @param data Dictionary containing the properties to update.
func update(data: Dictionary) -> void:
	if data.has("type"):
		type = data.type
	
	if data.has("item_reference"):
		item_reference = data.item_reference
	
	if data.has("drag_data"):
		drag_data = data.drag_data
	
	if data.has("hover_target"):
		hover_target = data.hover_target
	
	if data.has("additional_data"):
		additional_data = data.additional_data
	
	if data.has("cursor_offset"):
		cursor_offset = data.cursor_offset
		
## Resets all cursor data to default values.
func reset() -> void:
	type = CursorTypes.Type.DEFAULT
	item_reference = null
	drag_data.clear()
	hover_target = null
	additional_data.clear()
	
## Checks if the cursor is currently associated with drag data.
## @return Boolean indicating whether drag data is present.
func has_drag_data() -> bool:
	return not drag_data.is_empty()
