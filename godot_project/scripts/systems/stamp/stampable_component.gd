class_name StampableComponent
extends Node

# Signal when stamped
signal stamped(stamp_component)
signal stamp_applied(stamp_component, is_perfect)

# Reference to the document node that can be stamped
var document_node: Node2D
var open_content_node: Node
var active_stamps: Array[StampComponent] = []

# Valid stamp area - this defines where stamps should be placed for a "perfect" stamp
var stamp_area_rect: Rect2
var z_index_for_stamps: int = 0  # The z-index to use for stamps


func _init(doc_node: Node2D, content_node: Node, stamp_area: Rect2 = Rect2()):
	document_node = doc_node
	open_content_node = content_node
	stamp_area_rect = stamp_area


# Apply a stamp to this document
func apply_stamp(stamp_component: StampComponent, position: Vector2) -> bool:
	print("Applying stamp at position: ", position)
	if not is_valid_stamp_position(position):
		print("Invalid stamp position!")
		return false

	# Remove any existing stamps of the opposite type
	# If stamping approve, remove reject stamps; if stamping reject, remove approve stamps
	var opposite_type = "reject" if stamp_component.stamp_type == "approve" else "approve"
	var stamps_to_remove = []

	for stamp in active_stamps:
		if stamp.stamp_type == opposite_type:
			stamps_to_remove.append(stamp)

	# Remove opposite stamps from array
	for stamp in stamps_to_remove:
		active_stamps.erase(stamp)

	# Remove opposite stamp sprites from document
	for child in open_content_node.get_children():
		if child is Sprite2D and child.texture:
			var texture_path = ""
			if child.texture.resource_path:
				texture_path = child.texture.resource_path.to_lower()

			# Check if this sprite is the opposite stamp type
			var is_opposite_stamp = false
			if opposite_type == "approve":
				is_opposite_stamp = "approve" in texture_path or "approved" in texture_path
			else:
				is_opposite_stamp = "reject" in texture_path or "denied" in texture_path

			if is_opposite_stamp:
				print("Removing opposite stamp type: ", texture_path)
				child.queue_free()

	# Convert position to be relative to open content node
	var relative_pos = document_node.to_local(position)
	relative_pos = open_content_node.get_transform().affine_inverse() * relative_pos

	# Create stamp sprite
	var stamp_sprite = create_stamp_sprite(stamp_component, relative_pos)

	# Check if this is a "perfect" stamp
	var perfect = is_perfect_stamp_position(position)
	stamp_component.is_perfect = perfect

	# Store the stamp component
	active_stamps.append(stamp_component)

	# Emit signal
	emit_signal("stamped", stamp_component)
	emit_signal("stamp_applied", stamp_component, perfect)

	print("Stamp created successfully!")
	return true


# Check if a position is valid for stamping
func is_valid_stamp_position(position: Vector2) -> bool:
	# Convert position to document local space
	var local_pos = document_node.to_local(position)

	# Check if within document bounds
	var rect = document_node.get_rect()
	return rect.has_point(local_pos)


# Check if this is a "perfect" stamp position
func is_perfect_stamp_position(position: Vector2) -> bool:
	if stamp_area_rect.size == Vector2.ZERO:
		return false  # No perfect area defined

	# Get document rect in global space
	var doc_rect = document_node.get_rect()
	var global_doc_rect = Rect2(document_node.global_position - doc_rect.size / 2, doc_rect.size)

	# Define perfect area (top 1/3 and center 1/3)
	var perfect_width = global_doc_rect.size.x / 3
	var perfect_height = global_doc_rect.size.y / 3

	var perfect_area = Rect2(
		global_doc_rect.position.x + perfect_width,  # Start at 1/3 from left
		global_doc_rect.position.y,  # Start at top
		perfect_width,  # 1/3 of width
		perfect_height  # 1/3 of height
	)

	# Get stamp rect - assuming 50x50 for stamp size
	# Half stamp size
	# Stamp size
	var stamp_rect = Rect2(position - Vector2(25, 25), Vector2(50, 50))

	# Get overlap area as percentage
	var overlap_area = stamp_rect.intersection(perfect_area).get_area()
	var stamp_area = stamp_rect.get_area()

	var accuracy = overlap_area / stamp_area

	# Return true if within 10% of perfect placement
	return abs(1.0 - accuracy) <= 0.1


