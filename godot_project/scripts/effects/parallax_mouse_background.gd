extends TextureRect
## Applies a subtle parallax effect to the background based on mouse position.
## Attach this script to a TextureRect to make it shift slightly when the mouse moves.

## Maximum offset in pixels when the mouse is at the edge of the screen
@export var max_offset: Vector2 = Vector2(30.0, 20.0)
## How smoothly the background follows the mouse (lower = smoother but slower)
@export var smoothing: float = 3.0
## Whether the parallax effect is enabled
@export var enabled: bool = true

var _target_offset: Vector2 = Vector2.ZERO
var _current_offset: Vector2 = Vector2.ZERO
var _base_position: Vector2 = Vector2.ZERO
var _initialized: bool = false


func _ready() -> void:
	# Store the initial position as base
	_base_position = position
	_initialized = true


func _process(delta: float) -> void:
	if not enabled or not _initialized:
		return

	# Get viewport size and mouse position
	var viewport_size = get_viewport_rect().size
	var mouse_pos = get_viewport().get_mouse_position()

	# Calculate normalized mouse position (-1 to 1 from center)
	var center = viewport_size / 2.0
	var normalized_mouse = (mouse_pos - center) / center

	# Clamp to prevent extreme values if mouse goes outside window
	normalized_mouse.x = clampf(normalized_mouse.x, -1.0, 1.0)
	normalized_mouse.y = clampf(normalized_mouse.y, -1.0, 1.0)

	# Calculate target offset (inverted for natural parallax feel)
	_target_offset = -normalized_mouse * max_offset

	# Smoothly interpolate to target offset
	_current_offset = _current_offset.lerp(_target_offset, smoothing * delta)

	# Apply offset to position
	position = _base_position + _current_offset
