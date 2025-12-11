shader_type canvas_item;

uniform vec3 STRIPE_COLOR: source_color = vec3(1.0, 1.0, 1.0);
uniform sampler2D NOISE_TEXTURE: repeat_enable, filter_linear;

uniform float stripe_width : hint_range(0.0, 1.0) = 0.08;
uniform float stripe_spacing : hint_range(0.01, 1.0) = 0.2;
uniform float speed : hint_range(0.0, 1.0) = 0.03;

void fragment() {
    vec2 uv = UV;

    // Stripe parameters
    float stripe_pos = mod(uv.x + uv.y + TIME * speed, stripe_spacing);

    float stripe = smoothstep(stripe_width, 0.0, stripe_pos);

    COLOR = vec4(STRIPE_COLOR * stripe + COLOR.xyz, COLOR.a);
}

