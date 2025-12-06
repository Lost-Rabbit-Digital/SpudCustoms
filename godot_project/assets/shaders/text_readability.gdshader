shader_type canvas_item;

// Text Readability Shader
// Creates a darkened backdrop and subtle glow effect behind UI text
// Designed to improve text visibility over busy backgrounds during tutorials

// Background darkening
uniform float backdrop_opacity : hint_range(0.0, 1.0) = 0.7;
uniform vec4 backdrop_color : source_color = vec4(0.0, 0.0, 0.05, 1.0);
uniform float backdrop_padding : hint_range(0.0, 0.5) = 0.15;
uniform float backdrop_softness : hint_range(0.0, 0.5) = 0.1;
uniform float backdrop_corner_radius : hint_range(0.0, 0.5) = 0.2;

// Glow effect for emphasis
uniform bool enable_glow = true;
uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.6, 1.0);
uniform float glow_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float glow_pulse_speed : hint_range(0.0, 5.0) = 1.5;
uniform float glow_pulse_amount : hint_range(0.0, 1.0) = 0.3;

// Master toggle
uniform bool enable_effect = true;

// Calculate rounded rectangle SDF
float rounded_rect_sdf(vec2 uv, vec2 size, float radius) {
	vec2 d = abs(uv - 0.5) * size - size * 0.5 + radius;
	return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0) - radius;
}

void fragment() {
	vec4 base_texture = texture(TEXTURE, UV);

	if (!enable_effect) {
		COLOR = base_texture;
		return;
	}

	// Calculate backdrop shape with padding (inverse UV expansion)
	// We want the backdrop to extend beyond the text, so we use padded coordinates
	vec2 padded_uv = (UV - 0.5) * (1.0 + backdrop_padding * 2.0) + 0.5;

	// Use the control's aspect ratio for proper rounded corners
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	float aspect = texture_size.x / texture_size.y;
	vec2 adjusted_size = vec2(1.0, 1.0 / aspect);

	// Calculate rounded rectangle distance for backdrop
	float corner_radius = backdrop_corner_radius * min(adjusted_size.x, adjusted_size.y);
	float dist = rounded_rect_sdf(padded_uv, adjusted_size, corner_radius);

	// Create soft-edged backdrop
	float backdrop_mask = 1.0 - smoothstep(-backdrop_softness, backdrop_softness, dist);

	// Calculate pulsing glow
	float pulse = 1.0;
	if (enable_glow && glow_pulse_speed > 0.0) {
		pulse = 1.0 - glow_pulse_amount + glow_pulse_amount * (0.5 + 0.5 * sin(TIME * glow_pulse_speed * 3.14159));
	}

	// Create glow effect (inner glow that emphasizes edges)
	float glow_dist = rounded_rect_sdf(padded_uv, adjusted_size * 0.9, corner_radius * 0.8);
	float glow_mask = smoothstep(0.0, -0.15, glow_dist) * (1.0 - smoothstep(-0.25, -0.1, glow_dist));

	// Combine backdrop and glow
	vec3 effect_color = backdrop_color.rgb;
	float effect_alpha = backdrop_mask * backdrop_opacity;

	if (enable_glow) {
		// Add glow on top of backdrop
		float glow_strength = glow_mask * glow_intensity * pulse;
		effect_color = mix(effect_color, glow_color.rgb, glow_strength);
		effect_alpha = max(effect_alpha, glow_strength * 0.5);
	}

	// Composite: backdrop first, then text on top
	// We render behind the text by only affecting areas where text alpha is low
	vec3 final_color = mix(effect_color, base_texture.rgb, base_texture.a);
	float final_alpha = max(effect_alpha, base_texture.a);

	COLOR = vec4(final_color, final_alpha);
}
