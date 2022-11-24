SHADER version 1
@OpenGL2.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform float resolution;
uniform vec2 position[4];
uniform vec2 texcoords[4];

in vec3 vertex_position;
in vec2 vertex_texcoords0;

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
uniform vec2 position[4];
uniform vec2 texcoords[4];

in vec3 vertex_position;
in vec2 vertex_texcoords0;

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
uniform usampler2D texture0;
uniform vec2 toolposition;
uniform int layerindex=0;

in vec2 ex_texcoords0;
in vec4 vertexposition;

out uvec4 fragData0;

void main(void)
{
	uint current = texture(texture0,ex_texcoords0).r;
	float d = length(vertexposition.xy-toolposition);
	d = 1.0 - (d - toolradius[1]);
	d = clamp(d,0.0,1.0);
	if (d<=0.0) discard;
	int bit = 0;
	if (strength>0.0)
	{
		current = current | int(pow(2,layerindex));
	}
	else
	{
		current = current & ~int(pow(2,layerindex));
	}
	fragData0 = uvec4(current);
}
