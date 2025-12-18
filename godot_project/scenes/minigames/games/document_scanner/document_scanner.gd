class_name DocumentScannerMinigame
extends MinigameContainer
## Fun minigame where you use a UV light to reveal hidden details on documents.
##
## Gameplay:
## - Drag the UV light around the document
## - Hidden elements glow when the light passes over them
## - Click to "mark" a discovered element
## - Find all hidden elements for a bonus!
##
## Design: Relaxing and rewarding, like a treasure hunt.
## No punishment for missing elements - you just don't get the bonus.

# Audio assets
var _snd_uv_activate = preload("res://assets/audio/minigames/document_scanner_uv_activate.mp3")
var _snd_uv_loop = preload("res://assets/audio/minigames/document_scanner_uv_loop.mp3")
var _snd_movement = preload("res://assets/audio/minigames/document_scanner_movement.mp3")
var _snd_reveal = preload("res://assets/audio/minigames/document_scanner_reveal.mp3")
var _snd_confirm = preload("res://assets/audio/minigames/document_scanner_confirm.mp3")

# Texture assets (preloaded for future use)
var _tex_desk_background = preload("res://assets/minigames/textures/document_scanner_desk_background.png")
var _tex_desk_background_1 = preload("res://assets/minigames/textures/document_scanner_desk_background_1.png")
var _tex_document_base = preload("res://assets/minigames/textures/document_scanner_document_base.png")
var _tex_hidden_elements = preload("res://assets/minigames/textures/document_scanner_hidden_elements.png")
var _tex_uv_lamp = preload("res://assets/minigames/textures/document_scanner_uv_lamp.png")

# UV loop audio player
var _uv_loop_player: AudioStreamPlayer

## Number of hidden elements to find
@export var elements_to_find: int = 4

## Points per element found
@export var points_per_element: int = 50

## Bonus for finding ALL elements
@export var completion_bonus: int = 200

## How close the light needs to be to reveal an element
@export var reveal_radius: float = 80.0

## The document texture to scan
@export var document_texture: Texture2D

# Internal state
var _found_elements: Array[int] = []
var _hidden_elements: Array[Dictionary] = []
var _uv_light_position: Vector2 = Vector2.ZERO
var _is_dragging_light: bool = false

# Scene nodes (in SubViewport)
var _document_sprite: Sprite2D
var _uv_light: Node2D
var _light_mask: Sprite2D
var _elements_container: Node2D
var _found_label: Label


func _play_sound(sound: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.volume_db = volume_db
		audio_player.pitch_scale = pitch
		audio_player.play()


func _setup_uv_loop_audio() -> void:
	# Create a separate audio player for the UV loop sound
	_uv_loop_player = AudioStreamPlayer.new()
	_uv_loop_player.stream = _snd_uv_loop
	_uv_loop_player.volume_db = -10.0
	_uv_loop_player.bus = "SFX"
	add_child(_uv_loop_player)


func _start_uv_loop() -> void:
	if _uv_loop_player and not _uv_loop_player.playing:
		_uv_loop_player.play()


func _stop_uv_loop() -> void:
	if _uv_loop_player and _uv_loop_player.playing:
		_uv_loop_player.stop()


func _ready() -> void:
	super._ready()

	# Set minigame properties
	minigame_type = "document_scanner"
	time_limit = 15.0  # Generous time - we want them to succeed!
	skippable = true
	reward_multiplier = 1.0

	# Update UI
	if title_label:
		title_label.text = tr("scanner_title")
	if instruction_label:
		instruction_label.text = tr("scanner_instruction")


func _on_minigame_start(config: Dictionary) -> void:
	# Reset state
	_found_elements.clear()
	_hidden_elements.clear()

	# Setup UV loop audio player
	_setup_uv_loop_audio()

	# Apply config
	if config.has("elements_to_find"):
		elements_to_find = config.elements_to_find
	if config.has("document_texture"):
		document_texture = config.document_texture

	# Build the minigame scene inside the SubViewport
	_setup_minigame_scene()


func _setup_minigame_scene() -> void:
	# Clear any existing content
	for child in subviewport.get_children():
		child.queue_free()

	# Create background
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.15, 1.0)
	bg.size = subviewport.size
	subviewport.add_child(bg)

	# Create document sprite
	_document_sprite = Sprite2D.new()
	_document_sprite.position = Vector2(subviewport.size) / 2
	if document_texture:
		_document_sprite.texture = document_texture
	else:
		# Create a placeholder document
		_document_sprite.texture = _create_placeholder_document()
	subviewport.add_child(_document_sprite)

	# Create elements container (hidden elements)
	_elements_container = Node2D.new()
	_elements_container.position = _document_sprite.position
	subviewport.add_child(_elements_container)

	# Generate hidden elements
	_generate_hidden_elements()

	# Create UV light effect
	_create_uv_light()

	# Create found counter
	_found_label = Label.new()
	_found_label.position = Vector2(20, 20)
	_found_label.add_theme_font_size_override("font_size", 24)
	_update_found_label()
	subviewport.add_child(_found_label)

	# Set initial light position
	_uv_light_position = Vector2(subviewport.size) / 2


