shader_type canvas_item;

// Texture array input
uniform sampler2D sprite_texture1;
uniform sampler2D sprite_texture2;
uniform sampler2D sprite_texture3;
uniform sampler2D sprite_texture4;

// Configuration parameters
uniform vec2 aspect = vec2(16.0, 9.0);    // Aspect ratio of the pattern
uniform float sprite_amount = 26.0;        // Number of sprites to generate
uniform vec2 scale = vec2(24.0, 24.0);     // Scale of individual sprites
uniform vec4 tint_color : source_color = vec4(1.0, 0.8, 0.8, 1.0);  // Overall tint
uniform float spacing = 3.0;               // Space between sprites
uniform vec2 scroll_speed = vec2(0.1, 0.1); // Scroll speed for x and y

// Hash function for pseudo-random number generation
float random(vec2 pos) {
    return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Function to select texture based on random value
vec4 select_texture(float rand, vec2 uv) {
    float selector = rand * 4.0;
    if (selector < 1.0) {
        return texture(sprite_texture1, uv);
    } else if (selector < 2.0) {
        return texture(sprite_texture2, uv);
    } else if (selector < 3.0) {
        return texture(sprite_texture3, uv);
    } else {
        return texture(sprite_texture4, uv);
    }
}

void fragment() {
    vec4 final_color = vec4(0.0);
    
    // Calculate scrolled UV coordinates
    vec2 scrolled_uv = UV * aspect;
    scrolled_uv += TIME * scroll_speed; // Add scrolling movement
    
    // Calculate grid size based on spacing
    vec2 grid_size = vec2(spacing);
    
    // Generate sprites in a less dense grid
    for (int y = -2; y < 6; y++) {
        for (int x = -2; x < 8; x++) {
            // Calculate base position for this sprite
            vec2 base_pos = vec2(float(x), float(y)) * grid_size;
            
            // Add some random offset to break up the grid
            vec2 random_offset = vec2(
                random(base_pos + vec2(0.0, 1.0)),
                random(base_pos + vec2(1.0, 0.0))
            ) * 0.3; // Reduce the random offset amount
            
            vec2 pos = base_pos + random_offset;
            
            // Get consistent random value for this position
            float rand_val = random(pos);
            
            // Calculate actual position including scroll
            vec2 actual_pos = pos - fract(scrolled_uv / grid_size) * grid_size;
            
            // Calculate rotation for this sprite
            float angle = 2.0 * PI * rand_val + TIME * 0.2; // Added slow rotation over time
            vec2 offset = vec2(
                cos(angle) * (UV.x - actual_pos.x / aspect.x) - sin(angle) * (UV.y - actual_pos.y / aspect.y),
                sin(angle) * (UV.x - actual_pos.x / aspect.x) + cos(angle) * (UV.y - actual_pos.y / aspect.y)
            );
            
            // Scale the sprite
            offset *= scale;
            
            // Check if we're within the sprite bounds
            if (abs(offset.x) < 0.5 && abs(offset.y) < 0.5) {
                // Get sprite UV coordinates
                vec2 sprite_uv = offset + vec2(0.5);
                
                // Select and sample texture
                vec4 sprite_color = select_texture(rand_val, sprite_uv);
                
                // Add slight pulse effect to sprites
                float pulse = 0.9 + 0.1 * sin(TIME * 2.0 + rand_val * 6.28);
                
                // Apply sprite if it has alpha
                if (sprite_color.a > 0.0) {
                    final_color = sprite_color * tint_color * pulse;
                }
            }
        }
    }
    
    // Output final color
    COLOR = final_color;
}