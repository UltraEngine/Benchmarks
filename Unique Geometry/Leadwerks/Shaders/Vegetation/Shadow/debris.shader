SHADER version 1
@OpenGL2.Vertex
#version 400
#define MAX_INSTANCES 4096

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
//uniform instancematrices { int matrix[MAX_INSTANCES];} entity;
//uniform bonematrices { int matrix[MAX_INSTANCES];} bone;
uniform vec4 clipplane0 = vec4(0.0);
uniform sampler2D texture5;// matrix grid
uniform sampler2D texture6;// terrain heightmap
uniform vec2 InstanceOffset;
uniform float TerrainSize;
uniform float TerrainHeight;
uniform float TerrainResolution;
uniform float CellResolution;
uniform float Density;
uniform vec3 cameraposition;
//uniform usamplerBuffer texture4;// instance buffer
uniform vec2 scalerange;
uniform vec2 gridoffset;
uniform float variationmapresolution;
uniform vec2 colorrange;
uniform float currenttime;
uniform float waterheight;
uniform int watermode;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec3 vertex_normal;
in vec3 vertex_binormal;
in vec3 vertex_tangent;
//in float vertex_texcoords1;
in uint vertex_texcoords1;

//Outputs
out vec4 ex_color;
out vec2 ex_texcoords0;
out vec3 ex_VertexCameraPosition;
out vec3 ex_normal;
out vec3 ex_tangent;
out vec3 ex_binormal;
out float clipdistance0;
out mat4 ex_entitymatrix;
out vec3 screendir;

