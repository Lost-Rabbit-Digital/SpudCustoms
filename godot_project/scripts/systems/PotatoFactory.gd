class_name PotatoFactory
extends Node

static var potato_scene = load("res://scripts/systems/PotatoPerson.tscn")


# Static function to create a new potato with random attributes
static func create_random_potato() -> PotatoPerson:
	var potato = potato_scene.instantiate()

	# Generate random potato info
	var potato_info = generate_random_potato_info()

	# Update the potato with the info
	potato.update_potato(potato_info)

	return potato


# Static function to create a potato with specific info
static func create_potato_with_info(info: Dictionary) -> PotatoPerson:
	var potato = potato_scene.instantiate()

	# Update the potato with the provided info
	potato.update_potato(info)

	# Set default movement speeds
	potato.regular_path_speed = 0.30  # Default fallback

	return potato


# Generate random potato info
static func generate_random_potato_info() -> Dictionary:
	# Generate character appearance
	var character_gen = load("res://scripts/systems/character_generator.tscn").instantiate()

	# Gender first since it affects character generation
	var sex = get_random_sex()

	# Set the gender on the character generator
	character_gen.set_sex("Male" if sex == "Male" else "Female")

	# Add race selection
	var race = get_random_race()

	# Now randomize
	character_gen.randomise_character()
	var character_data = character_gen.get_character_data()
	character_gen.queue_free()

	# Randomize expiration date
	var expiration_date: String
	if randf() < 0.2:
		expiration_date = get_past_date(0, 3)
	else:
		expiration_date = get_future_date(0, 3)

	return {
		"name": get_random_name(),
		"condition": get_random_condition(),
		"sex": sex,
		"race": race,  # Add race to the potato info
		"country_of_issue": get_random_country(),
		"date_of_birth": get_past_date(1, 10),
		"expiration_date": expiration_date,
		"character_data": character_data
	}


# Helper functions from mainGame.gd
static func get_random_name() -> String:
	var first_names = [
		"Spud",
		"Tater",
		"Mash",
		"Spudnik",
		"Tater Tot",
		"Potato",
		"Chip",
		"Murph",
		"Yam",
		"Tato",
		"Spuddy",
		"Tuber",
		"Russet",
		"Fry",
		"Hash"
		# Add more names as needed
	]
	var last_names = [
		"Ouwiw",
		"Sehi",
		"Sig",
		"Heechou",
		"Oufug",
		"Azej",
		"Holly",
		"Ekepa",
		"Nuz",
		"Chegee",
		"Kusee",
		"Houf",
		"Fito",
		"Mog",
		"Urife"
		# Add more last names as needed
	]
	return (
		"%s %s"
		% [first_names[randi() % first_names.size()], last_names[randi() % last_names.size()]]
	)


static func get_random_condition() -> String:
	var conditions = ["Fresh", "Extra Eyes", "Rotten", "Sprouted", "Dehydrated", "Frozen"]
	return conditions[randi() % conditions.size()]


static func get_random_race() -> String:
	var races = ["Russet", "Yukon Gold", "Sweet Potato", "Purple Majesty"]
	return races[randi() % races.size()]


static func get_random_sex() -> String:
	return ["Male", "Female"][randi() % 2]


static func get_random_country() -> String:
	var countries = [
		"Spudland",
		"Potatopia",
		"Tuberstan",
		"North Yamnea",
		"Spuddington",
		"Tatcross",
		"Mash Meadows",
		"Tuberville",
		"Chip Hill",
		"Murphyland",
		"Colcannon",
		"Pratie Point"
	]
	return countries[randi() % countries.size()]


static func get_past_date(years_ago_start: int, years_ago_end: int) -> String:
	var current_date = Time.get_date_dict_from_system()
	var year = current_date.year - years_ago_start - randi() % (years_ago_end - years_ago_start + 1)
	var month = randi() % 12 + 1
	var day = randi() % 28 + 1
	return "%04d.%02d.%02d" % [year, month, day]


static func get_future_date(years_ahead_start: int, years_ahead_end: int) -> String:
	var current_date = Time.get_date_dict_from_system()
	var year = (
		current_date.year + years_ahead_start + randi() % (years_ahead_end - years_ahead_start + 1)
	)
	var month = randi() % 12 + 1
	var day = randi() % 28 + 1
	return "%04d.%02d.%02d" % [year, month, day]


class Gib:
	extends Sprite2D
	var velocity = Vector2.ZERO
	var spin = 0.0
	var lifetime = 0.0
	var max_lifetime = 1.0
	var gravity = 300.0

	func _process(delta):
		# Update position
		position += velocity * delta

		# Apply gravity
		velocity.y += gravity * delta

		# Rotate
		rotation += spin * delta

		# Update lifetime and fade
		lifetime += delta
		modulate.a = 1.0 - (lifetime / max_lifetime)

		# Remove when lifetime expires
		if lifetime >= max_lifetime:
			queue_free()


