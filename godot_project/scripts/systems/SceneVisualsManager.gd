extends Node
## SceneVisualsManager - Dynamic scene visual changes based on story progression
##
## This manager controls environmental visuals that change based on the current shift,
## emphasizing the passage of time and story events. It works whether the player
## arrives at a shift through linear progression or level select.
##
## Visuals controlled:
## - Propaganda posters that accumulate on walls as shifts progress
## - (Future) Environmental shader parameters, lighting, etc.

# ============================================================================
# CONFIGURATION
# ============================================================================

## Poster visibility configuration: maps shift thresholds to poster visibility
## Posters accumulate - once a poster appears, it stays visible for all higher shifts
const POSTER_SHIFT_THRESHOLDS: Dictionary = {
	"Poster1": 4,   # "Glory to Spudland" - appears at shift 4
	"Poster2": 6,   # "Report Suspicious Tubers" - appears at shift 6
	"Poster3": 9,   # "Keep Our Borders Clean" - appears at shift 9
}

## Animation duration for poster fade-in (seconds)
const POSTER_FADE_DURATION: float = 1.0

## Hover preview scale multiplier (how much larger to show poster on hover)
const HOVER_PREVIEW_SCALE: float = 5.0

## Hover preview fade duration (seconds)
const HOVER_PREVIEW_FADE_DURATION: float = 0.2

## Normal-size poster textures for hover preview (larger than mini versions)
const POSTER_FULL_TEXTURES: Dictionary = {
	"Poster1": preload("res://assets/world/posters/normal_size/poster_1_normal.png"),
	"Poster2": preload("res://assets/world/posters/normal_size/poster_2_normal.png"),
	"Poster3": preload("res://assets/world/posters/normal_size/poster_3_normal.png"),
}

# ============================================================================
# NODE REFERENCES
# ============================================================================

## Container node that holds all poster sprites
## PostersContainer is under Elements node for proper scaling/positioning
@onready var posters_container: Node2D = get_node_or_null("../Elements/PostersContainer")

## Individual poster references (set up in _ready)
var _posters: Dictionary = {}

# ============================================================================
# STATE
# ============================================================================

## Track which posters are currently visible to avoid redundant animations
var _visible_posters: Dictionary = {}

## Hover preview overlay components
var _preview_layer: CanvasLayer = null
var _preview_sprite: Sprite2D = null
var _preview_background: ColorRect = null
var _current_preview_tween: Tween = null

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	_setup_poster_references()
	_setup_hover_preview()
	_connect_signals()

	# Initialize visuals based on current shift (handles level select case)
	# Use call_deferred to ensure GameStateManager is ready
	call_deferred("_initialize_for_current_shift")


func _setup_poster_references() -> void:
	"""Cache references to poster nodes and add hover detection"""
	if not posters_container:
		push_warning("SceneVisualsManager: PostersContainer not found")
		return

	for poster_name in POSTER_SHIFT_THRESHOLDS.keys():
		var poster_node = posters_container.get_node_or_null(poster_name)
		if poster_node:
			_posters[poster_name] = poster_node
			# Start all posters hidden
			poster_node.modulate.a = 0.0
			poster_node.visible = true  # Keep visible but transparent for animation
			_visible_posters[poster_name] = false

			# Add Area2D for hover detection
			_setup_poster_hover_area(poster_node, poster_name)
		else:
			push_warning("SceneVisualsManager: Poster node '%s' not found" % poster_name)


func _setup_poster_hover_area(poster: Sprite2D, poster_name: String) -> void:
	"""Add Area2D with collision shape for hover detection on a poster"""
	var area = Area2D.new()
	area.name = "HoverArea"
	area.input_pickable = true
	area.set_meta("poster_name", poster_name)

	# Create collision shape based on poster size
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()

	# Get poster texture size and adjust for scale
	if poster.texture:
		var tex_size = poster.texture.get_size()
		shape.size = tex_size
	else:
		shape.size = Vector2(100, 150)  # Default size

	collision.shape = shape
	area.add_child(collision)

	# Connect hover signals
	area.mouse_entered.connect(_on_poster_mouse_entered.bind(poster_name))
	area.mouse_exited.connect(_on_poster_mouse_exited)

	poster.add_child(area)


func _setup_hover_preview() -> void:
	"""Create the CanvasLayer for hover preview display"""
	_preview_layer = CanvasLayer.new()
	_preview_layer.name = "PosterPreviewLayer"
	_preview_layer.layer = 90  # Below dialogue skip button but above game

	# Semi-transparent background
	_preview_background = ColorRect.new()
	_preview_background.color = Color(0, 0, 0, 0)
	_preview_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_preview_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_layer.add_child(_preview_background)

	# Preview sprite centered on screen
	_preview_sprite = Sprite2D.new()
	_preview_sprite.name = "PreviewSprite"
	_preview_sprite.modulate.a = 0.0
	_preview_sprite.z_index = 1

	# Create a Control to center the sprite
	var center_control = Control.new()
	center_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	center_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_layer.add_child(center_control)

	# Position sprite in center of viewport
	_preview_sprite.position = Vector2(640, 360)  # Center of 1280x720
	center_control.add_child(_preview_sprite)

	add_child(_preview_layer)
	_preview_layer.visible = false