float rand(vec2 co)
{
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

mat4 GetInstanceMatrix(in uint id)
{
	float x = floor(id/CellResolution);
	float z = id-x*CellResolution;
	x += gridoffset.x;
	z += gridoffset.y;
	
	mat4 mat;
	vec2 texcoord = vec2(0.5);
	
	mat[0][0]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 0.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[0][1]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 1.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[0][2]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 2.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[0][3]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 3.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	
	mat[1][0]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 4.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[1][1]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 5.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[1][2]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 6.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[1][3]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 7.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	
	mat[2][0]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 8.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[2][1]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 9.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[2][2]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 10.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[2][3]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 11.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	
	mat[3][0]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 12.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[3][1]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 13.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[3][2]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 14.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[3][3]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 15.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	
	mat[3][0] += x * Density;
	mat[3][2] += z * Density;
	
	vec2 texcoords = vec2((mat[3][0]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0),(mat[3][2]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0));
	mat[3][1] = texture(texture6,texcoords).r * TerrainHeight;
	
	//Adjust scale
	float scale = mat[3][3];
	scale = scalerange.x + scale * (scalerange.y - scalerange.x);
	mat[0].xyz = mat[0].xyz * scale;
	mat[1].xyz = mat[1].xyz * scale;
	mat[2].xyz = mat[2].xyz * scale;
	
	return mat;
}

void main()
{
	uint id = uint(vertex_texcoords1);//texelFetch(texture4,gl_InstanceID).r;
	//uint id = gl_InstanceID;
	mat4 entitymatrix_ = GetInstanceMatrix( id );
	ex_color = vec4(entitymatrix_[0][3]) * (colorrange.y - colorrange.x) + colorrange.x;
	ex_color.a = 1.0;
	entitymatrix_[0][3]=0.0; entitymatrix_[1][3]=0.0; entitymatrix_[2][3]=0.0; entitymatrix_[3][3]=1.0;
	ex_entitymatrix = entitymatrix_;
	
	vec4 modelvertexposition = vec4(vertex_position,1.0);
	
	//Wind animation
	/*float seed = mod(currenttime * 0.0015 ,360.0);
	seed += ex_entitymatrix[3].x*33.0 + ex_entitymatrix[3].y*67.8 + ex_entitymatrix[3].z*123.5;
	seed += modelvertexposition.x + modelvertexposition.y + modelvertexposition.z;
	vec4 movement = vec4( vec3( (1.0-vertex_color.r) * vertex_normal * 0.02 * (sin(seed)+0.25*cos(seed*5.2+3.2)) ),0.0);		
	modelvertexposition += movement;*/
	
	modelvertexposition = entitymatrix_ * modelvertexposition;
	
	//Offset vertex by terrain height
	vec2 texcoords = vec2((modelvertexposition.x+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0),(modelvertexposition.z+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0));
	modelvertexposition.y += texture(texture6,texcoords).r * TerrainHeight - entitymatrix_[3][1];
	
	//Float on water
	//if (watermode==1)
	//{
		if (modelvertexposition.y + vertex_position.y < waterheight)
		{
			modelvertexposition.y = waterheight + vertex_position.y;
			
			//Floating animation
			float seed = mod(currenttime * 0.0015 ,360.0);
			seed += ex_entitymatrix[3].x*33.0 + ex_entitymatrix[3].y*67.8 + ex_entitymatrix[3].z*123.5;
			seed += modelvertexposition.x + modelvertexposition.y + modelvertexposition.z;
			vec4 movement = vec4( vec3( (1.0-vertex_color.r) * vec3(0,1,0) * 0.02 * (sin(seed)+0.25*cos(seed*5.2+3.2)) ),0.0);		
			modelvertexposition.y += movement.y;
		}
	//}

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
	
	screendir = entitymatrix_[3].xyz - cameraposition;
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
	nmat = nmat * mat3(entitymatrix_[0].xyz,entitymatrix_[1].xyz,entitymatrix_[2].xyz);
	ex_normal = normalize(nmat * vec3(0.0,1.0,0.0));	
	ex_tangent = normalize(nmat * vertex_tangent);
	ex_binormal = normalize(nmat * vertex_binormal);	
	
	ex_texcoords0 = vertex_texcoords0;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define MAX_INSTANCES 4096

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
//uniform instancematrices { int matrix[MAX_INSTANCES];} entity;
//uniform bonematrices { int matrix[MAX_INSTANCES];} bone;
uniform vec4 clipplane0 = vec4(0.0);
uniform sampler2D texture5;// matrix grid
uniform sampler2D texture6;// terrain heightmap
uniform vec2 InstanceOffset;
uniform float TerrainSize;
uniform float TerrainHeight;
uniform float TerrainResolution;
uniform float CellResolution;
uniform float Density;
uniform vec3 cameraposition;
//uniform usamplerBuffer texture4;// instance buffer
uniform vec2 scalerange;
uniform vec2 gridoffset;
uniform float variationmapresolution;
uniform vec2 colorrange;
uniform float currenttime;
uniform float waterheight;
uniform int watermode;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec3 vertex_normal;
in vec3 vertex_binormal;
in vec3 vertex_tangent;
//in float vertex_texcoords1;
in uint vertex_texcoords1;

//Outputs
out vec4 ex_color;
out vec2 ex_texcoords0;
out vec3 ex_VertexCameraPosition;
out vec3 ex_normal;
out vec3 ex_tangent;
out vec3 ex_binormal;
out float clipdistance0;
out mat4 ex_entitymatrix;
out vec3 screendir;

float rand(vec2 co)
{
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

mat4 GetInstanceMatrix(in uint id)
{
	float x = floor(id/CellResolution);
	float z = id-x*CellResolution;
	x += gridoffset.x;
	z += gridoffset.y;
	
	mat4 mat;
	vec2 texcoord = vec2(0.5);
	
	mat[0][0]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 0.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[0][1]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 1.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[0][2]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 2.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[0][3]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 3.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	
	mat[1][0]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 4.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[1][1]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 5.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[1][2]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 6.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[1][3]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 7.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	
	mat[2][0]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 8.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[2][1]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 9.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[2][2]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 10.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[2][3]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 11.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	
	mat[3][0]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 12.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[3][1]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 13.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[3][2]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 14.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	mat[3][3]=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 15.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	
	mat[3][0] += x * Density;
	mat[3][2] += z * Density;
	
	vec2 texcoords = vec2((mat[3][0]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0),(mat[3][2]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0));
	mat[3][1] = texture(texture6,texcoords).r * TerrainHeight;
	
	//Adjust scale
	float scale = mat[3][3];
	scale = scalerange.x + scale * (scalerange.y - scalerange.x);
	mat[0].xyz = mat[0].xyz * scale;
	mat[1].xyz = mat[1].xyz * scale;
	mat[2].xyz = mat[2].xyz * scale;
	
	return mat;
}

void main()
{
	uint id = uint(vertex_texcoords1);//texelFetch(texture4,gl_InstanceID).r;
	//uint id = gl_InstanceID;
	mat4 entitymatrix_ = GetInstanceMatrix( id );
	ex_color = vec4(entitymatrix_[0][3]) * (colorrange.y - colorrange.x) + colorrange.x;
	ex_color.a = 1.0;
	entitymatrix_[0][3]=0.0; entitymatrix_[1][3]=0.0; entitymatrix_[2][3]=0.0; entitymatrix_[3][3]=1.0;
	ex_entitymatrix = entitymatrix_;
	
	vec4 modelvertexposition = vec4(vertex_position,1.0);
	
	//Wind animation
	/*float seed = mod(currenttime * 0.0015 ,360.0);
	seed += ex_entitymatrix[3].x*33.0 + ex_entitymatrix[3].y*67.8 + ex_entitymatrix[3].z*123.5;
	seed += modelvertexposition.x + modelvertexposition.y + modelvertexposition.z;
	vec4 movement = vec4( vec3( (1.0-vertex_color.r) * vertex_normal * 0.02 * (sin(seed)+0.25*cos(seed*5.2+3.2)) ),0.0);		
	modelvertexposition += movement;*/
	
	modelvertexposition = entitymatrix_ * modelvertexposition;
	
	//Offset vertex by terrain height
	vec2 texcoords = vec2((modelvertexposition.x+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0),(modelvertexposition.z+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0));
	modelvertexposition.y += texture(texture6,texcoords).r * TerrainHeight - entitymatrix_[3][1];
	
	//Float on water
	//if (watermode==1)
	//{
		if (modelvertexposition.y + vertex_position.y < waterheight)
		{
			modelvertexposition.y = waterheight + vertex_position.y;
			
			//Floating animation
			float seed = mod(currenttime * 0.0015 ,360.0);
			seed += ex_entitymatrix[3].x*33.0 + ex_entitymatrix[3].y*67.8 + ex_entitymatrix[3].z*123.5;
			seed += modelvertexposition.x + modelvertexposition.y + modelvertexposition.z;
			vec4 movement = vec4( vec3( (1.0-vertex_color.r) * vec3(0,1,0) * 0.02 * (sin(seed)+0.25*cos(seed*5.2+3.2)) ),0.0);		
			modelvertexposition.y += movement.y;
		}
	//}

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
	
	screendir = entitymatrix_[3].xyz - cameraposition;
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
	nmat = nmat * mat3(entitymatrix_[0].xyz,entitymatrix_[1].xyz,entitymatrix_[2].xyz);
	ex_normal = normalize(nmat * vec3(0.0,1.0,0.0));	
	ex_tangent = normalize(nmat * vertex_tangent);
	ex_binormal = normalize(nmat * vertex_binormal);	
	
	ex_texcoords0 = vertex_texcoords0;
}
@OpenGL4.Fragment
#version 400
#define BFN_ENABLED 1

//Uniforms
uniform sampler2D texture0;//diffuse map
uniform sampler2D texture1;//normal map
uniform samplerCube texture15;//BFN map
uniform vec4 materialcolorspecular;
uniform vec4 materialcolordiffuse;
uniform vec4 lighting_ambient;

//Lighting
uniform vec3 lightdirection[4];
uniform vec4 lightcolor[4];
uniform vec4 lightposition[4];
uniform float lightrange[4];
uniform vec3 lightingcenter[4];
uniform vec2 lightingconeanglescos[4];
uniform vec4 lightspecular[4];
uniform vec4 clipplane0 = vec4(0.0);
uniform int cameraprojectionmode;
uniform mat4 cameramatrix;

//Inputs
in vec2 ex_texcoords0;
in vec4 ex_color;
in vec3 ex_VertexCameraPosition;
in vec3 ex_normal;
in vec3 ex_tangent;
in vec3 ex_binormal;
in float clipdistance0;
in vec3 screendir;

uniform bool isbackbuffer;
uniform vec2 camerarange;//automatic
uniform vec2 buffersize;//automatic
uniform vec2 faderange;// = vec2(10.0,15.0);
uniform float camerazoom;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float depthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x)) * depthrange.y;
}

