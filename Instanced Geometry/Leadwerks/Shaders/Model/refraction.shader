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
uniform mat4 cameramatrix;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec3 vertex_normal;
in vec3 vertex_binormal;
in vec3 vertex_tangent;

//Outputs
out vec4 ex_color;
out vec2 ex_texcoords0;
out float ex_selectionstate;
out vec3 ex_VertexCameraPosition;
out vec3 ex_normal;
out vec3 ex_tangent;
out vec3 ex_binormal;
out float clipdistance0;
out vec4 ex_vertexposition;

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
	
	ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);

	gl_Position = projectioncameramatrix * modelvertexposition;
	
	ex_vertexposition = gl_Position;//inverse(cameramatrix) * modelvertexposition;
	
	//mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	//nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	mat3 nmat = mat3(entitymatrix);
	ex_normal = normalize(nmat * vertex_normal);	
	ex_tangent = normalize(nmat * vertex_tangent);
	ex_binormal = normalize(nmat * vertex_binormal);
	
	ex_texcoords0 = vertex_texcoords0;
	
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
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0 = vec4(0.0);
uniform mat4 cameramatrix;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec3 vertex_normal;
in vec3 vertex_binormal;
in vec3 vertex_tangent;

//Outputs
out vec4 ex_color;
out vec2 ex_texcoords0;
out float ex_selectionstate;
out vec3 ex_VertexCameraPosition;
out vec3 ex_normal;
out vec3 ex_tangent;
out vec3 ex_binormal;
out float clipdistance0;
out vec4 ex_vertexposition;

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
	
	ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);

	gl_Position = projectioncameramatrix * modelvertexposition;
	
	ex_vertexposition = gl_Position;//inverse(cameramatrix) * modelvertexposition;
	
	//mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	//nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	mat3 nmat = mat3(entitymatrix);
	ex_normal = normalize(nmat * vertex_normal);	
	ex_tangent = normalize(nmat * vertex_tangent);
	ex_binormal = normalize(nmat * vertex_binormal);
	
	ex_texcoords0 = vertex_texcoords0;
	
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
#define BFN_ENABLED 1

//Uniforms
uniform sampler2D texture0;//diffuse map
uniform sampler2D texture1;//normal map
uniform sampler2D texture10;//screen color
uniform sampler2DMS texture11;//screen depth
uniform vec4 materialcolorspecular;
uniform vec4 lighting_ambient;
uniform samplerCube texture15;
uniform int decalmode;
uniform float materialroughness;
uniform sampler2DMS texture9;
uniform vec2 buffersize;
uniform bool isbackbuffer;
uniform vec2 camerarange;
uniform float camerazoom;
uniform mat3 camerainversenormalmatrix;
uniform mat3 cameranormalmatrix;
uniform mat4 camerainverseprojectionmatrix;
uniform mat4 cameraprojectionmatrix;

//Inputs
in vec2 ex_texcoords0;
in vec4 ex_color;
in float ex_selectionstate;
in vec3 ex_VertexCameraPosition;
in vec3 ex_normal;
in vec3 ex_tangent;
in vec3 ex_binormal;
in float clipdistance0;
in vec4 ex_vertexposition;

out vec4 fragData0;
out vec4 fragData1;
out vec4 fragData2;
out vec4 fragData3;

float depthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x)) * depthrange.y;
}

float positionToDepth(in float z, in vec2 depthrange) {
	return (depthrange.x / (z / depthrange.y) - depthrange.y) / -(depthrange.y - depthrange.x);
}

void main(void)
{
	//Clip plane discard
	if (clipdistance0>0.0) discard;
	
	//Diffuse and specular
	vec4 outcolor = ex_color * texture(texture0,ex_texcoords0);
	vec4 color_specular = materialcolorspecular;
	
	//------------------------------------------------------
	const vec3 refractionflip = vec3(-1,-1,1);
	const vec3 normalflip = vec3(-1,1,1);
	const float eta = 0.95;// should be less than 1.0.  Lower = more refraction.
	//------------------------------------------------------
	
	//Get model normal
	vec3 normal = ex_normal;
	normal = texture(texture1,ex_texcoords0).xyz * 2.0 - 1.0;
	normal = ex_tangent*normal.x + ex_binormal*normal.y + ex_normal*normal.z;
	normal = normalize(camerainversenormalmatrix * normal) * normalflip;
	
	//Transform texture coordinate into screen normal
	vec3 screencoord = vec3(((gl_FragCoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-gl_FragCoord.y/buffersize.y)+0.5) * 2.0,depthToPosition(gl_FragCoord.z,camerarange));
	screencoord.x *= screencoord.z / camerazoom;
	screencoord.y *= -screencoord.z / camerazoom;
	if (isbackbuffer) screencoord.y *= -1.0f;
	vec3 eyevector = screencoord * refractionflip;
	eyevector = normalize(eyevector);
	
	//Calculate refraction angle
	vec3 refractionvector = refract(eyevector,normal,eta);
	
	//Transform screen normal into texture coordinate
	screencoord = refractionvector * refractionflip;
	vec2 texCoord;	
	screencoord.x /= screencoord.z / camerazoom;
	screencoord.y /= -screencoord.z / camerazoom;
	texCoord.x = (screencoord.x / (buffersize.x/buffersize.y) / 2.0f + 0.5);
	texCoord.y = (screencoord.y / 2.0f - 0.5) * -1.0;
	
	//Check depth buffer
	if (ex_vertexposition.z > depthToPosition(texelFetch(texture11,ivec2(texCoord*buffersize),0).x,camerarange))
	//if (gl_FragCoord.z > texelFetch(texture11,ivec2(texCoord*buffersize),0).x)
	{
		texCoord = gl_FragCoord.xy/buffersize;
		if (isbackbuffer) texCoord.y = 1.0-texCoord.y;		
	}
	fragData0 = mix(outcolor,texture(texture10,texCoord),outcolor.a);
	
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
