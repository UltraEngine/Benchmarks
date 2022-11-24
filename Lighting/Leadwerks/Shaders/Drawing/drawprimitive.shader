SHADER version 1
@OpenGL2.Vertex
uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;

attribute vec3 vertex_position;

uniform vec2 position[4];

void main(void)
{
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i]+offset, 0.0, 1.0));
}
@OpenGL2.Fragment
uniform vec4 drawcolor;

void main(void)
{
    gl_FragData[0] = drawcolor;
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
uniform vec2 position[256];

in vec3 vertex_position;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID]+offset, 0.0, 1.0));
}
@OpenGL4.Fragment
#version 400

uniform vec4 drawcolor;

out vec4 fragData0;

void main(void)
{
    fragData0 = drawcolor;
}
