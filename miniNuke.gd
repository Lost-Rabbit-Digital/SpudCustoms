# Mini-nuke for when potatoes run the border, or are rejected on their entry visa,
# and also for Lovecraftian horrors
extends GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready(): 
	# Set up the particle system
	amount = 255
	lifetime = 3.0 
	explosiveness = 0.8
	randomness = 0.2
	
	# Detonate the mini-nuke
	self.trigger_explosion()
	
	# Create a new ParticlesMaterial 
	var particle_material = ParticleProcessMaterial.new()
	
	# Set up the emission shape ( a sphere for a 3d-like effect) 
	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	particle_material.emission_sphere_radius = 50.0
	
	# set up particle movement
	particle_material.gravity = Vector3( -1, -2, 0) # adjust for an isometric perspective
	particle_material.initial_velocity_min = -10.0
	particle_material.initial_velocity_max = 10.0 
	
	# Set up particle appearance
	particle_material.scale_min = .05
	particle_material.scale_max = .25
	particle_material.color_ramp = create_color_ramp()
	
	# apply the material to the particle
	process_material = particle_material
	
	# Apply the small circular gradient texture for the particles
	texture = preload("res://textures/miniNuke_particle_texture.png")
	
func create_color_ramp():
	var color_ramp = Gradient.new()
	color_ramp.add_point(0.0, Color(1, 0.5, 0, 1)) # Orange
	color_ramp.add_point(0.4, Color(1, 0, 0, 1)) # Red
	color_ramp.add_point(0.7, Color(0.3, 0.3, 0.3, 1)) # Dark grey
	color_ramp.add_point(1.0, Color(0.1, 0.1, 0.1, 0)) # Fading to transparent 
	
func trigger_explosion():
	emitting = true
	
	
	
