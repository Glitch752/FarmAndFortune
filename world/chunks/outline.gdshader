shader_type canvas_item;

uniform vec3 STRIPE_COLOR: source_color = vec3(1.0, 1.0, 1.0);
uniform sampler2D NOISE_TEXTURE: repeat_enable, filter_linear;

void fragment() {
    vec2 uv = UV;

    // Stripe parameters
    float stripe_width = 0.08; // width of each stripe
    float stripe_spacing = 0.16; // distance between stripes
    float speed = 0.03; // movement speed

    float stripe_pos = uv.x + uv.y + TIME * speed;

    float stripe = smoothstep(stripe_width, 0.0, mod(stripe_pos, stripe_spacing));

    COLOR = vec4(STRIPE_COLOR * stripe + COLOR.xyz, COLOR.a);
}

