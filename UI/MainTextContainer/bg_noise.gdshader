shader_type canvas_item;

uniform sampler2D noise;

void fragment() {
	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
	COLOR = color;
	COLOR.a *= step(0.3, texture(noise, texture(noise, UV).xy + sin(TIME)  / 300.0).r);
	COLOR.a += 0.7;
}
