extends Node2D
class_name CraterSystem


class Crater:
	var position: Vector2
	var size: float
	var alpha: float
	var lifetime: float
	var max_lifetime: float
	var rotation: float
	var debris_rotations: Array[float]
	var debris_positions: Array[Vector2]
	var debris_scales: Array[float]  # Added for variable debris sizes

	func _init(pos: Vector2, sz: float, lt: float):
		position = pos
		size = sz
		alpha = 1.0
		lifetime = 0.0
		max_lifetime = lt
		rotation = randf() * TAU

		# Precalculate debris positions, rotations, and scales
		debris_rotations = []
		debris_positions = []
		debris_scales = []
		for i in range(12):  # Increased from 6 to 12 pieces
			debris_rotations.append(randf() * TAU)
			var angle = randf() * TAU
			# Wider spread for debris
			var distance = randf_range(sz * 0.3, sz * 1.5)
			debris_positions.append(Vector2(cos(angle), sin(angle)) * distance)
			# More variation in debris sizes
			debris_scales.append(randf_range(0.15, 0.3))  # Smaller scale range

	func update(delta: float) -> bool:
		lifetime += delta
		alpha = 1.0 - (lifetime / max_lifetime)
		return lifetime < max_lifetime


@export var max_craters: int = 10
@export var crater_fade_time: float = 30.0
@export var crater_base_size: float = 20.0
@export var crater_color: Color
@export var show_debug: bool
@export_group("Textures")
@export var crater_texture: Texture2D = preload("res://assets/missiles/missile_crater.png")
@export var debris_texture: Texture2D = preload("res://assets/missiles/dirt_particle.png")

var active_craters: Array[Crater] = []


func _ready():
	z_index = 8
	position = Vector2.ZERO
	scale = Vector2.ONE
	show()


func add_crater(position: Vector2, size_multiplier: float = 1.0):
	if active_craters.size() >= max_craters:
		active_craters.pop_front()
	print("Drawing new crater at position: ", position)
	var crater = Crater.new(position, crater_base_size * size_multiplier, crater_fade_time)
	active_craters.append(crater)
	queue_redraw()


func _process(delta):
	var i = active_craters.size() - 1
	while i >= 0:
		if not active_craters[i].update(delta):
			active_craters.remove_at(i)
		i -= 1

	if active_craters.size() > 0:
		queue_redraw()


func _draw():
	if not crater_texture or not debris_texture:
		push_error("Crater or debris textures not set!")
		return

	if show_debug:
		print("Drawing craters: ", active_craters.size())

	for crater in active_craters:
		var draw_pos = crater.position
		var modulate = Color(1, 1, 1, crater.alpha)

		# Calculate the scale factor based on the desired size
		var crater_scale = (crater.size * 2) / crater_texture.get_width()

		# Draw main crater texture
		draw_set_transform(draw_pos, crater.rotation, Vector2(crater_scale, crater_scale))
		draw_texture(crater_texture, -crater_texture.get_size() / 2, modulate)

		# Draw debris pieces with individual scales
		for i in range(crater.debris_positions.size()):
			var debris_pos = draw_pos + crater.debris_positions[i]
			var debris_scale = crater_scale * crater.debris_scales[i]  # Use individual scales
			draw_set_transform(
				debris_pos, crater.debris_rotations[i], Vector2(debris_scale, debris_scale)
			)
			draw_texture(debris_texture, -debris_texture.get_size() / 2, modulate)

		# Reset transform
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

		if show_debug:
			# Ensure debug cross is drawn at correct z-index
			# Draw red border for better visibility
			var border_width = 3.0
			var border_color = Color.BLACK
			border_color.a = crater.alpha

			# Draw black border
			draw_line(
				draw_pos + Vector2(-12, 0), draw_pos + Vector2(12, 0), border_color, border_width
			)
			draw_line(
				draw_pos + Vector2(0, -12), draw_pos + Vector2(0, 12), border_color, border_width
			)

			# Draw red center
			var debug_color = Color.RED
			debug_color.a = crater.alpha
			draw_line(draw_pos + Vector2(-10, 0), draw_pos + Vector2(10, 0), debug_color, 2.0)
			draw_line(draw_pos + Vector2(0, -10), draw_pos + Vector2(0, 10), debug_color, 2.0)
