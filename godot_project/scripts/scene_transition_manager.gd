# scene_transition_manager.gd
extends Node

# Signal when transition is complete
signal transition_completed

# Reference to a full-screen fade rectangle
var fade_rect: ColorRect

func _ready():
	# Create the fade rect as a child of a CanvasLayer to ensure it covers everything
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 128
	add_child(canvas_layer)
	
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.anchors_preset = Control.PRESET_FULL_RECT
	canvas_layer.add_child(fade_rect)

# Transition to a new scene with fade
func transition_to_scene(scene_path: String):
	# Fade out
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.5)
	await fade_tween.finished
	
	# Load new scene
	if scene_path.ends_with(".tscn"):
		# Direct scene change
		get_tree().change_scene_to_file(scene_path)
	else:
		# Try to use instantiated PackedScene
		var new_scene = load(scene_path).instantiate()
		
		# Get the current scene and replace it
		var root = get_tree().root
		var current_scene = get_tree().current_scene
		
		root.remove_child(current_scene)
		current_scene.queue_free()
		
		root.add_child(new_scene)
		get_tree().current_scene = new_scene
	
	# Fade back in
	fade_tween = create_tween()
	fade_tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.5)
	await fade_tween.finished
	
	emit_signal("transition_completed")

# Reload the current scene
func reload_current_scene():
	transition_to_scene(get_tree().current_scene.scene_file_path)
