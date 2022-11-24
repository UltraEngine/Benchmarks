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
	//ex_texcoords0 = texcoords[i];
	
	//gl_Position = projectionmatrix * (drawmatrix * vec4(vertex_position, 1.0) + vec4(offset,0,0));
}
@OpenGL2.Fragment
uniform vec4 drawcolor;

void main(void)
{
    gl_FragData[0] = vec4(1.0,1.0,1.0,1.0);
    gl_FragData[1] = vec4(0.5,0.5,1.0,1.0);
}
@OpenGLES2.Vertex
precision highp float;

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;

attribute vec4 vertex_position;
attribute vec2 vertex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vertex_position + vec4(offset,0,0));
}
@OpenGLES2.Fragment
precision highp float;

uniform vec4 drawcolor;

void main(void)
{
    gl_FragData[0] = vec4(1.0,1.0,1.0,1.0);
    //gl_FragData[1] = vec4(normalize(vec3(0.5,0.5,1.0)),1.0);
}
@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];

in vec3 vertex_position;

void main(void)
{
    int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i]+offset, 0.0, 1.0));
	//ex_texcoords0 = texcoords[i];
	
	//gl_Position = projectionmatrix * (drawmatrix * vec4(vertex_position, 1.0) + vec4(offset,0,0));
}
@OpenGL4.Fragment
#version 400

uniform vec4 drawcolor;

out vec4 fragData0;
out vec4 fragData1;

void main(void)
{
    fragData0 = vec4(1.0,1.0,1.0,1.0);
    fragData1 = vec4(0.5,0.5,1.0,1.0);
}
