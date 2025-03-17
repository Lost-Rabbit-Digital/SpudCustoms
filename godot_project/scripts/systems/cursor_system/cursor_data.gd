class_name CursorData
extends Resource

var type: CursorTypes.Type = CursorTypes.Type.DEFAULT
var item_reference: Object = null
var drag_data: Dictionary = {}
var hover_target: Object = null
var additional_data: Dictionary = {}

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
		
func reset() -> void:
	type = CursorTypes.Type.DEFAULT
	item_reference = null
	drag_data.clear()
	hover_target = null
	additional_data.clear()
	
func has_drag_data() -> bool:
	return not drag_data.is_empty()
