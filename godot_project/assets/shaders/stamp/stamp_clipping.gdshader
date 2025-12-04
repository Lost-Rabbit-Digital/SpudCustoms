shader_type canvas_item;

// Document bounds in local coordinates (relative to stamp position)
// x = left offset, y = top offset, z = right offset, w = bottom offset
uniform vec4 clip_bounds = vec4(-100.0, -100.0, 100.0, 100.0);

// Enable/disable clipping
uniform bool clipping_enabled = true;

// Soft edge fade (0 = hard clip, higher = softer edge)
uniform float edge_softness : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	if (!clipping_enabled) {
		COLOR = tex_color;
	} else {
		// Get the pixel position relative to the stamp center
		// UV goes 0-1, we need to convert to local space based on texture size
		vec2 texture_size = vec2(textureSize(TEXTURE, 0));
		vec2 local_pos = (UV - 0.5) * texture_size;

		// Calculate distance from each edge
		float left_dist = local_pos.x - clip_bounds.x;
		float top_dist = local_pos.y - clip_bounds.y;
		float right_dist = clip_bounds.z - local_pos.x;
		float bottom_dist = clip_bounds.w - local_pos.y;

		// Find minimum distance to any edge
		float min_dist = min(min(left_dist, right_dist), min(top_dist, bottom_dist));

		// Apply soft edge or hard clip
		float alpha_multiplier = 1.0;
		if (edge_softness > 0.0) {
			alpha_multiplier = smoothstep(0.0, edge_softness, min_dist);
		} else {
			alpha_multiplier = step(0.0, min_dist);
		}

		COLOR = vec4(tex_color.rgb, tex_color.a * alpha_multiplier);
	}
}
