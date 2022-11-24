SHADER version 1
@OpenGL2.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 cameramatrix;
uniform mat4 camerainversematrix;
uniform mat3 camerainversenormalmatrix;
uniform mat4 projectioncameramatrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec2 vertex_texcoords1;
in vec3 vertex_normal;
in vec3 vertex_tangent;
in vec3 vertex_binormal;

//Outputs
out vec4 ex_vertexposition;
out vec4 ex_color;
out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out float ex_selectionstate;
out vec3 ex_normal;
out vec3 ex_tangent;
out vec3 ex_binormal;
out vec3 ex_VertexCameraPosition;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	ex_vertexposition = entitymatrix_ * vec4(vertex_position, 1.0);
	gl_Position = projectioncameramatrix * ex_vertexposition;
	
	ex_VertexCameraPosition = vec3(camerainversematrix * ex_vertexposition);
	
	ex_texcoords0 = vertex_texcoords0;
	ex_texcoords1 = vertex_texcoords1;
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	ex_selectionstate = 0.0;
	if (ex_color.a<-5.0)
	{
		ex_color.a += 10.0;
		ex_selectionstate = 1.0;
	}
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 cameramatrix;
uniform mat4 camerainversematrix;
uniform mat3 camerainversenormalmatrix;
uniform mat4 projectioncameramatrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec2 vertex_texcoords1;
in vec3 vertex_normal;
in vec3 vertex_tangent;
in vec3 vertex_binormal;

//Outputs
out vec4 ex_vertexposition;
out vec4 ex_color;
out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out float ex_selectionstate;
out vec3 ex_normal;
out vec3 ex_tangent;
out vec3 ex_binormal;
out vec3 ex_VertexCameraPosition;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	ex_vertexposition = entitymatrix_ * vec4(vertex_position, 1.0);
	gl_Position = projectioncameramatrix * ex_vertexposition;
	
	ex_VertexCameraPosition = vec3(camerainversematrix * ex_vertexposition);
	
	ex_texcoords0 = vertex_texcoords0;
	ex_texcoords1 = vertex_texcoords1;
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	ex_selectionstate = 0.0;
	if (ex_color.a<-5.0)
	{
		ex_color.a += 10.0;
		ex_selectionstate = 1.0;
	}
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGL4.Fragment
#version 400

//Uniforms	
uniform samplerCube texture0;//cube map
uniform vec3 cameraposition;
uniform vec2 camerarange;

//Inputs
in vec4 ex_vertexposition;
in float ex_selectionstate;
in vec3 ex_VertexCameraPosition;

out vec4 fragData0;
out vec4 fragData1;
out vec4 fragData2;
out vec4 fragData3;

void main(void)
{
	vec3 cubecoord = normalize( ex_vertexposition.xyz - cameraposition );
	vec4 outcolor = texture(texture0,cubecoord);
	fragData0 = outcolor * (1.0-ex_selectionstate) + ex_selectionstate * (outcolor*0.5+vec4(0.5,0.0,0.0,0.0));
	fragData1 = vec4(0.0);
	fragData2 = vec4(0.0,0.0,0.0,0.0);
	fragData3 = vec4(ex_VertexCameraPosition,1.0f);
}
