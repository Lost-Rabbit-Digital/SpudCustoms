extends Sprite2D

var current_point: int = 0
var target_point: int = 0
var potato_info: Dictionary = {}

# Preload all the textures
var textures = {
	"Russet Burbank": preload("res://assets/potatoes/bodies/RussetBurbank_SmallSilhouette.png"),
	"Yukon Gold": preload("res://assets/potatoes/bodies/yukon_gold_body.png"),
	"Sweet Potato": preload("res://assets/potatoes/bodies/sweet_potato_body.png"),
	"Purple Majesty": preload("res://assets/potatoes/bodies/purple_majesty_body.png"),
	"Red Bliss": preload("res://assets/potatoes/bodies/red_bliss_body.png"),
}

# Reference to the Sprite2D node
@onready var sprite = $"Sprite2D"

func _ready():
	# Ensure the Sprite2D node exists
	if not sprite:
		print("Warning: Sprite2D node not found in PotatoPerson")

func move_toward(target: Vector2, speed: float):
	position = position.move_toward(target, speed)

# Function to update the potato's appearance and info
func update_potato(new_potato_info: Dictionary):
	potato_info = new_potato_info
	update_appearance()

# WARNING: GOING TO REPLACE THIS WHEN DOING CHARACTER GENERATION
# Function to update the potato's appearance
func update_appearance():
	if not sprite:
		print("Warning: Cannot update appearance, Sprite2D node not found")
		return
	
	if potato_info.has("type") and potato_info.type in textures:
		sprite.texture = textures[potato_info.type]
	else:
		print("Warning: Unknown or missing potato type: ", potato_info.get("type", "N/A"))

# You can call this function to get the current potato info
func get_potato_info() -> Dictionary:
	return potato_info