# Clear all stamps from the document
func clear_stamps():
	print("Attempting to clear stamps from document")
	# Add this temporarily at the beginning of clear_stamps() to debug
	print("open_content_node children count:", open_content_node.get_child_count())
	for child in open_content_node.get_children():
		if child is Sprite2D and child.texture:
			print(
				"Child sprite texture:",
				child.texture.resource_path if child.texture.resource_path else "no path"
			)

	# Safety check
	if not open_content_node:
		push_error("Cannot clear stamps: open_content_node is null")
		return

	var stamps_found = 0

	# Look for and remove all stamp sprites
	for child in open_content_node.get_children():
		if child is Sprite2D:
			# More reliable check using resource_path if available
			var texture_path = ""
			if child.texture and child.texture.resource_path:
				texture_path = child.texture.resource_path.to_lower()

			# Check if it's a stamp using multiple potential identifiers
			if (
				"stamp" in texture_path
				or "approved" in texture_path
				or "denied" in texture_path
				or "approve" in texture_path
				or "reject" in texture_path
			):
				print("Found stamp to remove: ", texture_path)
				stamps_found += 1
				child.queue_free()

	# Clear the tracked stamps array
	active_stamps.clear()

	print("Cleared ", stamps_found, " stamps from document")

	# Force update visual representation if needed
	if open_content_node.has_method("update"):
		open_content_node.update()


# Preload the clipping shader
const STAMP_CLIPPING_SHADER = preload("res://assets/shaders/stamp/stamp_clipping.gdshader")


# Create the visual stamp sprite
func create_stamp_sprite(stamp: StampComponent, position: Vector2) -> Sprite2D:
	var texture_path: String

	# Set texture based on stamp type
	if stamp.stamp_type == "approve":
		texture_path = "res://assets/stamps/approved_stamp.png"
	else:  # reject
		texture_path = "res://assets/stamps/denied_stamp.png"

	var final_stamp = Sprite2D.new()
	final_stamp.texture = load(texture_path)
	final_stamp.position = position
	final_stamp.modulate.a = 0  # Start invisible
	final_stamp.z_index = z_index_for_stamps
	final_stamp.z_as_relative = true

	# Apply viewport clipping to keep stamp within document bounds
	_apply_clipping_shader(final_stamp, position)

	# Apply colorblind mode adjustments if enabled
	_apply_colorblind_style(final_stamp, stamp.stamp_type)

	# Add stamp to document
	open_content_node.add_child(final_stamp)

	# Fade in the stamp
	var tween = final_stamp.create_tween()
	tween.tween_property(final_stamp, "modulate:a", 1.0, 0.1)

	return final_stamp


## Apply viewport clipping shader to keep stamps within document bounds.
## Prevents stamps from visually extending beyond the document edges.
func _apply_clipping_shader(stamp_sprite: Sprite2D, stamp_position: Vector2) -> void:
	# Use open_content_node bounds if it's a Sprite2D, otherwise fall back to document_node
	var clip_source: Sprite2D = null
	if open_content_node is Sprite2D:
		clip_source = open_content_node as Sprite2D
	elif document_node is Sprite2D:
		clip_source = document_node as Sprite2D

	if not clip_source:
		push_warning("StampableComponent: Cannot apply clipping - no Sprite2D source found")
		return

	# Get the content bounds in local space
	var content_rect = clip_source.get_rect()

	# Calculate clipping bounds relative to stamp position
	# Stamps are positioned relative to open_content_node
	# We need to determine how much of the stamp should be visible based on document edges

	# Get the content half-size (Sprite2D is centered by default)
	var half_size = content_rect.size / 2.0

	# Calculate clip bounds relative to stamp position
	# These values represent how far the stamp can extend in each direction
	# before it should be clipped
	var clip_left = -stamp_position.x - half_size.x
	var clip_top = -stamp_position.y - half_size.y
	var clip_right = half_size.x - stamp_position.x
	var clip_bottom = half_size.y - stamp_position.y

	# Create shader material
	var shader_material = ShaderMaterial.new()
	shader_material.shader = STAMP_CLIPPING_SHADER
	shader_material.set_shader_parameter("clip_bounds", Vector4(clip_left, clip_top, clip_right, clip_bottom))
	shader_material.set_shader_parameter("clipping_enabled", true)
	shader_material.set_shader_parameter("edge_softness", 2.0)

	stamp_sprite.material = shader_material


