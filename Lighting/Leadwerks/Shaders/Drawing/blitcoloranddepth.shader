SHADER version 1
@OpenGL2.Vertex
#version 400

//Uniforms
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
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

//Uniforms
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
uniform sampler2D texture1;
uniform vec2 buffersize;
uniform vec4 drawcolor;

//Inputs
in vec2 ex_texcoords0;

//Outputs
out vec4 fragData0;

void main(void)
{
	fragData0 = texture(texture0,ex_texcoords0) * drawcolor;
	gl_FragDepth = texture(texture1,ex_texcoords0).r;
}
