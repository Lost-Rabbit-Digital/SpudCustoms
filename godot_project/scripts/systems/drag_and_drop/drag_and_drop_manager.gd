class_name DragAndDropManager
extends Node
## Manager class for the drag and drop interaction system.
##
## Serves as a coordinator between various document controllers and the core
## drag and drop system. Handles high-level operations like opening and
## closing documents, as well as initializing the system components.

# Systems
## Reference to the core drag and drop system implementation.
var drag_system: DragAndDropSystem

# Document references
## Reference to the passport document controller.
var passport_document: DraggableDocument
## Reference to the law receipt document controller.
var law_receipt_document: DraggableDocument

# Scene references
## Reference to the inspection table node where documents can be examined.
var inspection_table: Node2D
## Reference to the suspect panel area.
var suspect_panel: Node2D
## Reference to the suspect mugshot node.
var suspect: Node2D
## Reference to the audio player for document interaction sounds.
var audio_player: AudioStreamPlayer2D

## Reference to the stamp system manager for handling document stamping.
var stamp_system_manager: StampSystemManager

## Reference to the cursor manager for handling cursor changes.
var cursor_manager = null

## Reference to the office shutter
var office_shutter = null


## Called when the node is added to the scene.
##
## Gets references to autoloaded singletons and initializes the core
## drag and drop system, connecting necessary signals.
func _ready():
	# REFACTORED: Direct reference to CursorManager autoload
	cursor_manager = CursorManager
	if not cursor_manager:
		push_warning("CursorManager autoload not found. Document hover effects won't work.")

	# Create our drag and drop system
	drag_system = DragAndDropSystem.new()
	add_child(drag_system)

	# Connect signals
	drag_system.item_opened.connect(_on_item_opened)
	drag_system.item_closed.connect(_on_item_closed)
	drag_system.connect("item_dropped", Callable(self, "_on_item_dropped"))


## Initializes the manager with references to scene nodes.
##
## Sets up all necessary references to scene nodes and initializes
## document controllers and the drag system.
## @param game_scene The root game scene containing all required nodes.
func initialize(game_scene: Node):
	# Get references to key nodes
	inspection_table = game_scene.get_node_or_null("Gameplay/InspectionTable")
	suspect_panel = game_scene.get_node_or_null("Gameplay/SuspectPanel")
	suspect = game_scene.get_node_or_null("Gameplay/MugshotPhotoGenerator/SizingSprite")
	audio_player = game_scene.get_node_or_null("SystemManagers/AudioManager/SFXPool")
	office_shutter = game_scene.get_node_or_null(
		"Gameplay/InteractiveElements/OfficeShutterController"
	)

	# Get stamp bar controller reference
	var stamp_bar_controller = game_scene.get_node_or_null(
		"Gameplay/InteractiveElements/StampBarController"
	)

	if !inspection_table or !suspect_panel or !suspect or !audio_player or !office_shutter:
		push_error("Required scene references not found for DragAndDropManager")
		return

	# Create document controllers
	passport_document = DocumentFactory.create_passport(game_scene)
	law_receipt_document = DocumentFactory.create_law_receipt(game_scene)

	# Get references to sprite nodes
	var passport_sprite = game_scene.get_node_or_null("Gameplay/InteractiveElements/Passport")
	var law_receipt_sprite = game_scene.get_node_or_null("Gameplay/InteractiveElements/LawReceipt")

	# Register draggable items
	var draggable_items = []
	if passport_sprite:
		draggable_items.append(passport_sprite)
	if law_receipt_sprite:
		draggable_items.append(law_receipt_sprite)

	# Initialize the drag system
	drag_system.initialize(
		{
			"inspection_table": inspection_table,
			"suspect_panel": suspect_panel,
			"suspect": suspect,
			"audio_player": audio_player,
			"draggable_items": draggable_items,
			"stamp_bar_controller": stamp_bar_controller,
			"office_shutter": office_shutter
		}
	)


## Handles input events for document interaction.
##
## Delegates input handling to the drag system.
## @param event The input event to handle.
## @return True if the event was handled, false otherwise.
func handle_input(event: InputEvent) -> bool:
	return drag_system.handle_input_event(event, get_viewport().get_mouse_position())


## Opens a document by name.
##
## Finds the appropriate document controller and calls its open method.
## @param document_name The name of the document to open.
func open_document(document_name: String):
	match document_name.to_lower():
		"passport":
			if passport_document:
				passport_document.open()
				drag_system.play_open_sound()
		"lawreceipt":
			if law_receipt_document:
				law_receipt_document.open()
				drag_system.play_open_sound()


## Closes a document by name.
##
## Finds the appropriate document controller and calls its close method.
## @param document_name The name of the document to close.
func close_document(document_name: String):
	match document_name.to_lower():
		"passport":
			if passport_document:
				passport_document.close()
				drag_system.play_close_sound()
		"lawreceipt":
			if law_receipt_document:
				law_receipt_document.close()
				drag_system.play_close_sound()


## Checks if a document is currently open.
##
## @param document_name The name of the document to check.
## @return True if the document is open, false otherwise.
func is_document_open(document_name: String) -> bool:
	match document_name.to_lower():
		"passport":
			return passport_document and passport_document.is_document_open()
		"lawreceipt":
			return law_receipt_document and law_receipt_document.is_document_open()
	return false


## Signal handler for when an item is opened.
##
## @param item The node that was opened.
func _on_item_opened(item: Node2D):
	item.z_index = ConstantZIndexes.Z_INDEX.IDLE_DOCUMENT
	var document_name = item.name
	open_document(document_name)


## Signal handler for when an item is closed.
##
## @param item The node that was closed.
func _on_item_closed(item: Node2D):
	item.z_index = ConstantZIndexes.Z_INDEX.CLOSED_DRAGGED_DOCUMENT
	var document_name = item.name
	close_document(document_name)


## Signal handler for when an item is dropped.
##
## @param item The node that was dropped.
## @param drop_zone The zone where the item was dropped.
func _on_item_dropped(item: Node2D, _drop_zone: String):
	item.z_index = ConstantZIndexes.Z_INDEX.IDLE_DOCUMENT


## Sets the stamp system manager reference.
##
## @param manager The stamp system manager instance.
func set_stamp_system_manager(manager: StampSystemManager):
	stamp_system_manager = manager

	# If you have a drag_system as a child/component, pass it down
	if has_node("DragSystem") or get("drag_system"):
		var drag_system = get_node_or_null("DragSystem") if has_node("DragSystem") else drag_system
		if drag_system and drag_system.has_method("set_stamp_system_manager"):
			drag_system.set_stamp_system_manager(manager)
