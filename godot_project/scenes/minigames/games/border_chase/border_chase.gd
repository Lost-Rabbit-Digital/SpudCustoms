class_name BorderChaseMinigame
extends MinigameContainer
## Quick reaction game - catch the contraband!
##
## Items scroll across the screen - click suspicious items before they escape!
## Fast and exciting without being punishing for misses.
##
## Unlocks: Shift 5+

# Audio assets
var _snd_conveyor_loop = preload("res://assets/audio/minigames/border_chase_conveyor_loop.mp3")
var _snd_item_grab = preload("res://assets/audio/minigames/border_chase_item_grab.mp3")
var _snd_item_miss = preload("res://assets/audio/minigames/border_chase_item_miss.mp3")
var _snd_item_pass = preload("res://assets/audio/minigames/border_chase_item_pass.mp3")

# Texture assets (preloaded for future use)
var _tex_conveyor_belt = preload("res://assets/minigames/textures/border_chase_conveyor_belt.png")
var _tex_approved_items = preload("res://assets/minigames/textures/border_chase_approved_items.png")
var _tex_contraband_items = preload("res://assets/minigames/textures/border_chase_contraband_items.png")
var _tex_scanner_frame = preload("res://assets/minigames/textures/border_chase_scanner_frame.png")

# Conveyor loop audio player
var _conveyor_loop_player: AudioStreamPlayer

## Number of items to catch
@export var items_to_catch: int = 5

## Points per item caught
@export var points_per_catch: int = 40

## Bonus for catching all
@export var perfect_bonus: int = 200

## Speed items move (pixels per second)
@export var scroll_speed: float = 150.0

## How often items spawn (seconds)
@export var spawn_interval: float = 1.2

# Internal state
var _caught_count: int = 0
var _missed_count: int = 0
var _total_spawned: int = 0
var _spawn_timer: float = 0.0
var _active_items: Array[Node2D] = []
var _game_running: bool = false