func _create_placeholder_document() -> Texture2D:
	# Create a simple document-like image
	var img = Image.create(300, 400, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.95, 0.93, 0.88))  # Paper color

	# Add some "text lines"
	for y in range(50, 350, 20):
		for x in range(40, 260):
			if randf() > 0.3:
				img.set_pixel(x, y, Color(0.2, 0.2, 0.2, 0.7))

	return ImageTexture.create_from_image(img)


func _generate_hidden_elements() -> void:
	# Generate random positions for hidden elements
	var doc_size = Vector2(280, 380) if not document_texture else document_texture.get_size()
	var margin = 60.0

	for i in range(elements_to_find):
		var element_data = {
			"index": i,
			"position": Vector2(
				randf_range(-doc_size.x/2 + margin, doc_size.x/2 - margin),
				randf_range(-doc_size.y/2 + margin, doc_size.y/2 - margin)
			),
			"type": _get_random_element_type(),
			"found": false,
			"revealed": false
		}
		_hidden_elements.append(element_data)

		# Create visual for this element
		var element_visual = _create_element_visual(element_data)
		_elements_container.add_child(element_visual)


func _get_random_element_type() -> String:
	var types = ["watermark", "stamp", "signature", "code", "symbol"]
	return types[randi() % types.size()]


func _create_element_visual(data: Dictionary) -> Node2D:
	var container = Node2D.new()
	container.position = data.position
	container.name = "Element_%d" % data.index

	# Hidden glow (only visible under UV)
	var glow = Sprite2D.new()
	glow.name = "Glow"
	var glow_tex = _create_glow_texture(data.type)
	glow.texture = glow_tex
	glow.modulate = Color(0.5, 1.0, 0.5, 0.0)  # Start invisible
	container.add_child(glow)

	# Found marker (checkmark when clicked)
	var marker = Label.new()
	marker.name = "Marker"
	marker.text = "✓"
	marker.add_theme_font_size_override("font_size", 32)
	marker.add_theme_color_override("font_color", Color.GREEN)
	marker.position = Vector2(-10, -20)
	marker.visible = false
	container.add_child(marker)

	return container


func _create_glow_texture(element_type: String) -> Texture2D:
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)

	# Draw different shapes based on type
	var center = Vector2(32, 32)

	match element_type:
		"watermark":
			# Circular watermark
			for x in range(64):
				for y in range(64):
					var dist = Vector2(x, y).distance_to(center)
					if dist < 28 and dist > 20:
						img.set_pixel(x, y, Color(1, 1, 1, 0.8))
		"stamp":
			# Square stamp
			for x in range(12, 52):
				for y in range(12, 52):
					if x < 16 or x > 47 or y < 16 or y > 47:
						img.set_pixel(x, y, Color(1, 0.2, 0.2, 0.8))
		"signature":
			# Wavy line
			for x in range(8, 56):
				var y_offset = int(sin(x * 0.3) * 8)
				for dy in range(-2, 3):
					var y = 32 + y_offset + dy
					if y >= 0 and y < 64:
						img.set_pixel(x, y, Color(0.2, 0.2, 1, 0.8))
		"code":
			# Binary-looking pattern
			for i in range(8):
				var x_start = 8 + i * 6
				var show = randi() % 2 == 0
				if show:
					for x in range(x_start, x_start + 4):
						for y in range(26, 38):
							img.set_pixel(x, y, Color(0, 1, 0, 0.8))
		_:  # symbol
			# Star shape
			for x in range(64):
				for y in range(64):
					var dist = Vector2(x, y).distance_to(center)
					var angle = atan2(y - 32, x - 32)
					var star_dist = 20 + 8 * abs(sin(angle * 5))
					if dist < star_dist:
						img.set_pixel(x, y, Color(1, 1, 0, 0.7))

	return ImageTexture.create_from_image(img)


func _create_uv_light() -> void:
	_uv_light = Node2D.new()
	_uv_light.name = "UVLight"
	_uv_light.position = _uv_light_position
	subviewport.add_child(_uv_light)

	# Light visual (the "flashlight")
	var light_visual = Sprite2D.new()
	light_visual.name = "LightVisual"
	var light_img = Image.create(int(reveal_radius * 2), int(reveal_radius * 2), false, Image.FORMAT_RGBA8)

	# Create gradient circle
	var center = Vector2(reveal_radius, reveal_radius)
	for x in range(int(reveal_radius * 2)):
		for y in range(int(reveal_radius * 2)):
			var dist = Vector2(x, y).distance_to(center)
			if dist < reveal_radius:
				var alpha = 1.0 - (dist / reveal_radius)
				alpha = alpha * alpha  # Quadratic falloff
				light_img.set_pixel(x, y, Color(0.7, 0.5, 1.0, alpha * 0.4))

	light_visual.texture = ImageTexture.create_from_image(light_img)
	_uv_light.add_child(light_visual)

	# Crosshair in center
	var crosshair = Label.new()
	crosshair.text = "+"
	crosshair.add_theme_font_size_override("font_size", 24)
	crosshair.position = Vector2(-6, -14)
	_uv_light.add_child(crosshair)


