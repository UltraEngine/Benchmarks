SHADER version 1
@OpenGL2.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0 = vec4(0.0);

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec3 vertex_normal;
in vec3 vertex_binormal;
in vec3 vertex_tangent;

//Outputs
out vec4 vPosition;
out vec4 vColor;
out vec2 vTexCoords0;
out vec3 vNormal;
out vec3 vTangent;
out vec3 vBinormal;
out float vSelectionState;
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
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	
	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = modelvertexposition.x*clipplane0.x + modelvertexposition.y*clipplane0.y + modelvertexposition.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}		
	
	//ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);
	//gl_Position = projectioncameramatrix * modelvertexposition;
	vPosition = modelvertexposition;

	//mat3 normalmatrix = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	//normalmatrix = normalmatrix * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	mat3 normalmatrix = mat3(entitymatrix_);
	vNormal = normalize(normalmatrix * vertex_normal);	
	vTangent = normalize(normalmatrix * vertex_tangent);
	vBinormal = normalize(normalmatrix * vertex_binormal);
	
	vTexCoords0 = vertex_texcoords0;
	
	vColor = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	vSelectionState = 0.0;
	if (vColor.a<-5.0)
	{
		vColor.a += 10.0;
		vSelectionState = 1.0;
	}
	vColor *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGL2.Fragment
#version 400

//Layout
layout(vertices = 3) out;

//Uniforms
uniform float tessstrength;
uniform mat4 entitymatrix;
uniform vec3 cameraposition;

//Inputs
in vec2 vTexCoords0[];
in vec3 vNormal[];
in vec3 vBinormal[];
in vec3 vTangent[];
in vec4 vColor[];
in vec4 vPosition[];
in float vSelectionState[];
in float clipdistance0[];

//Outputs
out vec4 cPosition[];
out vec2 cTexCoords0[];
out vec3 cNormal[];
out vec3 cBinormal[];
out vec3 cTangent[];
out vec4 cColor[];
out float cSelectionState[];
out float cclipdistance0[];

void main()
{
	cSelectionState[gl_InvocationID] = vSelectionState[gl_InvocationID];
	cPosition[gl_InvocationID] = vPosition[gl_InvocationID];
	cTexCoords0[gl_InvocationID] = vTexCoords0[gl_InvocationID];
	cNormal[gl_InvocationID] = vNormal[gl_InvocationID];
	cBinormal[gl_InvocationID] = vBinormal[gl_InvocationID];
	cTangent[gl_InvocationID] = vTangent[gl_InvocationID];
	cColor[gl_InvocationID] = vColor[gl_InvocationID];
	cclipdistance0[gl_InvocationID] = clipdistance0[gl_InvocationID];
	
	float MaxTess = 1.0 * tessstrength;
	float TessDistance = 8.0;
	
	gl_TessLevelInner[0] = max(1.0, tessstrength * (MaxTess * (1.0 - length(entitymatrix[3].xyz - cameraposition) / TessDistance)));	
	
	if (gl_InvocationID==0)
	{
		float TessLevelOuter = max(1.0, tessstrength * (MaxTess * (1.0 - length(entitymatrix[3].xyz - cameraposition) / TessDistance)));
		gl_TessLevelOuter[0] = TessLevelOuter;
		gl_TessLevelOuter[1] = TessLevelOuter;
		gl_TessLevelOuter[2] = TessLevelOuter;
	}
}
@OpenGLES2.Vertex
#version 400
#define TESS_USE_NORMALMAP 0

//Layout
layout(triangles, equal_spacing, ccw) in;

//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform sampler2D texture1;
uniform sampler2D texture3;
uniform mat4 camerainversematrix;

//Inputs
in vec4 cPosition[];
in vec2 cTexCoords0[];
in vec3 cNormal[];
in vec3 cBinormal[];
in vec3 cTangent[];
in vec4 cColor[];
in float cSelectionState[];
in float cclipdistance0[];

//Outputs
out vec2 vTexCoords0;
out vec3 vNormal;
out vec3 vBinormal;
out vec3 vTangent;
out vec4 vColor;
out vec4 vPosition;
out float vSelectionState;
out float clipdistance0;

