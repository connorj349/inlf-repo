shader_type canvas_item;

uniform float offset_amount : hint_range(0.0, 10.0) = 3.0;  // Intensity of double vision
uniform float mix_amount : hint_range(0.0, 1.0) = 0.5;      // Blend factor for the effect
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Fetch the base texture
    vec4 original = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // Calculate the UV offset
    // Dividing the offset by the width of the screen ensures the offset is properly scaled
    vec2 offset_uv = SCREEN_UV + vec2(offset_amount / SCREEN_PIXEL_SIZE.x, 0.0);
    
    // Fetch the shifted version of the texture for double vision
    vec4 shifted = texture(SCREEN_TEXTURE, offset_uv);

    // Blend the two textures to create the double vision effect
    COLOR = mix(original, shifted, mix_amount);
}