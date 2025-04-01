shader_type canvas_item;

// Customizable properties for the highlight effect
uniform vec4 highlight_color : source_color = vec4(1.0, 0.8, 0.2, 0.8); // Golden glow
uniform float pulse_speed : hint_range(0.0, 10.0) = 6.0;
uniform float edge_width : hint_range(0.0, 0.1) = 0.02; // Width as percentage of texture size
uniform bool enable_highlight = false;
uniform int fill_mode : hint_range(0, 1) = 1; // 0 = edge only, 1 = full fill

// Multi-color ignoring system - maximum of 8 ignored colors
uniform bool ignore_colors = false;
uniform vec4 ignored_color1 : source_color = vec4(0.0, 0.0, 0.0, 1.0); // Default: Black
uniform vec4 ignored_color2 : source_color = vec4(0.0, 0.0, 0.0, 0.0); // Alpha 0 means unused
uniform vec4 ignored_color3 : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec4 ignored_color4 : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec4 ignored_color5 : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec4 ignored_color6 : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec4 ignored_color7 : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform vec4 ignored_color8 : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float color_tolerance : hint_range(0.0, 0.3) = 0.1; // How much variation to allow

// Check if a color matches any of the ignored colors
bool is_ignored_color(vec4 color) {
    if (!ignore_colors) return false;
    
    // Only check colors that have an alpha > 0 (to indicate they're being used)
    if (ignored_color1.a > 0.0 && length(color.rgb - ignored_color1.rgb) < color_tolerance) return true;
    if (ignored_color2.a > 0.0 && length(color.rgb - ignored_color2.rgb) < color_tolerance) return true;
    if (ignored_color3.a > 0.0 && length(color.rgb - ignored_color3.rgb) < color_tolerance) return true;
    if (ignored_color4.a > 0.0 && length(color.rgb - ignored_color4.rgb) < color_tolerance) return true;
    if (ignored_color5.a > 0.0 && length(color.rgb - ignored_color5.rgb) < color_tolerance) return true;
    if (ignored_color6.a > 0.0 && length(color.rgb - ignored_color6.rgb) < color_tolerance) return true;
    if (ignored_color7.a > 0.0 && length(color.rgb - ignored_color7.rgb) < color_tolerance) return true;
    if (ignored_color8.a > 0.0 && length(color.rgb - ignored_color8.rgb) < color_tolerance) return true;
    
    return false;
}

void fragment() {
    // Get the original color at this pixel
    vec4 original = texture(TEXTURE, UV);
    
    // Initialize final color to original
    vec4 final_color = original;
    
    // Skip processing for fully transparent pixels
    if (original.a >= 0.1) {
        // Check if this color should be ignored
        bool should_ignore = is_ignored_color(original);
        
        // Only process if highlight is enabled and color isn't ignored
        if (enable_highlight && !should_ignore) {
            // Create pulsing effect
            float pulse = (sin(TIME * pulse_speed) * 0.5 + 0.5);
            
            // Handle fill mode (full fill)
            if (fill_mode == 1) {
                // Apply highlight to the entire sprite
                final_color = mix(original, highlight_color, pulse * 0.7);
            } 
            // Handle edge mode
            else {
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
                    if (sample_color.a < 0.1 || is_ignored_color(sample_color)) {
                        is_edge = true;
                        break;
                    }
                }
                
                // Calculate normalized distance from UV coordinate to nearest edge of texture space
                float distance_from_edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
                
                // Apply highlight if either edge detected or near texture boundary
                if (is_edge || distance_from_edge < edge_width) {
                    // Apply highlight to edge only
                    final_color = mix(original, highlight_color, pulse * 0.9);
                }
            }
        }
    }
    
    // Output the final color while preserving original alpha
    final_color.a = original.a;
    COLOR = final_color;
}