SHADER version 1
@OpenGL2.Vertex
uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];

attribute vec3 vertex_position;

varying vec2 ex_texcoords0;

void main(void)
{
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i], 1.0, 1.0));
	ex_texcoords0 = texcoords[i];
}
@OpenGL2.Fragment
uniform sampler2D texture0;
uniform vec2 buffersize;
uniform vec4 drawcolor;

varying vec2 ex_texcoords0;

void main(void)
{
	gl_FragColor = texture2D(texture0,ex_texcoords0) * drawcolor;
}
@OpenGLES2.Vertex
uniform mediump mat4 projectionmatrix;
uniform mediump mat4 drawmatrix;
uniform mediump vec2 offset;

attribute mediump vec3 vertex_position;
attribute mediump vec2 vertex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(vertex_position, 1.0) + vec4(offset,0,0));
}
@OpenGLES2.Fragment
uniform sampler2D texture0;
uniform mediump vec2 buffersize;

void main(void)
{
	gl_FragDepth = texture2D(texture0,gl_FragCoord/buffersize).r;
}
@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];

//Inputs
in vec3 vertex_position;

//Outputs
out vec2 ex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID], 1.0, 1.0));
	ex_texcoords0 = texcoords[gl_VertexID];
}
@OpenGL4.Fragment
#version 400

//Uniforms
uniform sampler2D texture0;
uniform vec2 buffersize;
uniform vec4 drawcolor;

//Inputs
in vec2 ex_texcoords0;

//Outputs
out vec4 fragData0;

void main(void)
{
	fragData0 = texture(texture0,ex_texcoords0) * drawcolor;
}
