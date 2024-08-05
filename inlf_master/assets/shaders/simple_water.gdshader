shader_type spatial;
//render_mode shadows_disabled;

uniform vec3 water_color : source_color;
uniform sampler2D water_texture;
uniform float time_scale : hint_range(0.0, 10.0, 0.25) = 1.0;
uniform float alpha_slider : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform sampler2D water_normal_noise;

void fragment() {
	vec2 _uv = UV;
	
	_uv.x += sin(TIME * time_scale + (_uv.x + _uv.y) * 25.0) * 0.01;
	_uv.y += cos(TIME * time_scale + (_uv.x - _uv.y) * 25.0) * 0.01;
	
	ALBEDO =water_color * texture(water_texture, _uv).rgb;
	NORMAL_MAP = texture(water_normal_noise, _uv).rgb;
	NORMAL *= 0.5;
	ALPHA = alpha_slider;
}
