shader_type canvas_item;

// Animation parameters
uniform float wave_speed : hint_range(0.1, 5.0) = 1.0;  // Speed of the wave movement
uniform int pixel_offset = 1;  // Exact number of pixels to shift (use integer for perfect snapping)
uniform float wave_width : hint_range(0.1, 10.0) = 3.0;  // Width of the wave (lower = wider wave)

void fragment() {
    // Get exact pixel size
    vec2 pixel_size = TEXTURE_PIXEL_SIZE;
    
    // Get the current pixel position
    vec2 uv = UV;
    
    // Calculate current pixel coordinates
    ivec2 pixel_coords = ivec2(floor(uv / pixel_size));
    
    // Height factor - only upper pixels move
    float height_factor = 1.0 - uv.y;
    
    // Initialize shifted_uv with original uv
    vec2 shifted_uv = uv;
    
    // Only apply movement to upper portion
    if (height_factor >= 0.3) {
        // Calculate wave position - this creates a wave that travels across the X axis
        float wave_position = mod(TIME * wave_speed, 2.0) - 1.0; // -1 to 1 range
        
        // Distance from current pixel to the wave center
        float distance_from_wave = abs(wave_position - uv.x);
        
        // Wave influence (strongest at center, fades with distance)
        float wave_influence = max(0.0, 1.0 - distance_from_wave * wave_width);
        wave_influence = smoothstep(0.0, 1.0, wave_influence); // Smooth falloff
        
        // Calculate intensity of the shift based on wave and height
        float shift_intensity = wave_influence * height_factor;
        
        // Convert to pixel offset (-pixel_offset to +pixel_offset)
        // Using round() for pixel-perfect snapping
        int x_shift = int(round(shift_intensity * float(pixel_offset)));
        
        // Apply pixel-perfect shift
        ivec2 shifted_coords = ivec2(pixel_coords.x + x_shift, pixel_coords.y);
        
        // Convert back to UV coordinates
        shifted_uv = vec2(shifted_coords) * pixel_size;
    }
    
    // Sample the texture at the shifted position
    COLOR = texture(TEXTURE, shifted_uv);
}