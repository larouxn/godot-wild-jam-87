shader_type canvas_item;

uniform bool enabled = false;

void fragment() {
	if(enabled) {
		COLOR.a = 0.5;
	}
}

