extends Sprite2D
var current_page = 1
var maximum_pages = 2
var how_to_play_note_1 = """To begin, press the speaker with the yellow flashing ring on top of the customs office building.
Take the documents from the Potato and bring them to the main table.
Then compare the information on the documents with the laws given.
If there are any discrepencies, deny entry.
After stamping the documents, hand them back to the Potato.

"""

var daily_laws = """
Deleting System32, please wait...
"""

func _ready():
	# Assuming the main game script is attached to a node named "Main"
	var main_node = get_node("/root/Root")
	if main_node:
		main_node.connect("rules_updated", Callable(self, "update_daily_laws"))

func update_daily_laws(new_laws):
	daily_laws = new_laws
	if current_page == 2:
		$OpenGuide/GuideNote.text = daily_laws

func _on_turn_right_pressed():
	if current_page + 1 <= maximum_pages:
		current_page += 1
		if current_page == 1:
			print(current_page)
			$OpenGuide/GuideNote.text = how_to_play_note_1
			$OpenGuide/TurnLeft.visible = false
		elif current_page == 2:
			print(current_page)
			$OpenGuide/GuideNote.text = daily_laws
			$OpenGuide/TurnLeft.visible = true
			$OpenGuide/TurnRight.visible = false

func _on_turn_left_pressed():
	if current_page - 1 >= 1:
		current_page -= 1
		if current_page == 1:
			print(current_page)
			$OpenGuide/GuideNote.text = how_to_play_note_1
			$OpenGuide/TurnLeft.visible = false
			$OpenGuide/TurnRight.visible = true
		elif current_page == 2:
			print(current_page)
			$OpenGuide/GuideNote.text = daily_laws
			$OpenGuide/TurnLeft.visible = true
