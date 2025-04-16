extends Sprite2D

var daily_laws = """

"""

@export var main_node: Node2D


func _ready():
	# Connect to rules_updated signal from main game node
	if main_node:
		main_node.connect("rules_updated", Callable(self, "update_daily_laws"))


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
	$OpenReceipt/ReceiptNote.text = receipt_text
