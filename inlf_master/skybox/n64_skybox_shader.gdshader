shader_type spatial;
render_mode unshaded;

uniform sampler2D texture : hint_albedo;
uniform bool lock_aspect = false;
uniform float aspect_ratio = 1.3333333;
uniform vec2 fov = vec2(180.0, 90.0);
uniform ivec2 tiling = ivec2(1, 1);
uniform vec2 offset = vec2(0.0, 0.0);

varying vec2 BG_COORDS;
varying vec2 BG_SCALE;

void vertex() {
	//Camera YX rotation per Basis.get_euler source code
	float y = atan(CAMERA_MATRIX[0][2], CAMERA_MATRIX[2][2]);
	float x = asin(CAMERA_MATRIX[1][2]);
	
	//Map rotation to screen space
	BG_COORDS = vec2(y * 0.5, -x) * -(1.0 / 3.141593);
	BG_COORDS.y += 0.5;
	
	BG_SCALE.y = fov.y * (1.0 / 180.0);
	BG_SCALE.x = !lock_aspect ? 
		fov.x * (1.0 / 360.0) : 
		VIEWPORT_SIZE.x / (VIEWPORT_SIZE.y * aspect_ratio) * BG_SCALE.y;
	
	//Keep background centered vertically when FOV changes
	BG_COORDS.y *= BG_SCALE.y > 1.0 ? 0.0 : 1.0 - BG_SCALE.y;
}

void fragment() {
	vec2 uv_offset = vec2(-offset.x, offset.y);
	vec2 uv = (SCREEN_UV + uv_offset) * BG_SCALE + BG_COORDS;
	uv *= vec2(tiling);
	ALBEDO = texture(texture, uv).rgb;
}