func _play_sound(sound: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.volume_db = volume_db
		audio_player.pitch_scale = pitch
		audio_player.play()


func _setup_conveyor_loop_audio() -> void:
	# Create a separate audio player for the conveyor loop sound
	_conveyor_loop_player = AudioStreamPlayer.new()
	_conveyor_loop_player.stream = _snd_conveyor_loop
	_conveyor_loop_player.volume_db = -12.0
	_conveyor_loop_player.bus = "SFX"
	add_child(_conveyor_loop_player)


func _start_conveyor_loop() -> void:
	if _conveyor_loop_player and not _conveyor_loop_player.playing:
		_conveyor_loop_player.play()


func _stop_conveyor_loop() -> void:
	if _conveyor_loop_player and _conveyor_loop_player.playing:
		_conveyor_loop_player.stop()


func _ready() -> void:
	super._ready()
	minigame_type = "border_chase"
	time_limit = 20.0
	skippable = true
	reward_multiplier = 1.0

	if title_label:
		title_label.text = tr("chase_title")
	if instruction_label:
		instruction_label.text = tr("chase_instruction")


func _on_minigame_start(config: Dictionary) -> void:
	_caught_count = 0
	_missed_count = 0
	_total_spawned = 0
	_spawn_timer = 0.0
	_active_items.clear()
	_game_running = true

	# Setup and start conveyor audio
	_setup_conveyor_loop_audio()
	_start_conveyor_loop()

	if config.has("items_to_catch"):
		items_to_catch = config.items_to_catch
	if config.has("scroll_speed"):
		scroll_speed = config.scroll_speed

	_setup_minigame_scene()


func _setup_minigame_scene() -> void:
	for child in subviewport.get_children():
		child.queue_free()

	# Background - conveyor belt look
	var bg = ColorRect.new()
	bg.color = Color(0.15, 0.15, 0.18)
	bg.size = subviewport.size
	subviewport.add_child(bg)

	# Conveyor belt visual
	var belt = ColorRect.new()
	belt.name = "Belt"
	belt.color = Color(0.25, 0.25, 0.28)
	belt.position = Vector2(0, 200)
	belt.size = Vector2(subviewport.size.x, 200)
	subviewport.add_child(belt)

	# Belt lines for movement illusion
	for i in range(20):
		var line = ColorRect.new()
		line.name = "BeltLine_%d" % i
		line.color = Color(0.3, 0.3, 0.33)
		line.position = Vector2(i * 50, 200)
		line.size = Vector2(3, 200)
		subviewport.add_child(line)

	# Items container
	var items_layer = Node2D.new()
	items_layer.name = "ItemsLayer"
	subviewport.add_child(items_layer)

	# Score display
	var score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.position = Vector2(20, 20)
	subviewport.add_child(score_label)
	_update_score_display()

	# Instructions
	var legend = Label.new()
	legend.text = tr("chase_legend")
	legend.add_theme_font_size_override("font_size", 16)
	legend.position = Vector2(subviewport.size.x / 2 - 120, 420)
	subviewport.add_child(legend)


func _process(delta: float) -> void:
	super._process(delta)

	if not _is_active or not _game_running:
		return

	# Animate belt lines
	_animate_belt(delta)

	# Spawn new items
	_spawn_timer += delta
	if _spawn_timer >= spawn_interval and _total_spawned < items_to_catch * 2:
		_spawn_timer = 0.0
		_spawn_item()

	# Move and check items
	_update_items(delta)


func _animate_belt(delta: float) -> void:
	for i in range(20):
		var line = subviewport.get_node_or_null("BeltLine_%d" % i)
		if line:
			line.position.x -= scroll_speed * delta
			if line.position.x < -10:
				line.position.x += 1000


func _spawn_item() -> void:
	_total_spawned += 1

	var items_layer = subviewport.get_node_or_null("ItemsLayer")
	if not items_layer:
		return

	# 50% chance of being contraband (red - catch it)
	var is_contraband = randf() > 0.5

	var item = Node2D.new()
	item.position = Vector2(-60, 300)
	item.set_meta("is_contraband", is_contraband)
	item.set_meta("caught", false)

	# Visual representation
	var visual = _create_item_visual(is_contraband)
	item.add_child(visual)

	# Store hit box size for manual hit testing (physics picking doesn't work when paused)
	item.set_meta("hit_size", Vector2(60, 60))

	items_layer.add_child(item)
	_active_items.append(item)


func _create_item_visual(is_contraband: bool) -> Node2D:
	var container = Node2D.new()

	# Use sprite-based visuals for better accessibility (shape differentiation)
	var sprite = Sprite2D.new()
	sprite.name = "ItemSprite"

	if is_contraband:
		# Contraband items use angular/dangerous shapes from spritesheet
		sprite.texture = _tex_contraband_items
		# Spritesheet is ~960x480 with items roughly 48x48 each (20 columns, 10 rows approx)
		sprite.hframes = 6
		sprite.vframes = 4
		sprite.frame = randi() % (sprite.hframes * sprite.vframes)
	else:
		# Safe items use rounded/friendly shapes from spritesheet
		sprite.texture = _tex_approved_items
		# Spritesheet layout for approved items
		sprite.hframes = 6
		sprite.vframes = 4
		sprite.frame = randi() % (sprite.hframes * sprite.vframes)

	# Scale sprite to fit item size (50x50 target)
	var frame_size = sprite.texture.get_size() / Vector2(sprite.hframes, sprite.vframes)
	var target_size = Vector2(50, 50)
	sprite.scale = target_size / frame_size

	# Apply accessibility-aware colors
	var base_color: Color
	if AccessibilityManager and AccessibilityManager.current_colorblind_mode != AccessibilityManager.ColorblindMode.NONE:
		# Use colorblind-friendly palette
		if is_contraband:
			base_color = AccessibilityManager.get_rejection_color()
		else:
			base_color = AccessibilityManager.get_approval_color()
		# Apply as a tint while preserving sprite details
		sprite.modulate = base_color.lightened(0.3)
	else:
		# Default: subtle tint to indicate type (sprites are primary differentiator)
		if is_contraband:
			sprite.modulate = Color(1.2, 0.9, 0.9)  # Slight warm tint
		else:
			sprite.modulate = Color(0.9, 1.1, 0.9)  # Slight cool tint

	container.add_child(sprite)

	# Add shape indicator for additional accessibility (works in grayscale too)
	var indicator = _create_shape_indicator(is_contraband)
	indicator.position = Vector2(20, -20)  # Top-right corner
	container.add_child(indicator)

	return container


## Create a shape-based indicator for accessibility (distinguishable without color)
func _create_shape_indicator(is_contraband: bool) -> Node2D:
	var indicator = Node2D.new()
	indicator.name = "ShapeIndicator"

	if is_contraband:
		# Triangle/warning shape for contraband
		var polygon = Polygon2D.new()
		polygon.polygon = PackedVector2Array([
			Vector2(0, -10),   # Top point
			Vector2(-8, 6),    # Bottom left
			Vector2(8, 6)      # Bottom right
		])
		polygon.color = Color(1.0, 0.3, 0.3, 0.9)

		# Apply colorblind color if active
		if AccessibilityManager and AccessibilityManager.current_colorblind_mode != AccessibilityManager.ColorblindMode.NONE:
			polygon.color = AccessibilityManager.get_rejection_color()

		# Add exclamation mark inside triangle
		var symbol = Label.new()
		symbol.text = "!"
		symbol.add_theme_font_size_override("font_size", 12)
		symbol.add_theme_color_override("font_color", Color.WHITE)
		symbol.position = Vector2(-3, -8)

		indicator.add_child(polygon)
		indicator.add_child(symbol)
	else:
		# Circle/checkmark shape for safe items
		var circle_points: PackedVector2Array = []
		for i in range(12):
			var angle = i * TAU / 12
			circle_points.append(Vector2(cos(angle), sin(angle)) * 8)

		var polygon = Polygon2D.new()
		polygon.polygon = circle_points
		polygon.color = Color(0.3, 0.8, 0.3, 0.9)

		# Apply colorblind color if active
		if AccessibilityManager and AccessibilityManager.current_colorblind_mode != AccessibilityManager.ColorblindMode.NONE:
			polygon.color = AccessibilityManager.get_approval_color()

		# Add checkmark inside circle
		var symbol = Label.new()
		symbol.text = "✓"
		symbol.add_theme_font_size_override("font_size", 10)
		symbol.add_theme_color_override("font_color", Color.WHITE)
		symbol.position = Vector2(-5, -7)

		indicator.add_child(polygon)
		indicator.add_child(symbol)

	return indicator


func _update_items(delta: float) -> void:
	var items_to_remove: Array[Node2D] = []

	for item in _active_items:
		if not is_instance_valid(item):
			items_to_remove.append(item)
			continue

		# Move item
		item.position.x += scroll_speed * delta

		# Check if escaped
		if item.position.x > subviewport.size.x + 50:
			var is_contraband = item.get_meta("is_contraband", false)
			var was_caught = item.get_meta("caught", false)

			if is_contraband and not was_caught:
				_missed_count += 1
				_update_score_display()
				_play_sound(_snd_item_miss, 0.0)
			elif not is_contraband and not was_caught:
				# Good item passed successfully
				_play_sound(_snd_item_pass, -5.0, randf_range(0.95, 1.05))

			items_to_remove.append(item)

	# Clean up
	for item in items_to_remove:
		_active_items.erase(item)
		if is_instance_valid(item):
			item.queue_free()

	# Check completion
	if _caught_count >= items_to_catch:
		_complete_game()
	elif _total_spawned >= items_to_catch * 2 and _active_items.is_empty():
		_complete_game()


## Convert screen mouse position to SubViewport local coordinates
func _get_subviewport_mouse_pos() -> Vector2:
	var screen_pos = get_viewport().get_mouse_position()
	var container_rect = subviewport_container.get_global_rect()
	var relative_pos = (screen_pos - container_rect.position) / container_rect.size
	return relative_pos * Vector2(subviewport.size)


## Handle input manually since physics picking doesn't work when tree is paused
func _input(event: InputEvent) -> void:
	if not _is_active or not _game_running:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_pos = _get_subviewport_mouse_pos()
		_check_item_click(local_pos)


## Check if click hit any item and handle it
func _check_item_click(click_pos: Vector2) -> void:
	# Check items in reverse order (top-most first)
	for i in range(_active_items.size() - 1, -1, -1):
		var item = _active_items[i]
		if not is_instance_valid(item):
			continue

		var was_caught = item.get_meta("caught", false)
		if was_caught:
			continue

		# Manual hit test using stored hit box size
		var hit_size: Vector2 = item.get_meta("hit_size", Vector2(60, 60))
		var item_rect = Rect2(item.position - hit_size / 2, hit_size)

		if item_rect.has_point(click_pos):
			_handle_item_clicked(item)
			return  # Only handle one click at a time


func _handle_item_clicked(item: Node2D) -> void:
	var is_contraband = item.get_meta("is_contraband", false)
	var was_caught = item.get_meta("caught", false)

	if was_caught:
		return

	item.set_meta("caught", true)

	if is_contraband:
		# Correct catch! Punt it off screen satisfyingly
		_caught_count += 1
		_punt_item(item)
		_play_sound(_snd_item_grab, 0.0, randf_range(0.95, 1.05))
	else:
		# Clicked a safe item - small penalty feedback but nothing harsh
		_flash_item(item, Color.ORANGE)

	_update_score_display()


func _punt_item(item: Node2D) -> void:
	## Punt the contraband off screen with a satisfying tumble effect
	if not is_instance_valid(item):
		return

	# Random punt direction - mostly upward, slightly left or right
	var punt_direction = Vector2(randf_range(-150, 150), randf_range(-400, -250))
	var target_pos = item.position + punt_direction
	var spin_amount = randf_range(-720, 720)  # 1-2 full rotations either direction

	var tween = create_tween()
	tween.set_parallel(true)

	# Flash green on impact
	tween.tween_property(item, "modulate", Color.GREEN, 0.05)

	# Launch upward with slight arc (ease out for natural arc feel)
	tween.tween_property(item, "position", target_pos, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# Tumble rotation
	tween.tween_property(item, "rotation_degrees", spin_amount, 0.4).set_ease(Tween.EASE_OUT)

	# Scale up slightly on impact, then shrink as it flies away
	tween.tween_property(item, "scale", Vector2(1.3, 1.3), 0.1).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(item, "scale", Vector2(0.3, 0.3), 0.3).set_ease(Tween.EASE_IN)

	# Fade out near the end
	tween.chain().tween_property(item, "modulate:a", 0.0, 0.15)

	# Clean up after animation
	tween.chain().tween_callback(func():
		if is_instance_valid(item):
			item.queue_free()
			_active_items.erase(item)
	)


func _flash_item(item: Node2D, color: Color) -> void:
	if not is_instance_valid(item):
		return

	var tween = create_tween()
	tween.tween_property(item, "modulate", color, 0.1)
	tween.tween_property(item, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_callback(func():
		if is_instance_valid(item):
			item.queue_free()
			_active_items.erase(item)
	)


func _update_score_display() -> void:
	var label = subviewport.get_node_or_null("ScoreLabel")
	if label:
		label.text = tr("chase_caught").format({"current": _caught_count, "total": items_to_catch})


func _complete_game() -> void:
	_game_running = false

	# Stop conveyor loop audio
	_stop_conveyor_loop()
	if _conveyor_loop_player:
		_conveyor_loop_player.queue_free()
		_conveyor_loop_player = null

	var base_score = _caught_count * points_per_catch
	var bonus = perfect_bonus if _caught_count >= items_to_catch and _missed_count == 0 else 0
	var total_score = base_score + bonus

	if instruction_label:
		if _caught_count >= items_to_catch and _missed_count == 0:
			instruction_label.text = tr("chase_perfect").format({"points": total_score})
		else:
			instruction_label.text = tr("chase_partial").format({"count": _caught_count, "points": total_score})

	complete_success(total_score, {
		"caught": _caught_count,
		"target": items_to_catch,
		"missed": _missed_count,
		"perfect": _caught_count >= items_to_catch and _missed_count == 0
	})
