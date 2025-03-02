shader_type canvas_item;

// Animation parameters
uniform float wind_speed : hint_range(0.1, 5.0) = 1.0;  // Speed of the shift animation
uniform float wind_strength : hint_range(1.0, 5.0) = 1.0;  // Max pixels of displacement
uniform bool individual_blades = true;  // Enable for more individualized movement

// Pseudo-random function for variety
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // Get texture size to calculate pixel size
    vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
    float pixel_width = 1.0 / texture_size.x;
    
    // Get the current pixel position
    vec2 uv = UV;
    
    // Height factor - top of grass moves more
    float height_factor = pow(1.0 - uv.y, 2.0);
    
    // Calculate simple left-right shift based on time
    // This creates a smoother back-and-forth motion
    float time_offset = 0.0;
    if (individual_blades) {
        // Add variation for individual blades
        int blade_index = int(uv.x * texture_size.x / 4.0);  // Group every 4 pixels as one "blade"
        time_offset = random(vec2(float(blade_index), 0.0)) * 3.14159;
    }
    
    // Simple left-right shifting (using step function for discrete steps)
    float shift_factor = step(0.5, 0.5 + 0.5 * sin(TIME * wind_speed + time_offset));
    
    // Calculate pixel offset
    int pixel_offset = 0;
    
    // Only apply movement to the upper portions
    if (height_factor > 0.2) {
        // Either -1 or 1 pixel based on shift_factor
        pixel_offset = shift_factor > 0.5 ? int(wind_strength) : -int(wind_strength);
    }
    
    // Apply pixel-perfect offset
    vec2 distorted_uv = vec2(uv.x + float(pixel_offset) * pixel_width, uv.y);
    
    // Sample the texture at the new position
    vec4 color = texture(TEXTURE, distorted_uv);
    
    // Output the modified color
    COLOR = color;
}