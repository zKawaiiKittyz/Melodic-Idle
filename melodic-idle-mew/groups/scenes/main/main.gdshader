shader_type canvas_item;

void fragment() {
	vec2 ratio = SCREEN_PIXEL_SIZE / TEXTURE_PIXEL_SIZE;

	vec2 tiled_uv = SCREEN_UV * ratio + vec2(TIME * 0.02, TIME * 0.01);

	COLOR = texture(TEXTURE, tiled_uv);
}