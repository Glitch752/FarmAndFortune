shader_type canvas_item;

// The seed is a random integer to vary the pattern between masks
uniform int seed = 0;

const vec2 ASPECT = vec2(1.0, 2.0);

float rand(float offset, float min_val, float max_val) {
    return fract(sin(offset + float(seed)) * 43758.5453) * (max_val - min_val) + min_val;
}

// 1D perlin noise function
float perlin(float x) {
    float x0 = floor(x);
    float x1 = x0 + 1.0;
    float sx = x - x0;

    float n0 = rand(x0, -1.0, 1.0);
    float n1 = rand(x1, -1.0, 1.0);

    // Smoothstep interpolation
    float u = sx * sx * (3.0 - 2.0 * sx);
    return mix(n0, n1, u);
}

// 1D fBM function
float fbm(float x) {
    float total = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for (int i = 0; i < 4; i++) {
        total += perlin(x * frequency) * amplitude;
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return total;
}

void fragment() {
    // Slight graininess
    vec2 scaled_uv = UV;
    scaled_uv.y = scaled_uv.y * 2.0 - 1.0;

    vec2 uv = scaled_uv;
    uv.x += (rand(uv.x * 10.0 + uv.y * 5.0, -1.0, 1.0) * 0.05);
    uv.y += (rand(uv.y * 10.0 + uv.x * 5.0, -1.0, 1.0) * 0.05);

    float scale = abs(0.5 - uv.x) * 2.0;
    scale = 1.0 - pow(scale, 2.0);
    // scale = 1.0;

    float widthScale = rand(0.0, 0.4, 1.2);
    float x = (uv.x - 0.5) * widthScale + 0.5;

    float wave = sin(x * PI * 2.0 + rand(0.0, -1.0, 1.0) - PI / 2.0);
    wave += 1.0;
    wave *= 0.5;

    float y = 0.8 - 0.15 * wave * scale - fbm(uv.x * 10.0) * 0.03 * scale;
    float fade = 0.05;

    if(scaled_uv.y > y) {
        COLOR.a = 0.0;
    } else if(scaled_uv.y > y - fade) {
        COLOR.a = 1.0 - smoothstep(y - fade, y, scaled_uv.y);
    } else {
        COLOR.a = 1.0;
    }

    // Spots of transparency
    if(COLOR.a > 0.0) {
        float spot_chance = rand(scaled_uv.x * 0.10873789 + scaled_uv.y * 34709.3, 0.0, 1.0);
        
        float spot_threshold = scaled_uv.y * 0.3; // More likely to be transparent lower down
        spot_threshold *= spot_threshold;
        spot_threshold *= scale;

        if(spot_chance < spot_threshold) {
            float spot_fade = 0.1;
            COLOR.a *= 1.0 - (spot_threshold - spot_chance) / spot_threshold;
        }
    }

    if(UV.y < 0.5) {
        COLOR.a = 1.0;
    }

    // Slight fade on the remaining edges
    vec2 edge_fade = 0.08 / ASPECT;
    COLOR.a *= 1.0 - smoothstep(edge_fade.x, 0.0, UV.x);
    COLOR.a *= 1.0 - smoothstep(1.0 - edge_fade.x, 1.0, UV.x);
    COLOR.a *= 1.0 - smoothstep(edge_fade.y, 0.0, UV.y);
}