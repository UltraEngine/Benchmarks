SHADER version 1
@OpenGL2.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];
uniform vec2 texturescale;
uniform float alphamapscale;
uniform float terrainresolution;
uniform vec3 terrainscale;
uniform vec2 layerscale;
uniform vec2 alphacoordoffset;
uniform vec2 texcoordoffset;

in vec3 vertex_position;
in vec2 vertex_texcoords0;
in vec2 vertex_texcoords1;

out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out vec2 ex_texcoords2;

void main(void)
{
	vec4 position = projectionmatrix * (vec4(vertex_position,1.0) + vec4(offset,0,0));	
	gl_Position = position;
	ex_texcoords1 = ((vertex_texcoords1-0.5) * alphamapscale + 0.5 + alphacoordoffset);
	ex_texcoords0 = vertex_texcoords0;


	//ex_texcoords0 = (((vertex_texcoords1-0.5) * alphamapscale + 0.5 + alphacoordoffset)) * terrainscale.x * terrainresolution / layerscale;

	/*
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	//ex_texcoords2 = texcoords[i];
	ex_texcoords1 = texcoords[i] * alphamapscale;
	ex_texcoords1 = ((texcoords[i]-0.5) * alphamapscale + 0.5 + alphacoordoffset);
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i], 1.0, 1.0));
	//ex_texcoords0 = texcoords[i] * texturescale;
	ex_texcoords0 = (((texcoords[i]-0.5) * alphamapscale + 0.5 + alphacoordoffset)) * terrainscale.x * terrainresolution;
	*/
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];
uniform vec2 texturescale;
uniform float alphamapscale;
uniform float terrainresolution;
uniform vec3 terrainscale;
uniform vec2 layerscale;
uniform vec2 alphacoordoffset;
uniform vec2 texcoordoffset;

in vec3 vertex_position;
in vec2 vertex_texcoords0;
in vec2 vertex_texcoords1;

out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out vec2 ex_texcoords2;

void main(void)
{
	vec4 position = projectionmatrix * (vec4(vertex_position,1.0) + vec4(offset,0,0));	
	gl_Position = position;
	ex_texcoords1 = ((vertex_texcoords1-0.5) * alphamapscale + 0.5 + alphacoordoffset);
	ex_texcoords0 = vertex_texcoords0;


	//ex_texcoords0 = (((vertex_texcoords1-0.5) * alphamapscale + 0.5 + alphacoordoffset)) * terrainscale.x * terrainresolution / layerscale;

	/*
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	//ex_texcoords2 = texcoords[i];
	ex_texcoords1 = texcoords[i] * alphamapscale;
	ex_texcoords1 = ((texcoords[i]-0.5) * alphamapscale + 0.5 + alphacoordoffset);
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i], 1.0, 1.0));
	//ex_texcoords0 = texcoords[i] * texturescale;
	ex_texcoords0 = (((texcoords[i]-0.5) * alphamapscale + 0.5 + alphacoordoffset)) * terrainscale.x * terrainresolution;
	*/
}
@OpenGL4.Fragment
#version 400
#define TERRAIN_LOW_FREQUENCY_BLEND 8.0

//Uniforms
uniform sampler2D texture0;// heightmap
uniform sampler2D texture1;// normalmap
uniform sampler2D texture2;// layer alpha
uniform sampler2D texture3;// previous layer diffuse
uniform sampler2D texture4;// previous layer normal + displacement
uniform sampler2D texture5;// diffuse
uniform sampler2D texture6;// normal
uniform sampler2D texture7;// displacement
uniform vec2 buffersize;
uniform vec4 drawcolor;
uniform vec2 alphacoordoffset;
uniform vec4 layermask;
uniform vec2 layerscale;
uniform int isfirstlayer;
uniform vec3 layerslopeconstraints;
uniform vec3 layerheightconstraints;
uniform vec3 terrainscale;
uniform vec2 texcoordoffset;
uniform float terrainresolution;
uniform int blendwithprevious;
uniform int displacementblend;
uniform float clipmaplevel;
uniform float layerdisplacement=0.1;
//uniform int texturemappingmode;
//uniform int texturelookupmode=1;
#define texturemappingmode 0

//Varyings
in vec2 ex_texcoords0;
in vec2 ex_texcoords1;
in vec2 ex_texcoords2;

out vec4 fragData0;
out vec4 fragData1;

vec4 TerrainTextureLookup(in sampler2D texmap, in vec3 coord, in vec3 axisstrength)
{
	switch (texturemappingmode)
	{
	case 0:
		return texture(texmap,coord.xz);
	case 1:
		return texture(texmap,coord.xy);// * axisstrength.y + texture(texmap,coord.zy) * axisstrength.x;
	case 2:
		return texture(texmap,coord.xy) * axisstrength.y + texture(texmap,coord.zy) * axisstrength.x + texture(texmap,coord.xz) * axisstrength.z;
	}
}

