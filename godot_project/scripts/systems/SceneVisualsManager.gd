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

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	_setup_poster_references()
	_connect_signals()

	# Initialize visuals based on current shift (handles level select case)
	# Use call_deferred to ensure GameStateManager is ready
	call_deferred("_initialize_for_current_shift")


func _setup_poster_references() -> void:
	"""Cache references to poster nodes"""
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
		else:
			push_warning("SceneVisualsManager: Poster node '%s' not found" % poster_name)


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
