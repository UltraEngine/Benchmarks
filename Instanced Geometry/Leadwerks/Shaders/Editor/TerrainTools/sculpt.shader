SHADER version 1
@OpenGL2.Vertex
uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;

attribute vec3 vertex_position;
attribute vec2 vertex_texcoords0;

uniform vec2 position[4];
uniform vec2 texcoords[4];

varying vec2 ex_texcoords0;
varying vec4 vertexposition;

void main(void)
{
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	vertexposition = (drawmatrix * vec4(position[i], 0.0, 1.0));
	gl_Position = projectionmatrix * vertexposition;
	ex_texcoords0 = texcoords[i];
}
@OpenGL2.Fragment
uniform vec4 drawcolor;
uniform vec2 toolradius;
uniform float strength;
uniform sampler2D texture0;
uniform vec2 toolposition;

varying vec2 ex_texcoords0;
varying vec4 vertexposition;

void main(void)
{
	float current = texture2D(texture0,ex_texcoords0).r;
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
	d *= 0.002 * strength;
	gl_FragData[0] = vec4(clamp(current+d,0.0,1.0),0.0,0.0,0.0);
}
@OpenGLES2.Vertex
uniform mediump mat4 projectionmatrix;
uniform highp mat4 drawmatrix;
uniform mediump vec2 offset;

attribute mediump vec4 vertex_position;
attribute mediump vec4 vertex_color;
attribute mediump vec2 vertex_texcoords0;
attribute mediump vec2 vertex_texcoords1;
attribute mediump vec3 vertex_normal;
 
void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vertex_position + vec4(offset.x,offset.y,0.0,0.0));
}
@OpenGLES2.Fragment
uniform mediump vec4 drawcolor;

void main(void)
{
    gl_FragData[0] = drawcolor;
}
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
uniform sampler2D texture0;
uniform vec2 toolposition;

in vec2 ex_texcoords0;
in vec4 vertexposition;

out vec4 fragData0;

void main(void)
{
	float current = texture(texture0,ex_texcoords0).r;
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
	d *= 0.002 * strength;
	fragData0 = vec4(clamp(current+d,0.0,1.0),0.0,0.0,0.0);
}
