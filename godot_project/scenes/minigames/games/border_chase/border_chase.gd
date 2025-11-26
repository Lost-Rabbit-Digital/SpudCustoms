class_name BorderChaseMinigame
extends MinigameContainer
## Quick reaction game - catch the contraband!
##
## Items scroll across the screen - click suspicious items before they escape!
## Fast and exciting without being punishing for misses.
##
## Unlocks: Shift 5+

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


func _ready() -> void:
	super._ready()
	minigame_type = "border_chase"
	time_limit = 20.0
	skippable = true
	reward_multiplier = 1.0

	if title_label:
		title_label.text = "BORDER CHASE"
	if instruction_label:
		instruction_label.text = "Click the RED contraband items! Let the GREEN items pass."


func _on_minigame_start(config: Dictionary) -> void:
	_caught_count = 0
	_missed_count = 0
	_total_spawned = 0
	_spawn_timer = 0.0
	_active_items.clear()
	_game_running = true

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
	legend.text = "RED = Catch!   GREEN = Let pass"
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

	# Clickable area
	var click_area = Area2D.new()
	click_area.name = "ClickArea"
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 60)
	collision.shape = shape
	click_area.add_child(collision)
	click_area.input_event.connect(_on_item_clicked.bind(item))
	item.add_child(click_area)

	items_layer.add_child(item)
	_active_items.append(item)


func _create_item_visual(is_contraband: bool) -> Node2D:
	var container = Node2D.new()

	var rect = ColorRect.new()
	rect.size = Vector2(50, 50)
	rect.position = Vector2(-25, -25)

	if is_contraband:
		# Red contraband - various suspicious shapes
		rect.color = Color(0.8, 0.2, 0.2)
		var shapes = ["!", "X", "?", "*"]
		var symbol = Label.new()
		symbol.text = shapes[randi() % shapes.size()]
		symbol.add_theme_font_size_override("font_size", 32)
		symbol.add_theme_color_override("font_color", Color.WHITE)
		symbol.position = Vector2(-10, -20)
		container.add_child(rect)
		container.add_child(symbol)
	else:
		# Green safe item
		rect.color = Color(0.2, 0.6, 0.2)
		var checkmark = Label.new()
		checkmark.text = "OK"
		checkmark.add_theme_font_size_override("font_size", 20)
		checkmark.add_theme_color_override("font_color", Color.WHITE)
		checkmark.position = Vector2(-15, -12)
		container.add_child(rect)
		container.add_child(checkmark)

	return container


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


func _on_item_clicked(viewport: Node, event: InputEvent, shape_idx: int, item: Node2D) -> void:
	if not event is InputEventMouseButton:
		return
	if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if not _is_active or not _game_running:
		return

	var is_contraband = item.get_meta("is_contraband", false)
	var was_caught = item.get_meta("caught", false)

	if was_caught:
		return

	item.set_meta("caught", true)

	if is_contraband:
		# Correct catch!
		_caught_count += 1
		_flash_item(item, Color.GREEN)
	else:
		# Clicked a safe item - small penalty feedback but nothing harsh
		_flash_item(item, Color.ORANGE)

	_update_score_display()


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
		label.text = "Caught: %d / %d" % [_caught_count, items_to_catch]


func _complete_game() -> void:
	_game_running = false

	var base_score = _caught_count * points_per_catch
	var bonus = perfect_bonus if _caught_count >= items_to_catch and _missed_count == 0 else 0
	var total_score = base_score + bonus

	if instruction_label:
		if _caught_count >= items_to_catch and _missed_count == 0:
			instruction_label.text = "Perfect catch! +%d points!" % total_score
		else:
			instruction_label.text = "Caught %d items. +%d points!" % [_caught_count, total_score]

	complete_success(total_score, {
		"caught": _caught_count,
		"target": items_to_catch,
		"missed": _missed_count,
		"perfect": _caught_count >= items_to_catch and _missed_count == 0
	})