vec4 TerrainNormalLookup(in sampler2D texmap, in vec3 coord, in vec3 axisstrength)
{
	vec4 color;
	switch (texturemappingmode)
	{
	case 0:
		color = texture(texmap,coord.xz);
		break;
	case 1:
		color = texture(texmap,coord.xy).xzyw;// * axisstrength.y + texture(texmap,coord.zy).zxyw * axisstrength.x;
		color = color*2.0-1.0;
		color = vec4(normalize(color.xyz),0.0);
		color *= vec4(0.0,1.0,1.0,1.0);
		color = color/2.0+0.5;
		color.r=0.5;
		color.g=0.0;
		color.b=0.5;
		break;
	case 2:
		color = texture(texmap,coord.xy).xyzw * axisstrength.y + texture(texmap,coord.zy).xyzw * axisstrength.x + texture(texmap,coord.xz) * axisstrength.z;		
		break;
	}
	return color;
}

void main(void)
{
	vec4 outcolor = vec4(1.0);	
	vec4 outcolor1 = vec4(0.5,0.5,1.0,0.0);
	float displacement=0.0;
	
	vec4 alpha4 = texture(texture2,ex_texcoords1) * layermask;
	float alpha = alpha4[0]+alpha4[1]+alpha4[2]+alpha4[3];
	float height = texture(texture0,ex_texcoords1).r;
	vec4 normalcolor = texture(texture1,ex_texcoords1);
	vec3 normal = normalcolor.xyz * 2.0 - 1.0;
	float slope = normalcolor.a * 90.0;
	vec4 ic;
	
	vec3 texcoords = vec3(ex_texcoords0.x, height * terrainscale.y/layerscale.y, ex_texcoords0.y);
	vec3 axisstrength = abs(normal);
	if (texturemappingmode != 2)
	{
		axisstrength.y=0.0;
	}
	float nsum = axisstrength.x + axisstrength.y + axisstrength.z;
	axisstrength = vec3(axisstrength.x/nsum,axisstrength.y/nsum,axisstrength.z/nsum);
	
	//Adjust alpha based on constraints
	if (isfirstlayer==0)
	{
		alpha *= (1.0 - clamp(layerslopeconstraints.x - slope, 0.0, layerslopeconstraints.z) / layerslopeconstraints.z);
		alpha *= (1.0 - clamp(slope - layerslopeconstraints.y, 0.0, layerslopeconstraints.z) / layerslopeconstraints.z);
		alpha *= 1.0 - clamp(layerheightconstraints.x-height,0.0,layerheightconstraints.z)/layerheightconstraints.z;
		alpha *= 1.0 - clamp(height-layerheightconstraints.y,0.0,layerheightconstraints.z)/layerheightconstraints.z;
	}
	else
	{
		alpha=1.0;
	}
	
	float layerblendcutoff = 0.9;
	
#ifdef TERRAIN_LOW_FREQUENCY_BLEND
	float lowfrequencymix = clamp(clipmaplevel/7.0,0.0,1.0)*0.75+0.25;
#endif
	
	// Normal
	outcolor1 = TerrainNormalLookup(texture6,texcoords,axisstrength);
#ifdef TERRAIN_LOW_FREQUENCY_BLEND
	outcolor1 = outcolor1 * lowfrequencymix + TerrainNormalLookup(texture6,texcoords,axisstrength);
#endif
	float normalalpha = alpha;
	
	//Displacement
	if (displacementblend!=0)
	{
		displacement = TerrainTextureLookup(texture7,texcoords,axisstrength).r;
#ifdef TERRAIN_LOW_FREQUENCY_BLEND
		displacement = displacement * lowfrequencymix + TerrainTextureLookup(texture7,texcoords,axisstrength).r;
#endif
		alpha += displacement * alpha;
		if (alpha<1.0) alpha *= max(0.0,alpha-layerblendcutoff) / (1.0-layerblendcutoff);
		alpha = clamp(alpha,0.0,1.0);
	}
	
	// Diffuse
	outcolor = TerrainTextureLookup(texture5,texcoords,axisstrength);
#ifdef TERRAIN_LOW_FREQUENCY_BLEND
	outcolor = outcolor * lowfrequencymix + TerrainTextureLookup(texture5,texcoords,axisstrength);
#endif
	
	fragData0 = vec4(outcolor.rgb,alpha);
	fragData1 = vec4(outcolor1.rgb,alpha);
	//fragData1.b = displacement * layerdisplacement;
}
