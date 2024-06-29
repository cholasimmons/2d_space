shader_type canvas_item;

uniform float trail_length = 0.5;
uniform float fade_length = 1.0;

void fragment() {
	// Get the length of the current segment
	float segment_length = distance(vec2(UV.x, 0.0), vec2(UV.y, 0.0));
    
    // Calculate the fading factor based on the segment length
	float fade_factor = 1.0;
	if (segment_length > trail_length - fade_length) {
		fade_factor = (trail_length - segment_length) / fade_length;
	}
    
    // Apply the fading factor to the color
	COLOR.a *= fade_factor;
}
