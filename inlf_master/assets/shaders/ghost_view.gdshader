shader_type canvas_item;

uniform float offset : hint_range(0, 10) = 0.05;
uniform float blur_amount : hint_range(0, 10) = 1.0;
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;
	
	vec2 offset_left = uv + vec2(-offset * blur_amount * 0.01, 0.0);
	vec2 offset_right = uv + vec2(offset * blur_amount * 0.01, 0.0);
	
	vec4 color_original = texture(TEXTURE, uv);
	vec4 color_left = texture(TEXTURE, offset_left);
	vec4 color_right = texture(TEXTURE, offset_right);
	
	vec4 blurred_color = (color_original + color_left + color_right) / 3.0;
	
	float ghost_alpha = smoothstep(0.2, 1.0, length(blurred_color.rgb)) * 0.5;
	blurred_color.a *= ghost_alpha;
	
	COLOR = blurred_color;
}
