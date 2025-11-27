class_name ExplosionPool
extends Node
## Object pool for explosion AnimatedSprite2D instances to prevent create/destroy overhead.
##
## Usage:
##   var pool = ExplosionPool.new()
##   add_child(pool)
##   pool.initialize(sprite_frames, 10)
##   pool.spawn_explosion(position, scale)

## Pool of available explosion sprites
var _available_pool: Array[AnimatedSprite2D] = []

## Currently active explosions
var _active_explosions: Array[AnimatedSprite2D] = []

## Maximum pool size
var _max_pool_size: int = 20

## Shared sprite frames for all explosions
var _explosion_frames: SpriteFrames = null

## Parent node for explosions
var _explosion_parent: Node = null

## Signal when an explosion completes (for external cleanup if needed)
signal explosion_finished(explosion: AnimatedSprite2D)


## Initialize the pool with sprite frames and pre-allocate explosions.
## @param sprite_frames The SpriteFrames resource for explosion animation.
## @param initial_size Number of explosions to pre-allocate.
## @param parent_node Node to add explosions to.
func initialize(sprite_frames: SpriteFrames, initial_size: int = 10, parent_node: Node = null) -> void:
	_explosion_frames = sprite_frames
	_max_pool_size = max(initial_size, _max_pool_size)
	_explosion_parent = parent_node

	# Pre-allocate explosions
	for i in initial_size:
		var explosion = _create_explosion()
		explosion.visible = false
		_available_pool.append(explosion)


## Get an explosion from the pool.
## @return An AnimatedSprite2D configured as an explosion.
func get_explosion() -> AnimatedSprite2D:
	var explosion: AnimatedSprite2D

	if _available_pool.size() > 0:
		explosion = _available_pool.pop_back()
	else:
		# Pool exhausted - create new or recycle oldest
		if _active_explosions.size() >= _max_pool_size:
			explosion = _active_explosions.pop_front()
			_reset_explosion(explosion)
		else:
			explosion = _create_explosion()

	_active_explosions.append(explosion)
	explosion.visible = true

	return explosion


## Return an explosion to the pool for reuse.
## @param explosion The AnimatedSprite2D to return.
func return_explosion(explosion: AnimatedSprite2D) -> void:
	if not is_instance_valid(explosion):
		return

	_active_explosions.erase(explosion)
	_reset_explosion(explosion)
	explosion.visible = false
	explosion.stop()

	_available_pool.append(explosion)
	explosion_finished.emit(explosion)


## Create a new explosion sprite.
func _create_explosion() -> AnimatedSprite2D:
	var explosion = AnimatedSprite2D.new()
	explosion.sprite_frames = _explosion_frames
	explosion.z_index = ConstantZIndexes.Z_INDEX.EXPLOSIONS

	# Connect animation finished signal for auto-return
	explosion.animation_finished.connect(_on_animation_finished.bind(explosion))

	# Add to parent
	var parent = _explosion_parent if _explosion_parent else self
	parent.add_child(explosion)

	return explosion


## Reset an explosion to default state.
func _reset_explosion(explosion: AnimatedSprite2D) -> void:
	explosion.modulate = Color.WHITE
	explosion.scale = Vector2.ONE
	explosion.rotation = 0.0
	explosion.global_position = Vector2.ZERO
	explosion.frame = 0


## Handle animation finished - keep explosion visible but stopped on last frames.
func _on_animation_finished(explosion: AnimatedSprite2D) -> void:
	explosion.stop()
	# Show one of the final smoke frames
	explosion.frame = randi_range(23, 25) if explosion.sprite_frames.get_frame_count("default") > 25 else explosion.sprite_frames.get_frame_count("default") - 1


## Spawn an explosion at the given position with animation and effects.
## @param position Global position for the explosion.
## @param base_scale Base scale for the explosion (will be randomized).
## @param fade_delay Delay before fade starts.
## @param fade_duration Duration of fade out.
## @param auto_return Whether to automatically return to pool after effects complete.
## @return The spawned explosion sprite.
func spawn_explosion(
	position: Vector2,
	base_scale: float = 5.0,
	fade_delay: float = 0.2,
	fade_duration: float = 3.0,
	auto_return: bool = true
) -> AnimatedSprite2D:
	var explosion = get_explosion()

	# Configure explosion
	var scale_variation = randf_range(0.5, 2.0)
	explosion.global_position = position
	explosion.scale = Vector2(base_scale, base_scale) * scale_variation
	explosion.modulate = Color.WHITE
	explosion.frame = 0
	explosion.play("default")

	# Create scale and fade tweens
	var tween = create_tween()
	tween.set_parallel(true)

	# Scale down with elastic effect
	var target_scale = Vector2(base_scale * 0.5, base_scale * 0.5) * randf_range(0.8, 1.2)
	(
		tween
		.tween_property(explosion, "scale", target_scale, 0.7)
		.set_trans(Tween.TRANS_ELASTIC)
		.set_ease(Tween.EASE_OUT)
	)

	# Fade out
	var final_alpha = 0.5 * randf_range(0.8, 1.2)
	tween.tween_property(explosion, "modulate:a", final_alpha, fade_duration).set_delay(fade_delay)

	# Auto-return to pool after effects complete
	if auto_return:
		var total_duration = max(fade_delay + fade_duration, 2.0)
		var return_timer = get_tree().create_timer(total_duration)
		return_timer.timeout.connect(func(): return_explosion(explosion))

	return explosion


## Get the number of available explosions in the pool.
func get_available_count() -> int:
	return _available_pool.size()


## Get the number of currently active explosions.
func get_active_count() -> int:
	return _active_explosions.size()


## Clean up all explosions.
func clear_all() -> void:
	for explosion in _active_explosions:
		if is_instance_valid(explosion):
			explosion.queue_free()

	for explosion in _available_pool:
		if is_instance_valid(explosion):
			explosion.queue_free()

	_active_explosions.clear()
	_available_pool.clear()
