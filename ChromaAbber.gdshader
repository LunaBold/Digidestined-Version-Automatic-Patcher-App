shader_type canvas_item;

uniform float r_displacement : hint_range(-.05,.05) = .0;
uniform float g_displacement : hint_range(-.05,.05) = .0;
uniform float b_displacement : hint_range(-.05,.05) = .0;
uniform float darkness : hint_range(0., 1.) = 0.;

uniform float filterclip = .02;
uniform float pos : hint_range(0., 1., .1) = .1;

void fragment()
{   
	vec2 Rdisplacement = vec2(r_displacement, 0.0);
	vec2 Gdisplacement = vec2(g_displacement, 0.0);
	vec2 Bdisplacement = vec2(b_displacement, 0.0);
	
	float outputr = texture(TEXTURE, UV-Rdisplacement).r;
	float outputg = texture(TEXTURE, UV-Gdisplacement).g;
	float outputb = texture(TEXTURE, UV-Bdisplacement).b;
	
	
	float alpha = 1.;
	
	if (outputr <= filterclip && outputg <= filterclip && outputb <= filterclip) {
		alpha = 0.;
	}
	
	
	COLOR = vec4(outputr*(1.0-darkness), outputg*(1.0-darkness), outputb*(1.0-darkness), alpha);
}