shader_type canvas_item;

uniform sampler2DArray icon_tex;
uniform float grid_spacing = 128.0; // pixels between icons
uniform float grid_angle = 0.5;     // radians
uniform vec2 scroll_speed = vec2(30.0, 20.0); // pixels/sec
uniform float icon_scale = 1.0;
uniform float icon_opacity = 1.0;

uniform float zoom_amplitude = 0.1;
uniform float zoom_period = 20.0;

uniform float max_rotation = 0.3; // radians
uniform float max_offset = 0.15; // fraction of a cell

vec4 alpha_blend(vec4 dest, vec4 src) {
    float out_a = src.a + dest.a * (1.0 - src.a);
    vec3 out_rgb = (src.rgb * src.a + dest.rgb * dest.a * (1.0 - src.a)) / out_a;
    return vec4(out_rgb, out_a);
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
vec2 hash2(vec2 p) {
    return vec2(
        hash(p),
        hash(p + 17.23)
    );
}

void fragment() {
    // World / screen coordinates
    vec2 pos = SCREEN_UV / SCREEN_PIXEL_SIZE;

    float zoom = 1.0 + zoom_amplitude * 0.5 * (1.0 + sin(TIME * 6.2831853 / zoom_period));
    pos = (pos - 1.0 / SCREEN_PIXEL_SIZE * 0.5) * zoom + 1.0 / SCREEN_PIXEL_SIZE * 0.5;

    // Time-based scroll
    vec2 scroll = TIME * scroll_speed;
    pos += scroll;

    // Rotation basis
    float c = cos(grid_angle);
    float s = sin(grid_angle);

    mat2 rot = mat2(
        vec2(c, -s),
        vec2(s,  c)
    );

    // Grid space
    vec2 grid_pos = rot * pos / grid_spacing;

    vec2 cell = floor(grid_pos);
    vec2 local = fract(grid_pos) - 0.5;

    // Random per-cell values
    float r = hash(cell);
    float r2 = hash(cell + 88.1337);
    vec2 r3 = hash2(cell);

    int icon_index = int(floor(r * float(textureSize(icon_tex, 0).z)));

    float angle = (r2 - 0.5) * 2.0 * max_rotation;
    vec2 offset = (r3 - 0.5) * 2.0 * max_offset;

    // Apply offset and rotation
    local -= offset;

    float rc = cos(angle);
    float rs = sin(angle);
    mat2 rmat = mat2(
        vec2(rc, -rs),
        vec2(rs, rc)
    );
    local = rmat * local;

    // Scale icon inside cell
    vec2 uv = local / icon_scale + 0.5;

    // Outside icon bounds → transparent
    if(uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0) {
        // Sample icon
        vec4 icon = texture(icon_tex, vec3(uv, float(icon_index)));
        icon.a *= icon_opacity;
        COLOR = alpha_blend(COLOR, icon);
    }
}