## Apply colorblind-friendly styling to a stamp sprite.
## Adds color tinting and pattern overlay when colorblind mode is active.
func _apply_colorblind_style(stamp_sprite: Sprite2D, stamp_type: String) -> void:
	# Check if AccessibilityManager exists and colorblind mode is enabled
	# Use Engine.get_main_loop() to access root when not in scene tree
	var accessibility: Node = null
	if is_inside_tree():
		accessibility = get_node_or_null("/root/AccessibilityManager")
	else:
		var main_loop = Engine.get_main_loop()
		if main_loop and main_loop is SceneTree:
			accessibility = main_loop.root.get_node_or_null("AccessibilityManager")
	if not accessibility:
		return

	if accessibility.current_colorblind_mode == accessibility.ColorblindMode.NONE:
		return

	# Apply colorblind-friendly color tinting
	var tint_color: Color
	if stamp_type == "approve":
		tint_color = accessibility.get_approval_color()
	else:
		tint_color = accessibility.get_rejection_color()

	# Apply a subtle tint while preserving the stamp texture
	stamp_sprite.modulate = tint_color * Color(1.2, 1.2, 1.2, 1.0)

	# Add pattern indicator for additional differentiation
	var pattern_type = ""
	if stamp_type == "approve":
		pattern_type = accessibility.get_approval_pattern()
	else:
		pattern_type = accessibility.get_rejection_pattern()

	if pattern_type != "none":
		_add_pattern_indicator(stamp_sprite, pattern_type, stamp_type)


## Add a small pattern indicator to the stamp for colorblind users.
## Uses shape patterns (stripes for approve, dots for reject) alongside color.
func _add_pattern_indicator(stamp_sprite: Sprite2D, pattern_type: String, stamp_type: String) -> void:
	# Create a small indicator in the corner of the stamp
	var indicator = Node2D.new()
	indicator.name = "ColorblindIndicator"

	var indicator_size = 12.0
	var offset = Vector2(-20, -20)  # Top-left corner offset

	if pattern_type == "stripes":
		# Draw diagonal stripes for approval
		for i in range(3):
			var line = Line2D.new()
			line.width = 2.0
			line.default_color = Color.WHITE
			var start_offset = i * 4.0
			line.add_point(Vector2(start_offset, 0) + offset)
			line.add_point(Vector2(start_offset + indicator_size, indicator_size) + offset)
			indicator.add_child(line)
	elif pattern_type == "dots":
		# Draw dots pattern for rejection
		for i in range(3):
			for j in range(3):
				var dot = Polygon2D.new()
				dot.color = Color.WHITE
				# Create a small circle using polygon points
				var points = PackedVector2Array()
				var dot_radius = 1.5
				for k in range(8):
					var angle = k * PI * 2 / 8
					points.append(Vector2(cos(angle), sin(angle)) * dot_radius)
				dot.polygon = points
				dot.position = Vector2(i * 5.0, j * 5.0) + offset
				indicator.add_child(dot)

	stamp_sprite.add_child(indicator)


# Get all stamps of a specific type
func get_stamps_by_type(type: String) -> Array[StampComponent]:
	var result: Array[StampComponent] = []

	for stamp in active_stamps:
		if stamp.stamp_type == type:
			result.append(stamp)

	return result


# Does this document have any stamps?
func has_stamps() -> bool:
	return active_stamps.size() > 0


# Does this document have an approval stamp?
func has_approval_stamp() -> bool:
	for stamp in active_stamps:
		if stamp.stamp_type == "approve":
			return true
	return false


# Does this document have a rejection stamp?
func has_rejection_stamp() -> bool:
	for stamp in active_stamps:
		if stamp.stamp_type == "reject":
			return true
	return false


# Get the decision based on stamps
func get_decision() -> String:
	if has_approval_stamp():
		return "approved"
	if has_rejection_stamp():
		return "rejected"
	return ""


# Add this function to visualize the stamp area
func visualize_stamp_area():
	var debug_rect = ColorRect.new()
	debug_rect.color = Color(1, 0, 0, 0.3)  # Semi-transparent red
	debug_rect.global_position = stamp_area_rect.position
	debug_rect.size = stamp_area_rect.size
	debug_rect.z_index = 100  # Make sure it's visible above everything

	# Add to the scene root to ensure it's visible
	var scene_root = Engine.get_main_loop().get_current_scene()
	scene_root.add_child(debug_rect)

	print("Added visualization of stamp area at global pos: ", debug_rect.global_position)
	print("With size: ", debug_rect.size)

	# Remove after 5 seconds
	var timer = Timer.new()
	scene_root.add_child(timer)
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.timeout.connect(
		func():
			debug_rect.queue_free()
			timer.queue_free()
	)
	timer.start()
