SHADER version 1
@OpenGL2.Vertex
#version 400
#define VIRTUAL_TEXTURE_STAGES 7
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform float terrainsize;
uniform float texturerange[VIRTUAL_TEXTURE_STAGES];
//uniform float terrainheight;
uniform vec2 renderposition[8];
uniform sampler2D texture0;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
//uniform sampler2D texture17;
uniform sampler2D texture8;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec3 vertex_normal;

//Outputs
out vec4 ex_color;
out float ex_selectionstate;
out vec3 ex_VertexCameraPosition;
out vec3 ex_normal;
out vec2 ex_texcoords0;
//out vec2 ex_texcoords1;
//out vec2 ex_texcoords2;
//out vec2 ex_texcoords3;
out float ty;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	//entitymatrix_ * 
	//ex_texcoords0.x = 1.0 - ex_texcoords0.x;
	
	vec4 modelvertexposition = entitymatrix_ * (vec4(vertex_position,1.0));
	
	ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;

	/*ex_texcoords[1] = (modelvertexposition.xz - renderposition[1]) / texturerange[1] + 0.5;
	ex_texcoords[2] = (modelvertexposition.xz - renderposition[2]) / texturerange[2] + 0.5;
	ex_texcoords[3] = (modelvertexposition.xz - renderposition[3]) / texturerange[3] + 0.5;
	ex_texcoords[4] = (modelvertexposition.xz - renderposition[4]) / texturerange[4] + 0.5;
	ex_texcoords[5] = (modelvertexposition.xz - renderposition[5]) / texturerange[5] + 0.5;
	ex_texcoords[6] = (modelvertexposition.xz - renderposition[6]) / texturerange[6] + 0.5;
	ex_texcoords[7] = (modelvertexposition.xz - renderposition[7]) / texturerange[7] + 0.5;*/
	
	float terrainheight = length(entitymatrix_[1].xyz);
	modelvertexposition.y = texture(texture0, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * terrainheight;	
	
	vec2 ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;
	vec4 normalcolor = texture(texture8,ex_texcoords0);
	vec3 normal = normalize( normalcolor.xzy * 2.0 - 1.0 );
	normal.y=0;
	normal=normalize(normal);
	//vec3 offset = normal * normalcolor.a * 8.0;
	//vec3 offset = normal * texture(texture17, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * 8.0;
	//modelvertexposition += vec4(offset,0.0);	
	
	ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);
	gl_Position = projectioncameramatrix * modelvertexposition;
	//ex_VertexCameraPosition = vec3(camerainversematrix * vec4(vertex_position, 1.0));
	//gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);	
	
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
#define VIRTUAL_TEXTURE_STAGES 7
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform float terrainsize;
uniform float texturerange[VIRTUAL_TEXTURE_STAGES];
//uniform float terrainheight;
uniform vec2 renderposition[8];
uniform sampler2D texture0;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
//uniform sampler2D texture17;
uniform sampler2D texture8;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec3 vertex_normal;

//Outputs
out vec4 ex_color;
out float ex_selectionstate;
out vec3 ex_VertexCameraPosition;
out vec3 ex_normal;
out vec2 ex_texcoords0;
//out vec2 ex_texcoords1;
//out vec2 ex_texcoords2;
//out vec2 ex_texcoords3;
out float ty;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	//entitymatrix_ * 
	//ex_texcoords0.x = 1.0 - ex_texcoords0.x;
	
	vec4 modelvertexposition = entitymatrix_ * (vec4(vertex_position,1.0));
	
	ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;

	/*ex_texcoords[1] = (modelvertexposition.xz - renderposition[1]) / texturerange[1] + 0.5;
	ex_texcoords[2] = (modelvertexposition.xz - renderposition[2]) / texturerange[2] + 0.5;
	ex_texcoords[3] = (modelvertexposition.xz - renderposition[3]) / texturerange[3] + 0.5;
	ex_texcoords[4] = (modelvertexposition.xz - renderposition[4]) / texturerange[4] + 0.5;
	ex_texcoords[5] = (modelvertexposition.xz - renderposition[5]) / texturerange[5] + 0.5;
	ex_texcoords[6] = (modelvertexposition.xz - renderposition[6]) / texturerange[6] + 0.5;
	ex_texcoords[7] = (modelvertexposition.xz - renderposition[7]) / texturerange[7] + 0.5;*/
	
	float terrainheight = length(entitymatrix_[1].xyz);
	modelvertexposition.y = texture(texture0, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * terrainheight;	
	
	vec2 ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;
	vec4 normalcolor = texture(texture8,ex_texcoords0);
	vec3 normal = normalize( normalcolor.xzy * 2.0 - 1.0 );
	normal.y=0;
	normal=normalize(normal);
	//vec3 offset = normal * normalcolor.a * 8.0;
	//vec3 offset = normal * texture(texture17, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * 8.0;
	//modelvertexposition += vec4(offset,0.0);	
	
	ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);
	gl_Position = projectioncameramatrix * modelvertexposition;
	//ex_VertexCameraPosition = vec3(camerainversematrix * vec4(vertex_position, 1.0));
	//gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);	
	
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
uniform sampler2D texture8;

//Inputs
in vec2 ex_texcoords0;

//Outputs
out vec4 fragData0;

void main(void)
{
	vec3 normal = texture(texture8,ex_texcoords0).xyz;
	vec4 outcolor = vec4(0.0,0.5,0.0,1.0);
	vec4 lightdir = vec4(-0.4,-0.7,0.5,1.0);
	float intensity = dot(normal,lightdir.xyz);
	outcolor *= 0.75 + intensity * 0.25;
	fragData0 = outcolor;
}
