shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if(UV.y > 0.48 && UV.y < 0.52) {} else {
		color.a *= pow(2.1 * (0.5 - abs(0.5 - UV.y)), 6.0);
		color.a *= step(0.1, color.a);
		COLOR = color;
	}
}
