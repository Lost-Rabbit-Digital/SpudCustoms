shader_type canvas_item;

uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	vec2 uv = UV;
	vec2 center = vec2(0.5, 0.5);
	float dist = distance(uv, center);

	// Calculate vignette based on distance from center
	float vignette = smoothstep(vignette_intensity, vignette_intensity + vignette_softness, dist);

	// Apply vignette color with opacity
	COLOR = vec4(vignette_color.rgb, vignette * vignette_opacity);
}
