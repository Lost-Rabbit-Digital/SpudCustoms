extends Node2D

# Explosion parameters
@export var num_particles = 50
@export var explosion_radius = 100.0
@export var explosion_duration = 0.75
@export var core_duration = 0.2
@export var particle_size = 4

# Colors
var colors = [Color(1, 1, 1), Color(1, 0.8, 0), Color(1, 0.5, 0), Color(1, 0, 0), Color(0.7, 0, 0)]  # White  # Yellow  # Orange  # Red  # Dark red

# Internal variables
var particles = []
var time = 0
var active = false
var core_size = 0
var explosion_active = false


class ExplosionParticle:
	var position: Vector2
	var velocity: Vector2
	var color: Color
	var size: float
	var lifetime: float
	var max_lifetime: float

	func _init(pos, vel, col, sz, life):
		position = pos
		velocity = vel
		color = col
		size = sz
		lifetime = life
		max_lifetime = life


func start_explosion():
	explosion_active = true
	time = 0
	core_size = 0
	particles.clear()

	# Create initial particles
	for i in range(num_particles):
		var angle = randf() * TAU
		var distance = randf() * explosion_radius
		var velocity = Vector2.from_angle(angle) * distance * 4

		var particle = ExplosionParticle.new(
			Vector2.ZERO,
			velocity,
			colors[randi() % colors.size()],
			particle_size * (1 + randf()),
			explosion_duration * (0.5 + randf() * 0.5)
		)
		particles.append(particle)

	# Start the cleanup timer
	var timer = get_tree().create_timer(explosion_duration)
	timer.connect("timeout", Callable(self, "_on_explosion_finished"))


func _process(delta):
	if not explosion_active:
		return

	time += delta
	queue_redraw()

	# Update core flash
	if time < core_duration:
		core_size = lerp(0.0, explosion_radius * 0.5, time / core_duration)
	else:
		core_size = lerp(
			explosion_radius * 0.5, 0.0, (time - core_duration) / (core_duration * 0.5)
		)

	# Update particles
	for particle in particles:
		particle.lifetime -= delta
		if particle.lifetime > 0:
			particle.velocity *= 0.95  # Add drag
			particle.position += particle.velocity * delta

			# Add some turbulence
			var turbulence = Vector2(
				randf_range(-1, 1) * 50 * delta, randf_range(-1, 1) * 50 * delta
			)
			particle.position += turbulence


func _draw():
	if not explosion_active:
		return

	# Draw core flash
	if time < core_duration * 1.5:
		var core_color = Color(1, 1, 1, 1 - (time / (core_duration * 1.5)))
		draw_circle(Vector2.ZERO, core_size, core_color)

	# Draw particles
	for particle in particles:
		if particle.lifetime <= 0:
			continue

		var alpha = particle.lifetime / particle.max_lifetime
		var color = particle.color
		color.a = alpha

		# Draw pixelated particle
		var rect = Rect2(
			particle.position - Vector2(particle.size / 2, particle.size / 2),
			Vector2(particle.size, particle.size)
		)
		draw_rect(rect, color)


func _on_explosion_finished():
	explosion_active = false
	particles.clear()
	queue_redraw()
