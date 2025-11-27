class_name FootprintPool
extends Node
## Object pool for footprint sprites to prevent create/destroy overhead.
##
## Usage:
##   var pool = FootprintPool.new()
##   add_child(pool)
##   pool.initialize(30)  # Pre-allocate 30 footprints
##   var footprint = pool.get_footprint()
##   # ... use footprint ...
##   pool.return_footprint(footprint)

## Preloaded footprint textures
var texture_concrete: Texture2D = preload("res://assets/effects/footstep_concrete.png")
var texture_grass: Texture2D = preload("res://assets/effects/footstep_grass.png")

## Pool of available footprint sprites
var _available_pool: Array[Sprite2D] = []

## Currently active footprints
var _active_footprints: Array[Sprite2D] = []

## Maximum pool size
var _max_pool_size: int = 50

## Parent node for footprints (usually the scene root)
var _footprint_parent: Node = null


## Initialize the pool with a given number of pre-allocated footprints.
## @param initial_size Number of footprints to pre-allocate.
## @param parent_node Node to add footprints to (defaults to current scene).
func initialize(initial_size: int = 30, parent_node: Node = null) -> void:
	_max_pool_size = max(initial_size, _max_pool_size)
	_footprint_parent = parent_node

	# Pre-allocate footprints
	for i in initial_size:
		var footprint = _create_footprint()
		footprint.visible = false
		_available_pool.append(footprint)


## Get a footprint from the pool, creating one if necessary.
## @param is_concrete Whether the footprint should use the concrete texture.
## @return A Sprite2D configured as a footprint.
func get_footprint(is_concrete: bool = false) -> Sprite2D:
	var footprint: Sprite2D

	if _available_pool.size() > 0:
		footprint = _available_pool.pop_back()
	else:
		# Pool exhausted, create new one (or recycle oldest active)
		if _active_footprints.size() >= _max_pool_size:
			# Recycle the oldest active footprint
			footprint = _active_footprints.pop_front()
			_reset_footprint(footprint)
		else:
			footprint = _create_footprint()

	# Configure for surface type
	_configure_footprint(footprint, is_concrete)

	# Track as active
	_active_footprints.append(footprint)
	footprint.visible = true

	return footprint


## Return a footprint to the pool for reuse.
## @param footprint The footprint sprite to return.
func return_footprint(footprint: Sprite2D) -> void:
	if not is_instance_valid(footprint):
		return

	# Remove from active list
	_active_footprints.erase(footprint)

	# Reset and add back to pool
	_reset_footprint(footprint)
	footprint.visible = false

	_available_pool.append(footprint)


## Create a new footprint sprite.
func _create_footprint() -> Sprite2D:
	var footprint = Sprite2D.new()
	footprint.z_index = ConstantZIndexes.Z_INDEX.FOOTPRINTS
	footprint.add_to_group("FootprintGroup")

	# Add to parent
	var parent = _footprint_parent if _footprint_parent else get_tree().current_scene
	if parent:
		parent.add_child(footprint)

	return footprint


## Reset a footprint to default state for reuse.
func _reset_footprint(footprint: Sprite2D) -> void:
	footprint.modulate = Color.WHITE
	footprint.scale = Vector2.ONE
	footprint.rotation = 0.0
	footprint.global_position = Vector2.ZERO


## Configure a footprint for a specific surface type.
func _configure_footprint(footprint: Sprite2D, is_concrete: bool) -> void:
	if is_concrete:
		footprint.texture = texture_concrete
		footprint.scale = Vector2(randf_range(0.65, 0.75), randf_range(0.65, 0.75))
		footprint.modulate = Color(1, 1, 1, 0.7)
	else:
		footprint.texture = texture_grass
		footprint.scale = Vector2(randf_range(0.75, 0.85), randf_range(0.75, 0.85))
		footprint.modulate = Color(1, 1, 1, 0.8)

	# Add random rotation for natural look
	footprint.rotation = randf_range(-0.1, 0.15)


## Spawn a footprint at the given position with fade-out animation.
## This is a convenience method that handles the full footprint lifecycle.
## @param position Global position to spawn the footprint.
## @param is_concrete Whether on concrete surface.
## @param fade_duration How long the fade-out takes.
## @param final_alpha The alpha value after fading.
func spawn_at_position(
	position: Vector2, is_concrete: bool = false, fade_duration: float = 3.0, final_alpha: float = 0.3
) -> Sprite2D:
	var footprint = get_footprint(is_concrete)

	# Apply position with random offset
	var x_offset = randf_range(-5, 5)
	var y_offset = randf_range(8, 14)
	footprint.global_position = position + Vector2(x_offset, y_offset)

	# Create fade tween
	var tween = create_tween()
	tween.tween_property(footprint, "modulate:a", final_alpha, fade_duration)
	tween.tween_callback(func(): return_footprint(footprint))

	return footprint


## Get the number of available footprints in the pool.
func get_available_count() -> int:
	return _available_pool.size()


## Get the number of currently active footprints.
func get_active_count() -> int:
	return _active_footprints.size()


## Clean up all footprints (useful when changing scenes).
func clear_all() -> void:
	for footprint in _active_footprints:
		if is_instance_valid(footprint):
			footprint.queue_free()

	for footprint in _available_pool:
		if is_instance_valid(footprint):
			footprint.queue_free()

	_active_footprints.clear()
	_available_pool.clear()
