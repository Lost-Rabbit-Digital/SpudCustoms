extends Node
## Manages Twitch integration for viewer name replacement on potatoes
##
## This system connects to Twitch IRC anonymously to collect viewer names
## from chat and use them on potato passports instead of random names.

signal connection_status_changed(is_connected: bool)
signal viewer_added(viewer_name: String)
signal viewer_removed(viewer_name: String)
signal chat_message_received(username: String, message: String)

# Configuration
var twitch_enabled: bool = false
var channel_name: String = ""

# Viewer name pool
var viewer_names: Array[String] = []
var used_viewer_names: Array[String] = []  # Track names currently assigned to potatoes

# Config reference for persistence
var _config_file_path: String = "user://twitch_config.cfg"

# IRC Connection
const TWITCH_IRC_URL = "wss://irc-ws.chat.twitch.tv:443"
var _websocket: WebSocketPeer = null
var is_connected: bool = false
var _reconnect_timer: float = 0.0
var _reconnect_delay: float = 5.0
var _should_reconnect: bool = false
var _ping_timer: float = 0.0
var _ping_interval: float = 60.0  # Send PING every 60 seconds to keep connection alive

# Reference to config panel scene
var _config_panel_scene: PackedScene = null
var _config_panel_instance: Control = null

# Max viewers to store (prevent unbounded growth)
const MAX_VIEWER_POOL_SIZE = 500


func _ready():
	_load_settings()
	# Auto-connect if enabled and channel is set
	if twitch_enabled and not channel_name.is_empty():
		connect_to_channel()


func _process(delta):
	if _websocket:
		_websocket.poll()

		var state = _websocket.get_ready_state()
		match state:
			WebSocketPeer.STATE_OPEN:
				if not is_connected:
					is_connected = true
					connection_status_changed.emit(true)
					_authenticate()

				# Handle incoming messages
				while _websocket.get_available_packet_count() > 0:
					var packet = _websocket.get_packet()
					var message = packet.get_string_from_utf8()
					_handle_irc_message(message)

				# Keep-alive ping
				_ping_timer += delta
				if _ping_timer >= _ping_interval:
					_ping_timer = 0.0
					_send_raw("PING :tmi.twitch.tv")

			WebSocketPeer.STATE_CLOSING:
				pass  # Wait for close

			WebSocketPeer.STATE_CLOSED:
				if is_connected:
					is_connected = false
					connection_status_changed.emit(false)
					var code = _websocket.get_close_code()
					var reason = _websocket.get_close_reason()
					DebugLogger.log("Twitch IRC disconnected: %d - %s" % [code, reason])

				_websocket = null
				if _should_reconnect:
					_reconnect_timer = _reconnect_delay

	# Handle reconnection
	if _should_reconnect and _websocket == null and _reconnect_timer > 0:
		_reconnect_timer -= delta
		if _reconnect_timer <= 0:
			connect_to_channel()


func _load_settings():
	"""Load Twitch settings from config file"""
	var config = ConfigFile.new()
	var err = config.load(_config_file_path)
	if err == OK:
		twitch_enabled = config.get_value("twitch", "enabled", false)
		channel_name = config.get_value("twitch", "channel_name", "")
		# Note: We don't save viewer names anymore - they're collected from chat


func _save_settings():
	"""Save Twitch settings to config file"""
	var config = ConfigFile.new()
	config.set_value("twitch", "enabled", twitch_enabled)
	config.set_value("twitch", "channel_name", channel_name)
	config.save(_config_file_path)


# ═══════════════════════════════════════════════════════════
# IRC CONNECTION
# ═══════════════════════════════════════════════════════════


func connect_to_channel() -> void:
	"""Connect to Twitch IRC for the configured channel"""
	if channel_name.is_empty():
		DebugLogger.warning("TwitchIntegrationManager: No channel name set")
		return

	if _websocket != null:
		disconnect_from_channel()

	DebugLogger.log("TwitchIntegrationManager: Connecting to Twitch IRC...")

	_websocket = WebSocketPeer.new()
	var err = _websocket.connect_to_url(TWITCH_IRC_URL)

	if err != OK:
		DebugLogger.error("TwitchIntegrationManager: Failed to connect to Twitch IRC: %d" % err)
		_websocket = null
		_should_reconnect = true
		_reconnect_timer = _reconnect_delay
	else:
		_should_reconnect = true


func disconnect_from_channel() -> void:
	"""Disconnect from Twitch IRC"""
	_should_reconnect = false
	if _websocket:
		_websocket.close()
		_websocket = null
	is_connected = false
	connection_status_changed.emit(false)


