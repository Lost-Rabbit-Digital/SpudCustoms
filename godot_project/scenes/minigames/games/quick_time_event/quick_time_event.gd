class_name QuickTimeEventMinigame
extends MinigameContainer
## Quick Time Event (QTE) minigame for dramatic narrative transitions.
##
## Shows a sequence of key prompts that the player must press within a time window.
## Success leads to bonus points and narrative progression.
## Great for tense moments like escapes, infiltrations, or confrontations.
##
## Now supports narrative images displayed alongside QTE prompts with fade transitions.
##
## Unlocks: Shift 8+

# Audio assets
var _snd_prompt_appear = preload("res://assets/audio/ui_feedback/motion_straight_air.wav")
var _snd_key_success = preload("res://assets/audio/ui_feedback/Task Complete Ensemble 001.wav")
var _snd_key_fail = preload("res://assets/audio/minigames/minigame_timeout_whomp.mp3")
var _snd_sequence_complete = preload("res://assets/audio/minigames/minigame_success_fanfare.mp3")

## Default placeholder color for missing images
const PLACEHOLDER_COLOR: Color = Color(0.15, 0.12, 0.18, 1.0)

## Default fade duration for image transitions
const IMAGE_FADE_DURATION: float = 0.5

## Number of QTE prompts in the sequence
@export var prompt_count: int = 5

## Time window to press each key (seconds)
## Default is generous for accessibility - can be reduced via config if needed
@export var time_per_prompt: float = 5.0

## Points per successful key press
@export var points_per_press: int = 50

## Available keys for QTE prompts
const QTE_KEYS = [
	{"key": KEY_SPACE, "display": "SPACE", "action": "ui_select"},
	{"key": KEY_E, "display": "E", "action": null},
	{"key": KEY_Q, "display": "Q", "action": null},
	{"key": KEY_F, "display": "F", "action": null},
]

# Internal state
var _current_prompt_index: int = 0
var _current_key: Dictionary = {}
var _prompt_time_remaining: float = 0.0
var _successful_presses: int = 0
var _is_waiting_for_input: bool = false

# UI elements
var _prompt_label: Label = null
var _key_label: Label = null
var _progress_bar: ProgressBar = null
var _feedback_label: Label = null
var _timer_bar: ProgressBar = null

# Visual pane elements for narrative images
var _visual_pane: Control = null
var _image_display: TextureRect = null
var _placeholder_panel: Panel = null
var _placeholder_label: Label = null
var _current_image_path: String = ""
var _image_fade_tween: Tween = null

# Multi-image progression system
var _image_paths: Array[String] = []
var _current_image_index: int = 0
const MAX_IMAGE_FRAMES: int = 3


func _ready() -> void:
	super._ready()
	minigame_type = "quick_time_event"
	time_limit = 0.0  # We use per-prompt timing instead
	skippable = true
	reward_multiplier = 1.0

	if title_label:
		title_label.text = tr("qte_title")
	if instruction_label:
		instruction_label.text = tr("qte_instruction")


func _on_minigame_start(config: Dictionary) -> void:
	_current_prompt_index = 0
	_successful_presses = 0
	_is_waiting_for_input = false
	_current_image_path = ""
	_image_paths.clear()
	_current_image_index = 0

	if config.has("prompt_count"):
		prompt_count = config.prompt_count
	if config.has("time_per_prompt"):
		time_per_prompt = config.time_per_prompt
	if config.has("narrative_context"):
		# Use narrative context to customize the display
		if instruction_label:
			instruction_label.text = config.narrative_context

	# Handle narrative image configuration
	# Support both single image_path and array of image_paths
	if config.has("image_paths") and config.image_paths is Array and config.image_paths.size() > 0:
		for path in config.image_paths:
			if path is String:
				_image_paths.append(path)
		# Set first image as current
		if _image_paths.size() > 0:
			_current_image_path = _image_paths[0]
	elif config.has("image_path"):
		_current_image_path = config.image_path
		_image_paths.append(_current_image_path)

	# Apply accessibility settings
	_apply_accessibility_settings()

	_setup_minigame_scene()

	# Show first narrative image if configured
	if _current_image_path != "":
		_show_narrative_image(_current_image_path)

	# Check for auto-complete mode
	if AccessibilityManager and AccessibilityManager.should_qte_auto_complete():
		_auto_complete_sequence()
	else:
		_show_next_prompt()


