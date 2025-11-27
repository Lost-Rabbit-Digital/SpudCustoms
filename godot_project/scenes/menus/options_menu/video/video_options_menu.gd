extends VideoOptionsMenu


func _ready():
	super._ready()
	# Connect to camera shake control changes
	# Find the camera shake control
	var camera_shake_control = find_node_by_name(self, "CameraShakeControl")
	if camera_shake_control and camera_shake_control.has_signal("setting_changed"):
		camera_shake_control.connect("setting_changed", _on_camera_shake_setting_changed)


# When camera shake setting changes
func _on_camera_shake_setting_changed(value):
	# Update the global screen shake multiplier
	# Update the global screen shake multiplier
	# REFACTORED: Use UIManager directly
	if UIManager:
		UIManager.update_camera_shake_setting()


# Helper function to find node by name recursively
func find_node_by_name(node, name):
	if node.name == name:
		return node

	for child in node.get_children():
		var found = find_node_by_name(child, name)
		if found:
			return found

	return null