static func create_gibs(
	position: Vector2, count: int, parent: Node, config: Dictionary = {}
) -> Array:
	var gibs = []
	var gib_textures = load_gib_textures()

	# Default configuration values
	var min_speed = config.get("min_speed", 250.0)
	var max_speed = config.get("max_speed", 375.0)
	var min_spin = config.get("min_spin", -13.0)
	var max_spin = config.get("max_spin", 13.0)
	var min_lifetime = config.get("min_lifetime", 1.5)
	var max_lifetime = config.get("max_lifetime", 2.5)
	var gib_scale = config.get("scale", Vector2(0.35, 0.35))
	var gravity = config.get("gravity", 300.0)

	for i in range(count):
		var gib = Gib.new()

		# Set appearance
		gib.texture = gib_textures[randi() % gib_textures.size()]
		gib.position = position
		gib.scale = gib_scale
		gib.z_index = ConstantZIndexes.Z_INDEX.GIBS  # Make sure gibs appear above other elements

		# Set random velocity - use half-circle upward direction
		var angle = randf_range(-PI, 0)  # Only spawn in upward half-circle (-180° to 0°)
		var speed = randf_range(min_speed, max_speed)
		gib.velocity = Vector2(cos(angle), sin(angle)) * speed

		# Set random rotation and spin
		gib.rotation = randf() * 2 * PI
		gib.spin = randf_range(min_spin, max_spin)

		# Set lifetime
		gib.max_lifetime = randf_range(min_lifetime, max_lifetime)
		gib.gravity = gravity

		# Add to parent
		parent.add_child(gib)
		gibs.append(gib)

	return gibs


# Helper to load gib textures
static func load_gib_textures() -> Array:
	var textures = []
	for i in range(1, 9):
		var texture_path = "res://assets/potato_giblets/giblet_" + str(i) + ".png"
		var texture = load(texture_path)
		if texture:
			textures.append(texture)
		else:
			print("Failed to load gib texture: ", texture_path)
	return textures


static func load_explosion_frames() -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	var spritesheet = load("res://assets/effects/explosion_spritesheet.png")

	if spritesheet:
		# Assuming 13 frames arranged horizontally
		var frame_width = spritesheet.get_width() / 13
		var frame_height = spritesheet.get_height()

		for i in range(13):
			var atlas = AtlasTexture.new()
			atlas.atlas = spritesheet
			atlas.region = Rect2(i * frame_width, 0, frame_width, frame_height)
			frames.append(atlas)

	return frames


# Function to create pixel art explosion at a position
static func create_pixel_explosion(position: Vector2, parent: Node, scale_multiplier: float = 2.0):
	# Load explosion frames
	var explosion_frames = load_explosion_frames()

	if explosion_frames.size() > 0:
		# Create animated explosion
		var explosion = AnimatedExplosion.new(explosion_frames, position)
		explosion.scale = Vector2(scale_multiplier, scale_multiplier)
		parent.add_child(explosion)

		# Create some gibs
		create_gibs(position, 20, parent)

		return explosion
	else:
		print("Failed to load explosion frames")
		return null


# Function to create missile sprites
static func create_missile_sprite() -> AnimatedSprite2D:
	# Create sprite frames resource
	var sprite_frames = SpriteFrames.new()

	# Load missile textures
	var missile_frames = []
	for i in range(1, 3):  # 2 frames
		var texture_path = "res://assets/missiles/rocket_frame_%d.png" % i
		var texture = load(texture_path)
		if texture:
			missile_frames.append(texture)
		else:
			print("Failed to load missile frame: ", texture_path)

	# Add animation
	if missile_frames.size() > 0:
		sprite_frames.add_animation("default")
		for frame in missile_frames:
			sprite_frames.add_frame("default", frame)

		# Set FPS
		sprite_frames.set_animation_speed("default", 10)  # 10 FPS

		# Create animated sprite
		var missile_sprite = AnimatedSprite2D.new()
		missile_sprite.sprite_frames = sprite_frames
		missile_sprite.play("default")

		return missile_sprite
	else:
		print("Failed to load missile frames")
		return null


# AnimatedExplosion class for handling explosion animations
class AnimatedExplosion:
	extends Node2D
	var frame = 0
	var frames: Array[Texture2D] = []
	var animation_speed = 0.05  # Time between frames in seconds
	var time_elapsed = 0.0
	var sprite: Sprite2D

	func _init(explosion_frames: Array[Texture2D], pos: Vector2):
		position = pos
		frames = explosion_frames
		z_index = ConstantZIndexes.Z_INDEX.EXPLOSIONS  # Ensure explosion appears above gibs and other elements

		# Create sprite for displaying frames
		sprite = Sprite2D.new()
		sprite.texture = frames[0]
		add_child(sprite)

	func _process(delta):
		time_elapsed += delta

		if time_elapsed >= animation_speed:
			time_elapsed = 0
			frame += 1

			if frame >= frames.size():
				# Animation complete, remove the explosion
				queue_free()
				return

			# Update to next frame
			sprite.texture = frames[frame]
