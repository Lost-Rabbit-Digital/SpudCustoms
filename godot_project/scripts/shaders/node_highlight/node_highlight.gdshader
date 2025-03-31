shader_type canvas_item;

// Customizable properties for the highlight effect
uniform vec4 highlight_color : source_color = vec4(1.0, 0.8, 0.2, 0.8); // Golden glow
uniform float pulse_speed : hint_range(0.0, 10.0) = 6.0;
uniform float edge_width : hint_range(0.0, 0.1) = 0.02; // Width as percentage of texture size
uniform bool enable_highlight = false;

void fragment() {
    // Get texture dimensions for calculations
    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    
    // Get the original color at this pixel
    vec4 original = texture(TEXTURE, UV);
    
    // Initialize output color
    vec4 final_color = original;
    
    // Only process if highlight is enabled and pixel is not transparent
    if (enable_highlight && original.a > 0.1) {
        // Alternative edge detection using distance from edge
        
        // Sample multiple directions to find edges
        float min_alpha = 1.0;
        
        // Calculate pixel step size
        vec2 pixel_step = 1.0 / tex_size;
        float step_size = max(pixel_step.x, pixel_step.y) * 2.0;
        
        // Sample in 8 directions
        vec2 directions[8];
        directions[0] = vec2(step_size, 0.0);          // right
        directions[1] = vec2(-step_size, 0.0);         // left
        directions[2] = vec2(0.0, step_size);          // down
        directions[3] = vec2(0.0, -step_size);         // up
        directions[4] = vec2(step_size, step_size);    // down-right
        directions[5] = vec2(-step_size, step_size);   // down-left
        directions[6] = vec2(step_size, -step_size);   // up-right
        directions[7] = vec2(-step_size, -step_size);  // up-left
        
        // Check all directions
        for (int i = 0; i < 8; i++) {
            vec2 sample_pos = UV + directions[i];
            
            // Keep coordinates in bounds
            sample_pos = clamp(sample_pos, vec2(0.0), vec2(1.0));
            
            // Get alpha at this position
            float alpha = texture(TEXTURE, sample_pos).a;
            
            // Track minimum alpha found in all directions
            min_alpha = min(min_alpha, alpha);
        }
        
        // If any direction had a transparent/semi-transparent pixel, this is an edge
        bool is_edge = min_alpha < 0.5 && original.a > 0.5;
        
        // Alternative approach: distance from edge 
        // Calculate normalized distance from UV coordinate to nearest edge of texture space
        float distance_from_edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
        
        // Combine both approaches - either pixel-based edge detection or distance-based edge detection
        if (is_edge || distance_from_edge < edge_width) {
            // Create pulsing effect
            float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5);
            
            // Apply highlight to edge only - stronger effect (0.95)
            final_color = mix(original, highlight_color, pulse * 0.95);
        }
    }
    
    // Preserve original alpha
    final_color.a = original.a;
    
    COLOR = final_color;
}