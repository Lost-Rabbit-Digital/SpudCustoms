shader_type canvas_item;

// Customizable properties for the highlight effect
uniform vec4 highlight_color : source_color = vec4(1.0, 0.8, 0.2, 0.8); // Golden glow
uniform float pulse_speed : hint_range(0.0, 10.0) = 6.0;
uniform float edge_width : hint_range(0.0, 0.1) = 0.02; // Width as percentage of texture size
uniform bool enable_highlight = false;

// Color ignoring system (directly editable in the inspector)
uniform bool ignore_colors = false;
uniform vec4 ignored_color : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Default: Black
uniform float color_tolerance : hint_range(0.0, 0.3) = 0.1; // How much variation to allow

void fragment() {
    // Get the original color at this pixel
    vec4 original = texture(TEXTURE, UV);
    
    // Initialize final color to original
    vec4 final_color = original;
    
    // Skip processing for fully transparent pixels
    if (original.a >= 0.1) {
        // Check if this color should be ignored based on the ignored_color uniform
        bool should_ignore = false;
        if (ignore_colors) {
            // Simple color distance check
            float color_distance = length(original.rgb - ignored_color.rgb);
            should_ignore = color_distance < color_tolerance;
        }
        
        // Only process if highlight is enabled and color isn't ignored
        if (enable_highlight && !should_ignore) {
            // Get texture dimensions for calculations
            vec2 tex_size = vec2(textureSize(TEXTURE, 0));
            vec2 pixel_step = 1.0 / tex_size;
            
            // Sample multiple directions to find edges
            bool is_edge = false;
            
            // Check 4 main directions for transparent pixels or ignored colors
            vec2 offsets[4] = {
                vec2(pixel_step.x * 2.0, 0.0),           // right
                vec2(-pixel_step.x * 2.0, 0.0),          // left
                vec2(0.0, pixel_step.y * 2.0),           // down
                vec2(0.0, -pixel_step.y * 2.0)           // up
            };
            
            for (int i = 0; i < 4; i++) {
                vec2 sample_pos = UV + offsets[i];
                
                // Keep coordinates in bounds
                sample_pos = clamp(sample_pos, vec2(0.0), vec2(1.0));
                
                // Get sample at this position
                vec4 sample_color = texture(TEXTURE, sample_pos);
                
                // Consider edge if neighboring pixel is transparent or if it's an ignored color
                bool neighbor_ignored = false;
                if (ignore_colors) {
                    float neighbor_distance = length(sample_color.rgb - ignored_color.rgb);
                    neighbor_ignored = neighbor_distance < color_tolerance;
                }
                
                if (sample_color.a < 0.1 || neighbor_ignored) {
                    is_edge = true;
                    break;
                }
            }
            
            // Calculate normalized distance from UV coordinate to nearest edge of texture space
            float distance_from_edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
            
            // Apply highlight if either edge detected or near texture boundary
            if (is_edge || distance_from_edge < edge_width) {
                // Create pulsing effect
                float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5);
                
                // Apply highlight to edge only
                final_color = mix(original, highlight_color, pulse * 0.9);
            }
        }
    }
    
    // Output the final color while preserving original alpha
    final_color.a = original.a;
    COLOR = final_color;
}