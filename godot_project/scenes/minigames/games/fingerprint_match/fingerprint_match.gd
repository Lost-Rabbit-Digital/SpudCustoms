class_name FingerprintMatchMinigame
extends MinigameContainer
## Match fingerprints to verify traveler identity!
##
## A reference fingerprint is shown - find the matching one from a grid.
## Tests observation skills without being frustrating.
##
## Unlocks: Shift 3+

# Audio assets
var _snd_hover = preload("res://assets/audio/minigames/fingerprint_match_hover.mp3")
var _snd_scan = preload("res://assets/audio/minigames/fingerprint_match_scan.mp3")
var _snd_correct = preload("res://assets/audio/minigames/fingerprint_match_correct.mp3")
var _snd_incorrect = preload("res://assets/audio/minigames/fingerprint_match_incorrect.mp3")
var _snd_round_complete = preload("res://assets/audio/minigames/fingerprint_match_round_complete.mp3")

# Texture assets (preloaded for future use)
var _tex_cards = preload("res://assets/minigames/textures/fingerprint_match_cards.png")
var _tex_cards_1 = preload("res://assets/minigames/textures/fingerprint_match_cards_1.png")
var _tex_indicators = preload("res://assets/minigames/textures/fingerprint_match_indictators.png")
var _tex_reference_frame = preload("res://assets/minigames/textures/fingerprint_match_reference_frame.png")
var _tex_scanner_frame = preload("res://assets/minigames/textures/fingerprint_match_scanner_frame.png")

## Number of fingerprints in the grid (including the correct one)
@export var grid_size: int = 6

## Points for correct match
@export var points_per_match: int = 100

## Number of matches to complete
@export var matches_to_complete: int = 3

## Bonus for completing all matches
@export var completion_bonus: int = 200

# Internal state
var _current_match: int = 0
var _correct_matches: int = 0
var _reference_pattern: int = 0
var _correct_index: int = 0
var _fingerprint_buttons: Array[Button] = []


func _play_sound(sound: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.volume_db = volume_db
		audio_player.pitch_scale = pitch
		audio_player.play()


func _ready() -> void:
	super._ready()
	minigame_type = "fingerprint_match"
	time_limit = 25.0
	skippable = true
	reward_multiplier = 1.0

	if title_label:
		title_label.text = "FINGERPRINT MATCH"
	if instruction_label:
		instruction_label.text = "Find the fingerprint that matches the reference!"


func _on_minigame_start(config: Dictionary) -> void:
	_current_match = 0
	_correct_matches = 0
	_fingerprint_buttons.clear()

	if config.has("matches_to_complete"):
		matches_to_complete = config.matches_to_complete
	if config.has("grid_size"):
		grid_size = config.grid_size

	_setup_minigame_scene()
	_generate_new_round()


func _setup_minigame_scene() -> void:
	for child in subviewport.get_children():
		child.queue_free()

	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.12, 0.12, 0.15)
	bg.size = subviewport.size
	subviewport.add_child(bg)

	# Reference panel (left side)
	var ref_panel = Panel.new()
	ref_panel.name = "ReferencePanel"
	ref_panel.position = Vector2(50, 100)
	ref_panel.size = Vector2(200, 250)
	subviewport.add_child(ref_panel)

	var ref_label = Label.new()
	ref_label.text = "REFERENCE"
	ref_label.add_theme_font_size_override("font_size", 18)
	ref_label.position = Vector2(50, 70)
	subviewport.add_child(ref_label)

	var ref_print = TextureRect.new()
	ref_print.name = "ReferencePrint"
	ref_print.position = Vector2(75, 130)
	ref_print.size = Vector2(150, 180)
	ref_print.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	subviewport.add_child(ref_print)

	# Grid panel (right side)
	var grid_label = Label.new()
	grid_label.text = "FIND THE MATCH"
	grid_label.add_theme_font_size_override("font_size", 18)
	grid_label.position = Vector2(350, 70)
	subviewport.add_child(grid_label)

	# Create button grid
	var grid_container = GridContainer.new()
	grid_container.name = "GridContainer"
	grid_container.columns = 3
	grid_container.position = Vector2(300, 100)
	grid_container.add_theme_constant_override("h_separation", 15)
	grid_container.add_theme_constant_override("v_separation", 15)
	subviewport.add_child(grid_container)

	# Create fingerprint buttons
	for i in range(grid_size):
		var btn = Button.new()
		btn.name = "Fingerprint_%d" % i
		btn.custom_minimum_size = Vector2(120, 140)
		btn.pressed.connect(_on_fingerprint_selected.bind(i))
		grid_container.add_child(btn)
		_fingerprint_buttons.append(btn)

	# Progress display
	var progress = Label.new()
	progress.name = "Progress"
	progress.add_theme_font_size_override("font_size", 22)
	progress.position = Vector2(subviewport.size.x / 2 - 80, 20)
	subviewport.add_child(progress)
	_update_progress()


func _generate_new_round() -> void:
	# Generate a random reference pattern
	_reference_pattern = randi() % 8

	# Choose which button will have the correct answer
	_correct_index = randi() % grid_size

	# Update reference display
	var ref_print = subviewport.get_node_or_null("ReferencePrint")
	if ref_print:
		ref_print.texture = _create_fingerprint_texture(_reference_pattern)

	# Update grid buttons with different patterns
	var used_patterns: Array[int] = []
	for i in range(_fingerprint_buttons.size()):
		var btn = _fingerprint_buttons[i]
		btn.disabled = false
		btn.modulate = Color.WHITE

		var pattern: int
		if i == _correct_index:
			pattern = _reference_pattern
		else:
			# Generate a different pattern
			pattern = randi() % 8
			while pattern == _reference_pattern or pattern in used_patterns:
				pattern = randi() % 8
			used_patterns.append(pattern)

		# Create icon for button
		var icon_tex = _create_fingerprint_texture(pattern, 100, 120)
		btn.icon = icon_tex


