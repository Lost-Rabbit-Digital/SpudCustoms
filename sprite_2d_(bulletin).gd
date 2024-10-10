extends Sprite2D

var current_page = 1
var maximum_pages = 2

var how_to_play_note_1 = """INSTRUCTIONS
To begin, press the speaker with the yellow flashing ring on top of the customs office building.
Take the documents from the Potato and bring them to the main table.
Then compare the information on the documents with the laws given.
If there are any discrepencies, deny entry.
After stamping the documents, hand them back to the Potato.

CONTROLS
[LEFT MOUSE] - Pick up and drops objects
[RIGHT MOUSE] - Perform actions with objects 
[ESCAPE] - Pause or return to the main menu
"""

var daily_laws = """
HTTPCLIENT ACTIVATED, FACEBOOK "CONNECT_DEFERRED
"""

func _on_texture_button_turn_right_pressed():
	if current_page + 1 <= maximum_pages:
		current_page += 1
		if current_page == 1:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = how_to_play_note_1
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = false
		elif current_page == 2:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = daily_laws
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = true
			$"Sprite2D (Open Bulletin)/TextureButton (TurnRight)".visible = false

		


func _on_texture_button_turn_left_pressed():
	if current_page - 1 >= 1:
		current_page -= 1
		if current_page == 1:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = how_to_play_note_1
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = false
			$"Sprite2D (Open Bulletin)/TextureButton (TurnRight)".visible = true
		elif current_page == 2:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = daily_laws
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = true
