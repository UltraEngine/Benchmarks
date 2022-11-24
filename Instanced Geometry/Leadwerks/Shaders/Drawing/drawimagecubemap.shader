SHADER version 1
@OpenGL2.Vertex
#version 120

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];

attribute vec3 vertex_position;

varying vec3 ex_texcoords0;

void main(void)
{
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i], 1.0, 1.0));
	ex_texcoords0.z = -(texcoords[i].x * 2.0 - 1.0) * 0.5773502691896;
	ex_texcoords0.y = -(texcoords[i].y * 2.0 - 1.0) * 0.5773502691896;
	ex_texcoords0.x = 0.5773502691896;//sqrt(1.0 - ex_texcoords0.x*ex_texcoords0.x - ex_texcoords0.y*ex_texcoords0.y);
}
@OpenGL2.Fragment
#version 120

uniform samplerCube texture0;
uniform vec2 buffersize;
uniform vec4 drawcolor;

varying vec3 ex_texcoords0;

void main(void)
{
	gl_FragColor = textureCube(texture0,ex_texcoords0) * drawcolor;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];

in vec3 vertex_position;

out vec3 ex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID], 1.0, 1.0));
	ex_texcoords0.z = -(texcoords[gl_VertexID].x * 2.0 - 1.0) * 0.5773502691896;
	ex_texcoords0.y = -(texcoords[gl_VertexID].y * 2.0 - 1.0) * 0.5773502691896;
	ex_texcoords0.x = 0.5773502691896;//sqrt(1.0 - ex_texcoords0.x*ex_texcoords0.x - ex_texcoords0.y*ex_texcoords0.y);
}
@OpenGL4.Fragment
#version 400

uniform samplerCube texture0;
uniform vec2 buffersize;
uniform vec4 drawcolor;

in vec3 ex_texcoords0;

out vec4 fragData0;

void main(void)
{
	fragData0 = texture(texture0,ex_texcoords0) * drawcolor;
}
