shader_type canvas_item;

uniform sampler2D image_color:repeat_enable, filter_linear_mipmap;

uniform vec3 ambient_light:source_color;
uniform vec3 light_color:source_color;
uniform vec3 light_direction = vec3(0.57735, 0.57735, 0.57735);

uniform sampler2D noise_color:repeat_enable, filter_linear_mipmap;
uniform float noise_magnitude:hint_range(0.0, 1.0) = 0.2;

uniform float rotation_speed:hint_range(0.0, 1.0)  = 0.0125;
uniform float convexity:hint_range(1.0, 2.0) = 1.0;
uniform float margin:hint_range(1.0, 1.5) = 1.125;
uniform float specular_power:hint_range(1.0, 50.0) = 5.0;
uniform float specular_intensity:hint_range(0.0, 1.0) = 0.25;

vec3 get_normal(vec2 uv) {
	float z = sqrt(1.0 - ( pow(uv.x, 2.0) + pow(uv.y, 2.0) ));
	return  vec3(uv.x, uv.y, z);
}

vec3 get_light(vec3 normal, vec3 color) {
	vec3 camera_direction = vec3(0.0, 0.0, 1.0);
	vec3 half_vector = normalize( camera_direction + light_direction );
	float diffuse    = max( 0.0, dot( light_direction, normal ) );
	float specular   = pow(max( 0.0, dot( half_vector, normal )), specular_power);
	return ambient_light + color * light_color.rgb * (diffuse + specular * specular_intensity); 
}

void fragment() {
	vec2 uv_centered = UV * margin * 2.0 - margin; // make uv (0,0) in sprite center
	vec3 sphere_normal = get_normal(uv_centered); // uv to spherical coordinates
	sphere_normal.xy /= (sphere_normal.z / margin + 1.0) * convexity; // convex effect
	sphere_normal = normalize(sphere_normal); // normalize normals
	
	float edge_fade = length(uv_centered);
	COLOR.a = smoothstep(1.0, 0.994, edge_fade); // make edge fade smoothly	
	
	float scroll = TIME * rotation_speed;
	vec2 uv = vec2(UV.x * 0.25 + scroll, UV.y * 0.5 + 0.25); // scroll texture
	
	vec2 noise_texture_color = texture(noise_color, uv.yx).rg;
	vec2 sphere_uv_offset = vec2(sphere_normal.r * 0.125, sphere_normal.g * 0.25);
	vec2 noise_uv = uv.yx + sphere_uv_offset.yx + (noise_texture_color - 0.5) * noise_magnitude  ;
	vec3 distorted_texture_color = texture(image_color, noise_uv).rgb;
	COLOR.rgb = get_light(sphere_normal, distorted_texture_color);
}
