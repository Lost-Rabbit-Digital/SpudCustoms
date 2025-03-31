shader_type canvas_item;

// Customizable properties for the highlight effect
uniform vec4 highlight_color : source_color = vec4(1.0, 0.8, 0.2, 0.8); // Golden glow
uniform float pulse_speed : hint_range(0.0, 10.0) = 6.0;
uniform bool enable_highlight = false;

void fragment() {
    // Get original pixel color from the sprite texture
    vec4 original = texture(TEXTURE, UV);
    
    // Only process non-transparent pixels
    if (original.a > 0.1) {
        // Create the highlighted color
        vec4 final_color = original;
        
        // Calculate pulsing effect - more pronounced
        float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5);
        
        if (enable_highlight) {
            // Apply a stronger mix - 90% toward highlight color at peak
            final_color = mix(original, highlight_color, pulse * 0.9);
        }
        
        // Keep original alpha to preserve sprite shape
        final_color.a = original.a;
        
        // Output the final color
        COLOR = final_color;
    } else {
        // For fully transparent pixels, just output the original
        COLOR = original;
    }
}