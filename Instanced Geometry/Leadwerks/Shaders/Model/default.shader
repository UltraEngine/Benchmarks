SHADER version 1
@OpenGL2.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
//uniform mat4 entitymatrix;
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0 = vec4(0.0);

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec3 vertex_normal;
in vec3 vertex_binormal;
in vec3 vertex_tangent;
in vec2 vertex_texcoords0;

//Outputs
//out vec4 ex_color;
out float ex_selectionstate;
//out vec3 ex_VertexCameraPosition;
//out vec3 ex_normal;
//out vec2 ex_texcoords0;

//Tessellation
out vec4 vPosition;
out vec2 vTexCoords0;
out vec3 vNormal;
out vec3 vBinormal;
out vec3 vTangent;
out vec4 vColor;
out float clipdistance0;
out vec3 ex_VertexCameraPosition;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vColor=vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	//ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);

	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = modelvertexposition.x*clipplane0.x + modelvertexposition.y*clipplane0.y + modelvertexposition.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}	

	vPosition = modelvertexposition;
	ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);
	gl_Position = projectioncameramatrix * vPosition;
	
	//ctrl_transformmatrix = projectioncameramatrix * entitymatrix_;
	
	//ex_VertexCameraPosition = vec3(camerainversematrix * vec4(vertex_position, 1.0));
	//gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	//mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	mat3 nmat = mat3(entitymatrix);
	vNormal = normalize(nmat * vertex_normal);	
	vBinormal = normalize(nmat * vertex_binormal);	
	vTangent = normalize(nmat * vertex_tangent);		
	
	vTexCoords0 = vertex_texcoords0;
	
	vColor = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	
	ex_selectionstate = 0.0;
	if (vColor.a<-5.0)
	{
		vColor.a += 10.0;
		ex_selectionstate = 1.0;
	}
	vColor *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
	
	//Tessellation
	//vPosition = entitymatrix_ * vec4(vertex_position,1.0);
	//ctrl_normal = ex_normal;	
	//ctrl_color = ex_color;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
//uniform mat4 entitymatrix;
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0 = vec4(0.0);

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec3 vertex_normal;
in vec3 vertex_binormal;
in vec3 vertex_tangent;
in vec2 vertex_texcoords0;

//Outputs
//out vec4 ex_color;
out float ex_selectionstate;
//out vec3 ex_VertexCameraPosition;
//out vec3 ex_normal;
//out vec2 ex_texcoords0;

//Tessellation
out vec4 vPosition;
out vec2 vTexCoords0;
out vec3 vNormal;
out vec3 vBinormal;
out vec3 vTangent;
out vec4 vColor;
out float clipdistance0;
out vec3 ex_VertexCameraPosition;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vColor=vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	//ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);

	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = modelvertexposition.x*clipplane0.x + modelvertexposition.y*clipplane0.y + modelvertexposition.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}	

	vPosition = modelvertexposition;
	ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);
	gl_Position = projectioncameramatrix * vPosition;
	
	//ctrl_transformmatrix = projectioncameramatrix * entitymatrix_;
	
	//ex_VertexCameraPosition = vec3(camerainversematrix * vec4(vertex_position, 1.0));
	//gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	//mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	mat3 nmat = mat3(entitymatrix);
	vNormal = normalize(nmat * vertex_normal);	
	vBinormal = normalize(nmat * vertex_binormal);	
	vTangent = normalize(nmat * vertex_tangent);		
	
	vTexCoords0 = vertex_texcoords0;
	
	vColor = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	
	ex_selectionstate = 0.0;
	if (vColor.a<-5.0)
	{
		vColor.a += 10.0;
		ex_selectionstate = 1.0;
	}
	vColor *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
	
	//Tessellation
	//vPosition = entitymatrix_ * vec4(vertex_position,1.0);
	//ctrl_normal = ex_normal;	
	//ctrl_color = ex_color;
}
@OpenGL4.Fragment
#version 400
#define BFN_ENABLED 1

//Uniforms	
uniform int lightingmode;
uniform vec2 buffersize;
uniform vec2 camerarange;
uniform float camerazoom;
uniform vec4 materialcolorspecular;
uniform vec4 lighting_ambient;
uniform samplerCube texture15;
uniform int decalmode;
uniform float materialroughness;

//Inputs
in float ex_selectionstate;
in vec2 vTexCoords0;
in vec3 vNormal;
in vec3 vBinormal;
in vec3 vTangent;
in vec4 vColor;
in float clipdistance0;
in vec3 ex_VertexCameraPosition;

//Outputs
out vec4 fragData0;
out vec4 fragData1;
out vec4 fragData2;
out vec4 fragData3;

void main(void)
{
	//Clip plane discard
	if (clipdistance0>0.0) discard;
	
	vec4 outcolor = vColor;
	fragData0 = outcolor;
	
	
	
	//Blend with selection color if selected
	fragData0 = outcolor;// * (1.0-ex_selectionstate) + ex_selectionstate * (outcolor*0.5+vec4(0.5,0.0,0.0,0.0));	
	
	vec3 normal=vNormal;
	
#if BFN_ENABLED==1
	//Best-fit normals
	fragData1 = texture(texture15,normalize(vec3(normal.x,-normal.y,normal.z)));
	fragData1.a = fragData0.a;
#else
	//Low-res normals
	fragData1 = vec4(normalize(normal)*0.5+0.5,fragData0.a);
#endif
	float specular = materialcolorspecular.r * 0.299 + materialcolorspecular.g * 0.587 + materialcolorspecular.b * 0.114;
	int materialflags=1;
	if (ex_selectionstate>0.0) materialflags += 2;
	if (decalmode==1) materialflags += 4;//brush
	if (decalmode==2) materialflags += 8;//model
	if (decalmode==4) materialflags += 16;//terrain
		if (materialroughness>=0.5)
	{
		materialflags += 32;
		if (materialroughness>=0.75) materialflags += 64;
	}
	else
	{
		if (materialroughness>=0.25) materialflags += 64;
	}
	fragData1.a = materialflags/255.0;
	fragData2 = vec4(0.0,0.0,0.0,specular);
	fragData3 = vec4(ex_VertexCameraPosition,1.0f);
}
