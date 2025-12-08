// shader_type canvas_item;

// // Time is built in as TIME.
// // but here we don't rely on external textures.

// uniform sampler3D worley_texture;

// // NOTE: Per https://github.com/godotengine/godot/issues/81627,
// // you must add a 1x1 texture to any polygon this is used on...
// // for some reason

// // float noise3D(vec3 p) {
// //     p = fract(p * 0.3183099 + 0.1);
// //     p *= 17.0;
// //     return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
// // }

// // float worley3D(vec3 p) {
// //     float r = 3.0;
// //     vec3 f = floor(p);
// //     vec3 x = fract(p);

// //     for (int i = -1; i <= 1; i++) {
// //         for (int j = -1; j <= 1; j++) {
// //             for (int k = -1; k <= 1; k++) {
// //                 vec3 q = vec3(float(i), float(j), float(k));
// //                 vec3 n = vec3(
// //                     noise3D((q + f) * 1.11),
// //                     noise3D((q + f) * 1.14),
// //                     noise3D((q + f) * 1.17)
// //                 );
// //                 vec3 v = q + n - x;
// //                 float d = dot(v, v);
// //                 r = min(r, d);
// //             }
// //         }
// //     }
// //     return sqrt(r);
// // }

// float worleyTexture(vec3 p) {
//     return texture(worley_texture, fract(p)).r;
// }

// float worley3D(vec3 p) {
//     p = p * 0.1;
    
//     // We need to use custom trilinear filtering because for some reason
//     // godot doesn't support it for 3D textures?
//     int size = textureSize(worley_texture, 0).x;
//     float filterStep = 1.0 / float(size);
    
//     vec3 ip = floor(p * float(size)) * filterStep;
//     vec3 c000 = ip + vec3(0.0, 0.0, 0.0) * filterStep;
//     vec3 c100 = ip + vec3(1.0, 0.0, 0.0) * filterStep;
//     vec3 c010 = ip + vec3(0.0, 1.0, 0.0) * filterStep;
//     vec3 c110 = ip + vec3(1.0, 1.0, 0.0) * filterStep;
//     vec3 c001 = ip + vec3(0.0, 0.0, 1.0) * filterStep;
//     vec3 c101 = ip + vec3(1.0, 0.0, 1.0) * filterStep;
//     vec3 c011 = ip + vec3(0.0, 1.0, 1.0) * filterStep;
//     vec3 c111 = ip + vec3(1.0, 1.0, 1.0) * filterStep;

//     vec3 f = fract(p * float(size));
//     float c00 = mix(worleyTexture(c000), worleyTexture(c100), f.x);
//     float c10 = mix(worleyTexture(c010), worleyTexture(c110), f.x);
//     float c01 = mix(worleyTexture(c001), worleyTexture(c101), f.x);
//     float c11 = mix(worleyTexture(c011), worleyTexture(c111), f.x);

//     float c0 = mix(c00, c10, f.y);
//     float c1 = mix(c01, c11, f.y);

//     return mix(c0, c1, f.z);
// }

// float fbm(vec2 p) {
//     float z = 2.0;
//     float rz = 0.0;
//     vec2 base = p;

//     for(float i = 1.0; i < 5.0; i++) {
//         vec3 pos = vec3(p, TIME * 0.3) / 2.0;
//         rz += abs((worley3D(pos) - 0.5) * 2.0) / z;
//         z *= 2.0;
//         p *= 2.0;
//     }
//     return rz;
// }

// float dualfbm(vec2 p) {
//     vec2 p2 = p * 0.7;
//     float time = TIME * 0.25;

//     vec2 basis = vec2(
//         fbm(p2 - time * 1.6),
//         fbm(p2 + time * 1.7)
//     );

//     basis = (basis - 0.5) * 0.2;
//     p += basis;

//     return fbm(p);
// }

// uniform vec3 WATER_BASE_COLOR: source_color = vec3(0.267, 0.545, 0.745);
// uniform vec3 WATER_LIGHT_COLOR: source_color = vec3(0.565, 0.803, 0.925);
// uniform vec2 UV_OFFSET = vec2(0.0, 0.0);

// const float WATER_COLOR_STEPS = 100.0;

// vec3 makeWater(vec2 p) {
//     float rz = dualfbm(p);

// 	float intensity = min(1.5, 0.1 / rz);
//     vec3 col = mix(
//         WATER_BASE_COLOR, WATER_LIGHT_COLOR,
//         floor(intensity * WATER_COLOR_STEPS) / WATER_COLOR_STEPS
//     );
//     return col;
// }


// void fragment() {
//     COLOR = vec4(makeWater((UV + UV_OFFSET) * 15.0), 1.0);
// }







shader_type canvas_item;

uniform vec3 WATER_BASE_COLOR: source_color = vec3(0.267, 0.545, 0.745);
uniform vec2 UV_OFFSET = vec2(0.0, 0.0);

// Fake 2D "sun" direction projected into 3D normal space
// (normalized)
uniform vec2 sun_dir_2d = vec2(0.6, -0.4);

float get_wave_coord(vec2 uv, vec2 direction) {
    return uv.x * direction.x + uv.y * direction.y;
}

vec3 sine_normal(vec2 uv, float frequency, float amplitude, float rotation, float time) {
    vec2 direction = vec2(sin(rotation), cos(rotation));
    float coord = get_wave_coord(uv, direction);

    vec2 normal2 = frequency * amplitude * direction * cos(coord * frequency + time);
    return vec3(normal2.x, 0.0, normal2.y);
}

vec3 steep_sine_normal(vec2 uv, float frequency, float amplitude, float rotation, float time) {
    vec2 direction = vec2(sin(rotation), cos(rotation));
    float coord = get_wave_coord(uv, direction);

    float steepness = 2.0;
    float h = pow((sin(coord * frequency + time) + 1.0) * 0.5,
                  max(1.0, steepness - 1.0));

    vec2 normal2 = direction * steepness * frequency * amplitude * h *
                   cos(coord * frequency + time);

    return vec3(normal2.x, 0.0, normal2.y);
}

const int SUM_OF_SINES_ITERATIONS = 6;

vec3 get_water_normal(vec2 uv) {
    vec3 normal = vec3(0.0);
    float frequency = 20.0;
    float amplitude = 1.0;
    float rotation = 0.0;
    float time = TIME / 4.0;

    for(int i = 0; i < SUM_OF_SINES_ITERATIONS; i++) {
        normal += steep_sine_normal(uv, frequency, amplitude, rotation, time);

        frequency *= 2.5;
        amplitude /= 2.5;
        rotation += 0.2;
        rotation *= 1.1;
        time *= 1.6;
    }

    return normalize(normal);
}

void fragment() {
    vec2 uv = UV + UV_OFFSET;

    vec3 normal = get_water_normal(uv);

    vec3 light_dir = normalize(vec3(sun_dir_2d.x, 0.0, sun_dir_2d.y));

    float light_dot = dot(normal, light_dir);

    float diffuse = clamp(light_dot * 0.3 + 0.6, 0.0, 1.0);
    float specular = pow(max(light_dot, 0.0), 32.0) * 0.5;

    COLOR = vec4(WATER_BASE_COLOR * diffuse + specular, 1.0);
}