## Apply accessibility settings to QTE parameters
func _apply_accessibility_settings() -> void:
	if not AccessibilityManager:
		return

	# Adjust time per prompt based on accessibility multiplier
	time_per_prompt = AccessibilityManager.get_adjusted_qte_time(time_per_prompt)

	# Adjust prompt count if reduced prompts is enabled
	prompt_count = AccessibilityManager.get_adjusted_qte_prompts(prompt_count)


## Auto-complete the QTE sequence for accessibility
func _auto_complete_sequence() -> void:
	# Simulate perfect completion
	_successful_presses = prompt_count
	_current_prompt_index = prompt_count

	# Show brief "Auto-completed" message
	_key_label.text = tr("qte_auto_completed")
	_key_label.add_theme_font_size_override("font_size", 36)
	_key_label.modulate = Color.CHARTREUSE
	_feedback_label.text = tr("qte_accessibility_note")
	_feedback_label.modulate = Color.WHITE
	_progress_bar.value = prompt_count

	# Complete after brief delay
	await get_tree().create_timer(1.5).timeout

	if _is_active:
		var total_score = prompt_count * points_per_press
		complete_success(total_score, {
			"successful_presses": prompt_count,
			"total_prompts": prompt_count,
			"success_rate": 1.0,
			"auto_completed": true
		})


func _setup_minigame_scene() -> void:
	for child in subviewport.get_children():
		child.queue_free()

	# Layout constants for two-column design
	var viewport_width: float = subviewport.size.x  # 800
	var viewport_height: float = subviewport.size.y  # 600
	var left_column_width: float = 380.0
	var right_column_start: float = left_column_width + 20.0  # 400
	var right_column_width: float = viewport_width - right_column_start  # 400
	var right_column_center: float = right_column_start + right_column_width / 2.0  # 600

	# Dark dramatic background
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08, 0.95)
	bg.size = subviewport.size
	subviewport.add_child(bg)

	# Visual pane for narrative images (left column)
	_setup_visual_pane()

	# Narrative prompt (top, spans full width)
	_prompt_label = Label.new()
	_prompt_label.name = "PromptLabel"
	_prompt_label.text = tr("qte_get_ready")
	_prompt_label.add_theme_font_size_override("font_size", 24)
	_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.size = Vector2(viewport_width, 50)
	_prompt_label.position = Vector2(0, 60)
	subviewport.add_child(_prompt_label)

	# Key to press (right column, large)
	_key_label = Label.new()
	_key_label.name = "KeyLabel"
	_key_label.text = ""
	_key_label.add_theme_font_size_override("font_size", 72)
	_key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_key_label.size = Vector2(right_column_width, 100)
	_key_label.position = Vector2(right_column_start, viewport_height / 2 - 80)
	_key_label.modulate = Color.WHITE
	subviewport.add_child(_key_label)

	# Timer bar (right column, below key)
	_timer_bar = ProgressBar.new()
	_timer_bar.name = "TimerBar"
	_timer_bar.min_value = 0
	_timer_bar.max_value = 100
	_timer_bar.value = 100
	_timer_bar.show_percentage = false
	_timer_bar.size = Vector2(280, 20)
	_timer_bar.position = Vector2(right_column_center - 140, viewport_height / 2 + 40)
	subviewport.add_child(_timer_bar)

	# Feedback label (right column, below timer)
	_feedback_label = Label.new()
	_feedback_label.name = "FeedbackLabel"
	_feedback_label.text = ""
	_feedback_label.add_theme_font_size_override("font_size", 28)
	_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback_label.size = Vector2(right_column_width, 40)
	_feedback_label.position = Vector2(right_column_start, viewport_height / 2 + 80)
	_feedback_label.modulate = Color.WHITE
	subviewport.add_child(_feedback_label)

	# Progress indicator (bottom center, spans full width)
	var progress_label = Label.new()
	progress_label.text = tr("qte_progress")
	progress_label.add_theme_font_size_override("font_size", 14)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.size = Vector2(300, 20)
	progress_label.position = Vector2(viewport_width / 2 - 150, viewport_height - 100)
	subviewport.add_child(progress_label)

	_progress_bar = ProgressBar.new()
	_progress_bar.name = "ProgressBar"
	_progress_bar.min_value = 0
	_progress_bar.max_value = prompt_count
	_progress_bar.value = 0
	_progress_bar.show_percentage = false
	_progress_bar.size = Vector2(300, 15)
	_progress_bar.position = Vector2(viewport_width / 2 - 150, viewport_height - 80)
	subviewport.add_child(_progress_bar)


