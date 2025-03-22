extends Node2D

var potato_texture = preload("res://assets/potatoes/bodies/russet_burbank_body.png")
var viewport_size
var spawn_timer = 0.0
var spawn_interval = 0.01  # Time between potato spawns
var max_active_potatoes = 400
var active_potatoes = []

class Potato extends Sprite2D:
	var velocity = Vector2.ZERO
	var rotation_speed = 50.0
	var lifetime = 0.0
	var max_lifetime = 4.0
	
	func _init(texture, pos, vel, rot_speed):
		self.texture = texture
		self.position = pos
		self.velocity = vel
		self.rotation_speed = rot_speed
		self.scale = Vector2(0.5, 0.5) * (randf() * 0.4 + 1)  # Random size variation
	
	func update(delta):
		# Update position based on velocity
		position += velocity * delta
		
		# Apply gravity
		velocity.y += 98 * delta
		
		# Rotate based on horizontal velocity
		rotation += rotation_speed * delta
		
		# Update lifetime
		lifetime += delta
		
		# Return true if still alive
		return lifetime < max_lifetime

func _ready():
	viewport_size = get_viewport_rect().size
	set_process(true)

func _process(delta):
	# Spawn new potatoes
	spawn_timer += delta
	if spawn_timer >= spawn_interval and active_potatoes.size() < max_active_potatoes:
		spawn_timer = 0
		spawn_potato()
	
	# Update existing potatoes
	var i = active_potatoes.size() - 1
	while i >= 0:
		var potato = active_potatoes[i]
		if not potato.update(delta):
			# Potato has expired, remove it
			potato.queue_free()
			active_potatoes.remove_at(i)
		i -= 1

func spawn_potato():
	# Create random position at top of screen
	var pos = Vector2(
		randf() * viewport_size.x,
		-50  # Start above screen
	)
	
	# Create random velocity
	var vel = Vector2(
		randf_range(-100, 100),  # Random horizontal velocity
		randf_range(50, 150)   # Random downward velocity
	)
	
	# Create rotation speed proportional to horizontal velocity
	var rot_speed = vel.x * 0.05
	
	# Create new potato
	var potato = Potato.new(potato_texture, pos, vel, rot_speed)
	add_child(potato)
	active_potatoes.append(potato)
