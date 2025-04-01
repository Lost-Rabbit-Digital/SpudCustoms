extends Node
class_name DragAndDropManager

# Systems
var drag_system: DragAndDropSystem

# Document references
var passport_document: DraggableDocument
var guide_document: DraggableDocument
var law_receipt_document: DraggableDocument

# Scene references
var inspection_table: Node2D
var suspect_panel: Node2D
var suspect: Node2D
var audio_player: AudioStreamPlayer2D

var stamp_system_manager: StampSystemManager

func _ready():
	# Create our drag and drop system
	drag_system = DragAndDropSystem.new()
	add_child(drag_system)
	
	# Connect signals
	drag_system.item_opened.connect(_on_item_opened)
	drag_system.item_closed.connect(_on_item_closed)
	drag_system.connect("item_dropped", Callable(self, "_on_item_dropped"))
# Initialize the manager with scene references
func initialize(game_scene: Node):
	# Get references to key nodes
	inspection_table = game_scene.get_node_or_null("Gameplay/InspectionTable")
	suspect_panel = game_scene.get_node_or_null("Gameplay/SuspectPanel")
	suspect = game_scene.get_node_or_null("Gameplay/MugshotPhotoGenerator/SizingSprite")
	audio_player = game_scene.get_node_or_null("SystemManagers/AudioManager/SFXPool")
	
	# Get stamp bar controller reference
	var stamp_bar_controller = game_scene.get_node_or_null("Gameplay/InteractiveElements/StampBarController")
	
	if !inspection_table or !suspect_panel or !suspect:
		push_error("Required scene references not found for DragAndDropManager")
		return
	
	# Create document controllers
	passport_document = DocumentFactory.create_passport(game_scene)
	# Not creating the guide anymore, may use the code later though
	#guide_document = DocumentFactory.create_guide(game_scene)
	law_receipt_document = DocumentFactory.create_law_receipt(game_scene)
	
	# Get references to sprite nodes
	var passport_sprite = game_scene.get_node_or_null("Gameplay/InteractiveElements/Passport")
	var guide_sprite = game_scene.get_node_or_null("Gameplay/InteractiveElements/Guide")
	var law_receipt_sprite = game_scene.get_node_or_null("Gameplay/InteractiveElements/LawReceipt")
	
	# Register draggable items
	var draggable_items = []
	if passport_sprite: 
		draggable_items.append(passport_sprite)
	if guide_sprite:
		draggable_items.append(guide_sprite)
	if law_receipt_sprite:
		draggable_items.append(law_receipt_sprite)
	
	# Initialize the drag system
	drag_system.initialize({
		"inspection_table": inspection_table,
		"suspect_panel": suspect_panel,
		"suspect": suspect,
		"audio_player": audio_player,
		"draggable_items": draggable_items,
		"stamp_bar_controller": stamp_bar_controller
	})

# Handle input events
func handle_input(event: InputEvent) -> bool:
	return drag_system.handle_input_event(event, get_viewport().get_mouse_position())

# Open a document by name
func open_document(document_name: String):
	match document_name.to_lower():
		"passport":
			if passport_document:
				passport_document.open()
				drag_system.play_open_sound()
		"guide":
			if guide_document:
				guide_document.open()
				drag_system.play_open_sound()
		"lawreceipt":
			if law_receipt_document:
				law_receipt_document.open()
				drag_system.play_open_sound()

# Close a document by name
func close_document(document_name: String):
	match document_name.to_lower():
		"passport":
			if passport_document:
				passport_document.close()
				drag_system.play_close_sound()
		"guide":
			if guide_document:
				guide_document.close()
				drag_system.play_close_sound()
		"lawreceipt":
			if law_receipt_document:
				law_receipt_document.close()
				drag_system.play_close_sound()

# Check if a document is open
func is_document_open(document_name: String) -> bool:
	match document_name.to_lower():
		"passport":
			return passport_document and passport_document.is_document_open()
		"guide":
			return guide_document and guide_document.is_document_open()
		"lawreceipt":
			return law_receipt_document and law_receipt_document.is_document_open()
	return false

# Signal handlers
func _on_item_opened(item: Node2D):
	var document_name = item.name
	open_document(document_name)

func _on_item_closed(item: Node2D):
	var document_name = item.name
	close_document(document_name)

func set_stamp_system_manager(manager: StampSystemManager):
	stamp_system_manager = manager
	
	# If you have a drag_system as a child/component, pass it down
	if has_node("DragSystem") or get("drag_system"):
		var drag_system = get_node_or_null("DragSystem") if has_node("DragSystem") else drag_system
		if drag_system and drag_system.has_method("set_stamp_system_manager"):
			drag_system.set_stamp_system_manager(manager)