void main()
{
	float DisplacementStrength = 0.02;
	
	vSelectionState = cSelectionState[0];

	//Get tex coords
	vTexCoords0 = cTexCoords0[0] * gl_TessCoord.x + cTexCoords0[1] * gl_TessCoord.y + cTexCoords0[2] * gl_TessCoord.z;
	
	//Lookup displacement
	float height = texture(texture3,vTexCoords0).r;
	
	//Get normal
	vNormal = cNormal[0] * gl_TessCoord.x + cNormal[1] * gl_TessCoord.y + cNormal[2] * gl_TessCoord.z;
	vBinormal = cBinormal[0] * gl_TessCoord.x + cBinormal[1] * gl_TessCoord.y + cBinormal[2] * gl_TessCoord.z;
	vTangent = cTangent[0] * gl_TessCoord.x + cTangent[1] * gl_TessCoord.y + cTangent[2] * gl_TessCoord.z;
	vColor = cColor[0] * gl_TessCoord.x + cColor[1] * gl_TessCoord.y + cColor[2] * gl_TessCoord.z;
	clipdistance0 = cclipdistance0[0] * gl_TessCoord.x + cclipdistance0[1] * gl_TessCoord.y + cclipdistance0[2] * gl_TessCoord.z;
	
	//Normal lookup
	vec3 normal = vNormal;
#if TESS_USE_NORMALMAP==1
	//Using a normal map lookup is technically more accurate, but results in noisy geometry
	normal = texture(texture1,vTexCoords0).xyz * 2.0 - 1.0;
	normal = vTangent*normal.x + vBinormal*normal.y + vNormal*normal.z;	
	normal=normalize(normal);
#endif
	
	mat3 normalmatrix = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
	vNormal = normalize(normalmatrix * vNormal);
	vBinormal = normalize(normalmatrix * vBinormal);
	vTangent = normalize(normalmatrix * vTangent);
	
	//Calculate displacement
	vec4 displacement = vec4( normal * (height-0.5) * DisplacementStrength * 2.0, 0.0 );//(height * DisplacementStrength - DisplacementStrength * 0.5), 1.0);
	
	//vPosition = vec4(displacement,1.0) + cPosition[0] * gl_TessCoord.x + cPosition[1] * gl_TessCoord.y + cPosition[2] * gl_TessCoord.z;
	vPosition = displacement + cPosition[0] * gl_TessCoord.x + cPosition[1] * gl_TessCoord.y + cPosition[2] * gl_TessCoord.z;
	gl_Position = projectioncameramatrix * vPosition;
}
@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0 = vec4(0.0);

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec3 vertex_normal;
in vec3 vertex_binormal;
in vec3 vertex_tangent;

//Outputs
out vec4 vPosition;
out vec4 vColor;
out vec2 vTexCoords0;
out vec3 vNormal;
out vec3 vTangent;
out vec3 vBinormal;
out float vSelectionState;
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
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	
	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = modelvertexposition.x*clipplane0.x + modelvertexposition.y*clipplane0.y + modelvertexposition.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}		
	
	//ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);
	//gl_Position = projectioncameramatrix * modelvertexposition;
	vPosition = modelvertexposition;

	//mat3 normalmatrix = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	//normalmatrix = normalmatrix * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	mat3 normalmatrix = mat3(entitymatrix_);
	vNormal = normalize(normalmatrix * vertex_normal);	
	vTangent = normalize(normalmatrix * vertex_tangent);
	vBinormal = normalize(normalmatrix * vertex_binormal);
	
	vTexCoords0 = vertex_texcoords0;
	
	vColor = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	vSelectionState = 0.0;
	if (vColor.a<-5.0)
	{
		vColor.a += 10.0;
		vSelectionState = 1.0;
	}
	vColor *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGL4.Control
#version 400

//Layout
layout(vertices = 3) out;

//Uniforms
uniform float tessstrength;
uniform mat4 entitymatrix;
uniform vec3 cameraposition;

