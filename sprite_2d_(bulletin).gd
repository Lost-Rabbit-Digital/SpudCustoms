extends Sprite2D

var current_page = 1
var maximum_pages = 4

var bulletin_welcome_note_1 = """As the previous Border Officer of the glorious nation of Spudarado, I feel compelled to share the importance and intricacies of your duties at your esteemed checkpoint.

Each day, you will stand as the first line of defense against those who would seek to enter our potato-rich paradise without proper documentation. Your responsibilities include:

Thorough examination of passports and entry permits,
verification of traveler identities,
scrutiny of any suspicious items or behavior,
and upholding the ever-changing immigration regulations
"""

var bulletin_welcome_note_2 = """It's not an easy job, mind you. Just yesterday, I had to deny entry to someone claiming to be a "french fry chef" - clearly a ruse to gain access to our precious potato reserves. And don't get me started on the constant attempts to smuggle in unauthorized condiments!

We take our motto very seriously: "Starch Diligence, Unwavering Vigilance!" The safety of our citizens and the integrity of our tuber-based economy depend on the decisions we make at the border.
"""

var bulletin_welcome_note_3 = """Of course, there are perks to the job. The government-issued starch allowance is generous, and the uniform, while a bit stiff, commands respect. Plus, there's nothing quite like the satisfaction of stamping "DENIED" on a clearly forged document.

Should you ever find yourself at our checkpoint, I trust you'll have your papers in order. Remember, a proper Spudarado visa should always smell faintly of earth and have the official seal featuring our national symbol - the Majestic Russet.

For the Glory of Spudorado!
"""

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

func _on_texture_button_turn_right_pressed():
	if current_page + 1 <= maximum_pages:
		current_page += 1
		if current_page == 1:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = how_to_play_note_1
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = false
		elif current_page == 2:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = bulletin_welcome_note_1
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = true
		elif current_page == 3:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = bulletin_welcome_note_2
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = true
		elif current_page == 4:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = bulletin_welcome_note_3
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = true
			$"Sprite2D (Open Bulletin)/TextureButton (TurnRight)".visible = false

		


func _on_texture_button_turn_left_pressed():
	if current_page - 1 >= 1:
		current_page -= 1
		if current_page == 1:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = how_to_play_note_1
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = false
		elif current_page == 2:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = bulletin_welcome_note_1
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = true
		elif current_page == 3:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = bulletin_welcome_note_2
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = true
			$"Sprite2D (Open Bulletin)/TextureButton (TurnRight)".visible = true
		elif current_page == 4:
			print(current_page)
			$"Sprite2D (Open Bulletin)/Label (BulletinNote)".text = bulletin_welcome_note_3
			$"Sprite2D (Open Bulletin)/TextureButton (TurnLeft)".visible = true
