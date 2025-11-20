shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.a *= pow(2.1 * (0.5 - abs(0.5 - UV.y)), 0.9);
	color.a *= pow(2.5 * (0.5 - abs(0.5 - UV.x * 1.2)), 1.0);
	//color.a *= step(0.3, color.a);
	color.rgb = vec3(0.0, 0.0, 0.0);
	COLOR = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
