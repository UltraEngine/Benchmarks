SHADER version 1
@OpenGL2.Vertex
//Uniforms
uniform mat4 projectioncameramatrix;
uniform mat4 entitymatrix;

//Attributes
attribute vec3 vertex_position;

void main(void)
{
	gl_Position = projectioncameramatrix * entitymatrix * vec4(vertex_position, 1.0);
}
@OpenGL2.Fragment
void main(void)
{
}
@OpenGLES2.Vertex
//Uniforms
uniform highp mat4 projectioncameramatrix;
uniform highp mat4 entitymatrix;

//Attributes
attribute highp vec3 vertex_position;

void main(void)
{
	gl_Position = projectioncameramatrix * entitymatrix * vec4(vertex_position, 1.0);
}
@OpenGLES2.Fragment
void main(void)
{
}
@OpenGL4.Vertex
#version 400

//Uniforms
uniform mat4 projectioncameramatrix;
uniform mat4 entitymatrix;

//Inputs
in vec3 vertex_position;

void main(void)
{
	gl_Position = projectioncameramatrix * entitymatrix * vec4(vertex_position, 1.0);
}