func _connect_signals() -> void:
	"""Connect to EventBus signals for shift changes"""
	EventBus.shift_advanced.connect(_on_shift_advanced)


func _initialize_for_current_shift() -> void:
	"""Set initial visual state based on current shift (for level select)"""
	var current_shift = GameStateManager.get_shift()
	_update_visuals_for_shift(current_shift, false)  # No animation on initial load
	LogManager.write_info("SceneVisualsManager: Initialized for shift %d" % current_shift)

# ============================================================================
# VISUAL UPDATE METHODS
# ============================================================================

func _update_visuals_for_shift(shift: int, animate: bool = true) -> void:
	"""Update all visual elements based on the given shift"""
	_update_posters_for_shift(shift, animate)
	# Future: Add other visual updates here (shaders, lighting, etc.)


func _update_posters_for_shift(shift: int, animate: bool = true) -> void:
	"""Show/hide posters based on shift thresholds"""
	for poster_name in POSTER_SHIFT_THRESHOLDS.keys():
		var threshold = POSTER_SHIFT_THRESHOLDS[poster_name]
		var should_be_visible = shift >= threshold

		if should_be_visible and not _visible_posters.get(poster_name, false):
			_show_poster(poster_name, animate)
		elif not should_be_visible and _visible_posters.get(poster_name, false):
			_hide_poster(poster_name, animate)


func _show_poster(poster_name: String, animate: bool = true) -> void:
	"""Make a poster visible, optionally with fade animation"""
	var poster = _posters.get(poster_name)
	if not poster:
		return

	_visible_posters[poster_name] = true

	if animate:
		var tween = create_tween()
		tween.tween_property(poster, "modulate:a", 1.0, POSTER_FADE_DURATION)
		LogManager.write_info("SceneVisualsManager: Animating poster '%s' visible" % poster_name)
	else:
		poster.modulate.a = 1.0
		LogManager.write_info("SceneVisualsManager: Set poster '%s' visible" % poster_name)


func _hide_poster(poster_name: String, animate: bool = true) -> void:
	"""Hide a poster, optionally with fade animation"""
	var poster = _posters.get(poster_name)
	if not poster:
		return

	_visible_posters[poster_name] = false

	if animate:
		var tween = create_tween()
		tween.tween_property(poster, "modulate:a", 0.0, POSTER_FADE_DURATION)
		LogManager.write_info("SceneVisualsManager: Animating poster '%s' hidden" % poster_name)
	else:
		poster.modulate.a = 0.0
		LogManager.write_info("SceneVisualsManager: Set poster '%s' hidden" % poster_name)

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_shift_advanced(from_shift: int, to_shift: int) -> void:
	"""Handle shift progression during gameplay"""
	LogManager.write_info("SceneVisualsManager: Shift advanced %d -> %d" % [from_shift, to_shift])
	_update_visuals_for_shift(to_shift, true)  # Animate during gameplay

# ============================================================================
# PUBLIC API
# ============================================================================

func force_update_visuals() -> void:
	"""Force an immediate visual update based on current shift (no animation)"""
	var current_shift = GameStateManager.get_shift()
	_update_visuals_for_shift(current_shift, false)


func get_visible_posters() -> Array:
	"""Get list of currently visible poster names"""
	var visible: Array = []
	for poster_name in _visible_posters.keys():
		if _visible_posters[poster_name]:
			visible.append(poster_name)
	return visible

# ============================================================================
# HOVER PREVIEW METHODS
# ============================================================================

func _on_poster_mouse_entered(poster_name: String) -> void:
	"""Show enlarged poster preview on hover"""
	# Only show preview if poster is actually visible
	if not _visible_posters.get(poster_name, false):
		return

	# Get full-size texture for this poster
	if not POSTER_FULL_TEXTURES.has(poster_name):
		return

	var full_texture = POSTER_FULL_TEXTURES[poster_name]
	_preview_sprite.texture = full_texture

	# Show the preview layer
	_preview_layer.visible = true

	# Kill any existing tween
	if _current_preview_tween and _current_preview_tween.is_valid():
		_current_preview_tween.kill()

	# Fade in the preview
	_current_preview_tween = create_tween()
	_current_preview_tween.set_parallel(true)
	_current_preview_tween.tween_property(_preview_sprite, "modulate:a", 1.0, HOVER_PREVIEW_FADE_DURATION)
	_current_preview_tween.tween_property(_preview_background, "color:a", 0.5, HOVER_PREVIEW_FADE_DURATION)


func _on_poster_mouse_exited() -> void:
	"""Hide poster preview when mouse leaves"""
	# Kill any existing tween
	if _current_preview_tween and _current_preview_tween.is_valid():
		_current_preview_tween.kill()

	# Fade out the preview
	_current_preview_tween = create_tween()
	_current_preview_tween.set_parallel(true)
	_current_preview_tween.tween_property(_preview_sprite, "modulate:a", 0.0, HOVER_PREVIEW_FADE_DURATION)
	_current_preview_tween.tween_property(_preview_background, "color:a", 0.0, HOVER_PREVIEW_FADE_DURATION)

	# Hide layer after fade completes
	_current_preview_tween.chain().tween_callback(func(): _preview_layer.visible = false)
