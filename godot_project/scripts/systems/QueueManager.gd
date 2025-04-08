extends Node2D

var PotatoPerson = preload("res://scripts/systems/PotatoPerson.tscn")
var path: Path2D
var curve: Curve2D
var max_potatoes: int
var potatoes: Array = []
var spawn_point: Vector2
var path_node_path: NodePath
var potato_walk_speed = 150
var potato_run_speed = 200

func _ready():
	path_node_path = %SpuddyQueue.get_path()
	path = get_node(path_node_path)
	
	# More verbose logging
	if path:
		print("SpuddyQueue Path found: ", path.name)
		#print("Path points: ", path.curve.get_point_count())
		#for i in range(path.curve.get_point_count()):
			#print("Point %d: %s" % [i, path.curve.get_point_position(i)])
	else:
		push_error("SpuddyQueue Path is null.")

	curve = path.curve
	spawn_point = curve.get_point_position(0)
	#print("Spawn point set to: ", spawn_point)
	
	# Set max potatoes based on length of curve
	max_potatoes = curve.get_point_count() - 1
	print("Maximum amount of potatoes in line: ", max_potatoes)

func can_add_potato() -> bool:
	return potatoes.size() < max_potatoes

func spawn_new_potato():	
	if %NarrativeManager.is_dialogue_active():
		#print("QueueManager disabled while in dialogue, no immigrating potatoes allowed.")
		return
		
	print("Attempting to spawn potato. Can add: ", can_add_potato())
	if can_add_potato():
		var potato = PotatoFactory.create_random_potato()
		
		# More detailed logging about potato creation
		if potato:
			#print("Potato created with info: ", potato.get_potato_info())
			add_child(potato)
			
			potato.position = spawn_point
			potato.set_state(potato.TaterState.QUEUED)
			potato.update_appearance()
			
			potatoes.push_front(potato)
			update_positions()
			print("Potato spawned. Total potatoes: ", potatoes.size())
		else:
			push_error("Failed to create potato via PotatoFactory!")
	else:
		print("Cannot add more potatoes. Current count: ", potatoes.size())

func add_potato(potato_info: Dictionary):
	var potato = PotatoPerson.instantiate()
	add_child(potato)
	potato.position = spawn_point
	potato.current_point = 0
	potato.target_point = 0
	potato.update_potato(potato_info)
	# Start with zero opacity
	potato.modulate.a = 0
	
	# Create fade-in tween
	var tween = create_tween()
	tween.tween_property(potato, "modulate:a", 1.0, 0.5)

	potatoes.push_front(potato)
	print("Potato Created, new total potatoes: ", potatoes.size())
	#print("New potato information: ", potato_info)
	update_positions()

func remove_potato() -> Dictionary:
	if potatoes.size() > 0:
		var potato = potatoes.pop_back()
		var info = potato.get_potato_info()
		potato.queue_free()
		print("Potato removed from this realm, new total potatoes: ", potatoes.size())
		#print("Dearly missed potato information: ", info)
		update_positions()
		return info
	return {}

func update_positions():
	var point_count = curve.get_point_count()
	var potato_count = potatoes.size()
	print("Updating positions for ", potato_count, " potatoes")
	
	if potato_count > 0:
		for i in range(potato_count):
			var target_point = min(point_count - 1, point_count - 1 - i)
			potatoes[potato_count - 1 - i].target_point = target_point
			#print("Potato ", potato_count - 1 - i, " target point set to: ", target_point)

func get_all_potatoes() -> Array:
	return potatoes

func _process(delta):
	var i = potatoes.size() - 1
	
	# Iterate backwards to safely remove elements
	while i >= 0:
		var potato = potatoes[i]
		
		# Check if potato is still valid before accessing its properties
		if is_instance_valid(potato):
			if potato.current_point < potato.target_point:
				var next_point = potato.current_point + 1
				var next_pos = curve.get_point_position(next_point)
				var target_pos = potato.position.move_toward(next_pos, delta * potato_walk_speed)
				
				if target_pos.distance_to(next_pos) < 1:
					potato.current_point = next_point
				
				potato.position = target_pos
			else:
				var target_pos = curve.get_point_position(potato.target_point)
				potato.position = potato.position.move_toward(target_pos, delta * potato_walk_speed)
		else:
			# If potato is not valid, remove it from the array
			potatoes.remove_at(i)
			print("Removed invalid potato from queue at index: ", i)
		
		i -= 1

func get_front_potato_info() -> Dictionary:
	if potatoes.size() > 0:
		return potatoes.back().get_potato_info()
	return {}
	
func remove_front_potato() -> PotatoPerson: 
	if potatoes.size() > 0: 
		var potato = potatoes.pop_back()
		print("Removing front potato. Remaining potatoes: ", potatoes.size())
		update_positions()
		return potato
	return null

func debug_add_potatoes(count: int):
	for i in range(count):
		var info = {
			"name": "Debug Potato " + str(i),
			"type": "Debug Type",
			"condition": "Fresh"
		}
		add_potato(info)
	print("Debug: Added ", count, " potatoes")

func disable():
	# Stop processing
	set_process(false)
	
	# Clear potatoes if needed
	if potatoes.size() > 0:
		for potato in potatoes:
			if potato:
				potato.set_process(false)
				if potato.has_method("cleanup"):
					potato.cleanup()
		potatoes.clear()
