SHADER version 1
@OpenGL2.Vertex
#version 400

uniform mat4 projectioncameramatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec3 lightglobalposition;
uniform vec2 lightrange;
uniform mat4 cameramatrix;
uniform mat4 camerainversematrix;

in vec3 vertex_position;

out vec4 vposition;

void main(void)
{
	vec4 pos = vec4(lightglobalposition + vertex_position * lightrange.y * 2.0,1.0);
	vposition = camerainversematrix * pos;
	gl_Position = projectioncameramatrix * pos;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

uniform mat4 projectioncameramatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec3 lightglobalposition;
uniform vec2 lightrange;
uniform mat4 cameramatrix;
uniform mat4 camerainversematrix;

in vec3 vertex_position;

out vec4 vposition;

void main(void)
{
	vec4 pos = vec4(lightglobalposition + vertex_position * lightrange.y * 2.0,1.0);
	vposition = camerainversematrix * pos;
	gl_Position = projectioncameramatrix * pos;
}
@OpenGL4.Fragment
#version 400
#ifndef SAMPLES
	#define SAMPLES 1
#endif
#define LOWERLIGHTTHRESHHOLD 0.001
#define PI 3.14159265359
#define HALFPI PI/2.0
#ifndef KERNEL
	#define KERNEL 3
#endif
#define KERNELF float(KERNEL)
#define GLOSS 10.0
#define VOLUMETRICLIGHTING 1

uniform sampler2DMS texture0;
uniform sampler2DMS texture4;
uniform vec2 texcoordoffset;
uniform mat3 camerainversenormalmatrix;
uniform samplerCubeShadow texture5;//shadowmap
uniform vec4 ambientlight;
uniform vec2 buffersize;
uniform vec3 lightposition;
uniform vec4 lightcolor;
uniform vec4 lightspecular;
uniform vec2 lightrange;
uniform vec3 lightglobalposition;
uniform vec2 camerarange;
uniform float camerazoom;
uniform mat4 lightprojectionmatrix;
uniform mat4 lightprojectioninversematrix;
uniform mat4 projectioncameramatrix;
uniform mat4 cameramatrix;
uniform mat4 camerainversematrix;
uniform mat4 projectionmatrix;
uniform vec2 lightshadowmapoffset;
uniform mat3 lightnormalmatrix;
uniform float shadowmapsize;
uniform bool isbackbuffer;
uniform float volumetricintensity = 0.2;
uniform int downsampling=1;
uniform bool fogmode = true;
uniform vec4 fogcolor = vec4(1.0);
uniform vec2 fogrange = vec2(0.0,100.0);
uniform vec2 fogangle = vec2(90.0,90.0);

in vec4 vposition;

out vec4 fragData0;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float shadowLookup(in samplerCubeShadow shadowmap, in vec4 shadowcoord, in vec3 sampleroffsetx, in vec3 sampleroffsety)
{
	float f=0.0;
	const float cornerdamping = 0.7071067;
	vec3 shadowcoord3 = shadowcoord.xyz;
	int x,y;
	vec2 sampleoffset;

	for (x=0; x<KERNEL; ++x)
	{
		sampleoffset.x = float(x) - KERNELF*0.5 + 0.5;
		for (y=0; y<KERNEL; ++y)
		{
			sampleoffset.y = float(y) - KERNELF*0.5 + 0.5;
			f += texture(shadowmap,vec4(shadowcoord3+sampleoffset.x*sampleroffsetx+sampleoffset.y*sampleroffsety,shadowcoord.w));
		}
	}
	return f/(KERNEL*KERNEL);
}

float depthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x)) * depthrange.y;
}

float positionToDepth(in float z, in vec2 depthrange) {
	return (depthrange.x / (z / depthrange.y) - depthrange.y) / -(depthrange.y - depthrange.x);
}

int getMajorAxis(in vec3 v)
{
	vec3 b = abs(v);
	if (b.x>b.y)
	{
		if (b.x>b.z)
		{
			return 0;
		}
		else
		{
			return 2;
		}
	}
	else
	{
		if (b.y>b.z)
		{
			return 1;
		}
		else
		{
			return 2;
		}
	}
}

