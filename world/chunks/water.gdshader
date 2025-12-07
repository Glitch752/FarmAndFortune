shader_type canvas_item;

// Time is built in as TIME.
// but here we don't rely on external textures.

uniform sampler3D worley_texture;

// NOTE: Per https://github.com/godotengine/godot/issues/81627,
// you must add a 1x1 texture to any polygon this is used on...
// for some reason

// float noise3D(vec3 p) {
//     p = fract(p * 0.3183099 + 0.1);
//     p *= 17.0;
//     return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
// }

// float worley3D(vec3 p) {
//     float r = 3.0;
//     vec3 f = floor(p);
//     vec3 x = fract(p);

//     for (int i = -1; i <= 1; i++) {
//         for (int j = -1; j <= 1; j++) {
//             for (int k = -1; k <= 1; k++) {
//                 vec3 q = vec3(float(i), float(j), float(k));
//                 vec3 n = vec3(
//                     noise3D((q + f) * 1.11),
//                     noise3D((q + f) * 1.14),
//                     noise3D((q + f) * 1.17)
//                 );
//                 vec3 v = q + n - x;
//                 float d = dot(v, v);
//                 r = min(r, d);
//             }
//         }
//     }
//     return sqrt(r);
// }

float worleyTexture(vec3 p) {
    return texture(worley_texture, fract(p)).r;
}

float worley3D(vec3 p) {
    p = p * 0.1;
    
    // We need to use custom trilinear filtering because for some reason
    // godot doesn't support it for 3D textures?
    int size = textureSize(worley_texture, 0).x;
    float filterStep = 1.0 / float(size);
    
    vec3 ip = floor(p * float(size)) * filterStep;
    vec3 c000 = ip + vec3(0.0, 0.0, 0.0) * filterStep;
    vec3 c100 = ip + vec3(1.0, 0.0, 0.0) * filterStep;
    vec3 c010 = ip + vec3(0.0, 1.0, 0.0) * filterStep;
    vec3 c110 = ip + vec3(1.0, 1.0, 0.0) * filterStep;
    vec3 c001 = ip + vec3(0.0, 0.0, 1.0) * filterStep;
    vec3 c101 = ip + vec3(1.0, 0.0, 1.0) * filterStep;
    vec3 c011 = ip + vec3(0.0, 1.0, 1.0) * filterStep;
    vec3 c111 = ip + vec3(1.0, 1.0, 1.0) * filterStep;

    vec3 f = fract(p * float(size));
    float c00 = mix(worleyTexture(c000), worleyTexture(c100), f.x);
    float c10 = mix(worleyTexture(c010), worleyTexture(c110), f.x);
    float c01 = mix(worleyTexture(c001), worleyTexture(c101), f.x);
    float c11 = mix(worleyTexture(c011), worleyTexture(c111), f.x);

    float c0 = mix(c00, c10, f.y);
    float c1 = mix(c01, c11, f.y);

    return mix(c0, c1, f.z);
}

float fbm(vec2 p) {
    float z = 2.0;
    float rz = 0.0;
    vec2 base = p;

    for(float i = 1.0; i < 5.0; i++) {
        vec3 pos = vec3(p, TIME * 0.3) / 2.0;
        rz += abs((worley3D(pos) - 0.5) * 2.0) / z;
        z *= 2.0;
        p *= 2.0;
    }
    return rz;
}

float dualfbm(vec2 p) {
    vec2 p2 = p * 0.7;
    float time = TIME * 0.25;

    vec2 basis = vec2(
        fbm(p2 - time * 1.6),
        fbm(p2 + time * 1.7)
    );

    basis = (basis - 0.5) * 0.2;
    p += basis;

    return fbm(p);
}

uniform vec3 WATER_BASE_COLOR: source_color = vec3(0.267, 0.545, 0.745);
uniform vec3 WATER_LIGHT_COLOR: source_color = vec3(0.565, 0.803, 0.925);

const float WATER_COLOR_STEPS = 10.0;

vec3 makeWater(vec2 p) {
    float rz = dualfbm(p);

	float intensity = min(1.5, 0.1 / rz);
    vec3 col = mix(
        WATER_BASE_COLOR, WATER_LIGHT_COLOR,
        floor(intensity * WATER_COLOR_STEPS) / WATER_COLOR_STEPS
    );
    return col;
}


void fragment() {
    COLOR = vec4(makeWater(UV * 15.0), 1.0);
}
