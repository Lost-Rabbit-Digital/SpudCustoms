shader_type canvas_item;

// Interval controls how often the color changes (in seconds)
uniform float interval : hint_range(0.1, 5.0) = 1.0;

// Randomness factor (0.0 = no randomness, 1.0 = fully random)
uniform float randomness : hint_range(0.0, 1.0) = 0.5;

// Smoothness of transition (lower = more pixelated/discrete changes)
uniform float smoothness : hint_range(0.0, 1.0) = 0.2;

void fragment() {
    // Get current pixel color
    vec4 current_color = texture(TEXTURE, UV);
    
    // Define the color to replace (332B3D - dark purple)
    vec3 old_color = vec3(0.2, 0.169, 0.239);
    
    // Define the replacement color (9E8212 - mustard gold)
    vec3 new_color = vec3(0.619, 0.51, 0.071);
    
    // Define threshold for color matching
    float threshold = 0.05;
    
    // Only process if current pixel is close to the color we want to replace
    if (length(current_color.rgb - old_color) < threshold) {
        // Create different random patterns based on position and time
        float random_offset = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453);
        
        // Calculate time-based factor for interval
        float time_factor = floor(TIME / interval) + 
                           smoothstep(0.0, smoothness, fract(TIME / interval));
        
        // Combine position and time for final random value
        float random_value = fract(random_offset + time_factor);
        
        // Apply randomness factor
        random_value = mix(0.0, random_value, randomness);
        
        // Determine if this pixel should change color
        if (random_value > 0.5) {
            // Change to new color
            COLOR = vec4(new_color, current_color.a);
        } else {
            // Keep original color
            COLOR = current_color;
        }
    } else {
        // Not the target color, keep original
        COLOR = current_color;
    }
}