void main(void)
{
	vec3 flipcoord = vec3(1.0);
	if (!isbackbuffer) flipcoord.y = -1.0;
	
	//----------------------------------------------------------------------
	//Calculate screen texcoord
	//----------------------------------------------------------------------
	vec2 coord = texcoordoffset + gl_FragCoord.xy / buffersize;
	if (isbackbuffer) coord.y = 1.0 - coord.y;
	
	ivec2 icoord = ivec2(texcoordoffset * buffersize + gl_FragCoord.xy);
	if (isbackbuffer) icoord.y = int(buffersize.y) - icoord.y;
	icoord *= downsampling;
	
	fragData0 = vec4(0.0);
	
	bool uselighting = false;
	
	//----------------------------------------------------------------------
	//Retrieve data from gbuffer
	//----------------------------------------------------------------------
	float depth = 		texelFetch(texture0,icoord,0).x;
	
	//----------------------------------------------------------------------
	//Calculate screen position and vector
	//----------------------------------------------------------------------
#ifdef USEPOSITIONBUFFER
	//VR Sheared mprojection
	vec3 screencoord = texelFetch(texture4,icoord,0).xyz;
	screencoord.y *= -1.0f;
#else
	vec3 screencoord = vec3(((gl_FragCoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-gl_FragCoord.y/buffersize.y)+0.5) * 2.0,depthToPosition(depth,camerarange));
	screencoord.x *= screencoord.z / camerazoom;
	screencoord.y *= -screencoord.z / camerazoom;
#endif
	
	vec3 screennormal = normalize(screencoord);
	vec4 lighting = vec4(0.0);
	
#if VOLUMETRICLIGHTING==1
	//Volumetric lighting
	screencoord *= flipcoord;
	screennormal *= flipcoord;
	if (vposition.z < screencoord.z) screencoord = vposition.xyz;		
	//const int steps=16;
	vec3 pos = screencoord;
	float stepsize = 0.25;//lightrange.y * 2.0 / float(steps);
	int steps = int(lightrange.y * 2.0 / stepsize + 0.5);
	float vlighting = 0.0;
	float lightdistance = length(lightposition);
	vec3 lightvector;
	vec4 shadowcoord;
	float attenuation;
	
	vec3 dithercoord = lightnormalmatrix * screennormal;
	pos += screennormal * stepsize * rand(dithercoord.xy*dithercoord.z);
	
	for (int n=0; n<steps; n++)
	{
		pos -= screennormal * stepsize;
		float dist = length(lightposition - pos);
		if (dist<lightrange.y && pos.z>camerarange.x)
		{
			attenuation = 1.0 - dist / lightrange.y;
			lightvector = pos - lightposition;
#ifdef USESHADOW
			if (attenuation>0.0)
			{
				shadowcoord = vec4(lightnormalmatrix*lightvector,1.0);
				switch (getMajorAxis(shadowcoord.xyz))
				{
				case 0:
					shadowcoord.w = abs(shadowcoord.x);
					break;
				case 1:
					shadowcoord.w = abs(shadowcoord.y);
					break;
				default:
					shadowcoord.w = abs(shadowcoord.z);
					break;
				}
				shadowcoord.w = positionToDepth(shadowcoord.w * lightshadowmapoffset.y*0.98 - lightshadowmapoffset.x,lightrange);
				attenuation *= texture(texture5,shadowcoord);
			}
#endif

			//-------------------------------------------------
			// Fog
			//-------------------------------------------------
			float fogeffect=0.0f;
			if (fogmode)
			{
				fogeffect = clamp( length(pos) / (fogrange.y - fogrange.x) , 0.0, 1.0 );
				fogeffect*=fogcolor.a;
			}	

			attenuation = max(0.0,attenuation);
			vlighting += volumetricintensity * 0.2 * stepsize * attenuation * (1.0-fogeffect);
		}
		if (lightdistance>lightrange.y || pos.z<camerarange.x)
		{
			if (length(pos)<lightdistance-lightrange.y || pos.z<camerarange.x) break;// slower?
		}
	}
	vlighting = min(volumetricintensity,vlighting);
	fragData0 += lightcolor * vlighting;
#endif

#if VOLUMETRICLIGHTING!=1
	if (!uselighting) discard;
#endif
	fragData0 = max(fragData0,0.0);
}
