// shader_type canvas_item;

// // Time is built in as TIME.
// // but here we don't rely on external textures.

// uniform sampler3D worley_texture;

// #include "res:///graphics/pixelate.gdshaderinc"

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

// const float WATER_COLOR_STEPS = 5.0;

// vec3 makeWater(vec2 p) {
//     float rz = dualfbm(p);

// 	float intensity = min(1.5, 0.1 / rz);
//     // intensity = floor(intensity * WATER_COLOR_STEPS) / WATER_COLOR_STEPS;
//     vec3 col = mix(WATER_BASE_COLOR, WATER_LIGHT_COLOR, intensity);
//     return col;
// }


// void fragment() {
//     COLOR = vec4(makeWater((pixelate(UV + UV_OFFSET, 150.0)) * 15.0), 1.0);
// }


shader_type canvas_item;

uniform vec3 WATER_BASE_COLOR: source_color = vec3(0.267, 0.545, 0.745);
uniform vec2 UV_OFFSET = vec2(0.0, 0.0);
uniform sampler2D FOAM_TEXTURE: hint_default_black;
uniform int FOAM_TEXTURE_MARGIN = 1;

vec2 foam_texture_coord(vec2 uv) {
    // the foam texture, which is textureSize(FOAM_TEXTURE) pixels, has a margin of
    // FOAM_TEXTURE_MARGIN pixels on every side. This converts the UV to span only the
    // non-margin area.
    float tex_size = float(textureSize(FOAM_TEXTURE, 0).x);
    float margin_uv = float(FOAM_TEXTURE_MARGIN) / tex_size;
    return uv * (1.0 - 2.0 * margin_uv) + vec2(margin_uv, margin_uv);
}

float random(vec2 st) {
    return fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 random2(vec2 p) {
    return fract(
        sin(vec2(
            dot(p, vec2(127.1, 311.7)),
            dot(p, vec2(269.5, 183.3))
        )) * 43758.5453
    );
}

void fragment() {
    vec2 st = (UV + UV_OFFSET - TIME * vec2(-0.005, -0.005)) * 25.0 * vec2(1.0, 1.3);

    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float m_dist = 8.0;
    float m_angle = 0.0;
    vec2 mb = vec2(0.0);
    vec2 mr = vec2(0.0);

    // First pass
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = random2(i_st + neighbor);

            point = 0.5 + 0.5 * sin(0.5 * TIME + 6.2831 * point);

            vec2 diff = neighbor + point - f_st;
            float dist = dot(diff, diff);

            if(dist < m_dist) {
                m_dist = dist;
                m_angle = atan(diff.y, diff.x);
                mb = neighbor;
                mr = diff;
            }
        }
    }

    // second pass
    m_dist = 8.0;
    vec2 nb = vec2(0.0);
    vec2 nr = vec2(0.0);

    for(int y = -2; y <= 2; y++) {
        for(int x = -2; x <= 2; x++) {

            vec2 neighbor = mb + vec2(float(x), float(y));
            vec2 point = random2(i_st + neighbor);
            point = 0.5 + 0.5 * sin(0.5 * TIME + 6.2831 * point);

            vec2 diff = neighbor + point - f_st;
            float dist = dot(0.5 * (mr + diff), normalize(diff - mr));

            if (dist < m_dist) {
                m_dist = dist;
                nb = point;
                nr = 0.5 * (diff - mr);
            }
        }
    }

    float n_dist = m_dist / 1.0;
    float c_id = random(i_st + mb);

    float th = 0.35 * 0.5 * (sin(TIME + 101.0 * c_id) + 1.0);

    float height = step(th, n_dist) * (n_dist - th) * (length(nr) - th);
    vec3 normal = normalize(vec3(n_dist * nr, 1.0));

    // Foam calculation
    float foam = texture(FOAM_TEXTURE, foam_texture_coord(UV)).r * (0.5 + height) * 1.5;

    // TODO: raise water height based on foam
    // not sure how to make this work with normals though...
    // can we find its derivative somehow?

    vec3 light_dir = normalize(vec3(0.9, 0.0, 0.5));
    float t1 = clamp(dot(light_dir, normal), 0.45, 1.0);
    t1 *= t1;
    t1 *= 5.;
    t1 += 0.1;

    vec3 foam_color = vec3(0.95, 0.98, 1.0); // light foam color
    vec3 water_color = t1 * WATER_BASE_COLOR;

    vec3 final_color = mix(water_color, foam_color, foam);

    COLOR = vec4(final_color, 1.0);
}