void main(void)
{
	//Clip plane discard
	if (clipdistance0>0.0) discard;
	
	ivec2 icoord = ivec2(gl_FragCoord.xy);
	if (isbackbuffer) icoord.y = int(buffersize.y) - icoord.y;	
	
	vec3 screencoord = vec3(((gl_FragCoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-gl_FragCoord.y/buffersize.y)+0.5) * 2.0,depthToPosition(gl_FragCoord.z,camerarange));
	screencoord.x *= screencoord.z / camerazoom;
	screencoord.y *= -screencoord.z / camerazoom;	
	
	//if (cameraprojectionmode==1)
	//{
		float z = length(screendir);//depthToPosition(gl_FragCoord.z,camerarange);
		if (z>faderange.x)
		{
			if (z>faderange.y) discard;
			vec2 tcoord = vec2(gl_FragCoord.xy/buffersize);
			float f = rand(gl_FragCoord.xy / buffersize * 1.0 + gl_SampleID*37.45128);
			if (f>1.0-(z-faderange.x)/(faderange.y-faderange.x)) discard;
		}
	//}
	
	vec4 outcolor = ex_color;
	
	//Modulate blend with diffuse map
	outcolor *= texture(texture0,ex_texcoords0);
	if (outcolor.a<0.5) discard;	
}
