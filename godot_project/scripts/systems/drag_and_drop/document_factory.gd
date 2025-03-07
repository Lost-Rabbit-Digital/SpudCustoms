extends Node
class_name DocumentFactory

# Create and configure Passport document
static func create_passport(parent_node: Node) -> DraggableDocument:
	var document = DraggableDocument.new()
	document.name = "DocumentController"
	
	# Get references to needed nodes
	var passport_sprite = parent_node.get_node_or_null("Gameplay/InteractiveElements/Passport")
	if not passport_sprite:
		push_error("Passport sprite not found!")
		return null
	
	passport_sprite.add_child(document)
	
	# Configure the document
	document.closed_texture = preload("res://assets/documents/closed_passport_small/closed_passport_small.png")
	document.open_texture = preload("res://assets/documents/passport-old.png")
	document.closed_content_node = passport_sprite.get_node_or_null("ClosedPassport")
	document.open_content_node = passport_sprite.get_node_or_null("OpenPassport")
	
	return document

# Create and configure Guide document
static func create_guide(parent_node: Node) -> DraggableDocument:
	var document = DraggableDocument.new()
	document.name = "DocumentController"
	
	# Get references to needed nodes
	var guide_sprite = parent_node.get_node_or_null("Gameplay/InteractiveElements/Guide")
	if not guide_sprite:
		push_error("Guide sprite not found!")
		return null
	
	guide_sprite.add_child(document)
	
	# Configure the document
	document.closed_texture = preload("res://assets/documents/customs_guide/customs_guide_closed_small.png")
	document.open_texture = preload("res://assets/documents/customs_guide/customs_guide_open_2.png")
	document.closed_content_node = guide_sprite.get_node_or_null("ClosedGuide")
	document.open_content_node = guide_sprite.get_node_or_null("OpenGuide")
	
	return document

# Create and configure LawReceipt document
static func create_law_receipt(parent_node: Node) -> DraggableDocument:
	var document = DraggableDocument.new()
	document.name = "DocumentController"
	
	# Get references to needed nodes
	var receipt_sprite = parent_node.get_node_or_null("Gameplay/InteractiveElements/LawReceipt")
	if not receipt_sprite:
		push_error("LawReceipt sprite not found!")
		return null
	
	receipt_sprite.add_child(document)
	
	# Configure the document
	# You'll need to update these paths to match your actual assets
	document.closed_texture = preload("res://assets/documents/customs_guide/customs_guide_closed_small.png")
	document.open_texture = preload("res://assets/documents/customs_guide/customs_guide_open_2.png")
	document.closed_content_node = receipt_sprite.get_node_or_null("ClosedReceipt") 
	document.open_content_node = receipt_sprite.get_node_or_null("OpenReceipt")
	
	return document
