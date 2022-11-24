SHADER version 1
@OpenGL2.Vertex
#version 400
#define VIRTUAL_TEXTURE_STAGES 1
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform vec3 cameraposition;
uniform float terrainsize;
uniform float texturerange[VIRTUAL_TEXTURE_STAGES];
uniform vec2 renderposition[VIRTUAL_TEXTURE_STAGES];
uniform sampler2D texture0;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0;	

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec3 vertex_normal;

//Varyings
out vec3 vertexposminuscamerapos;
out vec4 ex_color;
out vec3 ex_normal;
out vec3 ex_VertexCameraPosition;
//varying vec2 ex_texcoords[VIRTUAL_TEXTURE_STAGES];
out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out vec2 ex_texcoords2;
out vec2 ex_texcoords3;
out vec2 ex_texcoords4;
out vec2 ex_texcoords5;
out vec2 ex_texcoords6;
out vec2 ex_texcoords7;
out mat3 nmat;
out float clipdistance0;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vec4 modelvertexposition = entitymatrix_ * (vec4(vertex_position,1.0));
		
	ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;
	
	/*ex_texcoords[0] = (modelvertexposition.xz) / terrainsize + 0.5;
	for (int i=1; i<VIRTUAL_TEXTURE_STAGES; i++)
	{
		ex_texcoords[i] = (modelvertexposition.xz - renderposition[i]) / texturerange[i] + 0.5;
	}*/
	
	float terrainheight = length(entitymatrix_[1].xyz);
	modelvertexposition.y = texture(texture0, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * terrainheight;

	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = modelvertexposition.x*clipplane0.x + modelvertexposition.y*clipplane0.y + modelvertexposition.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}

	vertexposminuscamerapos = modelvertexposition.xyz - cameraposition;
	ex_VertexCameraPosition = (camerainversematrix * modelvertexposition).xyz;
	
	gl_Position = projectioncameramatrix * modelvertexposition;
	
	//nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	//nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	nmat = mat3(entitymatrix);
	ex_normal = vertex_normal;//(nmat * vertex_normal);	
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define VIRTUAL_TEXTURE_STAGES 1
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform vec3 cameraposition;
uniform float terrainsize;
uniform float texturerange[VIRTUAL_TEXTURE_STAGES];
uniform vec2 renderposition[VIRTUAL_TEXTURE_STAGES];
uniform sampler2D texture0;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0;	

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec3 vertex_normal;

//Varyings
out vec3 vertexposminuscamerapos;
out vec4 ex_color;
out vec3 ex_normal;
out vec3 ex_VertexCameraPosition;
//varying vec2 ex_texcoords[VIRTUAL_TEXTURE_STAGES];
out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out vec2 ex_texcoords2;
out vec2 ex_texcoords3;
out vec2 ex_texcoords4;
out vec2 ex_texcoords5;
out vec2 ex_texcoords6;
out vec2 ex_texcoords7;
out mat3 nmat;
out float clipdistance0;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vec4 modelvertexposition = entitymatrix_ * (vec4(vertex_position,1.0));
		
	ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;
	
	/*ex_texcoords[0] = (modelvertexposition.xz) / terrainsize + 0.5;
	for (int i=1; i<VIRTUAL_TEXTURE_STAGES; i++)
	{
		ex_texcoords[i] = (modelvertexposition.xz - renderposition[i]) / texturerange[i] + 0.5;
	}*/
	
	float terrainheight = length(entitymatrix_[1].xyz);
	modelvertexposition.y = texture(texture0, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * terrainheight;

	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = modelvertexposition.x*clipplane0.x + modelvertexposition.y*clipplane0.y + modelvertexposition.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}

	vertexposminuscamerapos = modelvertexposition.xyz - cameraposition;
	ex_VertexCameraPosition = (camerainversematrix * modelvertexposition).xyz;
	
	gl_Position = projectioncameramatrix * modelvertexposition;
	
	//nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	//nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	nmat = mat3(entitymatrix);
	ex_normal = vertex_normal;//(nmat * vertex_normal);	
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGL4.Fragment
#version 400
#define VIRTUAL_TEXTURE_STAGES 1

//ins
in vec3 vertexposminuscamerapos;
//==========================================================
// WARNING - in arrays will cause all other ins to be ignored on ATI 3870
//==========================================================
//in vec2 ex_texcoords[VIRTUAL_TEXTURE_STAGES];
in vec2 ex_texcoords0;
in vec2 ex_texcoords1;
in vec2 ex_texcoords2;
in vec2 ex_texcoords3;
in vec2 ex_texcoords4;
in vec2 ex_texcoords5;
in vec2 ex_texcoords6;
in vec2 ex_texcoords7;
in mat3 nmat;
in float clipdistance0;
in vec3 ex_VertexCameraPosition;

//Uniforms
uniform vec4 ambientlight;
uniform float texturerange[VIRTUAL_TEXTURE_STAGES];
uniform vec4 lighting_ambient;
uniform vec4 lightdirection;
uniform vec4 lightcolor;
uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D texture4;
uniform sampler2D texture5;
uniform sampler2D texture6;
uniform sampler2D texture7;
uniform sampler2D texture8;
uniform sampler2D texture9;
uniform sampler2D texture10;
uniform sampler2D texture11;
uniform sampler2D texture12;
uniform sampler2D texture13;
uniform sampler2D texture14;
uniform sampler2D texture15;
uniform mat4 camerainversematrix;

out vec4 fragData0;
out vec4 fragData1;
out vec4 fragData2;
out vec4 fragData3;

void main(void)
{
	//Clip plane discard
	if (clipdistance0>0.0) discard;
	
	vec4 outcolor = texture(texture1,ex_texcoords0);
	vec3 normalcolor = texture(texture8,ex_texcoords0).rbg;
	
	fragData0 = outcolor;
	int materialflags=1+16;//16 for decal mode
	fragData1.rgb = normalcolor;
	fragData1.a = materialflags / 255.0;
	fragData2 = vec4(0.0);
	fragData3 = vec4(ex_VertexCameraPosition,1.0f);
}