func _input(event: InputEvent) -> void:
	if not _is_active:
		return

	# Handle mouse in SubViewport coordinates
	if event is InputEventMouseButton:
		var local_pos = _get_subviewport_mouse_pos()

		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging_light = true
				_play_sound(_snd_uv_activate, -5.0)
				_start_uv_loop()
				_check_element_click(local_pos)
			else:
				_is_dragging_light = false
				_stop_uv_loop()

	elif event is InputEventMouseMotion and _is_dragging_light:
		_uv_light_position = _get_subviewport_mouse_pos()
		if _uv_light:
			_uv_light.position = _uv_light_position
		_update_element_visibility()


func _get_subviewport_mouse_pos() -> Vector2:
	# Convert screen mouse position to SubViewport coordinates
	var screen_pos = get_viewport().get_mouse_position()
	var container_rect = subviewport_container.get_global_rect()

	# Calculate relative position within SubViewportContainer
	var relative_pos = (screen_pos - container_rect.position) / container_rect.size
	return relative_pos * Vector2(subviewport.size)


func _update_element_visibility() -> void:
	for i in range(_hidden_elements.size()):
		var element_data = _hidden_elements[i]
		if element_data.found:
			continue

		var element_node = _elements_container.get_node("Element_%d" % i)
		if not element_node:
			continue

		var glow = element_node.get_node("Glow")
		if not glow:
			continue

		# Calculate distance from UV light to element
		var element_world_pos = _elements_container.position + element_data.position
		var dist = _uv_light_position.distance_to(element_world_pos)

		# Track if element was revealed before
		var was_revealed = element_data.revealed

		# Reveal based on distance
		if dist < reveal_radius:
			var intensity = 1.0 - (dist / reveal_radius)
			glow.modulate.a = intensity
			element_data.revealed = true
			# Play reveal sound when first revealed
			if not was_revealed:
				_play_sound(_snd_reveal, -5.0, randf_range(0.95, 1.05))
		else:
			glow.modulate.a = max(0, glow.modulate.a - 0.1)  # Fade out slowly
			if glow.modulate.a < 0.1:
				element_data.revealed = false


func _check_element_click(click_pos: Vector2) -> void:
	for i in range(_hidden_elements.size()):
		var element_data = _hidden_elements[i]
		if element_data.found:
			continue

		if not element_data.revealed:
			continue

		# Check if click is near the element
		var element_world_pos = _elements_container.position + element_data.position
		var dist = click_pos.distance_to(element_world_pos)

		if dist < 40:  # Click radius
			_mark_element_found(i)
			break


func _mark_element_found(index: int) -> void:
	_hidden_elements[index].found = true
	_found_elements.append(index)

	# Show the checkmark
	var element_node = _elements_container.get_node("Element_%d" % index)
	if element_node:
		var marker = element_node.get_node("Marker")
		if marker:
			marker.visible = true

		# Make glow stay visible
		var glow = element_node.get_node("Glow")
		if glow:
			glow.modulate = Color(0.3, 1.0, 0.3, 1.0)

	# Play confirm sound with pitch increasing for each element found
	var pitch = 1.0 + (0.1 * _found_elements.size())
	_play_sound(_snd_confirm, 0.0, pitch)

	_update_found_label()

	# Check if all found
	if _found_elements.size() >= elements_to_find:
		_all_elements_found()


func _update_found_label() -> void:
	if _found_label:
		_found_label.text = tr("scanner_found").format({"current": _found_elements.size(), "total": elements_to_find})

		if _found_elements.size() >= elements_to_find:
			_found_label.add_theme_color_override("font_color", Color.GREEN)


func _all_elements_found() -> void:
	# Calculate bonus
	var total_score = (elements_to_find * points_per_element) + completion_bonus

	# Update instruction with celebration
	if instruction_label:
		instruction_label.text = tr("scanner_perfect").format({"points": total_score})

	# Complete with success
	complete_success(total_score, {
		"elements_found": _found_elements.size(),
		"total_elements": elements_to_find,
		"perfect": true
	})


func _on_minigame_complete() -> void:
	# Stop UV loop if playing
	_stop_uv_loop()
	if _uv_loop_player:
		_uv_loop_player.queue_free()
		_uv_loop_player = null

	# If not all found, still give partial credit
	if _found_elements.size() < elements_to_find and _found_elements.size() > 0:
		var partial_score = _found_elements.size() * points_per_element

		_result.score_bonus = partial_score
		_result.elements_found = _found_elements.size()
		_result.total_elements = elements_to_find
		_result.perfect = false

		if instruction_label:
			instruction_label.text = tr("scanner_partial").format({
				"found": _found_elements.size(), "total": elements_to_find, "points": partial_score
			})
