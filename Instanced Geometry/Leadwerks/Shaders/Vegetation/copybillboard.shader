SHADER version 1
@OpenGL2.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];

in vec3 vertex_position;
in vec2 vertex_texcoords0;

out vec2 vTexCoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID], 0.0, 1.0));
	vTexCoords0 = texcoords[gl_VertexID];
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
in vec2 vertex_texcoords0;

out vec2 vTexCoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID], 0.0, 1.0));
	vTexCoords0 = texcoords[gl_VertexID];
}
@OpenGL4.Fragment
#version 400

uniform vec4 drawcolor;
uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;

in vec2 vTexCoords0;

out vec4 fragData0;
out vec4 fragData1;
out vec4 fragData2;

void main(void)
{
	fragData0 = texture(texture0,vTexCoords0);
	fragData1 = texture(texture1,vTexCoords0);
	fragData2 = texture(texture2,vTexCoords0);
}
