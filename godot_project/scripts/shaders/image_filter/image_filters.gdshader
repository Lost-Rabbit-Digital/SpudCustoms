shader_type canvas_item;

// A shader that provides controls for brightness, contrast, and saturation adjustment.
//
// This shader is optimized for SubViewportContainer to apply color adjustments
// to an entire viewport's contents. It can also be used on any CanvasItem
// (Sprite2D, TextureRect, etc.) as needed.

// Uniform variables exposed to the inspector
uniform float brightness : hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float contrast : hint_range(0.0, 3.0, 0.01) = 1.0;
uniform float saturation : hint_range(0.0, 3.0, 0.01) = 1.0;

// Fragment shader function
void fragment() {
	// Sample the texture
	vec4 color = texture(TEXTURE, UV);

	// Apply brightness adjustment
	// Values > 0 increase brightness, < 0 decrease brightness
	vec3 adjusted = color.rgb + vec3(brightness);

	// Apply contrast adjustment
	// First normalize around 0.5, then apply contrast, then shift back
	adjusted = ((adjusted - 0.5) * contrast) + 0.5;

	// Apply saturation adjustment
	// Convert to grayscale using luminance values
	float gray = dot(adjusted, vec3(0.299, 0.587, 0.114));

	// Mix between grayscale and color based on saturation
	// saturation = 0.0 gives grayscale, saturation = 1.0 gives original, > 1.0 increases saturation
	adjusted = mix(vec3(gray), adjusted, saturation);

	// Ensure color values stay in valid range
	adjusted = clamp(adjusted, 0.0, 1.0);

	// Set the final color with original alpha
	COLOR = vec4(adjusted, color.a);
}