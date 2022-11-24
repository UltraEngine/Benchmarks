SHADER version 1
@OpenGL2.Vertex
uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];
uniform vec2 drawoffset;

attribute vec3 vertex_position;

varying vec2 ex_texcoords0;

void main(void)
{
	//mat4 drawmatrix_ = drawmatrix;
	//drawmatrix_[3][0]+=drawoffset.x;
	//drawmatrix_[3][1]+=drawoffset.y;
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i], 1.0, 1.0));
	ex_texcoords0 = texcoords[i];
}
@OpenGL2.Fragment
#version 120

uniform vec4 drawcolor;
uniform sampler2D texture0;

varying vec2 ex_texcoords0;

void main(void)
{
	vec4 color = drawcolor;
	color.a *= texture2D(texture0,ex_texcoords0).a;
	gl_FragColor = color;
}
@OpenGLES2.Vertex
uniform mediump mat4 projectionmatrix;
uniform mediump mat4 drawmatrix;
uniform mediump vec2 offset;
uniform mediump vec2 position[4];
uniform mediump vec2 texcoords[4];
uniform mediump vec2 drawoffset;

attribute mediump vec3 vertex_position;

varying mediump vec2 ex_texcoords0;

void main(void)
{
	mediump mat4 drawmatrix_ = drawmatrix;
	drawmatrix_[3][0]+=drawoffset.x;
	drawmatrix_[3][1]+=drawoffset.y;
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix_ * vec4(position[i], 1.0, 1.0));
	ex_texcoords0 = texcoords[i];
}
@OpenGLES2.Fragment
uniform mediump vec4 drawcolor;
uniform sampler2D texture0;

varying mediump vec2 ex_texcoords0;

void main(void)
{
	mediump vec4 color = drawcolor;
	color.a *= texture2D(texture0,ex_texcoords0).a;
	gl_FragColor = color;
}
@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];
uniform vec2 drawoffset;

in vec3 vertex_position;
in vec2 vertex_texcoords0;

out vec2 ex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID], 1.0, 1.0));
	ex_texcoords0 = texcoords[gl_VertexID];
}
@OpenGL4.Fragment
#version 400

uniform vec4 drawcolor;
uniform sampler2D texture0;

in vec2 ex_texcoords0;

out vec4 fragData0;

void main(void)
{
	vec4 color = drawcolor;
	color.a *= texture(texture0,ex_texcoords0).a;
	fragData0 = color;
}
