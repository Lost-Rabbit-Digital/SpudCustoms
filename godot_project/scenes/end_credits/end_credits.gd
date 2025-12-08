@tool
extends Credits

@export_file("*.tscn") var main_menu_scene: String
@onready var init_mouse_filter = mouse_filter

# Preload both credit images
var default_credits_image: Texture2D = preload("res://assets/narrative/credits.png")
var sasha_credits_image: Texture2D = preload("res://assets/narrative/credits_sasha.png")


func _end_reached():
	%EndMessagePanel.get_parent().show()
	mouse_filter = Control.MOUSE_FILTER_STOP
	super._end_reached()


func _on_MenuButton_pressed():
	# SceneLoader.load_scene(main_menu_scene)
	get_tree().change_scene_to_file("res://scenes/menus/main_menu/main_menu_with_animations.tscn")


func _on_ExitButton_pressed():
	get_tree().quit()


func _ready():
	if main_menu_scene.is_empty():
		%MenuButton.hide()
	if OS.has_feature("web"):
		%ExitButton.hide()

	# Check if player committed to Sasha throughout the game
	_update_credits_image_based_on_choices()

	super._ready()


## Checks narrative choices to determine if player committed to Sasha.
## Uses the special Sasha credits image if player made committed choices.
func _update_credits_image_based_on_choices() -> void:
	var background_texture: TextureRect = get_node_or_null("BackgroundTextureRect")
	if not background_texture:
		return

	# Check Sasha-related narrative choices from Dialogic
	var sasha_commitment_score: int = 0

	# Key commitment choices with Sasha
	if Dialogic.VAR.has("sasha_trust_level") and Dialogic.VAR.get("sasha_trust_level") == "committed":
		sasha_commitment_score += 1

	if Dialogic.VAR.has("sasha_investigation") and Dialogic.VAR.get("sasha_investigation") == "committed":
		sasha_commitment_score += 1

	if Dialogic.VAR.has("sasha_plan_response") and Dialogic.VAR.get("sasha_plan_response") == "committed":
		sasha_commitment_score += 1

	if Dialogic.VAR.has("murphy_final_alliance") and Dialogic.VAR.get("murphy_final_alliance") == "committed":
		sasha_commitment_score += 1

	# Sasha arrest reaction - intervening or promising shows commitment
	if Dialogic.VAR.has("sasha_arrest_reaction"):
		var reaction: String = Dialogic.VAR.get("sasha_arrest_reaction")
		if reaction == "intervene" or reaction == "promise":
			sasha_commitment_score += 1

	# Require at least 3 committed choices to show Sasha ending image
	const SASHA_COMMITMENT_THRESHOLD: int = 3

	if sasha_commitment_score >= SASHA_COMMITMENT_THRESHOLD:
		background_texture.texture = sasha_credits_image
		print("End Credits: Showing Sasha credits image (commitment score: ", sasha_commitment_score, ")")
	else:
		background_texture.texture = default_credits_image
		print("End Credits: Showing default credits image (commitment score: ", sasha_commitment_score, ")")


func reset():
	super.reset()
	%EndMessagePanel.get_parent().hide()
	mouse_filter = init_mouse_filter


func _unhandled_input(event):
	if not enabled:
		return
	if event.is_action_pressed("ui_cancel"):
		if not %EndMessagePanel.get_parent().visible:
			_end_reached()
		else:
			get_tree().quit()
