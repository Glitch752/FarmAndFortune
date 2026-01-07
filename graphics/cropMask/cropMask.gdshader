shader_type canvas_item;

// The seed is a random integer to vary the pattern between masks
uniform int seed = 0;

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
    float scale = abs(0.5 - UV.x) * 2.0;
    scale = 1.0 - pow(scale, 2.0);
    // scale = 1.0;

    float wave = sin(UV.x * PI * 2.0 + rand(0.0, -1.0, 1.0) - PI / 2.0);
    wave += 1.0;
    wave *= 0.5;

    float y = 1.0 - 0.15 * wave * scale - fbm(UV.x * 10.0) * 0.03 * scale;
    float fade = 0.02;

    if(UV.y > y) {
        COLOR.a = 0.0;
    } else if(UV.y > y - fade) {
        COLOR.a = 1.0 - smoothstep(y - fade, y, UV.y);
    } else {
        COLOR.a = 1.0;
    }
}