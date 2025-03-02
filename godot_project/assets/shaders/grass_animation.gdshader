shader_type canvas_item;

// Animation parameters
uniform float wind_speed : hint_range(0.1, 5.0) = 1.0;  // Speed of the wind animation
uniform float wind_strength : hint_range(0.0, 10.0) = 1.5;  // Strength of displacement
uniform float noise_scale : hint_range(0.1, 10.0) = 3.0;  // Scale of noise pattern
uniform float secondary_frequency : hint_range(0.1, 5.0) = 2.7;  // For a secondary wave
uniform bool individual_blades = true;  // Enable for more individualized movement

// Pseudo-random function
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // Get the current pixel position
    vec2 uv = UV;
    
    // Height factor - top of grass moves more
    float height_factor = pow(1.0 - uv.y, 2.0);
    
    // Add some variation based on x position to make each column of pixels move differently
    float x_variation = 0.0;
    if (individual_blades) {
        // This creates a unique phase for different x-positions (grass blades)
        x_variation = random(vec2(floor(uv.x * 20.0), 0.0)) * 6.28;
    }
    
    // Primary wave movement
    float primary_wave = sin(uv.y * noise_scale + TIME * wind_speed + x_variation) 
                       * wind_strength * 0.01;
    
    // Secondary wave for more natural movement
    float secondary_wave = cos(uv.y * noise_scale * 0.5 + TIME * wind_speed * secondary_frequency + x_variation) 
                         * wind_strength * 0.005;
    
    // Combine waves and apply height factor
    float final_wave = (primary_wave + secondary_wave) * height_factor;
    
    // Modify the x-coordinate based on the combined wave effect
    vec2 distorted_uv = vec2(uv.x + final_wave, uv.y);
    
    // Sample the texture at the new position
    vec4 color = texture(TEXTURE, distorted_uv);
    
    // Output the modified color
    COLOR = color;
}