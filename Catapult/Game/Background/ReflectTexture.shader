shader_type canvas_item;
render_mode blend_mix;

uniform float noiseSize : hint_range(0, 50) = 15.0;
uniform float speed : hint_range(-10.0, 10.0);
uniform float albedo : hint_range(0.0, 1.0) = 0.7;

float rand(vec2 coord) {
	return fract(sin(dot(coord, vec2(35, 62)) * 1000.0) * 1000.0);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

void fragment() {
	// get texture size in floats
	ivec2 ITexSize = textureSize(TEXTURE, 0);
	vec2 TSize = vec2(float(ITexSize.x), float(ITexSize.y));
	
	// pixelize UV
	vec2 uv = floor(UV * TSize)/TSize;
	
	// read colors with y inversed, for mirror effect
	vec4 col = texture(TEXTURE, vec2(UV.x, 1.0-uv.y));
	
	// make some noise
	float n = noise((uv*noiseSize) + vec2(TIME,0.0)*speed);
	
	// decrease noise value the lower down texture is.
	n *= (1.0 - uv.y);
	
	// remove noise value every 2nd pixel, creating an empty line
	col.a *= step(1.0, mod(UV.y * TSize.y, 2.0));
	
	// set alpha to 0 or 1
	col.a *= step(1.0-albedo, n);
	
	COLOR = col;
}