# MultiPotatoRain.gd
extends Node2D

@onready var particle_system = $GPUParticles2D
@onready var viewport_size = get_viewport_rect().size

func _ready():
	# Create animated texture with multiple frames
	var animated_texture = AnimatedTexture.new()
	animated_texture.frames = 4  # Set to number of potato textures you have
	
	# Load your potato texture
	var potato_texture = preload("res://assets/potatoes/bodies/yukon_gold_body.png")
	var potato_texture_1 = preload("res://assets/potatoes/bodies/russet_burbank_body.png")
	var potato_texture_2 = preload("res://assets/potatoes/bodies/sweet_potato_body.png")
	var potato_texture_3 = preload("res://assets/potatoes/bodies/purple_majesty_body.png")
	animated_texture.set_frame_texture(0, potato_texture)
	animated_texture.set_frame_texture(1, potato_texture_1)
	animated_texture.set_frame_texture(2, potato_texture_2)
	animated_texture.set_frame_texture(3, potato_texture_3)
	# Assign to particle system
	particle_system.texture = animated_texture
	
	# Configure particle system
	setup_particle_system()
	
func setup_particle_system():
	var process_material = ParticleProcessMaterial.new()
	
	# Basic emission settings
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3(viewport_size.x / 2, 1, 1)
	
	# Particle behavior
	process_material.direction = Vector3(0, 1, 0)
	process_material.spread = 10.0
	process_material.gravity = Vector3(0, 98, 0)
	process_material.initial_velocity_min = 50.0
	process_material.initial_velocity_max = 100.0
	
	# Animation settings for multiple frames
	process_material.anim_offset_min = 0.0
	process_material.anim_offset_max = 1.0  # Will randomly select frames
	
	# Particle appearance
	process_material.angle_min = 0.0
	process_material.angle_max = 360.0
	process_material.angular_velocity_min = -90.0
	process_material.angular_velocity_max = 90.0
	process_material.scale_min = 0.3
	process_material.scale_max = 0.5
	
	# Apply material
	particle_system.process_material = process_material
	
	# Configure particle system node
	particle_system.amount = 50
	particle_system.lifetime = 4.0
	particle_system.explosiveness = 0.0
	particle_system.randomness = 1.0
	particle_system.visibility_rect = Rect2(-viewport_size.x/2, -50, viewport_size.x, viewport_size.y + 100)
