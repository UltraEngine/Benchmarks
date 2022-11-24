SHADER version 1
@OpenGL2.Vertex
uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];
uniform float rotation;

attribute vec3 vertex_position;

varying vec2 ex_texcoords0;

uniform vec3 stampscale;

void main(void)
{
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i], 1.0, 1.0));
	//gl_Position = projectionmatrix * (drawmatrix * vec4(vertex_position * stampscale, 1.0));
	
	//ex_texcoords0 = texcoords[i];
	
	float sa = sin(rotation);
	float ca = cos(rotation);
	ex_texcoords0.x = (sa * (texcoords[i].x-0.5) + ca * (texcoords[i].y-0.5)) + 0.5;
	ex_texcoords0.y = (sa * (texcoords[i].y-0.5) - ca * (texcoords[i].x-0.5)) + 0.5;
}
@OpenGL2.Fragment
uniform sampler2D texture0;
uniform vec2 buffersize;
uniform vec4 stampcolor;

varying vec2 ex_texcoords0;

void main(void)
{
	if (ex_texcoords0.x<0.0 || ex_texcoords0.x>1.0 || ex_texcoords0.y<0.0 || ex_texcoords0.y>1.0) discard;
	gl_FragColor = texture2D(texture0,ex_texcoords0) * stampcolor;
}
@OpenGLES2.Vertex
uniform mediump mat4 projectionmatrix;
uniform mediump mat4 drawmatrix;
uniform mediump vec2 offset;

attribute mediump vec3 vertex_position;
attribute mediump vec2 vertex_texcoords0;

varying mediump vec2 ex_texcoords0;
uniform float rotation;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(vertex_position, 1.0) + vec4(offset,0,0));
	float sa = sin(rotation);
	float ca = cos(rotation);
	ex_texcoords0.x = sa * vertex_texcoords0.x + ca * vertex_texcoords0.y;
	ex_texcoords0.y = sa * vertex_texcoords0.y + ca * vertex_texcoords0.x;
}
@OpenGLES2.Fragment
uniform sampler2D texture0;
uniform mediump vec2 buffersize;
uniform mediump vec4 drawcolor;

varying mediump vec2 ex_texcoords0;

void main(void)
{
	gl_FragData[0] = texture2D(texture0,ex_texcoords0) * drawcolor;
}
@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];
uniform float rotation;
uniform vec3 stampscale;

in vec3 vertex_position;

out vec2 ex_texcoords0;

void main(void)
{
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i], 1.0, 1.0));
	//gl_Position = projectionmatrix * (drawmatrix * vec4(vertex_position * stampscale, 1.0));
	
	//ex_texcoords0 = texcoords[i];
	
	float sa = sin(rotation);
	float ca = cos(rotation);
	ex_texcoords0.x = (sa * (texcoords[i].x-0.5) + ca * (texcoords[i].y-0.5)) + 0.5;
	ex_texcoords0.y = (sa * (texcoords[i].y-0.5) - ca * (texcoords[i].x-0.5)) + 0.5;
}
@OpenGL4.Fragment
#version 400

uniform sampler2D texture0;
uniform vec2 buffersize;
uniform vec4 stampcolor;

in vec2 ex_texcoords0;

out vec4 fragData0;

void main(void)
{
	if (ex_texcoords0.x<0.0 || ex_texcoords0.x>1.0 || ex_texcoords0.y<0.0 || ex_texcoords0.y>1.0) discard;
	fragData0 = texture(texture0,ex_texcoords0) * stampcolor;
}
