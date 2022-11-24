SHADER version 1
@OpenGL2.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
//uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0 = vec4(0.0);

//Inputs
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;

//Outputs
out vec4 ex_color;
out vec2 texcoords0;
out float clipdistance0;

void main ()
{
	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = vertex_position.x*clipplane0.x + vertex_position.y*clipplane0.y + vertex_position.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}	
	
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	gl_Position = projectioncameramatrix * vec4(vertex_position, 1.0);
	ex_color.r = 1.0 - vertex_color.r;
	ex_color.g = 1.0 - vertex_color.g;
	ex_color.b = 1.0 - vertex_color.b;
	ex_color.a = vertex_color.a;
	
	ex_color.r *= entitymatrix[0][3];
	ex_color.g *= entitymatrix[1][3];
	ex_color.b *= entitymatrix[2][3];
	ex_color.a *= entitymatrix[3][3];
	
	texcoords0 = vertex_texcoords0;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
//uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0 = vec4(0.0);

//Inputs
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;

//Outputs
out vec4 ex_color;
out vec2 texcoords0;
out float clipdistance0;

void main ()
{
	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = vertex_position.x*clipplane0.x + vertex_position.y*clipplane0.y + vertex_position.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}	
	
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	gl_Position = projectioncameramatrix * vec4(vertex_position, 1.0);
	ex_color.r = 1.0 - vertex_color.r;
	ex_color.g = 1.0 - vertex_color.g;
	ex_color.b = 1.0 - vertex_color.b;
	ex_color.a = vertex_color.a;
	
	ex_color.r *= entitymatrix[0][3];
	ex_color.g *= entitymatrix[1][3];
	ex_color.b *= entitymatrix[2][3];
	ex_color.a *= entitymatrix[3][3];
	
	texcoords0 = vertex_texcoords0;
}
@OpenGL4.Fragment
#version 400

//Uniforms
uniform sampler2D texture0;
uniform vec4 materialcolordiffuse;

//Inputs
in vec4 ex_color;
in vec2 texcoords0;
in float clipdistance0;

//Outputs
out vec4 fragData0;

void main()
{
	//Clip plane discard
	if (clipdistance0>0.0) discard;
	
	fragData0 = ex_color * texture(texture0,texcoords0) * materialcolordiffuse;
}