func _authenticate():
	"""Send anonymous authentication to Twitch IRC"""
	# Use anonymous login with justinfan username
	var random_id = randi() % 99999
	_send_raw("CAP REQ :twitch.tv/tags twitch.tv/commands")
	_send_raw("PASS SCHMOOPIIE")
	_send_raw("NICK justinfan%d" % random_id)

	# Join the channel
	_send_raw("JOIN #%s" % channel_name.to_lower())
	DebugLogger.log("TwitchIntegrationManager: Joined #%s" % channel_name)


func _send_raw(message: String):
	"""Send a raw IRC message"""
	if _websocket and _websocket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_websocket.send_text(message + "\r\n")


func _handle_irc_message(raw_message: String):
	"""Parse and handle incoming IRC messages"""
	# IRC messages can contain multiple lines
	var lines = raw_message.split("\r\n", false)

	for line in lines:
		if line.is_empty():
			continue

		# Handle PING
		if line.begins_with("PING"):
			_send_raw("PONG :tmi.twitch.tv")
			continue

		# Parse PRIVMSG for usernames
		if "PRIVMSG" in line:
			var parsed = _parse_privmsg(line)
			if parsed.has("username") and parsed.has("message"):
				_on_chat_message(parsed.username, parsed.message)


func _parse_privmsg(line: String) -> Dictionary:
	"""Parse a PRIVMSG IRC line to extract username and message"""
	var result = {}

	# Format: @tags :username!username@username.tmi.twitch.tv PRIVMSG #channel :message
	# Or without tags: :username!username@username.tmi.twitch.tv PRIVMSG #channel :message

	var username_start = line.find(":")
	if username_start == -1:
		return result

	# Skip tags if present
	if line.begins_with("@"):
		username_start = line.find(" :")
		if username_start != -1:
			username_start += 1  # Move past the space

	var username_end = line.find("!", username_start)
	if username_end == -1:
		return result

	var username = line.substr(username_start + 1, username_end - username_start - 1)

	# Find the message (after the second colon following PRIVMSG)
	var privmsg_pos = line.find("PRIVMSG")
	if privmsg_pos == -1:
		return result

	var message_start = line.find(":", privmsg_pos)
	if message_start == -1:
		return result

	var message = line.substr(message_start + 1)

	result["username"] = username
	result["message"] = message

	return result


func _on_chat_message(username: String, message: String):
	"""Handle a chat message - add user to viewer pool"""
	chat_message_received.emit(username, message)

	# Add viewer to pool if not already present
	add_viewer(username)


# ═══════════════════════════════════════════════════════════
# PUBLIC API
# ═══════════════════════════════════════════════════════════


func set_enabled(enabled: bool) -> void:
	"""Enable or disable Twitch integration"""
	var was_enabled = twitch_enabled
	twitch_enabled = enabled
	_save_settings()

	if enabled and not was_enabled:
		# Just enabled - connect if channel is set
		if not channel_name.is_empty():
			connect_to_channel()
	elif not enabled and was_enabled:
		# Just disabled - disconnect
		disconnect_from_channel()
		clear_all_viewers()


func is_enabled() -> bool:
	"""Check if Twitch integration is enabled"""
	return twitch_enabled


func set_channel_name(name: String) -> void:
	"""Set the Twitch channel name and reconnect"""
	var old_channel = channel_name
	channel_name = name.strip_edges().to_lower()
	_save_settings()

	# Reconnect if channel changed and enabled
	if twitch_enabled and channel_name != old_channel:
		clear_all_viewers()  # Clear old channel's viewers
		if not channel_name.is_empty():
			connect_to_channel()
		else:
			disconnect_from_channel()


func get_channel_name() -> String:
	"""Get the current channel name"""
	return channel_name


func add_viewer(viewer_name: String) -> bool:
	"""Add a viewer name to the pool"""
	var clean_name = viewer_name.strip_edges()
	if clean_name.is_empty():
		return false

	# Don't add duplicates (case-insensitive check)
	for existing in viewer_names:
		if existing.to_lower() == clean_name.to_lower():
			return false

	# Limit pool size
	if viewer_names.size() >= MAX_VIEWER_POOL_SIZE:
		# Remove oldest viewer to make room
		viewer_names.pop_front()

	viewer_names.append(clean_name)
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
		viewer_removed.emit(removed)
		return true
	return false


func clear_all_viewers() -> void:
	"""Clear all viewer names from the pool"""
	viewer_names.clear()
	used_viewer_names.clear()


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


func is_irc_connected() -> bool:
	"""Check if connected to Twitch IRC"""
	return is_connected


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