func _create_fingerprint_texture(pattern: int, width: int = 150, height: int = 180) -> ImageTexture:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.9, 0.85, 0.8))  # Skin tone background

	var center_x = width / 2
	var center_y = height / 2

	# Different fingerprint patterns based on pattern ID
	var ridge_color = Color(0.4, 0.35, 0.3)

	match pattern:
		0:  # Loop left
			for y in range(20, height - 20):
				var wave = sin(y * 0.15) * 15 + sin(y * 0.08) * 10
				for t in range(-2, 3):
					var x = int(center_x + wave + t - 20)
					if x >= 0 and x < width:
						img.set_pixel(x, y, ridge_color)
		1:  # Loop right
			for y in range(20, height - 20):
				var wave = sin(y * 0.15) * 15 + sin(y * 0.08) * 10
				for t in range(-2, 3):
					var x = int(center_x - wave + t + 20)
					if x >= 0 and x < width:
						img.set_pixel(x, y, ridge_color)
		2:  # Whorl
			for angle in range(0, 360, 5):
				var rad = deg_to_rad(angle)
				for r in range(10, min(width, height) / 2 - 10, 8):
					var x = int(center_x + cos(rad + r * 0.1) * r)
					var y = int(center_y + sin(rad + r * 0.1) * r)
					if x >= 0 and x < width and y >= 0 and y < height:
						img.set_pixel(x, y, ridge_color)
		3:  # Arch
			for x in range(15, width - 15):
				var arch_height = pow((x - center_x) / float(width / 2), 2) * (height / 3)
				for layer in range(8):
					var y = int(center_y + arch_height + layer * 10)
					if y >= 0 and y < height:
						img.set_pixel(x, y, ridge_color)
		4:  # Tented arch
			for x in range(15, width - 15):
				var dist_from_center = abs(x - center_x)
				var tent_height = (height / 3) - dist_from_center * 0.8
				for layer in range(8):
					var y = int(center_y - tent_height + layer * 12)
					if y >= 0 and y < height:
						img.set_pixel(x, y, ridge_color)
		5:  # Double loop
			for y in range(20, height / 2):
				var wave = sin(y * 0.2) * 10
				for t in range(-1, 2):
					var x = int(center_x / 2 + wave + t)
					if x >= 0 and x < width:
						img.set_pixel(x, y, ridge_color)
			for y in range(height / 2, height - 20):
				var wave = sin(y * 0.2) * 10
				for t in range(-1, 2):
					var x = int(center_x + center_x / 2 - wave + t)
					if x >= 0 and x < width:
						img.set_pixel(x, y, ridge_color)
		6:  # Central pocket
			for angle in range(0, 360, 8):
				var rad = deg_to_rad(angle)
				for r in range(20, min(width, height) / 3, 6):
					var x = int(center_x + cos(rad) * r)
					var y = int(center_y + sin(rad) * r * 1.2)
					if x >= 0 and x < width and y >= 0 and y < height:
						img.set_pixel(x, y, ridge_color)
		_:  # Plain arch
			for x in range(10, width - 10):
				for layer in range(10):
					var y = int(height / 2 + layer * 10 + sin(x * 0.05) * 5)
					if y >= 0 and y < height:
						img.set_pixel(x, y, ridge_color)

	return ImageTexture.create_from_image(img)


func _on_fingerprint_selected(index: int) -> void:
	if not _is_active:
		return

	var btn = _fingerprint_buttons[index]
	_play_sound(_snd_scan, -3.0)

	if index == _correct_index:
		# Correct match!
		_correct_matches += 1
		_current_match += 1
		btn.modulate = Color.GREEN
		_play_sound(_snd_correct, 0.0)

		# Disable all buttons briefly
		for b in _fingerprint_buttons:
			b.disabled = true

		_update_progress()

		if _current_match >= matches_to_complete:
			_complete_game()
		else:
			# Play round complete sound
			_play_sound(_snd_round_complete, 0.0)
			# Next round after delay
			await get_tree().create_timer(0.5).timeout
			if _is_active:
				_generate_new_round()
	else:
		# Wrong - visual feedback but no harsh penalty
		btn.modulate = Color(1, 0.5, 0.5)
		btn.disabled = true
		_play_sound(_snd_incorrect, 0.0)


func _update_progress() -> void:
	var progress = subviewport.get_node_or_null("Progress")
	if progress:
		progress.text = "Matched: %d / %d" % [_correct_matches, matches_to_complete]


func _complete_game() -> void:
	var total_score = (matches_to_complete * points_per_match) + completion_bonus

	if instruction_label:
		instruction_label.text = "All fingerprints matched! +%d points!" % total_score

	complete_success(total_score, {
		"matches": _correct_matches,
		"total": matches_to_complete,
		"perfect": true
	})


func _on_minigame_complete() -> void:
	# Partial credit if some matches were made
	if _correct_matches > 0 and _correct_matches < matches_to_complete:
		var partial_score = _correct_matches * points_per_match

		_result.score_bonus = partial_score
		_result.matches = _correct_matches
		_result.total = matches_to_complete
		_result.perfect = false

		if instruction_label:
			instruction_label.text = "Matched %d/%d. +%d points!" % [
				_correct_matches, matches_to_complete, partial_score
			]
