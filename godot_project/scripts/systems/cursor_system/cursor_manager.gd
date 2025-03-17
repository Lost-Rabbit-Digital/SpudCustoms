class_name CursorManager
extends Node

signal cursor_changed(cursor_type)
signal cursor_data_updated(data)

# Reference to visual cursor node
@onready var cursor_sprite: Sprite2D = $CursorSprite

# Cursor configuration
@export var default_cursor_type: CursorTypes.Type = CursorTypes.Type.DEFAULT
@export var cursor_textures: Dictionary = {}
@export var cursor_offset: Vector2 = Vector2.ZERO
@export var use_hardware_cursor: bool = false

# Current state
var current_cursor_type: CursorTypes.Type = CursorTypes.Type.DEFAULT
var cursor_data: CursorData = null
var cursor_visible: bool = true

func _ready() -> void:
	# Initialize cursor system
	cursor_data = CursorData.new()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if use_hardware_cursor:
		# Use Godot's hardware cursor system
		_setup_hardware_cursor()
	else:
		# Use custom sprite-based cursor
		_setup_custom_cursor()
	
	# Set default cursor
	set_cursor(default_cursor_type)

func _process(_delta: float) -> void:
	if not use_hardware_cursor and cursor_visible:
		# Update custom cursor position
		cursor_sprite.global_position = get_viewport().get_mouse_position() + cursor_offset

func set_cursor(type: CursorTypes.Type) -> void:
	if current_cursor_type == type:
		return
		
	current_cursor_type = type
	
	if use_hardware_cursor:
		# Update hardware cursor
		_update_hardware_cursor()
	else:
		# Update custom cursor
		_update_custom_cursor()
	
	cursor_changed.emit(type)

func set_cursor_data(data: Dictionary) -> void:
	cursor_data.update(data)
	cursor_data_updated.emit(cursor_data)

func get_cursor_data() -> CursorData:
	return cursor_data

func set_cursor_visibility(visible: bool) -> void:
	cursor_visible = visible
	
	if use_hardware_cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_HIDDEN)
	else:
		cursor_sprite.visible = visible

func _setup_hardware_cursor() -> void:
	# Initial hardware cursor setup
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_update_hardware_cursor()

func _setup_custom_cursor() -> void:
	# Hide system cursor and use our own
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Create cursor sprite if it doesn't exist
	if not cursor_sprite:
		cursor_sprite = Sprite2D.new()
		cursor_sprite.name = "CursorSprite"
		add_child(cursor_sprite)
	
	_update_custom_cursor()

func _update_hardware_cursor() -> void:
	# Set the appropriate hardware cursor
	if cursor_textures.has(current_cursor_type):
		var texture = cursor_textures[current_cursor_type]
		Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, cursor_offset)

func _update_custom_cursor() -> void:
	# Update custom cursor sprite
	if cursor_sprite and cursor_textures.has(current_cursor_type):
		cursor_sprite.texture = cursor_textures[current_cursor_type]
