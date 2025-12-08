// pixelates the given UV coordinates based on pixel_size and the screen resolution
vec2 pixelate(vec2 uv, float pixels) {
    vec2 pixelated_uv = floor(uv * pixels) / pixels;
    return pixelated_uv;
}