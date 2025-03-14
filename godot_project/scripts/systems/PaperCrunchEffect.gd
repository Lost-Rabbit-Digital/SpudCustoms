extends Node2D
class_name PaperCrunchEffect

# Create a custom class for paper bits
class PaperBit extends Sprite2D:
	var velocity: Vector2
	var gravity: float
	var lifetime: float
	var max_lifetime: float
	var spin_speed: float
	var arc_height: float
	var arc_progress: float

# Paper bit particle parameters
@export var num_bits = 15
@export var bit_lifetime = 1.0
@export var max_spawn_radius = 2.0
@export var gravity = 300.0
@export var max_initial_velocity = 90.0
@export var arc_height_factor = 90.0
@export var bit_size_range = Vector2(0.01, 0.025)  # Scale range for paper bits
@export var spin_speed_range = Vector2(3.0, 8.0)  # Rotation speed range

var paper_bits = []  # Will hold custom PaperBit instances
var smoke_frames = []  # Will store our atlas textures

# Optional parameter to use a different spritesheet
@export var custom_spritesheet: Texture2D

func _ready():
	# Load the smoke spritesheet or use custom one if provided
	var spritesheet = custom_spritesheet
	if not spritesheet:
		spritesheet = preload("res://assets/effects/smoke_spritesheet.png")
	
	# Create sprite frames from spritesheet
	create_frames_from_spritesheet(spritesheet)

func create_frames_from_spritesheet(spritesheet: Texture2D):
	var hframes = 8  # Number of horizontal frames, adjust based on your spritesheet
	
	# Calculate frame dimensions
	var frame_width = spritesheet.get_width() / hframes
	var frame_height = spritesheet.get_height()
	
	# Create atlas textures for each frame
	for i in range(hframes):
		var atlas = AtlasTexture.new()
		atlas.atlas = spritesheet
		atlas.region = Rect2(i * frame_width, 0, frame_width, frame_height)
		smoke_frames.append(atlas)

# Create the effect at a specific position
func spawn_at(position: Vector2):
	global_position = position
	spawn_paper_bits()

# Spawn paper bits with arc trajectories
func spawn_paper_bits():
	# Clear any existing bits
	clear_bits()
	
	# Create paper bits
	for i in range(num_bits):
		var bit = create_paper_bit()
		add_child(bit)
		paper_bits.append(bit)
		
		# Set random properties
		var spawn_offset = Vector2(
			randf_range(-max_spawn_radius, max_spawn_radius),
			randf_range(-max_spawn_radius, max_spawn_radius)
		)
		bit.position = spawn_offset
		
		# Random frame for visual variety
		bit.texture = smoke_frames[randi() % smoke_frames.size()]
		
		# Random size
		var bit_scale = randf_range(bit_size_range.x, bit_size_range.y)
		bit.scale = Vector2(bit_scale, bit_scale)
		
		# Random color tint (paper-like colors)
		var color_variation = randf_range(0.8, 1.0)
		bit.modulate = Color(color_variation, color_variation, color_variation * 0.9)
		
		# Set random trajectory
		var angle = randf_range(0, TAU)  # Random direction
		var speed = randf_range(max_initial_velocity * 0.3, max_initial_velocity)
		
		# Store velocity and other movement properties in the bit
		bit.velocity = Vector2(cos(angle), sin(angle)) * speed
		bit.gravity = gravity
		bit.lifetime = 0
		bit.max_lifetime = bit_lifetime * randf_range(0.7, 1.3)  # Varied lifetime
		bit.spin_speed = randf_range(spin_speed_range.x, spin_speed_range.y) * (1 if randf() > 0.5 else -1)
		
		# Add arc height influence
		bit.arc_height = randf_range(arc_height_factor * 0.5, arc_height_factor)
		bit.arc_progress = 0
		
		bit.z_as_relative = false
		bit.z_index = 0

# Create a single paper bit sprite
func create_paper_bit() -> PaperBit:
	var bit = PaperBit.new()
	return bit

# Clear all paper bits
func clear_bits():
	for bit in paper_bits:
		if is_instance_valid(bit):
			bit.queue_free()
	paper_bits.clear()

func _process(delta):
	var i = paper_bits.size() - 1
	
	while i >= 0:
		var bit = paper_bits[i]
		
		if is_instance_valid(bit):
			# Update lifetime
			bit.lifetime += delta
			
			# Check if lifetime exceeded
			if bit.lifetime >= bit.max_lifetime:
				bit.modulate.a = max(0, (bit.max_lifetime - bit.lifetime) / 0.2)  # Fade out
				
				if bit.modulate.a <= 0:
					bit.queue_free()
					paper_bits.remove_at(i)
					i -= 1
					continue
			
			# Update arc progress (0 to 1 over lifetime)
			bit.arc_progress = min(bit.lifetime / (bit.max_lifetime * 0.7), 1.0)
			
			# Apply gravity to velocity
			bit.velocity.y += bit.gravity * delta
			
			# Arc influence on Y position (peaked at 0.5 progress)
			var arc_influence = -bit.arc_height * sin(bit.arc_progress * PI) * delta
			
			# Apply movement
			bit.position += bit.velocity * delta
			bit.position.y += arc_influence
			
			# Apply rotation
			bit.rotation += bit.spin_speed * delta
			
			# Apply fade-in at start and fade-out at end
			if bit.lifetime < 0.1:
				bit.modulate.a = bit.lifetime / 0.1
			elif bit.lifetime > bit.max_lifetime - 0.3:
				bit.modulate.a = (bit.max_lifetime - bit.lifetime) / 0.3
		else:
			paper_bits.remove_at(i)
		
		i -= 1
		
	# Auto-free when all particles are gone
	if paper_bits.size() == 0 and not Engine.is_editor_hint():
		queue_free()

# Static method to easily create and add the effect to a scene
static func create_at(parent: Node, position: Vector2) -> PaperCrunchEffect:
	var effect = load("res://scripts/systems/PaperCrunchEffect.gd").new()
	parent.add_child(effect)
	effect.spawn_at(position)
	return effect
