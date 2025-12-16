shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur = 2.0;

vec4 alpha_blend(vec4 base, vec4 overlay) {
    float alpha = overlay.a;
    return vec4(
        mix(base.rgb, overlay.rgb, alpha),
        max(base.a, overlay.a)
    );
}

void fragment() {
    COLOR = alpha_blend(texture(screen_texture, SCREEN_UV, blur), COLOR);
}