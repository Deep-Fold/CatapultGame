shader_type canvas_item;
render_mode blend_mix;

uniform vec4 outline_color : hint_color;
const float delta = 0.01;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	if (col.a < delta) {
		col.a += texture(TEXTURE, UV+vec2(TEXTURE_PIXEL_SIZE.x, 0.0)).a;
		col.a += texture(TEXTURE, UV+vec2(-TEXTURE_PIXEL_SIZE.x, 0.0)).a;
		col.a += texture(TEXTURE, UV+vec2(0.0, TEXTURE_PIXEL_SIZE.y)).a;
		col.a += texture(TEXTURE, UV+vec2(0.0, -TEXTURE_PIXEL_SIZE.y)).a;
		col.a = step(delta, col.a);
		col.rgb = outline_color.rgb;
	}
	
	COLOR = col;
}