//Inputs
in vec2 vTexCoords0[];
in vec3 vNormal[];
in vec3 vBinormal[];
in vec3 vTangent[];
in vec4 vColor[];
in vec4 vPosition[];
in float vSelectionState[];
in float clipdistance0[];

//Outputs
out vec4 cPosition[];
out vec2 cTexCoords0[];
out vec3 cNormal[];
out vec3 cBinormal[];
out vec3 cTangent[];
out vec4 cColor[];
out float cSelectionState[];
out float cclipdistance0[];

void main()
{
	cSelectionState[gl_InvocationID] = vSelectionState[gl_InvocationID];
	cPosition[gl_InvocationID] = vPosition[gl_InvocationID];
	cTexCoords0[gl_InvocationID] = vTexCoords0[gl_InvocationID];
	cNormal[gl_InvocationID] = vNormal[gl_InvocationID];
	cBinormal[gl_InvocationID] = vBinormal[gl_InvocationID];
	cTangent[gl_InvocationID] = vTangent[gl_InvocationID];
	cColor[gl_InvocationID] = vColor[gl_InvocationID];
	cclipdistance0[gl_InvocationID] = clipdistance0[gl_InvocationID];
	
	float MaxTess = 1.0 * tessstrength;
	float TessDistance = 8.0;
	
	gl_TessLevelInner[0] = max(1.0, tessstrength * (MaxTess * (1.0 - length(entitymatrix[3].xyz - cameraposition) / TessDistance)));	
	
	if (gl_InvocationID==0)
	{
		float TessLevelOuter = max(1.0, tessstrength * (MaxTess * (1.0 - length(entitymatrix[3].xyz - cameraposition) / TessDistance)));
		gl_TessLevelOuter[0] = TessLevelOuter;
		gl_TessLevelOuter[1] = TessLevelOuter;
		gl_TessLevelOuter[2] = TessLevelOuter;
	}
}
@OpenGL4.Evaluation
#version 400
#define TESS_USE_NORMALMAP 0

//Layout
layout(triangles, equal_spacing, ccw) in;

//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform sampler2D texture1;
uniform sampler2D texture3;
uniform mat4 camerainversematrix;

//Inputs
in vec4 cPosition[];
in vec2 cTexCoords0[];
in vec3 cNormal[];
in vec3 cBinormal[];
in vec3 cTangent[];
in vec4 cColor[];
in float cSelectionState[];
in float cclipdistance0[];

//Outputs
out vec2 vTexCoords0;
out vec3 vNormal;
out vec3 vBinormal;
out vec3 vTangent;
out vec4 vColor;
out vec4 vPosition;
out float vSelectionState;
out float clipdistance0;

void main()
{
	float DisplacementStrength = 0.02;
	
	vSelectionState = cSelectionState[0];

	//Get tex coords
	vTexCoords0 = cTexCoords0[0] * gl_TessCoord.x + cTexCoords0[1] * gl_TessCoord.y + cTexCoords0[2] * gl_TessCoord.z;
	
	//Lookup displacement
	float height = texture(texture3,vTexCoords0).r;
	
	//Get normal
	vNormal = cNormal[0] * gl_TessCoord.x + cNormal[1] * gl_TessCoord.y + cNormal[2] * gl_TessCoord.z;
	vBinormal = cBinormal[0] * gl_TessCoord.x + cBinormal[1] * gl_TessCoord.y + cBinormal[2] * gl_TessCoord.z;
	vTangent = cTangent[0] * gl_TessCoord.x + cTangent[1] * gl_TessCoord.y + cTangent[2] * gl_TessCoord.z;
	vColor = cColor[0] * gl_TessCoord.x + cColor[1] * gl_TessCoord.y + cColor[2] * gl_TessCoord.z;
	clipdistance0 = cclipdistance0[0] * gl_TessCoord.x + cclipdistance0[1] * gl_TessCoord.y + cclipdistance0[2] * gl_TessCoord.z;
	
	//Normal lookup
	vec3 normal = vNormal;
#if TESS_USE_NORMALMAP==1
	//Using a normal map lookup is technically more accurate, but results in noisy geometry
	normal = texture(texture1,vTexCoords0).xyz * 2.0 - 1.0;
	normal = vTangent*normal.x + vBinormal*normal.y + vNormal*normal.z;	
	normal=normalize(normal);
#endif
	
	mat3 normalmatrix = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
	vNormal = normalize(normalmatrix * vNormal);
	vBinormal = normalize(normalmatrix * vBinormal);
	vTangent = normalize(normalmatrix * vTangent);
	
	//Calculate displacement
	vec4 displacement = vec4( normal * (height-0.5) * DisplacementStrength * 2.0, 0.0 );//(height * DisplacementStrength - DisplacementStrength * 0.5), 1.0);
	
	//vPosition = vec4(displacement,1.0) + cPosition[0] * gl_TessCoord.x + cPosition[1] * gl_TessCoord.y + cPosition[2] * gl_TessCoord.z;
	vPosition = displacement + cPosition[0] * gl_TessCoord.x + cPosition[1] * gl_TessCoord.y + cPosition[2] * gl_TessCoord.z;
	gl_Position = projectioncameramatrix * vPosition;
}
@OpenGL4.Fragment
#version 400
#define BFN_ENABLED 1

