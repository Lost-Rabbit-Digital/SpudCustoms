extends Node2D

var PotatoPerson = preload("res://PotatoPerson.tscn")
var path: Path2D
var curve: Curve2D
var max_potatoes: int = 10
var potatoes: Array = []
var spawn_point: Vector2

func _ready():
	var path_node_path: NodePath = ^"../Path2D (SpuddyQueue)"
	path = get_node(path_node_path)
	curve = path.curve
	spawn_point = curve.get_point_position(0)
	print("Path loaded, spawn point set to: ", spawn_point)

func add_potato():
	if potatoes.size() >= max_potatoes:
		print("Maximum number of potatoes reached")
		return
	
	var potato = PotatoPerson.instantiate()
	add_child(potato)
	potato.position = spawn_point
	potatoes.push_front(potato)  # Add new potatoes to the front of the array
	print("Potato added. Total potatoes: ", potatoes.size())
	update_positions()

func remove_potato():
	if potatoes.size() > 0:
		var potato = potatoes.pop_back()  # Remove the potato at the end of the queue
		potato.queue_free()
		print("Potato removed. Total potatoes: ", potatoes.size())
		update_positions()

func update_positions():
	var path_length = curve.get_baked_length()
	print("Updating positions for ", potatoes.size(), " potatoes")
	for i in range(potatoes.size()):
		var offset = 1.0 - (float(i) / max(1, potatoes.size() - 1))  # Reverse the offset
		var distance_along_path = path_length * offset
		var target_position = curve.sample_baked(distance_along_path)
		var random_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
		potatoes[i].target_position = target_position + random_offset
		print("Potato ", i, " target position set to: ", potatoes[i].target_position)

func _process(delta):
	for potato in potatoes:
		if potato.has_method("move_toward"):
			potato.move_toward(potato.target_position, delta * 50)
		else:
			potato.position = potato.position.move_toward(potato.target_position, delta * 50)

# Call this function to manually add potatoes for testing
func debug_add_potatoes(count: int):
	for i in range(count):
		add_potato()
	print("Debug: Added ", count, " potatoes")