func _show_next_prompt() -> void:
	if _current_prompt_index >= prompt_count:
		_sequence_complete()
		return

	# Pick a random key
	_current_key = QTE_KEYS[randi() % QTE_KEYS.size()]

	# Reset timer
	_prompt_time_remaining = time_per_prompt

	# Update UI
	_key_label.text = "[%s]" % _current_key.display
	_key_label.modulate = Color.WHITE
	_feedback_label.text = ""
	_timer_bar.value = 100

	# Play prompt sound
	_play_sound(_snd_prompt_appear, -5.0, 1.0 + _current_prompt_index * 0.1)

	# Animate key appearing
	_key_label.scale = Vector2(0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(_key_label, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	_is_waiting_for_input = true


func _process(delta: float) -> void:
	super._process(delta)

	if not _is_active or not _is_waiting_for_input:
		return

	# Update prompt timer
	_prompt_time_remaining -= delta
	_timer_bar.value = (_prompt_time_remaining / time_per_prompt) * 100

	# Color timer bar based on urgency
	if _prompt_time_remaining < time_per_prompt * 0.3:
		_timer_bar.modulate = Color.RED
		_key_label.modulate = Color(1.0, 0.5, 0.5)
	elif _prompt_time_remaining < time_per_prompt * 0.6:
		_timer_bar.modulate = Color.ORANGE
	else:
		_timer_bar.modulate = Color.WHITE

	# Check for timeout
	if _prompt_time_remaining <= 0:
		_on_prompt_timeout()


func _input(event: InputEvent) -> void:
	if not _is_active or not _is_waiting_for_input:
		return

	# Check for key press
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == _current_key.key:
			_on_correct_key_pressed()
		else:
			# Wrong key - show feedback but don't fail
			_show_feedback("Wrong key!", Color.YELLOW)

	# Also check for action if defined
	if _current_key.action and event.is_action_pressed(_current_key.action):
		_on_correct_key_pressed()


func _on_correct_key_pressed() -> void:
	_is_waiting_for_input = false
	_successful_presses += 1
	_current_prompt_index += 1

	# Update progress
	_progress_bar.value = _current_prompt_index

	# Visual feedback
	_key_label.modulate = Color.GREEN
	_show_feedback("Nice!", Color.GREEN)

	# Play success sound with increasing pitch
	_play_sound(_snd_key_success, -3.0, 0.9 + _successful_presses * 0.05)

	# Progress to next image if available (on successful press only)
	_advance_narrative_image()

	# Small delay before next prompt
	await get_tree().create_timer(0.4).timeout

	if _is_active:
		_show_next_prompt()


func _on_prompt_timeout() -> void:
	_is_waiting_for_input = false
	_current_prompt_index += 1

	# Update progress
	_progress_bar.value = _current_prompt_index

	# Visual feedback
	_key_label.modulate = Color.RED
	_show_feedback("Missed!", Color.RED)

	# Play fail sound
	_play_sound(_snd_key_fail, -5.0)

	# Delay before next prompt
	await get_tree().create_timer(0.6).timeout

	if _is_active:
		_show_next_prompt()


func _show_feedback(text: String, color: Color) -> void:
	_feedback_label.text = text
	_feedback_label.modulate = color

	# Fade out feedback
	var tween = create_tween()
	tween.tween_property(_feedback_label, "modulate:a", 0.0, 0.5).set_delay(0.3)


func _sequence_complete() -> void:
	_is_waiting_for_input = false

	# Calculate score
	var total_score = _successful_presses * points_per_press
	var success_rate = float(_successful_presses) / float(prompt_count)

	# Determine outcome message
	var outcome_message: String
	if success_rate >= 0.8:
		outcome_message = "Excellent! Perfect timing!"
		_key_label.modulate = Color.GREEN
	elif success_rate >= 0.5:
		outcome_message = "Good effort! You made it through!"
		_key_label.modulate = Color.YELLOW
	else:
		outcome_message = "Close call! But you survived!"
		_key_label.modulate = Color.ORANGE

	_key_label.text = outcome_message
	_key_label.add_theme_font_size_override("font_size", 32)
	_feedback_label.text = tr("qte_result").format({"successful": _successful_presses, "total": prompt_count, "points": total_score})
	_feedback_label.modulate = Color.WHITE

	# Fade out the narrative image if visible
	_hide_narrative_image()

	# Play completion sound
	_play_sound(_snd_sequence_complete, -3.0)

	complete_success(total_score, {
		"successful_presses": _successful_presses,
		"total_prompts": prompt_count,
		"success_rate": success_rate,
		"image_shown": _current_image_path != ""
	})


func _play_sound(sound: AudioStream, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.volume_db = volume_db
		audio_player.pitch_scale = pitch
		audio_player.play()


# === Visual Pane Methods ===

## Set up the visual pane container for narrative images
func _setup_visual_pane() -> void:
	# Layout constants for left column
	var viewport_height: float = subviewport.size.y
	var pane_width: float = 360.0
	var pane_height: float = 380.0
	var pane_x: float = 20.0
	var pane_y: float = (viewport_height - pane_height) / 2.0 + 20.0  # Slightly below center

	# Create visual pane container (left column)
	_visual_pane = Control.new()
	_visual_pane.name = "VisualPane"
	_visual_pane.size = Vector2(pane_width, pane_height)
	_visual_pane.position = Vector2(pane_x, pane_y)
	_visual_pane.modulate.a = 0.0  # Start hidden
	subviewport.add_child(_visual_pane)

	# Create image display (fills the visual pane)
	_image_display = TextureRect.new()
	_image_display.name = "ImageDisplay"
	_image_display.size = _visual_pane.size
	_image_display.position = Vector2.ZERO
	_image_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_image_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_visual_pane.add_child(_image_display)

	# Create placeholder panel (shown when image is missing)
	_placeholder_panel = Panel.new()
	_placeholder_panel.name = "PlaceholderPanel"
	_placeholder_panel.size = _visual_pane.size
	_placeholder_panel.position = Vector2.ZERO
	_placeholder_panel.visible = false

	# Style the placeholder with a dark color
	var style = StyleBoxFlat.new()
	style.bg_color = PLACEHOLDER_COLOR
	style.border_color = Color(0.3, 0.25, 0.35, 1.0)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	_placeholder_panel.add_theme_stylebox_override("panel", style)
	_visual_pane.add_child(_placeholder_panel)

	# Create placeholder label
	_placeholder_label = Label.new()
	_placeholder_label.name = "PlaceholderLabel"
	_placeholder_label.text = tr("qte_image_pending")
	_placeholder_label.add_theme_font_size_override("font_size", 18)
	_placeholder_label.add_theme_color_override("font_color", Color(0.5, 0.45, 0.55, 1.0))
	_placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_placeholder_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_placeholder_label.size = _visual_pane.size
	_placeholder_label.position = Vector2.ZERO
	_placeholder_panel.add_child(_placeholder_label)


## Show a narrative image with fade-in animation
## [param image_path]: Path to the image resource (e.g., "res://assets/narrative/sasha_rescue.png")
func _show_narrative_image(image_path: String) -> void:
	if _visual_pane == null:
		return

	# Cancel any existing fade tween
	if _image_fade_tween and _image_fade_tween.is_running():
		_image_fade_tween.kill()

	# Try to load the image
	var texture: Texture2D = null
	if ResourceLoader.exists(image_path):
		texture = load(image_path) as Texture2D

	if texture:
		# Show the actual image
		_image_display.texture = texture
		_image_display.visible = true
		_placeholder_panel.visible = false
	else:
		# Show placeholder for missing image
		_image_display.visible = false
		_placeholder_panel.visible = true
		# Extract filename for display
		var filename = image_path.get_file().get_basename()
		_placeholder_label.text = "[%s]" % filename.replace("_", " ").capitalize()

	# Fade in the visual pane
	_image_fade_tween = create_tween()
	_image_fade_tween.tween_property(_visual_pane, "modulate:a", 1.0, IMAGE_FADE_DURATION).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


## Hide the narrative image with fade-out animation
func _hide_narrative_image() -> void:
	if _visual_pane == null:
		return

	# Cancel any existing fade tween
	if _image_fade_tween and _image_fade_tween.is_running():
		_image_fade_tween.kill()

	# Fade out the visual pane
	_image_fade_tween = create_tween()
	_image_fade_tween.tween_property(_visual_pane, "modulate:a", 0.0, IMAGE_FADE_DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)


## Transition to a new narrative image with crossfade
## [param image_path]: Path to the new image resource
func _transition_narrative_image(image_path: String) -> void:
	if _visual_pane == null:
		return

	# If already visible, do a crossfade
	if _visual_pane.modulate.a > 0.5:
		# Quick fade out then fade in with new image
		if _image_fade_tween and _image_fade_tween.is_running():
			_image_fade_tween.kill()

		_image_fade_tween = create_tween()
		_image_fade_tween.tween_property(_visual_pane, "modulate:a", 0.0, IMAGE_FADE_DURATION * 0.5)
		_image_fade_tween.tween_callback(_load_image_texture.bind(image_path))
		_image_fade_tween.tween_property(_visual_pane, "modulate:a", 1.0, IMAGE_FADE_DURATION * 0.5)
	else:
		# Just show the new image
		_show_narrative_image(image_path)


## Helper to load image texture for crossfade callback
func _load_image_texture(image_path: String) -> void:
	var texture: Texture2D = null
	if ResourceLoader.exists(image_path):
		texture = load(image_path) as Texture2D

	if texture:
		_image_display.texture = texture
		_image_display.visible = true
		_placeholder_panel.visible = false
	else:
		_image_display.visible = false
		_placeholder_panel.visible = true
		var filename = image_path.get_file().get_basename()
		_placeholder_label.text = "[%s]" % filename.replace("_", " ").capitalize()


## Check if an image exists at the given path
func _image_exists(image_path: String) -> bool:
	return ResourceLoader.exists(image_path)


## Advance to the next narrative image in the sequence (called on successful key press)
## Stays on the last available image if we've shown all frames
func _advance_narrative_image() -> void:
	if _image_paths.size() <= 1:
		return  # No progression needed for single image or no images

	# Calculate next image index (cap at last available image)
	var next_index: int = mini(_current_image_index + 1, _image_paths.size() - 1)

	# Only transition if we're actually changing images
	if next_index != _current_image_index:
		_current_image_index = next_index
		_current_image_path = _image_paths[_current_image_index]
		_transition_narrative_image(_current_image_path)
