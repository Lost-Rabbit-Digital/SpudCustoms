shader_type canvas_item;

// Animation parameters
uniform float wind_speed : hint_range(0.1, 5.0) = 1.0;  // Speed of the shift animation
uniform int pixel_offset = 1;  // Exact number of pixels to shift (use integer for perfect snapping)
uniform bool individual_blades = true;  // Enable for more individualized movement

// Pseudo-random function for variety
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

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
        // Determine timing offset for individual blades
        float time_offset = 0.0;
        if (individual_blades) {
            // Group pixels horizontally as "blades"
            int blade_index = int(pixel_coords.x / 2);  // Every 2 pixels is one "blade"
            time_offset = random(vec2(float(blade_index), 0.0)) * 6.28;
        }
        
        // Calculate discrete state (0 or 1) using step function
        float shift_state = step(0.5, 0.5 + 0.5 * sin(TIME * wind_speed + time_offset));
        
        // Calculate exact pixel shift (either -pixel_offset or +pixel_offset)
        int x_shift = shift_state > 0.5 ? pixel_offset : -pixel_offset;
        
        // Apply pixel-perfect shift by modifying pixel coordinates
        ivec2 shifted_coords = ivec2(pixel_coords.x + x_shift, pixel_coords.y);
        
        // Convert back to UV coordinates
        shifted_uv = vec2(shifted_coords) * pixel_size;
    }
    
    // Sample the texture at the appropriate position (shifted or original)
    COLOR = texture(TEXTURE, shifted_uv);
}