# ui_hint_system.gd
class_name UIHintSystem
extends Node

signal hint_activated(node_name: String)
signal hint_deactivated(node_name: String)

# Dictionary to track all hintable nodes
var hint_timers = {}
var hint_threshold = 15.0  # Default threshold in seconds
var hint_shader = preload("res://scripts/shaders/node_highlight/node_highlight.tres")


# Register a node to receive hints
func register_hintable(node: Node, node_name: String, custom_threshold: float = -1.0):
	# Skip if node is invalid
	if !is_instance_valid(node):
		push_warning("Attempted to register invalid node as hintable: " + node_name)
		return

	# Setup the material if needed
	if !node.material:
		node.material = hint_shader.duplicate()

	# Always ensure highlight is disabled initially
	node.material.set_shader_parameter("enable_highlight", false)

	# Register the node with its properties
	hint_timers[node_name] = {
		"node": node,
		"timer": 0.0,
		"threshold": custom_threshold if custom_threshold > 0 else hint_threshold,
		"active": false,
		"enabled": true  # Can be used to temporarily disable hints
	}

	print("Registered hintable UI element: " + node_name)


# Process all hint timers - call this from _process
func process_hints(delta: float):
	for name in hint_timers.keys():
		var hint = hint_timers[name]

		# Skip if node is no longer valid or hints are disabled
		if !is_instance_valid(hint.node) or !hint.enabled:
			continue

		# Update timer
		hint.timer += delta

		# Check if we should activate the hint
		if hint.timer >= hint.threshold and !hint.active:
			activate_hint(name)


# Activate the hint on a specific node
func activate_hint(name: String):
	if !hint_timers.has(name):
		return

	var hint = hint_timers[name]
	if !hint.active and is_instance_valid(hint.node) and hint.enabled:
		hint.node.material.set_shader_parameter("enable_highlight", true)
		hint.active = true
		emit_signal("hint_activated", name)
		print("Hint activated: " + name)


# Deactivate the hint on a specific node
func deactivate_hint(name: String):
	if !hint_timers.has(name):
		return

	var hint = hint_timers[name]
	if hint.active and is_instance_valid(hint.node):
		hint.node.material.set_shader_parameter("enable_highlight", false)
		hint.active = false
		emit_signal("hint_deactivated", name)
		print("Hint deactivated: " + name)


# Reset the timer on a specific node
func reset_timer(name: String):
	if hint_timers.has(name):
		hint_timers[name].timer = 0.0
		deactivate_hint(name)


# Enable or disable hints for a specific node
func set_hint_enabled(name: String, enabled: bool):
	if hint_timers.has(name):
		hint_timers[name].enabled = enabled
		if !enabled:
			deactivate_hint(name)


# Enable or disable all hints
func set_all_hints_enabled(enabled: bool):
	for name in hint_timers.keys():
		set_hint_enabled(name, enabled)


# Check if a hint is currently active
func is_hint_active(name: String) -> bool:
	return hint_timers.has(name) and hint_timers[name].active


# Update the threshold for a specific hint
func set_hint_threshold(name: String, new_threshold: float):
	if hint_timers.has(name):
		hint_timers[name].threshold = new_threshold
