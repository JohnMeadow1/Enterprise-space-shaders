shader_type canvas_item;

uniform sampler2D rings_texture : source_color,filter_linear_mipmap;
uniform float rim_distance = 0.5;
uniform float shadow_width = 0.5;
uniform float shadow_edge_dispersion = 0.025;
uniform vec2 light_direction = vec2(0.707, 0.707);

void fragment() {
	vec2 uv_from_center = UV * 2.0 - 1.0;
	float y = (length(uv_from_center) - rim_distance) / (1.0 - rim_distance);
	float x = atan(uv_from_center.y, uv_from_center.x) / TAU;
	
	float shade_cross = abs(light_direction.x * uv_from_center.y - light_direction.y * uv_from_center.x);
	float shade_dot = dot(light_direction, uv_from_center);
	float shade_value = max(sign(shade_dot), smoothstep(shadow_width - shadow_edge_dispersion, shadow_width + shadow_edge_dispersion, shade_cross) );
	
	COLOR = texture(rings_texture, vec2(y,x));
	COLOR.rgb *= max(0.2,shade_value);
}