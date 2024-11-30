extends Sprite2D
var current_page = 1
var maximum_pages = 2
var how_to_play_note_1 = """[center]
Press the [color=#2C7A1F]speaker[/color] on top of the building to begin
Drag [color=#2C7A1F]papers[/color] from the Potato to your desk
Check [color=#2C7A1F]laws[/color] on [color=#2C7A1F]page 2[/color] of guide book
Hold [color=#2C7A1F]left-click[/color] on stamp, then [color=#2C7A1F]right-click[/color] while holding to stamp papers

[color=#FF0000]Left-click[/color] running potatoes to fire [color=#FF0000]missiles[/color]
If anything is wrong, [color=#FF0000]deny entry[/color]
Hand papers back to finish
[/center]
"""

var daily_laws = """

"""

@export var main_node : Node2D


func _ready():
	# Assuming the main game script is attached to a node named "Main"
	if main_node:
		main_node.connect("rules_updated", Callable(self, "update_daily_laws"))

func update_daily_laws(new_laws):
	daily_laws = new_laws
	if Guide.current_page == 2:
		$OpenGuide/GuideNote.text = daily_laws

func _on_turn_right_pressed():
	if Guide.current_page + 1 <= maximum_pages:
		Guide.current_page += 1
		if Guide.current_page == 1:
			print(Guide.current_page)
			$OpenGuide/GuideNote.text = how_to_play_note_1
			$OpenGuide/TurnLeft.visible = false
		elif Guide.current_page == 2:
			print(Guide.current_page)
			$OpenGuide/GuideNote.text = daily_laws
			$OpenGuide/TurnLeft.visible = true
			$OpenGuide/TurnRight.visible = false

func _on_turn_left_pressed():
	if Guide.current_page - 1 >= 1:
		Guide.current_page -= 1
		if Guide.current_page == 1:
			print(Guide.current_page)
			$OpenGuide/GuideNote.text = how_to_play_note_1
			$OpenGuide/TurnLeft.visible = false
			$OpenGuide/TurnRight.visible = true
		elif Guide.current_page == 2:
			print(Guide.current_page)
			$OpenGuide/GuideNote.text = daily_laws
			$OpenGuide/TurnLeft.visible = true
