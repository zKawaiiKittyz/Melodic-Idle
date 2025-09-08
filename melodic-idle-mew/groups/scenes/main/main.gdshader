shader_type canvas_item;

void fragment() {
    vec2 scrolled_uv = UV + vec2(TIME * 0.02, TIME * 0.01);

    COLOR = texture(TEXTURE, scrolled_uv);
}