//Uniforms
uniform sampler2D texture0;//diffuse map
uniform sampler2D texture1;//light map
uniform vec4 materialcolorspecular;
uniform vec4 lighting_ambient;

//Lighting
uniform vec3 lightdirection[4];
uniform vec4 lightcolor[4];
uniform vec4 lightposition[4];
uniform float lightrange[4];
uniform vec3 lightingcenter[4];
uniform vec2 lightingconeanglescos[4];
uniform vec4 lightspecular[4];
uniform vec2 buffersize;
uniform vec2 camerarange;
uniform float camerazoom;
uniform samplerCube texture15;
uniform int decalmode;
uniform float materialroughness;

//Inputs
in vec2 vTexCoords0;
in vec4 vColor;
in float vSelectionState;
in vec3 vNormal;
in vec3 vTangent;
in vec3 vBinormal;
in float clipdistance0;
in vec3 ex_VertexCameraPosition;

out vec4 fragData0;
out vec4 fragData1;
out vec4 fragData2;
out vec4 fragData3;

float DepthToZPosition(in float depth) {
	return camerarange.x / (camerarange.y - depth * (camerarange.y - camerarange.x)) * camerarange.y;
}

void main(void)
{
	//Clip plane discard
	if (clipdistance0>0.0) discard;

	vec4 outcolor = vColor;
	vec4 color_specular = materialcolorspecular;
	
	vec3 screencoord = vec3(((gl_FragCoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-gl_FragCoord.y/buffersize.y)+0.5) * 2.0,DepthToZPosition( gl_FragCoord.z ));
	screencoord.x *= screencoord.z / camerazoom;
	screencoord.y *= -screencoord.z / camerazoom;   
	vec3 nscreencoord = normalize(screencoord);
	
	//Modulate blend with diffuse map
	outcolor *= texture(texture0,vTexCoords0);
	
	//Normal map
	vec3 normal = vNormal;
	normal = texture(texture1,vTexCoords0).xyz * 2.0 - 1.0;
	float ao = normal.z;
	normal = vTangent*normal.x + vBinormal*normal.y + vNormal*normal.z;	
	normal=normalize(normal);
	
	//Blend with selection color if selected
	fragData0 = outcolor;// * (1.0-vSelectionState) + vSelectionState * (outcolor*0.5+vec4(0.5,0.0,0.0,0.0));
	
#if BFN_ENABLED==1
	//Best-fit normals
	fragData1 = texture(texture15,normalize(vec3(normal.x,-normal.y,normal.z)));
	fragData1.a = fragData0.a;
#else
	//Low-res normals
	fragData1 = vec4(normalize(normal)*0.5+0.5,fragData0.a);
#endif
	float specular = color_specular.r * 0.299 + color_specular.g * 0.587 + color_specular.b * 0.114;
	int materialflags=1;
	if (vSelectionState>0.0) materialflags += 2;
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
