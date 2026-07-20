shader_type canvas_item;

// Used only by the Staff Corridor warning portrait. Clarity ramps in over the
// conversation without introducing a second portrait asset.
uniform float blur_strength : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 pixel = TEXTURE_PIXEL_SIZE * mix(0.0, 8.0, blur_strength);
	vec4 color = texture(TEXTURE, UV) * 0.20;
	color += texture(TEXTURE, UV + vec2(pixel.x, 0.0)) * 0.20;
	color += texture(TEXTURE, UV - vec2(pixel.x, 0.0)) * 0.20;
	color += texture(TEXTURE, UV + vec2(0.0, pixel.y)) * 0.20;
	color += texture(TEXTURE, UV - vec2(0.0, pixel.y)) * 0.20;
	COLOR = color * COLOR;
}
