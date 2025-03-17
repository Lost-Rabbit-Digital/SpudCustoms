# scripts/systems/cursor_system/cursor_manager.gd
class_name CursorManager
extends RefCounted

## Singleton instance
static var _instance: CursorManager
static func get_instance() -> CursorManager:
	if not _instance:
		_instance = CursorManager.new()
	return _instance
	
signal cursor_changed(cursor_type)
signal cursor_data_updated(data)

# Cursor configuration
var default_cursor_type: CursorTypes.Type = CursorTypes.Type.DEFAULT
var use_hardware_cursor: bool = true

# Current state
var current_cursor_type: CursorTypes.Type = CursorTypes.Type.DEFAULT
var cursor_data: CursorData = null
var cursor_visible: bool = true
var _custom_cursor_sprite: Sprite2D = null

func _init() -> void:
	cursor_data = CursorData.new()
	# Default initialization - can be configured later

func initialize(use_hw_cursor: bool = true, 
				initial_type: CursorTypes.Type = CursorTypes.Type.DEFAULT) -> void:
	use_hardware_cursor = use_hw_cursor
	default_cursor_type = initial_type
	
	if use_hardware_cursor:
		_setup_hardware_cursor()
	else:
		_setup_custom_cursor()
	
	set_cursor(default_cursor_type)
	
	# Connect to process for custom cursor updates if needed
	if not use_hardware_cursor:
		_setup_process_callback()

## Sets custom textures for the cursor system
## @param textures Dictionary mapping cursor types to textures
func set_cursor_textures(textures: Dictionary) -> void:
	cursor_data.set_textures(textures)
	# Update current cursor with new texture
	_update_cursor_visual()

## Sets the cursor offset (hotspot position)
## @param offset Vector2 representing the offset from the top-left corner
func set_cursor_offset(offset: Vector2) -> void:
	cursor_data.cursor_offset = offset
	_update_cursor_visual()

func set_cursor(type: CursorTypes.Type) -> void:
	if current_cursor_type == type:
		return
		
	current_cursor_type = type
	cursor_data.type = type
	
	_update_cursor_visual()
	cursor_changed.emit(type)

func _update_cursor_visual() -> void:
	if use_hardware_cursor:
		_update_hardware_cursor()
	else:
		_update_custom_cursor()

func set_cursor_data(data: Dictionary) -> void:
	cursor_data.update(data)
	cursor_data_updated.emit(cursor_data)

func get_cursor_data() -> CursorData:
	return cursor_data

func set_cursor_visibility(visible: bool) -> void:
	cursor_visible = visible
	
	if use_hardware_cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_HIDDEN)
	elif _custom_cursor_sprite:
		_custom_cursor_sprite.visible = visible

func _setup_hardware_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_update_hardware_cursor()

func _setup_custom_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Create a sprite and add it to the root viewport
	if not _custom_cursor_sprite:
		_custom_cursor_sprite = Sprite2D.new()
		_custom_cursor_sprite.name = "CustomCursor"
		_custom_cursor_sprite.z_index = 100  # Ensure it's on top
		
		# Wait until tree is ready, then add sprite
		_ensure_viewport_available(func():
			var viewport = Engine.get_main_loop().root
			viewport.call_deferred("add_child", _custom_cursor_sprite)
		)
	
	_update_custom_cursor()

func _update_hardware_cursor() -> void:
	if cursor_data.has_texture_for(current_cursor_type):
		# Use custom texture
		var texture = cursor_data.get_texture(current_cursor_type)
		if texture:
			Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, cursor_data.cursor_offset)
	else:
		# Reset to default system cursor
		Input.set_custom_mouse_cursor(null)

func _update_custom_cursor() -> void:
	if _custom_cursor_sprite:
		if cursor_data.has_texture_for(current_cursor_type):
			_custom_cursor_sprite.texture = cursor_data.get_texture(current_cursor_type)
			_custom_cursor_sprite.visible = cursor_visible
		else:
			# Hide custom cursor and show system cursor for types without custom textures
			_custom_cursor_sprite.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Set up a process callback for custom cursor movement
func _setup_process_callback() -> void:
	_ensure_viewport_available(func():
		var script = GDScript.new()
		script.source_code = """
extends Node
func _process(_delta):
	CursorManager.get_instance()._update_custom_cursor_position()
"""
		script.reload()
		
		var processor = Node.new()
		processor.name = "CursorUpdateProcessor"
		processor.set_script(script)
		
		var viewport = Engine.get_main_loop().root
		viewport.call_deferred("add_child", processor)
	)

func _update_custom_cursor_position() -> void:
	if _custom_cursor_sprite and cursor_visible and cursor_data.has_texture_for(current_cursor_type):
		_custom_cursor_sprite.global_position = get_viewport().get_mouse_position() + cursor_data.cursor_offset

func _ensure_viewport_available(callback: Callable) -> void:
	# If viewport is available now, call the callback immediately
	if Engine.get_main_loop() and Engine.get_main_loop().root:
		callback.call()
	else:
		# Otherwise, set up a one-shot timer to check later
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = 0.05
		timer.timeout.connect(func():
			if Engine.get_main_loop() and Engine.get_main_loop().root:
				callback.call()
			else:
				# Try again
				timer.start()
		)
		timer.start()

func get_viewport() -> Viewport:
	return Engine.get_main_loop().root
