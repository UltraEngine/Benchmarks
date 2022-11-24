SHADER version 1
@OpenGL2.Vertex
#version 400

uniform int VBOSize;

out uint ex_instanceID;

void main()
{
	ex_instanceID = gl_InstanceID * VBOSize + gl_VertexID;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment
#version 400

layout(points) in;
layout(points,max_vertices=256) out;

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform vec4 clipplane0 = vec4(0.0);
uniform sampler2D texture5;
uniform sampler2D texture6;
uniform sampler2D texture7;
uniform usampler2D texture8;
uniform vec2 InstanceOffset;
uniform float CellResolution;
uniform vec3 cameraposition;
uniform float Density;
uniform vec4 frustumplane0;
uniform vec4 frustumplane1;
uniform vec4 frustumplane2;
uniform vec4 frustumplane3;
uniform vec4 frustumplane4;
uniform vec4 frustumplane5;
uniform vec3 aabbmin;
uniform vec3 aabbmax;
uniform int NumInstances;
uniform float TerrainSize;
uniform int layerindex=0;
uniform float TerrainHeight;
uniform float TerrainResolution;
uniform vec2 viewrange;
uniform vec2 sloperange;
uniform vec2 heightrange;
uniform vec3 aabboffset;
uniform vec2 scalerange;
uniform int cameraprojectionmode;
uniform vec2 gridoffset;
uniform float variationmapresolution;

in uint ex_instanceID[1];

//layout (location=0) flat out uint InstanceID;
out uint transformfeedback0;

mat4 GetInstanceMatrix(in uint id)
{
	//float x = floor((id+gridoffsetx)/CellResolution) ;
	//float z = (id+gridoffsety)-(x+gridoffsetx)*CellResolution;
	float x = floor(id/CellResolution);
	float z = id-x*CellResolution;
	x += gridoffset.x;
	z += gridoffset.y;
	
	//x += InstanceOffset.x * CellResolution;
	//z += InstanceOffset.y * CellResolution;
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
	
	mat[3][0] += x * Density;// - TerrainSize * 0.5;
	mat[3][2] += z * Density;// - TerrainSize * 0.5;
	
	vec2 texcoords = vec2((mat[3][0]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0),(mat[3][2]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0));
	mat[3][1] = texture(texture6,texcoords).r * TerrainHeight;
	
	return mat;
}

float PlaneDistanceToPoint(in vec4 plane, in vec3 point)
{
	return plane.x*point.x + plane.y*point.y + plane.z*point.z + plane.w;
}

void main()
{
	transformfeedback0=0;

	if (ex_instanceID[0]>=NumInstances) return;
	
	mat4 mat = GetInstanceMatrix(ex_instanceID[0]);
	
	if (mat[3][0]<-TerrainSize*0.5) return;
	if (mat[3][0]>TerrainSize*0.5) return;
	if (mat[3][2]<-TerrainSize*0.5) return;
	if (mat[3][2]>TerrainSize*0.5) return;	
	
	float dist = length(cameraposition - mat[3].xyz);
	
	if (dist >= viewrange.y) return;
	if (dist < viewrange.x) return;
	
	//Check slope
	vec2 texcoords = vec2((mat[3][0]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0),(mat[3][2]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0));
	
	ivec2 icoords = ivec2(texcoords*TerrainResolution);
	uint layerflags = texelFetch(texture8,icoords,0).r;
	if ((layerflags & int(pow(2,layerindex)+0.01))==0) return;
	
	vec3 normal = texture(texture7,texcoords).xyz * 2.0 - 1.0;
	float slope = 90.0 - asin(normal.z) * 57.2957795;
	
	#define EPSILON 0.01
	
	if (slope<sloperange.x-EPSILON) return;
	if (slope>sloperange.y+EPSILON) return;
	if (mat[3][1]<heightrange.x-EPSILON) return;
	if (mat[3][1]>heightrange.y+EPSILON) return;
	
	float scale = mat[3][3];//vec3(length(mat[0].xyz),length(mat[1].xyz),length(mat[2].xyz));
	scale = scalerange.x + scale * (scalerange.y - scalerange.x);	
	
	vec3 size = vec3(0);
	vec3 aabbcenter = aabbmin + (aabbmax - aabbmin) / 2.0;
	size.x = max(abs(aabbcenter.x-aabbmin.x),abs(aabbmax.x-aabbcenter.x));
	size.y = max(abs(aabbcenter.y-aabbmin.y),abs(aabbmax.y-aabbcenter.y));
	size.z = max(abs(aabbcenter.z-aabbmin.z),abs(aabbmax.z-aabbcenter.z));
	
	float radius = length(size*scale);
	vec3 center = mat[3].xyz;
	
	center.x += aabboffset.x * scale;
	center.y += aabboffset.y * scale;
	center.z += aabboffset.z * scale;
	
	#define PADDING 0.0f
	
	if (PlaneDistanceToPoint(frustumplane0,center)>radius-PADDING) return;
	if (PlaneDistanceToPoint(frustumplane1,center)>radius-PADDING) return;
	if (PlaneDistanceToPoint(frustumplane2,center)>radius-PADDING) return;
	if (PlaneDistanceToPoint(frustumplane3,center)>radius-PADDING) return;
	if (PlaneDistanceToPoint(frustumplane4,center)>radius-PADDING) return;
	if (PlaneDistanceToPoint(frustumplane5,center)>radius-PADDING) return;
	
	transformfeedback0 = ex_instanceID[0];
	EmitVertex();
}
@OpenGL4.Vertex
#version 400

uniform int VBOSize;

out uint ex_instanceID;

void main()
{
	ex_instanceID = gl_InstanceID * VBOSize + gl_VertexID;
}
@OpenGL4.Geometry
#version 400

layout(points) in;
layout(points,max_vertices=256) out;

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform vec4 clipplane0 = vec4(0.0);
uniform sampler2D texture5;
uniform sampler2D texture6;
uniform sampler2D texture7;
uniform usampler2D texture8;
uniform vec2 InstanceOffset;
uniform float CellResolution;
uniform vec3 cameraposition;
uniform float Density;
uniform vec4 frustumplane0;
uniform vec4 frustumplane1;
uniform vec4 frustumplane2;
uniform vec4 frustumplane3;
uniform vec4 frustumplane4;
uniform vec4 frustumplane5;
uniform vec3 aabbmin;
uniform vec3 aabbmax;
uniform int NumInstances;
uniform float TerrainSize;
uniform int layerindex=0;
uniform float TerrainHeight;
uniform float TerrainResolution;
uniform vec2 viewrange;
uniform vec2 sloperange;
uniform vec2 heightrange;
uniform vec3 aabboffset;
uniform vec2 scalerange;
uniform int cameraprojectionmode;
uniform vec2 gridoffset;
uniform float variationmapresolution;

in uint ex_instanceID[1];

//layout (location=0) flat out uint InstanceID;
out uint transformfeedback0;

mat4 GetInstanceMatrix(in uint id)
{
	//float x = floor((id+gridoffsetx)/CellResolution) ;
	//float z = (id+gridoffsety)-(x+gridoffsetx)*CellResolution;
	float x = floor(id/CellResolution);
	float z = id-x*CellResolution;
	x += gridoffset.x;
	z += gridoffset.y;
	
	//x += InstanceOffset.x * CellResolution;
	//z += InstanceOffset.y * CellResolution;
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
	
	mat[3][0] += x * Density;// - TerrainSize * 0.5;
	mat[3][2] += z * Density;// - TerrainSize * 0.5;
	
	vec2 texcoords = vec2((mat[3][0]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0),(mat[3][2]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0));
	mat[3][1] = texture(texture6,texcoords).r * TerrainHeight;
	
	return mat;
}

float PlaneDistanceToPoint(in vec4 plane, in vec3 point)
{
	return plane.x*point.x + plane.y*point.y + plane.z*point.z + plane.w;
}

void main()
{
	transformfeedback0=0;

	if (ex_instanceID[0]>=NumInstances) return;
	
	mat4 mat = GetInstanceMatrix(ex_instanceID[0]);
	
	if (mat[3][0]<-TerrainSize*0.5) return;
	if (mat[3][0]>TerrainSize*0.5) return;
	if (mat[3][2]<-TerrainSize*0.5) return;
	if (mat[3][2]>TerrainSize*0.5) return;	
	
	float dist = length(cameraposition - mat[3].xyz);
	
	if (dist >= viewrange.y) return;
	if (dist < viewrange.x) return;
	
	//Check slope
	vec2 texcoords = vec2((mat[3][0]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0),(mat[3][2]+TerrainSize/2.0)/TerrainSize+(1.0/TerrainResolution/2.0));
	
	ivec2 icoords = ivec2(texcoords*TerrainResolution);
	uint layerflags = texelFetch(texture8,icoords,0).r;
	if ((layerflags & int(pow(2,layerindex)+0.01))==0) return;
	
	vec3 normal = texture(texture7,texcoords).xyz * 2.0 - 1.0;
	float slope = 90.0 - asin(normal.z) * 57.2957795;
	
	#define EPSILON 0.01
	
	if (slope<sloperange.x-EPSILON) return;
	if (slope>sloperange.y+EPSILON) return;
	if (mat[3][1]<heightrange.x-EPSILON) return;
	if (mat[3][1]>heightrange.y+EPSILON) return;
	
	float scale = mat[3][3];//vec3(length(mat[0].xyz),length(mat[1].xyz),length(mat[2].xyz));
	scale = scalerange.x + scale * (scalerange.y - scalerange.x);	
	
	vec3 size = vec3(0);
	vec3 aabbcenter = aabbmin + (aabbmax - aabbmin) / 2.0;
	size.x = max(abs(aabbcenter.x-aabbmin.x),abs(aabbmax.x-aabbcenter.x));
	size.y = max(abs(aabbcenter.y-aabbmin.y),abs(aabbmax.y-aabbcenter.y));
	size.z = max(abs(aabbcenter.z-aabbmin.z),abs(aabbmax.z-aabbcenter.z));
	
	float radius = length(size*scale);
	vec3 center = mat[3].xyz;
	
	center.x += aabboffset.x * scale;
	center.y += aabboffset.y * scale;
	center.z += aabboffset.z * scale;
	
	#define PADDING 0.0f
	
	if (PlaneDistanceToPoint(frustumplane0,center)>radius-PADDING) return;
	if (PlaneDistanceToPoint(frustumplane1,center)>radius-PADDING) return;
	if (PlaneDistanceToPoint(frustumplane2,center)>radius-PADDING) return;
	if (PlaneDistanceToPoint(frustumplane3,center)>radius-PADDING) return;
	if (PlaneDistanceToPoint(frustumplane4,center)>radius-PADDING) return;
	if (PlaneDistanceToPoint(frustumplane5,center)>radius-PADDING) return;
	
	transformfeedback0 = ex_instanceID[0];
	EmitVertex();
}
@OpenGL4.Fragment
//Intel graphics need this to run
#version 400

void main()
{
}
