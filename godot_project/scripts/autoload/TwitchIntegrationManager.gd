extends Node
## Manages Twitch integration for viewer name replacement on potatoes
##
## This system allows streamers to connect their Twitch channel and have
## viewer names appear on potato passports instead of random names.

signal connection_status_changed(is_connected: bool)
signal viewer_added(viewer_name: String)
signal viewer_removed(viewer_name: String)

# Configuration
var twitch_enabled: bool = false
var channel_name: String = ""

# Viewer name pool
var viewer_names: Array[String] = []
var used_viewer_names: Array[String] = []  # Track names currently assigned to potatoes

# Config reference for persistence
var _config_file_path: String = "user://twitch_config.cfg"

# Connection state (for future WebSocket integration)
var is_connected: bool = false

# Reference to config panel scene
var _config_panel_scene: PackedScene = null
var _config_panel_instance: Control = null


func _ready():
	_load_settings()


func _load_settings():
	"""Load Twitch settings from config file"""
	var config = ConfigFile.new()
	var err = config.load(_config_file_path)
	if err == OK:
		twitch_enabled = config.get_value("twitch", "enabled", false)
		channel_name = config.get_value("twitch", "channel_name", "")
		var saved_names = config.get_value("twitch", "viewer_names", [])
		viewer_names.clear()
		for name in saved_names:
			viewer_names.append(name)


func _save_settings():
	"""Save Twitch settings to config file"""
	var config = ConfigFile.new()
	config.set_value("twitch", "enabled", twitch_enabled)
	config.set_value("twitch", "channel_name", channel_name)
	config.set_value("twitch", "viewer_names", viewer_names)
	config.save(_config_file_path)


# ═══════════════════════════════════════════════════════════
# PUBLIC API
# ═══════════════════════════════════════════════════════════


func set_enabled(enabled: bool) -> void:
	"""Enable or disable Twitch integration"""
	twitch_enabled = enabled
	_save_settings()


func is_enabled() -> bool:
	"""Check if Twitch integration is enabled"""
	return twitch_enabled


func set_channel_name(name: String) -> void:
	"""Set the Twitch channel name"""
	channel_name = name.strip_edges().to_lower()
	_save_settings()


func get_channel_name() -> String:
	"""Get the current channel name"""
	return channel_name


func add_viewer(viewer_name: String) -> bool:
	"""Add a viewer name to the pool"""
	var clean_name = viewer_name.strip_edges()
	if clean_name.is_empty():
		return false

	# Don't add duplicates
	if clean_name.to_lower() in viewer_names.map(func(n): return n.to_lower()):
		return false

	viewer_names.append(clean_name)
	_save_settings()
	viewer_added.emit(clean_name)
	return true


func remove_viewer(viewer_name: String) -> bool:
	"""Remove a viewer name from the pool"""
	var idx = -1
	for i in viewer_names.size():
		if viewer_names[i].to_lower() == viewer_name.to_lower():
			idx = i
			break

	if idx >= 0:
		var removed = viewer_names[idx]
		viewer_names.remove_at(idx)
		_save_settings()
		viewer_removed.emit(removed)
		return true
	return false


func clear_all_viewers() -> void:
	"""Clear all viewer names from the pool"""
	viewer_names.clear()
	used_viewer_names.clear()
	_save_settings()


func get_viewer_count() -> int:
	"""Get the number of viewers in the pool"""
	return viewer_names.size()


func get_available_viewer_count() -> int:
	"""Get the number of available (unused) viewer names"""
	return viewer_names.size() - used_viewer_names.size()


func get_next_viewer_name() -> String:
	"""
	Get the next available viewer name for a potato.
	Returns empty string if no viewers available or Twitch is disabled.
	"""
	if not twitch_enabled:
		return ""

	if viewer_names.is_empty():
		return ""

	# Find unused names
	var available: Array[String] = []
	for name in viewer_names:
		if name not in used_viewer_names:
			available.append(name)

	# If all names are used, recycle from the beginning
	if available.is_empty():
		used_viewer_names.clear()
		available = viewer_names.duplicate()

	if available.is_empty():
		return ""

	# Pick a random available name
	var chosen = available[randi() % available.size()]
	used_viewer_names.append(chosen)
	return chosen


func release_viewer_name(name: String) -> void:
	"""Release a viewer name back to the pool (when potato leaves)"""
	var idx = used_viewer_names.find(name)
	if idx >= 0:
		used_viewer_names.remove_at(idx)


func get_all_viewers() -> Array[String]:
	"""Get all viewer names in the pool"""
	return viewer_names.duplicate()


# ═══════════════════════════════════════════════════════════
# CONFIG PANEL MANAGEMENT
# ═══════════════════════════════════════════════════════════


func show_config_panel() -> void:
	"""Show the Twitch configuration panel"""
	if _config_panel_instance and is_instance_valid(_config_panel_instance):
		_config_panel_instance.visible = true
		_config_panel_instance.refresh_ui()
		return

	# Load and instantiate the config panel
	if not _config_panel_scene:
		_config_panel_scene = load("res://scenes/menus/main_menu/twitch_config_menu.tscn")

	if _config_panel_scene:
		_config_panel_instance = _config_panel_scene.instantiate()

		# Add to the current scene tree
		var root = get_tree().current_scene
		if root:
			root.add_child(_config_panel_instance)
			_config_panel_instance.refresh_ui()


func hide_config_panel() -> void:
	"""Hide the Twitch configuration panel"""
	if _config_panel_instance and is_instance_valid(_config_panel_instance):
		_config_panel_instance.visible = false


func is_config_panel_visible() -> bool:
	"""Check if config panel is currently visible"""
	return _config_panel_instance and is_instance_valid(_config_panel_instance) and _config_panel_instance.visible
