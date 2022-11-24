SHADER version 1
@OpenGL2.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform float resolution;

in vec3 vertex_position;
in vec2 vertex_texcoords0;

uniform vec2 position[4];
uniform vec2 texcoords[4];

out vec2 ex_texcoords0;
out vec4 vertexposition;

void main(void)
{
	vertexposition = (drawmatrix * vec4(position[gl_VertexID], 0.0, 1.0));
	gl_Position = projectionmatrix * vertexposition;
	ex_texcoords0 = texcoords[gl_VertexID];
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform float resolution;

in vec3 vertex_position;
in vec2 vertex_texcoords0;

uniform vec2 position[4];
uniform vec2 texcoords[4];

out vec2 ex_texcoords0;
out vec4 vertexposition;

void main(void)
{
	vertexposition = (drawmatrix * vec4(position[gl_VertexID], 0.0, 1.0));
	gl_Position = projectionmatrix * vertexposition;
	ex_texcoords0 = texcoords[gl_VertexID];
}
@OpenGL4.Fragment
#version 400

uniform vec4 drawcolor;
uniform vec2 toolradius;
uniform float strength;
uniform sampler2D texture0;
uniform float imagesize;
uniform vec2 toolposition;

in vec2 ex_texcoords0;
in vec4 vertexposition;

out vec4 fragData0;

void main(void)
{
	//Calculate distance attenuation
	float d = length(vertexposition.xy-toolposition);
	if (toolradius[1]-toolradius[0]>0.0)
	{
		d = 1.0 - (d - toolradius[0]) /(toolradius[1]-toolradius[0]);
	}
	else
	{
		d = 1.0 - (d - toolradius[0]);
	}
	d = clamp(d,0.0,1.0);
	
	float offset = 1.0 / imagesize;
	float f = 1.0;
	float h0 = texture(texture0,ex_texcoords0).r;
	
	float h1 = texture(texture0,ex_texcoords0 + vec2(-offset,-offset)).r;
	h1 += texture(texture0,ex_texcoords0 + vec2(0,-offset)).r;
	h1 += texture(texture0,ex_texcoords0 + vec2(offset,-offset)).r;
	
	h1 += texture(texture0,ex_texcoords0 + vec2(-offset,0)).r;
	h1 += texture(texture0,ex_texcoords0 + vec2(0,0)).r;
	h1 += texture(texture0,ex_texcoords0 + vec2(offset,0)).r;
	
	h1 += texture(texture0,ex_texcoords0 + vec2(-offset,offset)).r;
	h1 += texture(texture0,ex_texcoords0 + vec2(0,offset)).r;
	h1 += texture(texture0,ex_texcoords0 + vec2(offset,offset)).r;
	
	h1 /= 9.0;
	
	d *= abs(strength);
	
	fragData0 = vec4(clamp(h0*(1.0-d)+h1*d,0.0,1.0),0.0,0.0,0.0);
}
