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
uniform mat4 cameramatrix;
uniform vec3 positionoffset;
uniform vec3 billboardscale;
uniform vec3 aabboffset;
uniform float billboardviews=8.0;
uniform float billboardvscale;
uniform vec2 colorrange;
uniform vec2 scalerange;
uniform int cameraprojectionmode;
uniform vec2 gridoffset;
uniform float variationmapresolution;
uniform vec3 aabbmax;

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
out vec2 ex_texcoords1;
out float ex_selectionstate;
out vec3 ex_VertexCameraPosition;
out vec3 ex_normal;
out vec3 ex_tangent;
out vec3 ex_binormal;
out float clipdistance0;
out mat4 ex_entitymatrix;
out vec3 screendir;
out vec3 worldnormal;
out float blend;
out mat3 ex_entitynormalmatrix;
flat out int ex_vertexid;

#define pi 3.14159265359

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
	
	mat4 mat=mat4(1.0);
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
	
	float scale = mat[3][3];
	scale = scalerange.x + scale * (scalerange.y - scalerange.x);
	
	//Rotate matrix
	//if (gl_VertexID<4)
	//{
		vec3 hdiff;
		
		if (cameraprojectionmode==1)
		{
			hdiff = normalize((mat[3].xyz - cameramatrix[3].xyz) * vec3(1.0,0.0,1.0));
		}
		else
		{
			hdiff = normalize(cameramatrix[2].xyz * vec3(1.0,0.0,1.0));
		}
		
		mat[2].xyz = -hdiff;
		mat[1].xyz = vec3(0,1,0);
		mat[0].xyz = cross(mat[2].xyz,mat[1].xyz);
		
		//Rescale matrix
		mat[0].xyz *= scale * billboardscale.x;
		mat[1].xyz *= scale * billboardscale.y;
		mat[2].xyz *= scale * billboardscale.z;
	/*}
	else
	{
		mat[0].xyz *= scale * billboardvscale;
		mat[1].xyz *= scale * billboardvscale;
		mat[2].xyz *= scale * billboardvscale;
	}*/

	return mat;
}

/*float GetYaw(in uint id)
{
	float x = floor(id/CellResolution);
	float z = id-x*CellResolution;
	vec2 texcoord = vec2(0.5,0.5);	
	float mx=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 8.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	float mz=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 10.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	return (atan(mz,mx) + pi) / (2.0*pi);
}*/

