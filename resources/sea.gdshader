shader_type spatial;

uniform vec3 albedo : source_color;
uniform vec3 foam_color: source_color;
uniform vec3 foam_color2: source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;
uniform float foam_step: hint_range(0.0, 1.0) = 0.8;
uniform float foam_step2: hint_range(0.0, 1.0) = 0.6;
uniform float scale_factor: hint_range(0.0, 100.0) = 1.0;

uniform vec2 move = vec2(1.0, 0.0);
uniform vec2 move2 = vec2(0.0, 1.0);
uniform float time_scale = 0.02;

uniform sampler2D foam_strength;


void fragment() {
	vec2 time = fract(TIME * time_scale * move);
	vec2 time2 = fract(TIME * time_scale * move2);
	float foam_value = mix(
		texture(foam_strength, (time + UV) * scale_factor).r,
		texture(foam_strength, (time2 + UV) * scale_factor).r,
		0.5
	);
	
	vec3 surface_color = mix(albedo, foam_color2, foam_value * step(foam_step2, foam_value));
	surface_color = mix(surface_color, foam_color, step(foam_step, foam_value));
	
	ALBEDO = surface_color;
	METALLIC = metallic;
	ROUGHNESS = roughness;
}
