shader_type canvas_item;

// Simplified parameters
uniform float speed = 1.0;  // Controls animation speed

void fragment() {
    // Get exact pixel size
    vec2 pixel_size = TEXTURE_PIXEL_SIZE;

    // Get current UV coordinates
    vec2 uv = UV;

    // Calculate a simple wave effect that moves across all grass
    // Using a single pixel offset (either 0 or 1)
    float wave = sin(TIME * speed + uv.x * 10.0);

    // Snap to exactly 0 or 1 pixel offset
    int pixel_shift = wave > 0.0 ? 1 : 0;

    // Apply the shift
    vec2 shifted_uv = vec2(uv.x + float(pixel_shift) * pixel_size.x, uv.y);

    // Sample texture at the new position
    COLOR = texture(TEXTURE, shifted_uv);
}