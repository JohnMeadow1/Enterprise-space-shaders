shader_type canvas_item;

uniform sampler2D image_color:repeat_enable, filter_linear_mipmap;
uniform sampler2D ring_color:repeat_disable, filter_linear_mipmap;

uniform vec3 ambient_light:source_color;
uniform vec3 light_color:source_color;
uniform vec3 light_direction = vec3(0.57735, 0.57735, 0.57735);

uniform float rotation_speed:hint_range(0.0, 1.0)  = 0.0125;
uniform float margin:hint_range(1.0, 1.5) = 1.125;
uniform float specular_power:hint_range(1.0, 50.0) = 5.0;
uniform float specular_intensity:hint_range(0.0, 1.0) = 0.25;
uniform float planet_tilt : hint_range(-2.0, 2.0, 0.1) = 0.15;
uniform float rings_outer_radius : hint_range(0.0, 4.0, 0.1) = 2.0;
uniform float rings_inner_radius = 0.5;
uniform mat3 planet_matrix;

vec3 get_light(vec3 normal, vec3 color, float shadow) {
	vec3 camera_direction = vec3(0.0, 0.0, 1.0);
	vec3 half_vector = normalize( camera_direction + light_direction );
	float diffuse    = max( 0.0, dot( light_direction, normal ) );
	float specular   = pow(max( 0.0, dot( half_vector, normal )), specular_power);
	return ambient_light + color * shadow * light_color.rgb * (diffuse + specular * specular_intensity); 
}

vec3 get_normal(vec2 uv) {
	float z = sqrt(1.0 - ( pow(uv.x, 2.0) + pow(uv.y, 2.0) ));
	return  vec3(uv.x, uv.y, z);
}

vec3 in_shadow(vec3 sphere_position ){
	vec3 rings_normal = vec3(0.0, cos(planet_tilt), -sin(planet_tilt));
	float nv = dot(rings_normal, light_direction);
	if (abs(nv) > 0.0) {
		float t = dot(rings_normal, sphere_position) / nv;
		if (t <= 0.0) {
			vec3 rings_hit = sphere_position - light_direction * t;
			
			float distance_to_hit = length(rings_hit);
			vec3 rings_alpha = vec3(0.0);
			if (distance_to_hit - rings_outer_radius < 0.0){
				//distance_to_hit /= rings_radius;
				
				float x = (distance_to_hit - rings_inner_radius) / (rings_outer_radius - rings_inner_radius);
				rings_alpha = texture(ring_color, vec2(x, 0.5)).aaa;
				return rings_alpha;
			}
		}
	}
	return vec3(0.0);
}

vec2 sphere_to_UV(vec3 sphere_point) {
	vec3 n = normalize(sphere_point);
	return vec2(atan(n.x, n.z) / TAU + 0.5, n.y * 0.5 + 0.5);
	}

void fragment() {
	float scroll = TIME * rotation_speed;
	vec2 uv_centered = UV * margin * 2.0 - margin;
	vec3 sphere_normal = get_normal(uv_centered); // uv to spherical coordinates
	vec3 shadow = in_shadow(sphere_normal);

	vec3 rotated_uv = planet_matrix * sphere_normal ;
	vec2 uv_cordintes = sphere_to_UV(rotated_uv);
	vec3 color = texture(image_color, uv_cordintes).rgb; // sample input texture
	
	COLOR.rgb = get_light(sphere_normal, color, 1.0-shadow.r*0.8); // get light color

	float edge_fade = length(uv_centered);
	COLOR.a = smoothstep(1.0, 0.994, edge_fade); // make edge fade smoothly		
}
