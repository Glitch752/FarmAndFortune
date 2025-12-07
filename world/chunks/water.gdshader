shader_type canvas_item;

// Time is built in as TIME.
// but here we don't rely on external textures.

uniform sampler3D worley_texture;

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

float worley3D(vec3 p) {
    return texture(worley_texture, p * 0.1).r;
}

float fbm(vec2 p) {
    float z = 2.0;
    float rz = 0.0;
    vec2 base = p;

    for (float i = 1.0; i < 5.0; i++) {
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

vec3 makeWater(vec2 p) {
    float rz = dualfbm(p);

    vec3 col = vec3(0.2, 0.5, 0.8) / rz / 5.0;
    col = pow(abs(col), vec3(0.99));

    float q = (col.r + col.g + col.b) / 3.0;
    q = round(q * 5.0) / 5.0;

    col = vec3(q, 0.5, 0.8);

    return col;
}

void fragment() {
    vec2 uv = UV * 2.0 - 1.0;

    // Preserve aspect ratio
    float aspect = float(TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x);
    uv.x *= aspect;

    uv *= 3.0;

    COLOR = vec4(makeWater(uv), 1.0);
}
