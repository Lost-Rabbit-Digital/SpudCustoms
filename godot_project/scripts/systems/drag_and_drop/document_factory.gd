class_name DocumentFactory
extends Node
## Factory responsible for creating and configuring different types of draggable documents.
##
## This factory class contains static methods that handle the creation of different
## document types used in the game, such as passports and receipts.
## Each method configures document properties and attaches necessary nodes.


## Creates and configures a Passport document instance.
##
## Locates necessary nodes in the scene tree, creates a DraggableDocument instance,
## and sets up its properties for a passport document.
## @param parent_node The root node containing the required document sprites.
## @return The configured DraggableDocument instance or null if setup fails.
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
	document.closed_texture = preload(
		"res://assets/documents/closed_passport_small/closed_passport_small.png"
	)
	document.open_texture = preload("res://assets/documents/passport_old.png")
	document.closed_content_node = passport_sprite.get_node_or_null("ClosedPassport")
	document.open_content_node = passport_sprite.get_node_or_null("OpenPassport")

	return document


## Creates and configures a LawReceipt document instance.
##
## Locates necessary nodes in the scene tree, creates a DraggableDocument instance,
## and sets up its properties for a law receipt document.
## @param parent_node The root node containing the required document sprites.
## @return The configured DraggableDocument instance or null if setup fails.
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
	document.closed_texture = preload("res://assets/documents/laws_receipt_small.png")
	document.open_texture = preload("res://assets/documents/laws_receipt.png")
	document.closed_content_node = receipt_sprite.get_node_or_null("ClosedReceipt")
	document.open_content_node = receipt_sprite.get_node_or_null("OpenReceipt")

	return document