float GetYaw(in uint id)
{
	float x = floor(id/CellResolution);
	float z = id-x*CellResolution;
	x += gridoffset.x;
	z += gridoffset.y;
	
	vec2 texcoord = vec2(0.5,0.5);
	float mx = texture(texture5,vec2((x*16.0 + texcoord.x + 8.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	float mz = texture(texture5,vec2((x*16.0 + texcoord.x + 10.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	return (atan(mz,mx) + pi) / (2.0*pi) - 0.25;
}

float GetScale(in uint id)
{
	//float x = floor(id/CellResolution);
	//float z = id-x*CellResolution;
	
	float x = floor(id/CellResolution);
	float z = id-x*CellResolution;
	x += gridoffset.x;
	z += gridoffset.y;
	
	vec2 texcoord = vec2(0.5,0.5);
	
	float scale = texture(texture5,vec2((float(x)*16.0 + texcoord.x + 15.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	return scalerange.x + scale * (scalerange.y - scalerange.x);
}

void main()
{
	uint id = uint(vertex_texcoords1);
	mat4 entitymatrix_ = GetInstanceMatrix( id );
	
	ex_color = vec4(entitymatrix_[0][3],entitymatrix_[1][3],entitymatrix_[2][3],entitymatrix_[3][3]);
	ex_color = colorrange.x + ex_color * (colorrange.y - colorrange.x);
	
	entitymatrix_[0][3]=0.0; entitymatrix_[1][3]=0.0; entitymatrix_[2][3]=0.0; entitymatrix_[3][3]=1.0;
	
	ex_entitynormalmatrix = mat3(entitymatrix_);
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	
	ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);
	
	modelvertexposition.xyz += positionoffset * GetScale(id);
	gl_Position = projectioncameramatrix * modelvertexposition;
	
	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = modelvertexposition.x*clipplane0.x + modelvertexposition.y*clipplane0.y + modelvertexposition.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}
	
	screendir = entitymatrix_[3].xyz - cameraposition;
	worldnormal = vertex_normal;
	
	//Normal, tangent, binormal
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
	nmat = nmat * mat3(entitymatrix_[0].xyz,entitymatrix_[1].xyz,entitymatrix_[2].xyz);
	ex_normal = normalize(nmat * vertex_normal);
	ex_tangent = normalize(nmat * vertex_tangent);
	ex_binormal = normalize(nmat * vertex_binormal);
	ex_normal.x *= -1.0;
	ex_tangent.x *= -1.0;
	ex_binormal.x *= -1.0;
	
	ex_texcoords0 = vertex_texcoords0;
	
	//ex_vertexid = gl_VertexID;
	
	//Blend between two closest side views
	//if (gl_VertexID<4)
	//{
		vec2 hdiff;
		if (cameraprojectionmode==1)
		{
			hdiff = normalize(entitymatrix_[3].xz - cameraposition.xz);
		}
		else
		{
			hdiff = normalize(cameramatrix[2].xz);
		}
		float a = (atan(hdiff.y,hdiff.x) + pi) / (2.0*pi) - 0.25;
		a -= GetYaw(id);
		a = mod(a,1.0);
			
		float stage = floor(a*billboardviews);
		
		blend = a * billboardviews - stage;
		
		float ix,iy;
		
		iy = floor(stage / 4);
		ix = stage - iy * 4.0;
		ex_texcoords0 *= 0.25;
		ex_texcoords0.x += ix * 0.25;
		ex_texcoords0.y += iy * 0.25;
		
		ex_texcoords1 = vertex_texcoords0;
		stage = ceil(a*billboardviews);
		if (stage>=billboardviews) stage = 0.0;
		
		iy = floor(stage / 4);
		ix = stage - iy * 4.0;
		ex_texcoords1 *= 0.25;
		ex_texcoords1.x += ix * 0.25;
		ex_texcoords1.y += iy * 0.25;		
		
		//ex_texcoords1.x /= billboardviews;
		//ex_texcoords1.x += stage / billboardviews;			
	//}
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
uniform mat4 cameramatrix;
uniform vec3 positionoffset;
uniform vec3 billboardscale;
uniform vec3 aabboffset;
uniform float billboardviews=8.0;
uniform float billboardvscale;
uniform vec2 colorrange;
uniform vec2 scalerange;
uniform int cameraprojectionmode;
uniform vec2 gridoffset;
uniform float variationmapresolution;
uniform vec3 aabbmax;

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
out vec2 ex_texcoords1;
out float ex_selectionstate;
out vec3 ex_VertexCameraPosition;
out vec3 ex_normal;
out vec3 ex_tangent;
out vec3 ex_binormal;
out float clipdistance0;
out mat4 ex_entitymatrix;
out vec3 screendir;
out vec3 worldnormal;
out float blend;
out mat3 ex_entitynormalmatrix;
flat out int ex_vertexid;

#define pi 3.14159265359

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
	
	mat4 mat=mat4(1.0);
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
	
	float scale = mat[3][3];
	scale = scalerange.x + scale * (scalerange.y - scalerange.x);
	
	//Rotate matrix
	//if (gl_VertexID<4)
	//{
		vec3 hdiff;
		
		if (cameraprojectionmode==1)
		{
			hdiff = normalize((mat[3].xyz - cameramatrix[3].xyz) * vec3(1.0,0.0,1.0));
		}
		else
		{
			hdiff = normalize(cameramatrix[2].xyz * vec3(1.0,0.0,1.0));
		}
		
		mat[2].xyz = -hdiff;
		mat[1].xyz = vec3(0,1,0);
		mat[0].xyz = cross(mat[2].xyz,mat[1].xyz);
		
		//Rescale matrix
		mat[0].xyz *= scale * billboardscale.x;
		mat[1].xyz *= scale * billboardscale.y;
		mat[2].xyz *= scale * billboardscale.z;
	/*}
	else
	{
		mat[0].xyz *= scale * billboardvscale;
		mat[1].xyz *= scale * billboardvscale;
		mat[2].xyz *= scale * billboardvscale;
	}*/

	return mat;
}

/*float GetYaw(in uint id)
{
	float x = floor(id/CellResolution);
	float z = id-x*CellResolution;
	vec2 texcoord = vec2(0.5,0.5);	
	float mx=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 8.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	float mz=texture(texture5,vec2((float(x)*16.0 + texcoord.x + 10.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	return (atan(mz,mx) + pi) / (2.0*pi);
}*/

float GetYaw(in uint id)
{
	float x = floor(id/CellResolution);
	float z = id-x*CellResolution;
	x += gridoffset.x;
	z += gridoffset.y;
	
	vec2 texcoord = vec2(0.5,0.5);
	float mx = texture(texture5,vec2((x*16.0 + texcoord.x + 8.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	float mz = texture(texture5,vec2((x*16.0 + texcoord.x + 10.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	return (atan(mz,mx) + pi) / (2.0*pi) - 0.25;
}

float GetScale(in uint id)
{
	//float x = floor(id/CellResolution);
	//float z = id-x*CellResolution;
	
	float x = floor(id/CellResolution);
	float z = id-x*CellResolution;
	x += gridoffset.x;
	z += gridoffset.y;
	
	vec2 texcoord = vec2(0.5,0.5);
	
	float scale = texture(texture5,vec2((float(x)*16.0 + texcoord.x + 15.0) / variationmapresolution / 16.0,texcoord.y + z / variationmapresolution)).r;
	return scalerange.x + scale * (scalerange.y - scalerange.x);
}

void main()
{
	uint id = uint(vertex_texcoords1);
	mat4 entitymatrix_ = GetInstanceMatrix( id );
	
	ex_color = vec4(entitymatrix_[0][3],entitymatrix_[1][3],entitymatrix_[2][3],entitymatrix_[3][3]);
	ex_color = colorrange.x + ex_color * (colorrange.y - colorrange.x);
	
	entitymatrix_[0][3]=0.0; entitymatrix_[1][3]=0.0; entitymatrix_[2][3]=0.0; entitymatrix_[3][3]=1.0;
	
	ex_entitynormalmatrix = mat3(entitymatrix_);
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	
	ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);
	
	modelvertexposition.xyz += positionoffset * GetScale(id);
	gl_Position = projectioncameramatrix * modelvertexposition;
	
	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = modelvertexposition.x*clipplane0.x + modelvertexposition.y*clipplane0.y + modelvertexposition.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}
	
	screendir = entitymatrix_[3].xyz - cameraposition;
	worldnormal = vertex_normal;
	
	//Normal, tangent, binormal
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
	nmat = nmat * mat3(entitymatrix_[0].xyz,entitymatrix_[1].xyz,entitymatrix_[2].xyz);
	ex_normal = normalize(nmat * vertex_normal);
	ex_tangent = normalize(nmat * vertex_tangent);
	ex_binormal = normalize(nmat * vertex_binormal);
	ex_normal.x *= -1.0;
	ex_tangent.x *= -1.0;
	ex_binormal.x *= -1.0;
	
	ex_texcoords0 = vertex_texcoords0;
	
	//ex_vertexid = gl_VertexID;
	
	//Blend between two closest side views
	//if (gl_VertexID<4)
	//{
		vec2 hdiff;
		if (cameraprojectionmode==1)
		{
			hdiff = normalize(entitymatrix_[3].xz - cameraposition.xz);
		}
		else
		{
			hdiff = normalize(cameramatrix[2].xz);
		}
		float a = (atan(hdiff.y,hdiff.x) + pi) / (2.0*pi) - 0.25;
		a -= GetYaw(id);
		a = mod(a,1.0);
			
		float stage = floor(a*billboardviews);
		
		blend = a * billboardviews - stage;
		
		float ix,iy;
		
		iy = floor(stage / 4);
		ix = stage - iy * 4.0;
		ex_texcoords0 *= 0.25;
		ex_texcoords0.x += ix * 0.25;
		ex_texcoords0.y += iy * 0.25;
		
		ex_texcoords1 = vertex_texcoords0;
		stage = ceil(a*billboardviews);
		if (stage>=billboardviews) stage = 0.0;
		
		iy = floor(stage / 4);
		ix = stage - iy * 4.0;
		ex_texcoords1 *= 0.25;
		ex_texcoords1.x += ix * 0.25;
		ex_texcoords1.y += iy * 0.25;		
		
		//ex_texcoords1.x /= billboardviews;
		//ex_texcoords1.x += stage / billboardviews;			
	//}
}
@OpenGL4.Fragment
#version 400
#define BFN_ENABLED 1

//Uniforms
//uniform sampler2DMS texture0;//diffuse map
//uniform sampler2DMS texture1;//diffuse map
//uniform sampler2DMS texture2;//diffuse map

uniform sampler2D texture0;//diffuse map
uniform sampler2D texture1;//normal map
uniform sampler2D texture2;//emission map
uniform sampler2D texture9;//diffuse map
uniform sampler2D texture10;//normal map
uniform sampler2D texture11;//emission map
uniform samplerCube texture15;//BFN map

uniform vec4 materialcolordiffuse;
uniform vec4 materialcolorspecular;
uniform vec4 lighting_ambient;
uniform mat4 cameramatrix;
uniform int cameraprojectionmode;

//Lighting
uniform vec3 lightdirection[4];
uniform vec4 lightcolor[4];
uniform vec4 lightposition[4];
uniform float lightrange[4];
uniform vec3 lightingcenter[4];
uniform vec2 lightingconeanglescos[4];
uniform vec4 lightspecular[4];
uniform vec4 clipplane0 = vec4(0.0);
uniform vec2 buffersize;
uniform float viewrange;

//Inputs
in vec2 ex_texcoords0;
in vec4 ex_color;
in float ex_selectionstate;
in vec3 ex_VertexCameraPosition;
in vec3 ex_normal;
in vec3 ex_tangent;
in vec3 ex_binormal;
in float clipdistance0;
in mat4 ex_entitymatrix;
in vec3 screendir;
in vec3 worldnormal;
in vec2 ex_texcoords1;
in float blend;
flat in int ex_vertexid;
in mat3 ex_entitynormalmatrix;

uniform vec2 faderange;

out vec4 fragData0;
out vec4 fragData1;
out vec4 fragData2;
out vec4 fragData3;

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 mixcolor(in vec4 color0, in vec4 color1)
{
	vec4 color;
	color.a = max(color0.a,color1.a);
	color.rgb = (color0.rgb * color0.a + color1.rgb * color1.a) / (color0.a + color1.a);
	return color;
}

void main(void)
{
	//Clip plane discard
	if (clipdistance0>0.0) discard;
	float f = rand(gl_FragCoord.xy / buffersize * 1.0 + gl_SampleID*37.45128 + ex_normal.xy);
	
	//if (cameraprojectionmode==1)
	//{
		float z = length(screendir);//depthToPosition(gl_FragCoord.z,camerarange);
		if (z<faderange.y)
		{
			//Fade in
			vec2 tcoord = vec2(gl_FragCoord.xy/buffersize);
			float f = 1.0-rand(gl_FragCoord.xy / buffersize * 1.0 + gl_SampleID*37.45128);
			if (f>(z-faderange.x)/(faderange.y-faderange.x)) discard;
		}
		else if (z>viewrange-10.0)
		{
			//Fade out with distance
			vec2 tcoord = vec2(gl_FragCoord.xy/buffersize);
			float f = rand(gl_FragCoord.xy / buffersize * 1.0 + gl_SampleID*37.45128);
			if (f>1.0-(z-(viewrange-10.0))/(10.0)) discard;			
		}
	//}
	
	//Diffuse
	vec4 outcolor = ex_color;
	//outcolor = texture(texture0,ex_texcoords0);// * (1.0 - blend), texture(texture0,ex_texcoords1) * (blend));
	vec4 color0 = texture(texture0,ex_texcoords0);
	vec4 color1 = texture(texture0,ex_texcoords1);
	
	vec4 normalcolor;
	vec4 normalcolor0 = texture(texture1,ex_texcoords0);
	vec4 normalcolor1 = texture(texture1,ex_texcoords1);
	
	vec4 emission;
	vec4 emission0 = texture(texture2,ex_texcoords0);
	vec4 emission1 = texture(texture2,ex_texcoords1);
	
	#define USEBLEND 1
	
#if USEBLEND==1
	
	//Dissolve blending
	if (f>blend)
	{
		outcolor = color0;
		normalcolor = normalcolor0;
		emission = emission0;
		/*if (outcolor.a<0.5)
		{
			float f2 = rand(gl_FragCoord.yx / buffersize * 1.0 + gl_SampleID*15.845 + ex_normal.xy);
			if (f2<color1.a*(1.0-blend)) discard;
			outcolor = color1;
			normalcolor = normalcolor1;
			emission = emission1;
		}*/
	}
	else
	{
		outcolor = color1;
		normalcolor = normalcolor1;
		emission = emission1;
		/*if (outcolor.a<0.5)
		{
			float f2 = rand(gl_FragCoord.yx / buffersize * 1.0 + gl_SampleID*15.845 + ex_normal.xy);
			if (f2<color0.a*(blend)) discard;
			outcolor = color0;
			normalcolor = normalcolor0;
			emission = emission0;
		}*/
	}

#elif USEBLEND==2

	//Alpha blending
	float m=blend;
	//float sum = color0.a + color1.a;
	//m *= color0.a / sum;
	
	outcolor = color0 * (1.0-m) + color1*m;
	normalcolor = normalcolor0 * (1.0-m) + normalcolor1*m;
	emission = emission0*(1.0-m) + emission1*m;	
#else

	//No blending
	outcolor = color0;
	normalcolor = normalcolor0;
	emission = emission0;
#endif	
	
	f = rand(gl_FragCoord.xy / buffersize * 1.0 + gl_SampleID*37.45128 + ex_normal.xy);
	if (outcolor.a<=f) discard;
	
	outcolor *= materialcolordiffuse;
	
	//Normal map
	vec3 normal = ex_normal;
	//normal = normalcolor.xyz * 2.0 - 1.0;
	normal = ex_entitynormalmatrix * normalize(normalcolor.xyz * 2.0 - 1.0);
	
	//normal.xz *= -1.0;
	//normal = ex_tangent*normal.x + ex_binormal*normal.y + ex_normal*normal.z;
	//normal=normalize(normal);
	//normal.yz *= -1.0;
	
	fragData0 = outcolor * ex_color;
	fragData1 = texture(texture15,normalize(vec3(normal.x,-normal.y,normal.z)));
	fragData1.w = 1.0/256.0;
	fragData2 = emission;
	fragData3 = vec4(ex_VertexCameraPosition,1.0f);
}
