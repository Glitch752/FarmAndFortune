shader_type canvas_item;

const vec3 TOP_COLOR = vec3(0.388, 0.7, 0.4);
const vec3 BOTTOM_COLOR = vec3(0.263, 0.369, 0.329);

void vertex() {
    // Pass UV coordinates to fragment shader
    UV = UV;

    // wind for the top of the grass
    if(UV.y < 0.5) {
        float wave = sin(UV.x * 20.0 + TIME * 5.0);
        VERTEX.x += wave * (UV.y - 0.5) * 2.0;
    }
}

void fragment() {
    float height_ratio = UV.y;
    vec3 color = mix(TOP_COLOR, BOTTOM_COLOR, height_ratio);
    COLOR = vec4(color, 1.0);
}