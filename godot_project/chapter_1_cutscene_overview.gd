extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.start("res://assets/narrative/chapter_1/chapter_1_1/chapter_1_1_overview.dtl")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent):
	# check if a dialog is already running
	if Dialogic.current_timeline != null:
		return

	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		Dialogic.start("res://assets/narrative/chapter_1/chapter_1_1/chapter_1_1_overview.dtl")
		get_viewport().set_input_as_handled()
