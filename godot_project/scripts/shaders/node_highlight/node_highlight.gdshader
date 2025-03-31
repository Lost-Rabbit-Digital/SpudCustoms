shader_type canvas_item;

// Customizable properties for the highlight effect
uniform vec4 highlight_color : source_color = vec4(1.0, 0.8, 0.2, 0.8); // Golden glow by default
uniform float pulse_speed : hint_range(0.0, 10.0) = 6.0;
uniform bool enable_highlight = true;

void fragment() {
    // Get original pixel color
    vec4 original = texture(TEXTURE, UV);
    
    // Default to original color
    vec4 final_color = original;
    
    if (enable_highlight && original.a > 0.1) {
        // Create smooth pulsing effect
        float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5);
        
        // Apply the highlight to the entire sprite
        // Smoothly transition between original color and highlight color
        final_color = mix(original, highlight_color, pulse * 0.7);
        
        // Preserve original alpha
        final_color.a = original.a;
    }
    
    // Make the shader visible in the editor
    #ifdef TOOL
    if (!enable_highlight && original.a > 0.1) {
        // Show a subtle preview in the editor
        final_color = mix(original, highlight_color * 0.3, 0.2);
        final_color.a = original.a;
    }
    #endif
    
    COLOR = final_color;
}