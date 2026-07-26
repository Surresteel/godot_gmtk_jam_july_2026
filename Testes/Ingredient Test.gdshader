shader_type spatial;


uniform float top_cook;
uniform float bot_cook = 1.0;

uniform vec3 base_colour = vec3(0,0,0);
uniform vec3 cooked_colour = vec3(1,1,1);

uniform float split_point = 0.5;
uniform float blend_width = 0.05;

uniform float min_y;
uniform float max_y;
varying float local_y;

void vertex() {
    local_y = VERTEX.y;
}
void fragment() {
float t = (local_y - min_y) / (max_y - min_y);

float top_mask = smoothstep(
    split_point - blend_width,
    split_point + blend_width,
    t
);
vec3 cooked = base_colour * cooked_colour;
vec3 top_gradient = mix(base_colour, cooked, top_cook);
vec3 bot_gradient = mix(base_colour, cooked, bot_cook);
ALBEDO = mix(bot_gradient, top_gradient, top_mask);
}