shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur = 2.0;
/// 0-255
uniform float alpha = 100;
uniform bool use_alpha_channel = true;

void fragment() {
    COLOR = vec4(
        mix(texture(screen_texture, SCREEN_UV, blur).rgb, COLOR.rgb, alpha / 255.0),
        use_alpha_channel ? COLOR.a : 1.0
    );
}