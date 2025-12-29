shader_type canvas_item;

// Just a simple noise shader for dirt texture

uniform float scale = 10.0;
uniform sampler2D noise_texture : repeat_enable;

void fragment() {
	vec2 uv = UV * scale;
	float fine_noise = texture(noise_texture, uv * 12.0).r * 0.2;
	float noise_value = texture(noise_texture, uv).r * 0.6 + 0.4 + fine_noise;

	// Horizontal ridges to look kind of like farmland
	noise_value *= 0.85 + 0.15 * sin(UV.y * 50.0);

	COLOR *= vec4(vec3(noise_value), 1.0);
}
 