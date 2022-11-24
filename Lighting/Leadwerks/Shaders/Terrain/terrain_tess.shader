SHADER version 1
@OpenGL2.Vertex
#version 400
#define VIRTUAL_TEXTURE_STAGES 7
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
//varying vec2 ex_texcoords[VIRTUAL_TEXTURE_STAGES];
out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out vec2 ex_texcoords2;
out vec2 ex_texcoords3;
out vec2 ex_texcoords4;
out vec2 ex_texcoords5;
out vec2 ex_texcoords6;
//out vec2 ex_texcoords7;
out mat3 nmat;
out float clipdistance0;
flat out int ex_instanceID;
out vec4 ex_position;

void main()
{
	ex_instanceID = gl_InstanceID;
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vec4 modelvertexposition = entitymatrix_ * (vec4(vertex_position,1.0));

	float terrainheight = length(entitymatrix_[1].xyz);
	modelvertexposition.y = texture(texture0, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * terrainheight;
	
	ex_position = modelvertexposition;
	//modelvertexposition = projectioncameramatrix * modelvertexposition;
	
	ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;
	ex_texcoords1 = (modelvertexposition.xz - renderposition[1]) / texturerange[1] + 0.5;
	ex_texcoords2 = (modelvertexposition.xz - renderposition[2]) / texturerange[2] + 0.5;
	ex_texcoords3 = (modelvertexposition.xz - renderposition[3]) / texturerange[3] + 0.5;
	ex_texcoords4 = (modelvertexposition.xz - renderposition[4]) / texturerange[4] + 0.5;
	ex_texcoords5 = (modelvertexposition.xz - renderposition[5]) / texturerange[5] + 0.5;
	ex_texcoords6 = (modelvertexposition.xz - renderposition[6]) / texturerange[6] + 0.5;	
	
	/*ex_texcoords[0] = (modelvertexposition.xz) / terrainsize + 0.5;
	for (int i=1; i<VIRTUAL_TEXTURE_STAGES; i++)
	{
		ex_texcoords[i] = (modelvertexposition.xz - renderposition[i]) / texturerange[i] + 0.5;
	}*/
	

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
	
	gl_Position = modelvertexposition;
	
	nmat = mat3(entitymatrix);
	//nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	//nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);	
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGL2.Fragment
#version 400

layout(vertices = 3) out;

uniform vec2 camerarange;
uniform vec2 buffersize;
uniform float cameratheta;
uniform vec3 cameraposition;
uniform mat4 camerainversematrix;
uniform float tessstrength;
uniform int LODLevel;

in vec2 ex_texcoords0[];
in vec2 ex_texcoords1[];
in vec2 ex_texcoords2[];
in vec2 ex_texcoords3[];
in vec2 ex_texcoords4[];
in vec2 ex_texcoords5[];
in vec2 ex_texcoords6[];
//in vec2 ex_texcoords7[];
in mat3 nmat[];
in float clipdistance0[];
flat in int ex_instanceID[];
in vec4 ex_position[];
in vec3 vertexposminuscamerapos[];

out vec2 e_texcoords0[];
out vec2 e_texcoords1[];
out vec2 e_texcoords2[];
out vec2 e_texcoords3[];
out vec2 e_texcoords4[];
out vec2 e_texcoords5[];
out vec2 e_texcoords6[];
//out vec2 e_texcoords7[];
out mat3 e_nmat[];
out float e_clipdistance0[];
flat out int instanceID[];
out vec4 e_position[];
out vec3 e_vertexposminuscamerapos[];

void main()
{
	e_vertexposminuscamerapos[gl_InvocationID]=vertexposminuscamerapos[gl_InvocationID];
	e_position[gl_InvocationID]=ex_position[gl_InvocationID];
	instanceID[gl_InvocationID]=ex_instanceID[gl_InvocationID];
	e_texcoords0[gl_InvocationID] = ex_texcoords0[gl_InvocationID];
	e_texcoords1[gl_InvocationID] = ex_texcoords1[gl_InvocationID];
	e_texcoords2[gl_InvocationID] = ex_texcoords2[gl_InvocationID];
	e_texcoords3[gl_InvocationID] = ex_texcoords3[gl_InvocationID];
	e_texcoords4[gl_InvocationID] = ex_texcoords4[gl_InvocationID];
	e_texcoords5[gl_InvocationID] = ex_texcoords5[gl_InvocationID];
	e_texcoords6[gl_InvocationID] = ex_texcoords6[gl_InvocationID];
	//e_texcoords7[gl_InvocationID] = ex_texcoords7[gl_InvocationID];
	e_nmat[gl_InvocationID] = nmat[gl_InvocationID];
	e_clipdistance0[gl_InvocationID] = clipdistance0[gl_InvocationID];
	
	if (gl_InvocationID==0)
	{
		vec3 pos = (ex_position[gl_InvocationID]).xyz;
		float dist = length(cameraposition - pos);	
		
		if (tessstrength==0.0 || dist>50)
		{
			gl_TessLevelInner[0] = 1.0;
			gl_TessLevelInner[1] = 1.0;
			gl_TessLevelOuter[0] = 1.0;
			gl_TessLevelOuter[1] = 1.0;
			gl_TessLevelOuter[2] = 1.0;
			gl_TessLevelOuter[3] = 1.0;
		}
		else
		{
			//Screen-space tessellation - displays roughly constant sized polys
			float tess;
			float maxtess = 8.0 * tessstrength;	
			maxtess = 8.0 * tessstrength;
			float polygonsize=0.02 / 3.0 * tessstrength;
			float pixelspertessellation = 0.25;	
			float screensize = polygonsize / (camerarange.y*2.0) * buffersize.y / (dist / camerarange.y) / cameratheta / pixelspertessellation;//camerarange.y);//3.0;//pos.z * 64.0;//polygonsize / pos.z /  /** buffersize.x*/ / cameratheta;
			screensize=max(1.0,screensize);
			tess = max(screensize,1);
			tess = min(tess,maxtess);
			gl_TessLevelInner[0] = tess;
			gl_TessLevelInner[1] = tess;			
			gl_TessLevelOuter[0] = maxtess;
			gl_TessLevelOuter[1] = maxtess;
			gl_TessLevelOuter[2] = maxtess;
			gl_TessLevelOuter[3] = maxtess;
		}
	}
}
@OpenGLES2.Vertex
#version 400
#define MAX_INSTANCES 256
#define VIRTUAL_TEXTURE_STAGES 7
//#define TERRAINNOISE

layout(triangles,fractional_even_spacing,ccw) in;

uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform float terrainsize;
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
uniform float texturerange[VIRTUAL_TEXTURE_STAGES];
uniform vec3 cameraposition;
uniform vec2 renderposition[VIRTUAL_TEXTURE_STAGES];

in vec2 e_texcoords0[];
in vec2 e_texcoords1[];
in vec2 e_texcoords2[];
in vec2 e_texcoords3[];
in vec2 e_texcoords4[];
in vec2 e_texcoords5[];
in vec2 e_texcoords6[];
//in vec2 e_texcoords7[];
in mat3 e_nmat[];
in float e_clipdistance0[];
flat in int instanceID[];
in vec4 e_position[];
in vec3 e_vertexposminuscamerapos[];

out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out vec2 ex_texcoords2;
out vec2 ex_texcoords3;
out vec2 ex_texcoords4;
out vec2 ex_texcoords5;
out vec2 ex_texcoords6;
//out vec2 ex_texcoords7;
out mat3 nmat;
out float clipdistance0;
out vec3 vertexposminuscamerapos;

//-----------------------------------------------------------------------------------------
#ifdef TERRAINNOISE
//
// GLSL textureless classic 3D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-10-11
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license. See LICENSE file.
// https://github.com/ashima/webgl-noise
//

vec3 mod289(vec3 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x)
{
  return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec3 fade(vec3 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// Classic Perlin noise
float cnoise(vec3 P)
{
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 * (1.0 / 7.0);
  vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 * (1.0 / 7.0);
  vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}

// Classic Perlin noise, periodic variant
float pnoise(vec3 P, vec3 rep)
{
  vec3 Pi0 = mod(floor(P), rep); // Integer part, modulo period
  vec3 Pi1 = mod(Pi0 + vec3(1.0), rep); // Integer part + 1, mod period
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 * (1.0 / 7.0);
  vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 * (1.0 / 7.0);
  vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}
#endif
//----------------------------------------------------------------------------------------------------

void main()
{
	nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	ex_texcoords0 = e_texcoords0[0] * gl_TessCoord.x + e_texcoords0[1] * gl_TessCoord.y + e_texcoords0[2] * gl_TessCoord.z;
	ex_texcoords1 = e_texcoords1[0] * gl_TessCoord.x + e_texcoords1[1] * gl_TessCoord.y + e_texcoords1[2] * gl_TessCoord.z;
	ex_texcoords2 = e_texcoords2[0] * gl_TessCoord.x + e_texcoords2[1] * gl_TessCoord.y + e_texcoords2[2] * gl_TessCoord.z;
	ex_texcoords3 = e_texcoords3[0] * gl_TessCoord.x + e_texcoords3[1] * gl_TessCoord.y + e_texcoords3[2] * gl_TessCoord.z;
	ex_texcoords4 = e_texcoords4[0] * gl_TessCoord.x + e_texcoords4[1] * gl_TessCoord.y + e_texcoords4[2] * gl_TessCoord.z;
	ex_texcoords5 = e_texcoords5[0] * gl_TessCoord.x + e_texcoords5[1] * gl_TessCoord.y + e_texcoords5[2] * gl_TessCoord.z;
	ex_texcoords6 = e_texcoords6[0] * gl_TessCoord.x + e_texcoords6[1] * gl_TessCoord.y + e_texcoords6[2] * gl_TessCoord.z;

	


	//ex_texcoords7 = e_texcoords7[0] * gl_TessCoord.x + e_texcoords7[1] * gl_TessCoord.y + e_texcoords7[2] * gl_TessCoord.z;
	clipdistance0 = e_clipdistance0[0] * gl_TessCoord.x + e_clipdistance0[1] * gl_TessCoord.y + e_clipdistance0[2] * gl_TessCoord.z;
	vertexposminuscamerapos = e_vertexposminuscamerapos[0] * gl_TessCoord.x + e_vertexposminuscamerapos[1] * gl_TessCoord.y + e_vertexposminuscamerapos[2] * gl_TessCoord.z;
	
	//Vertex position
	vec4 pos = e_position[0] * gl_TessCoord.x + e_position[1] * gl_TessCoord.y + e_position[2] * gl_TessCoord.z;
	mat4 entitymatrix = entity.matrix[instanceID[0]];
	entitymatrix[0][3]=0.0;
	entitymatrix[1][3]=0.0;
	entitymatrix[2][3]=0.0;
	entitymatrix[3][3]=1.0;
	//float terrainheight = length(entitymatrix[1].xyz);
	//pos.y = texture(texture0, (pos.xz+0.5)/ terrainsize + 0.5).r * terrainheight;
	
	//vertexposminuscamerapos = pos.xyz - cameraposition;
	
	//Displacement mapping
	vec4 outcolor = texture(texture1,ex_texcoords0);
	vec4 normalcolor = texture(texture9,ex_texcoords0);
	vec3 normal = normalize( texture(texture8,ex_texcoords0).xzy * 2.0 - 1.0 );
	
	const float magicnumber = 0.646446609 / 2.0;
	int i=0;
	float d = length(vertexposminuscamerapos);
	float blend;
	float len[VIRTUAL_TEXTURE_STAGES];
	
	len[1]=length(ex_texcoords1-0.5);
	len[2]=length(ex_texcoords2-0.5);
	len[3]=length(ex_texcoords3-0.5);
	len[4]=length(ex_texcoords4-0.5);
	len[5]=length(ex_texcoords5-0.5);
	len[6]=length(ex_texcoords6-0.5);
	i=1;
	
#if VIRTUAL_TEXTURE_STAGES > 1
	if (len[i]<0.5 && d<texturerange[i]*magicnumber)
	{
		blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
		blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
		outcolor = outcolor * blend + (1.0-blend) * texture(texture2,ex_texcoords1);
		normalcolor = normalcolor * blend + (1.0-blend) * texture(texture10,ex_texcoords1);
		i++;	
	#if VIRTUAL_TEXTURE_STAGES > 2
		if (len[i]<0.5 && d<texturerange[i]*magicnumber)
		{
			blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
			blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
			outcolor = outcolor * blend + (1.0-blend) * texture(texture3,ex_texcoords2);
			normalcolor = normalcolor * blend + (1.0-blend) * texture(texture11,ex_texcoords2);
			i++;			
		#if VIRTUAL_TEXTURE_STAGES > 3
			if (len[i]<0.5 && d<texturerange[i]*magicnumber)
			{
				blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
				blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
				outcolor = outcolor * blend + (1.0-blend) * texture(texture4,ex_texcoords3);
				normalcolor = normalcolor * blend + (1.0-blend) * texture(texture12,ex_texcoords3);
				i++;				
			#if VIRTUAL_TEXTURE_STAGES > 4
				if (len[i]<0.5 && d<texturerange[i]*magicnumber)
				{
					blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
					blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
					outcolor = outcolor * blend + (1.0-blend) * texture(texture5,ex_texcoords4);
					normalcolor = normalcolor * blend + (1.0-blend) * texture(texture13,ex_texcoords4);
					i++;
				#if VIRTUAL_TEXTURE_STAGES > 5
					if (len[i]<0.5 && d<texturerange[i]*magicnumber)
					{
						blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
						blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
						outcolor = outcolor * blend + (1.0-blend) * texture(texture6,ex_texcoords5);
						normalcolor = normalcolor * blend + (1.0-blend) * texture(texture14,ex_texcoords5);
						i++;
					#if VIRTUAL_TEXTURE_STAGES > 6
						if (len[i]<0.5 && d<texturerange[i]*magicnumber)
						{
							blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
							blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
							outcolor = outcolor * blend + (1.0-blend) * texture(texture7,ex_texcoords6);
							normalcolor = normalcolor * blend + (1.0-blend) * texture(texture15,ex_texcoords6);
						}
					#endif
					}
				#endif
				}
			#endif
			}
		#endif
		}
	#endif
	}
#endif
	pos.xyz += normalcolor.b * normal * 1.0;	
	
#ifdef TERRAINNOISE	
	float noiseamplitude = 0.0;
	float noisefrequency = 0.05;
	const float threshhold=35.0;
	const float transition=10.0;		
	float slope = 90.0 - asin(normal.y) * 57.2957795;
	if (slope>threshhold)
	{
		slope -= threshhold;
		noiseamplitude=(1.0-(transition-slope))/transition;
	}
	noiseamplitude = clamp(noiseamplitude,0.0,1.0) * 5;
	pos.xyz = pos.xyz + noiseamplitude * cnoise(pos.xyz*noisefrequency) * vec3(normal.x,normal.y,normal.z);	
#endif	

	gl_Position = projectioncameramatrix * pos;
}
@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define VIRTUAL_TEXTURE_STAGES 7
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
//varying vec2 ex_texcoords[VIRTUAL_TEXTURE_STAGES];
out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out vec2 ex_texcoords2;
out vec2 ex_texcoords3;
out vec2 ex_texcoords4;
out vec2 ex_texcoords5;
out vec2 ex_texcoords6;
//out vec2 ex_texcoords7;
out mat3 nmat;
out float clipdistance0;
flat out int ex_instanceID;
out vec4 ex_position;

void main()
{
	ex_instanceID = gl_InstanceID;
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vec4 modelvertexposition = entitymatrix_ * (vec4(vertex_position,1.0));

	float terrainheight = length(entitymatrix_[1].xyz);
	modelvertexposition.y = texture(texture0, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * terrainheight;
	
	ex_position = modelvertexposition;
	//modelvertexposition = projectioncameramatrix * modelvertexposition;
	
	ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;
	ex_texcoords1 = (modelvertexposition.xz - renderposition[1]) / texturerange[1] + 0.5;
	ex_texcoords2 = (modelvertexposition.xz - renderposition[2]) / texturerange[2] + 0.5;
	ex_texcoords3 = (modelvertexposition.xz - renderposition[3]) / texturerange[3] + 0.5;
	ex_texcoords4 = (modelvertexposition.xz - renderposition[4]) / texturerange[4] + 0.5;
	ex_texcoords5 = (modelvertexposition.xz - renderposition[5]) / texturerange[5] + 0.5;
	ex_texcoords6 = (modelvertexposition.xz - renderposition[6]) / texturerange[6] + 0.5;	
	
	/*ex_texcoords[0] = (modelvertexposition.xz) / terrainsize + 0.5;
	for (int i=1; i<VIRTUAL_TEXTURE_STAGES; i++)
	{
		ex_texcoords[i] = (modelvertexposition.xz - renderposition[i]) / texturerange[i] + 0.5;
	}*/
	

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
	
	gl_Position = modelvertexposition;
	
	nmat = mat3(entitymatrix);
	//nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	//nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);	
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGL4.Control
#version 400

layout(vertices = 3) out;

uniform vec2 camerarange;
uniform vec2 buffersize;
uniform float cameratheta;
uniform vec3 cameraposition;
uniform mat4 camerainversematrix;
uniform float tessstrength;
uniform int LODLevel;

in vec2 ex_texcoords0[];
in vec2 ex_texcoords1[];
in vec2 ex_texcoords2[];
in vec2 ex_texcoords3[];
in vec2 ex_texcoords4[];
in vec2 ex_texcoords5[];
in vec2 ex_texcoords6[];
//in vec2 ex_texcoords7[];
in mat3 nmat[];
in float clipdistance0[];
flat in int ex_instanceID[];
in vec4 ex_position[];
in vec3 vertexposminuscamerapos[];

out vec2 e_texcoords0[];
out vec2 e_texcoords1[];
out vec2 e_texcoords2[];
out vec2 e_texcoords3[];
out vec2 e_texcoords4[];
out vec2 e_texcoords5[];
out vec2 e_texcoords6[];
//out vec2 e_texcoords7[];
out mat3 e_nmat[];
out float e_clipdistance0[];
flat out int instanceID[];
out vec4 e_position[];
out vec3 e_vertexposminuscamerapos[];

void main()
{
	e_vertexposminuscamerapos[gl_InvocationID]=vertexposminuscamerapos[gl_InvocationID];
	e_position[gl_InvocationID]=ex_position[gl_InvocationID];
	instanceID[gl_InvocationID]=ex_instanceID[gl_InvocationID];
	e_texcoords0[gl_InvocationID] = ex_texcoords0[gl_InvocationID];
	e_texcoords1[gl_InvocationID] = ex_texcoords1[gl_InvocationID];
	e_texcoords2[gl_InvocationID] = ex_texcoords2[gl_InvocationID];
	e_texcoords3[gl_InvocationID] = ex_texcoords3[gl_InvocationID];
	e_texcoords4[gl_InvocationID] = ex_texcoords4[gl_InvocationID];
	e_texcoords5[gl_InvocationID] = ex_texcoords5[gl_InvocationID];
	e_texcoords6[gl_InvocationID] = ex_texcoords6[gl_InvocationID];
	//e_texcoords7[gl_InvocationID] = ex_texcoords7[gl_InvocationID];
	e_nmat[gl_InvocationID] = nmat[gl_InvocationID];
	e_clipdistance0[gl_InvocationID] = clipdistance0[gl_InvocationID];
	
	if (gl_InvocationID==0)
	{
		vec3 pos = (ex_position[gl_InvocationID]).xyz;
		float dist = length(cameraposition - pos);	
		
		if (tessstrength==0.0 || dist>50)
		{
			gl_TessLevelInner[0] = 1.0;
			gl_TessLevelInner[1] = 1.0;
			gl_TessLevelOuter[0] = 1.0;
			gl_TessLevelOuter[1] = 1.0;
			gl_TessLevelOuter[2] = 1.0;
			gl_TessLevelOuter[3] = 1.0;
		}
		else
		{
			//Screen-space tessellation - displays roughly constant sized polys
			float tess;
			float maxtess = 8.0 * tessstrength;	
			maxtess = 8.0 * tessstrength;
			float polygonsize=0.02 / 3.0 * tessstrength;
			float pixelspertessellation = 0.25;	
			float screensize = polygonsize / (camerarange.y*2.0) * buffersize.y / (dist / camerarange.y) / cameratheta / pixelspertessellation;//camerarange.y);//3.0;//pos.z * 64.0;//polygonsize / pos.z /  /** buffersize.x*/ / cameratheta;
			screensize=max(1.0,screensize);
			tess = max(screensize,1);
			tess = min(tess,maxtess);
			gl_TessLevelInner[0] = tess;
			gl_TessLevelInner[1] = tess;			
			gl_TessLevelOuter[0] = maxtess;
			gl_TessLevelOuter[1] = maxtess;
			gl_TessLevelOuter[2] = maxtess;
			gl_TessLevelOuter[3] = maxtess;
		}
	}
}
@OpenGL4.Evaluation
#version 400
#define MAX_INSTANCES 256
#define VIRTUAL_TEXTURE_STAGES 7
//#define TERRAINNOISE

layout(triangles,fractional_even_spacing,ccw) in;

uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform float terrainsize;
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
uniform float texturerange[VIRTUAL_TEXTURE_STAGES];
uniform vec3 cameraposition;
uniform vec2 renderposition[VIRTUAL_TEXTURE_STAGES];

in vec2 e_texcoords0[];
in vec2 e_texcoords1[];
in vec2 e_texcoords2[];
in vec2 e_texcoords3[];
in vec2 e_texcoords4[];
in vec2 e_texcoords5[];
in vec2 e_texcoords6[];
//in vec2 e_texcoords7[];
in mat3 e_nmat[];
in float e_clipdistance0[];
flat in int instanceID[];
in vec4 e_position[];
in vec3 e_vertexposminuscamerapos[];

out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out vec2 ex_texcoords2;
out vec2 ex_texcoords3;
out vec2 ex_texcoords4;
out vec2 ex_texcoords5;
out vec2 ex_texcoords6;
//out vec2 ex_texcoords7;
out mat3 nmat;
out float clipdistance0;
out vec3 vertexposminuscamerapos;

//-----------------------------------------------------------------------------------------
#ifdef TERRAINNOISE
//
// GLSL textureless classic 3D noise "cnoise",
// with an RSL-style periodic variant "pnoise".
// Author:  Stefan Gustavson (stefan.gustavson@liu.se)
// Version: 2011-10-11
//
// Many thanks to Ian McEwan of Ashima Arts for the
// ideas for permutation and gradient selection.
//
// Copyright (c) 2011 Stefan Gustavson. All rights reserved.
// Distributed under the MIT license. See LICENSE file.
// https://github.com/ashima/webgl-noise
//

vec3 mod289(vec3 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x)
{
  return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec3 fade(vec3 t) {
  return t*t*t*(t*(t*6.0-15.0)+10.0);
}

// Classic Perlin noise
float cnoise(vec3 P)
{
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 * (1.0 / 7.0);
  vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 * (1.0 / 7.0);
  vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}

// Classic Perlin noise, periodic variant
float pnoise(vec3 P, vec3 rep)
{
  vec3 Pi0 = mod(floor(P), rep); // Integer part, modulo period
  vec3 Pi1 = mod(Pi0 + vec3(1.0), rep); // Integer part + 1, mod period
  Pi0 = mod289(Pi0);
  Pi1 = mod289(Pi1);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 * (1.0 / 7.0);
  vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 * (1.0 / 7.0);
  vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x); 
  return 2.2 * n_xyz;
}
#endif
//----------------------------------------------------------------------------------------------------

void main()
{
	nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	ex_texcoords0 = e_texcoords0[0] * gl_TessCoord.x + e_texcoords0[1] * gl_TessCoord.y + e_texcoords0[2] * gl_TessCoord.z;
	ex_texcoords1 = e_texcoords1[0] * gl_TessCoord.x + e_texcoords1[1] * gl_TessCoord.y + e_texcoords1[2] * gl_TessCoord.z;
	ex_texcoords2 = e_texcoords2[0] * gl_TessCoord.x + e_texcoords2[1] * gl_TessCoord.y + e_texcoords2[2] * gl_TessCoord.z;
	ex_texcoords3 = e_texcoords3[0] * gl_TessCoord.x + e_texcoords3[1] * gl_TessCoord.y + e_texcoords3[2] * gl_TessCoord.z;
	ex_texcoords4 = e_texcoords4[0] * gl_TessCoord.x + e_texcoords4[1] * gl_TessCoord.y + e_texcoords4[2] * gl_TessCoord.z;
	ex_texcoords5 = e_texcoords5[0] * gl_TessCoord.x + e_texcoords5[1] * gl_TessCoord.y + e_texcoords5[2] * gl_TessCoord.z;
	ex_texcoords6 = e_texcoords6[0] * gl_TessCoord.x + e_texcoords6[1] * gl_TessCoord.y + e_texcoords6[2] * gl_TessCoord.z;

	


	//ex_texcoords7 = e_texcoords7[0] * gl_TessCoord.x + e_texcoords7[1] * gl_TessCoord.y + e_texcoords7[2] * gl_TessCoord.z;
	clipdistance0 = e_clipdistance0[0] * gl_TessCoord.x + e_clipdistance0[1] * gl_TessCoord.y + e_clipdistance0[2] * gl_TessCoord.z;
	vertexposminuscamerapos = e_vertexposminuscamerapos[0] * gl_TessCoord.x + e_vertexposminuscamerapos[1] * gl_TessCoord.y + e_vertexposminuscamerapos[2] * gl_TessCoord.z;
	
	//Vertex position
	vec4 pos = e_position[0] * gl_TessCoord.x + e_position[1] * gl_TessCoord.y + e_position[2] * gl_TessCoord.z;
	mat4 entitymatrix = entity.matrix[instanceID[0]];
	entitymatrix[0][3]=0.0;
	entitymatrix[1][3]=0.0;
	entitymatrix[2][3]=0.0;
	entitymatrix[3][3]=1.0;
	//float terrainheight = length(entitymatrix[1].xyz);
	//pos.y = texture(texture0, (pos.xz+0.5)/ terrainsize + 0.5).r * terrainheight;
	
	//vertexposminuscamerapos = pos.xyz - cameraposition;
	
	//Displacement mapping
	vec4 outcolor = texture(texture1,ex_texcoords0);
	vec4 normalcolor = texture(texture9,ex_texcoords0);
	vec3 normal = normalize( texture(texture8,ex_texcoords0).xzy * 2.0 - 1.0 );
	
	const float magicnumber = 0.646446609 / 2.0;
	int i=0;
	float d = length(vertexposminuscamerapos);
	float blend;
	float len[VIRTUAL_TEXTURE_STAGES];
	
	len[1]=length(ex_texcoords1-0.5);
	len[2]=length(ex_texcoords2-0.5);
	len[3]=length(ex_texcoords3-0.5);
	len[4]=length(ex_texcoords4-0.5);
	len[5]=length(ex_texcoords5-0.5);
	len[6]=length(ex_texcoords6-0.5);
	i=1;
	
#if VIRTUAL_TEXTURE_STAGES > 1
	if (len[i]<0.5 && d<texturerange[i]*magicnumber)
	{
		blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
		blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
		outcolor = outcolor * blend + (1.0-blend) * texture(texture2,ex_texcoords1);
		normalcolor = normalcolor * blend + (1.0-blend) * texture(texture10,ex_texcoords1);
		i++;	
	#if VIRTUAL_TEXTURE_STAGES > 2
		if (len[i]<0.5 && d<texturerange[i]*magicnumber)
		{
			blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
			blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
			outcolor = outcolor * blend + (1.0-blend) * texture(texture3,ex_texcoords2);
			normalcolor = normalcolor * blend + (1.0-blend) * texture(texture11,ex_texcoords2);
			i++;			
		#if VIRTUAL_TEXTURE_STAGES > 3
			if (len[i]<0.5 && d<texturerange[i]*magicnumber)
			{
				blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
				blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
				outcolor = outcolor * blend + (1.0-blend) * texture(texture4,ex_texcoords3);
				normalcolor = normalcolor * blend + (1.0-blend) * texture(texture12,ex_texcoords3);
				i++;				
			#if VIRTUAL_TEXTURE_STAGES > 4
				if (len[i]<0.5 && d<texturerange[i]*magicnumber)
				{
					blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
					blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
					outcolor = outcolor * blend + (1.0-blend) * texture(texture5,ex_texcoords4);
					normalcolor = normalcolor * blend + (1.0-blend) * texture(texture13,ex_texcoords4);
					i++;
				#if VIRTUAL_TEXTURE_STAGES > 5
					if (len[i]<0.5 && d<texturerange[i]*magicnumber)
					{
						blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
						blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
						outcolor = outcolor * blend + (1.0-blend) * texture(texture6,ex_texcoords5);
						normalcolor = normalcolor * blend + (1.0-blend) * texture(texture14,ex_texcoords5);
						i++;
					#if VIRTUAL_TEXTURE_STAGES > 6
						if (len[i]<0.5 && d<texturerange[i]*magicnumber)
						{
							blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
							blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
							outcolor = outcolor * blend + (1.0-blend) * texture(texture7,ex_texcoords6);
							normalcolor = normalcolor * blend + (1.0-blend) * texture(texture15,ex_texcoords6);
						}
					#endif
					}
				#endif
				}
			#endif
			}
		#endif
		}
	#endif
	}
#endif
	pos.xyz += normalcolor.b * normal * 1.0;	
	
#ifdef TERRAINNOISE	
	float noiseamplitude = 0.0;
	float noisefrequency = 0.05;
	const float threshhold=35.0;
	const float transition=10.0;		
	float slope = 90.0 - asin(normal.y) * 57.2957795;
	if (slope>threshhold)
	{
		slope -= threshhold;
		noiseamplitude=(1.0-(transition-slope))/transition;
	}
	noiseamplitude = clamp(noiseamplitude,0.0,1.0) * 5;
	pos.xyz = pos.xyz + noiseamplitude * cnoise(pos.xyz*noisefrequency) * vec3(normal.x,normal.y,normal.z);	
#endif	

	gl_Position = projectioncameramatrix * pos;
}
@OpenGL4.Fragment
#version 400
#define VIRTUAL_TEXTURE_STAGES 7

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
//in vec2 ex_texcoords7;
in mat3 nmat;
in float clipdistance0;

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
	vec4 normalcolor = texture(texture9,ex_texcoords0);
	vec3 normal = normalize( texture(texture8,ex_texcoords0).xzy * 2.0 - 1.0 );
	
	const float magicnumber = 0.646446609 / 2.0;
	int i=0;
	float d = length(vertexposminuscamerapos);
	float blend;
	float len[VIRTUAL_TEXTURE_STAGES];
	
	len[1]=length(ex_texcoords1-0.5);
	len[2]=length(ex_texcoords2-0.5);
	len[3]=length(ex_texcoords3-0.5);
	len[4]=length(ex_texcoords4-0.5);
	len[5]=length(ex_texcoords5-0.5);
	len[6]=length(ex_texcoords6-0.5);
	i=1;
	
#if VIRTUAL_TEXTURE_STAGES > 1
	if (len[i]<0.5 && d<texturerange[i]*magicnumber)
	{
		blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
		blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
		outcolor = outcolor * blend + (1.0-blend) * texture(texture2,ex_texcoords1);
		normalcolor = normalcolor * blend + (1.0-blend) * texture(texture10,ex_texcoords1);
		i++;	
	#if VIRTUAL_TEXTURE_STAGES > 2
		if (len[i]<0.5 && d<texturerange[i]*magicnumber)
		{
			blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
			blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
			outcolor = outcolor * blend + (1.0-blend) * texture(texture3,ex_texcoords2);
			normalcolor = normalcolor * blend + (1.0-blend) * texture(texture11,ex_texcoords2);
			i++;			
		#if VIRTUAL_TEXTURE_STAGES > 3
			if (len[i]<0.5 && d<texturerange[i]*magicnumber)
			{
				blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
				blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
				outcolor = outcolor * blend + (1.0-blend) * texture(texture4,ex_texcoords3);
				normalcolor = normalcolor * blend + (1.0-blend) * texture(texture12,ex_texcoords3);
				i++;				
			#if VIRTUAL_TEXTURE_STAGES > 4
				if (len[i]<0.5 && d<texturerange[i]*magicnumber)
				{
					blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
					blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
					outcolor = outcolor * blend + (1.0-blend) * texture(texture5,ex_texcoords4);
					normalcolor = normalcolor * blend + (1.0-blend) * texture(texture13,ex_texcoords4);
					i++;
				#if VIRTUAL_TEXTURE_STAGES > 5
					if (len[i]<0.5 && d<texturerange[i]*magicnumber)
					{
						blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
						blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
						outcolor = outcolor * blend + (1.0-blend) * texture(texture6,ex_texcoords5);
						normalcolor = normalcolor * blend + (1.0-blend) * texture(texture14,ex_texcoords5);
						i++;
					#if VIRTUAL_TEXTURE_STAGES > 6
						if (len[i]<0.5 && d<texturerange[i]*magicnumber)
						{
							blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
							blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
							outcolor = outcolor * blend + (1.0-blend) * texture(texture7,ex_texcoords6);
							normalcolor = normalcolor * blend + (1.0-blend) * texture(texture15,ex_texcoords6);
						}
					#endif
					}
				#endif
				}
			#endif
			}
		#endif
		}
	#endif
	}
#endif
	
	//Normal map
	vec3 tangent = vec3(1,0,0);
	vec3 binormal = vec3(0,0,1);
	
	vec3 n = normalcolor.xyz * 2.0 - 1.0;
	n.z = sqrt(1-dot(n.xy, n.xy));
	
	float ao=n.z;
	normal = normalize(tangent*n.x + binormal*n.y + normal*n.z);
	
	fragData0 = outcolor;
	fragData1 = vec4(normal * 0.5 + 0.5, 0.0);
	int materialflags=1+16;//16 for decal mode
	fragData2 = vec4(0.0,0.0,0.0,materialflags/255.0);
}
