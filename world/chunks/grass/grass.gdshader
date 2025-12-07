shader_type canvas_item;

//  #6a8d59
uniform vec3 TOP_COLOR: source_color = vec3(0.416, 0.553, 0.349);
uniform vec3 BOTTOM_COLOR: source_color = vec3(0.263, 0.369, 0.329);
uniform sampler2D NOISE_TEXTURE: repeat_enable, filter_linear;

float hashNormalized(int n) {
    return fract(sin(float(n) * 12.9898) * 43758.5453);
}

float fbm(float x, float time, float offset, float position_sum, int octaves, float lacunarity, float gain) {
    float amplitude = 1.0;
    float frequency = 1.0;
    float value = 0.0;
    for (int i = 0; i < octaves; i++) {
        value += amplitude * sin(
            x * frequency * 20.0 +
            time * frequency +
            position_sum * 0.02 * frequency +
            offset * frequency
        );
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return value;
}

varying flat vec3 model_pos;
varying flat int instance_id;

void vertex() {
    // Pass UV coordinates to fragment shader
    UV = UV;

    // wind for the top of the grass
    if(UV.y < 0.5) {
        vec3 position = MODEL_MATRIX[3].xyz;
        float offset = hashNormalized(INSTANCE_ID) * 0.2;
        float position_sum = position.x + position.y;
        // Use 3 octaves of fBm, lacunarity 2.0, gain 0.5
        float wave = fbm(UV.x, TIME * 0.5, offset, position_sum, 3, 2.0, 0.5);
        VERTEX.x += wave * (UV.y - 0.5) * 2.0;
    }

    model_pos = MODEL_MATRIX[3].xyz;
    instance_id = INSTANCE_ID;
}

void fragment() {
    vec3 color = TOP_COLOR;

    // Add small variation based on position and per-blade randomness
    float blade_rand = hashNormalized(instance_id);
    float pos_var = texture(NOISE_TEXTURE, model_pos.xy * 0.0005).r;

    float variation = (pos_var * 0.4 - 0.2) + (blade_rand * 0.1 - 0.05);
    color += variation;

    float height_ratio = UV.y;

    // Stylized white shading stripe on the right side of the blade
    float triangle_x = 0.5 + (UV.x - 0.5) / UV.y;
    float stripe = smoothstep(0.6, 0.95, triangle_x);
    color += stripe * 0.3;

    // Toon shading
    int toon_levels = 160;
    vec3 toon_color = floor(mix(color, BOTTOM_COLOR, height_ratio) * float(toon_levels)) / float(toon_levels);

    COLOR = vec4(toon_color, 1.0);
}