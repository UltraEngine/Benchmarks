SHADER version 1
@OpenGL2.Vertex
#version 400

uniform mat4 projectioncameramatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec3 lightglobalposition;
uniform vec2 lightrange;
uniform vec2 lightconeangles;
uniform mat4 entitymatrix;

in vec3 vertex_position;

out vec4 vertexposition;

void main(void)
{
	gl_Position = projectioncameramatrix * entitymatrix * vec4(vertex_position,1.0);
	/*
	vec3 position = vertex_position;
	position.x *= lightrange.y * tan(lightconeangles[1]);
	position.y *= lightrange.y;
	position.z *= lightrange.y * tan(lightconeangles[1]);
	gl_Position = projectioncameramatrix * vec4(lightglobalposition + position,1.0);*/
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
uniform vec2 lightconeangles;
uniform mat4 entitymatrix;

in vec3 vertex_position;

out vec4 vertexposition;

void main(void)
{
	gl_Position = projectioncameramatrix * entitymatrix * vec4(vertex_position,1.0);
	/*
	vec3 position = vertex_position;
	position.x *= lightrange.y * tan(lightconeangles[1]);
	position.y *= lightrange.y;
	position.z *= lightrange.y * tan(lightconeangles[1]);
	gl_Position = projectioncameramatrix * vec4(lightglobalposition + position,1.0);*/
}
@OpenGL4.Fragment
#version 400
#ifndef SAMPLES
	#define SAMPLES 1
#endif
#define PI 3.14159265359
#define HALFPI PI/2.0
#define LOWERLIGHTTHRESHHOLD 0.001
#ifndef KERNEL
	#define KERNEL 3
#endif
#define KERNELF float(KERNEL)
#define GLOSS 10.0

#if SAMPLES==0
	uniform sampler2D texture0;
	uniform sampler2D texture1;
	uniform sampler2D texture2;
	uniform sampler2D texture3;
	uniform sampler2D texture4;
#else
	uniform sampler2DMS texture0;
	uniform sampler2DMS texture1;
	uniform sampler2DMS texture2;
	uniform sampler2DMS texture3;
	uniform sampler2DMS texture4;
#endif

uniform sampler2D texture6;// first texture of material, if present

uniform mat3 camerainversenormalmatrix;
uniform sampler2DShadow texture5;//shadowmap
uniform vec2 lightconeangles;
uniform vec2 lightconeanglescos;
uniform vec4 ambientlight;
uniform vec2 buffersize;

uniform vec3 lightposition;
uniform vec3 lightdirection;
uniform vec4 lightcolor;
uniform vec4 lightspecular;
uniform vec2 lightrange;

uniform vec2 camerarange;
uniform float camerazoom;
uniform float shadowmapsize;
uniform mat4 lightprojectioncamerainversematrix;
uniform mat3 lightnormalmatrix;
uniform vec2 lightshadowmapoffset;
uniform float shadowsoftness;
uniform bool isbackbuffer;
uniform vec2 texcoordoffset;
uniform mat4 projectionmatrix;
uniform mat4 projectioncameramatrix;
uniform mat3 cameranormalmatrix;

//Fog parameters
uniform bool fogmode = true;
uniform vec4 fogcolor = vec4(1.0);
uniform vec2 fogrange = vec2(0.0,100.0);

in vec4 vertexposition;

out vec4 fragData0;

float depthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x)) * depthrange.y;
}

float positionToDepth(in float z, in vec2 depthrange) {
	return (depthrange.x / (z / depthrange.y) - depthrange.y) / -(depthrange.y - depthrange.x);
}

float shadowLookup(in sampler2DShadow shadowmap, in vec3 shadowcoord, in float offset)
{
	float f=0.0;
	const float cornerdamping = 0.7071067;
	int x,y;
	vec2 sampleoffset;
	
	for (x=0; x<KERNEL; ++x)
	{
		sampleoffset.x = float(x) - KERNELF*0.5 + 0.5;
		for (y=0; y<KERNEL; ++y)
		{
			sampleoffset.y = float(y) - KERNELF*0.5 + 0.5;
			f += texture(shadowmap,vec3(shadowcoord.x+x*offset,shadowcoord.y+y*offset,shadowcoord.z));
		}
	}
	return f/(KERNEL*KERNEL);
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
	
	fragData0 = vec4(0.0);
	bool uselighting = false;
	
	for (int i=0; i<max(1,SAMPLES); i++)
	{
		//----------------------------------------------------------------------
		//Retrieve data from gbuffer
		//----------------------------------------------------------------------
#if SAMPLES==0
		float depth = 		texelFetch(texture0,icoord,i).x;
		vec4 diffuse = 		texelFetch(texture1,icoord,i);
		vec4 normaldata =	texelFetch(texture2,icoord,i);
		vec4 emission = 	texelFetch(texture3,icoord,i);
#else		
		float depth = 		texelFetch(texture0,icoord,i).x;
		vec4 diffuse = 		texelFetch(texture1,icoord,i);
		vec4 normaldata =	texelFetch(texture2,icoord,i);
		vec4 emission = 	texelFetch(texture3,icoord,i);
#endif
		
		vec3 normal = 		camerainversenormalmatrix * normalize(normaldata.xyz*2.0-1.0);
		float specularity =	emission.a;
		int materialflags = 	int(normaldata.a*255.0+0.5);
		if ((1 & materialflags)!=0) uselighting=true;
		
		//----------------------------------------------------------------------
		//Discard pixel if no lighting is used
		//----------------------------------------------------------------------	
#if SAMPLES==1		
		if (!uselighting) discard;
#endif
		//----------------------------------------------------------------------
		//Calculate screen position and vector
		//----------------------------------------------------------------------
		
#ifdef USEPOSITIONBUFFER
		//VR Sheared mprojection
		vec3 screencoord = texelFetch(texture4,icoord,i).xyz;
		screencoord.y *= -1.0f;
#else
		vec3 screencoord = vec3(((gl_FragCoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-gl_FragCoord.y/buffersize.y)+0.5) * 2.0,depthToPosition(depth,camerarange));
		screencoord.x *= screencoord.z / camerazoom;
		screencoord.y *= -screencoord.z / camerazoom;
#endif
		
		vec3 screennormal = normalize(screencoord);
				
		//Calculate gloss
		float gloss=70.0;
		if ((32 & materialflags)!=0) gloss -= 40;
		if ((64 & materialflags)!=0) gloss -= 20;
		
		//-------------------------------------------------
		// Fog
		//-------------------------------------------------
		float fogeffect=0.0f;
		if (fogmode)
		{
			vec3 worldpos = cameranormalmatrix * screencoord;
			fogeffect = clamp( 1.0 - (fogrange.y - length(screencoord.xyz)) / (fogrange.y - fogrange.x) , 0.0, 1.0 );
			fogeffect*=fogcolor.a;	
		}		
		
		//----------------------------------------------------------------------
		//Calculate lighting
		//----------------------------------------------------------------------		
		float attenuation=1.0;
		vec4 specular;
		vec3 lightvector = (screencoord - lightposition * flipcoord) * flipcoord;
		vec3 lightnormal = normalize(lightvector);
		
		//Directional attenuation
		attenuation = max(0.0,-dot(lightnormal,normal));
		
		//Distance attenuation
		attenuation *= sqrt(min(1.0,1.0-length(lightvector)/lightrange.y));
		
		//Spot cone attenuation
		float denom = lightconeanglescos.y-lightconeanglescos.x;	
		float anglecos = dot(lightnormal,lightdirection);
		
		if (denom>0.0)
		{		
			attenuation *= 1.0-clamp((lightconeanglescos.y-anglecos)/denom,0.0,1.0);
		}
		else
		{
#if SAMPLES==1
			if (anglecos<lightconeanglescos.x) discard;
#endif
		}

#if SAMPLES==1		
		if (attenuation<LOWERLIGHTTHRESHHOLD) discard;
#endif		
		if (!isbackbuffer) normal.y *= -1.0;
		vec3 lightreflection = normalize(reflect(lightvector*flipcoord,normal));
		specular = lightspecular * specularity * pow(clamp(-dot(lightreflection,screennormal),0.0,1.0),gloss);
		specular *= lightcolor.r * 0.299 + lightcolor.g * 0.587 + lightcolor.b * 0.114;
		
	#ifdef USESHADOW
		
		//----------------------------------------------------------------------
		//Shadow lookup
		//----------------------------------------------------------------------
		vec3 shadowcoord = lightnormalmatrix * lightvector;
		shadowcoord.x /= -shadowcoord.z/0.5;
		shadowcoord.y /= shadowcoord.z/0.5;
		shadowcoord.x += 0.5;
		shadowcoord.y += 0.5;
		shadowcoord.z = positionToDepth(shadowcoord.z * lightshadowmapoffset.y - lightshadowmapoffset.x,lightrange);
		attenuation *= shadowLookup(texture5,shadowcoord,1.0/shadowmapsize);	
				
		#if SAMPLES==1
		if (attenuation<LOWERLIGHTTHRESHHOLD) discard;
		#endif	
	#endif
	
	#ifdef USELIGHTDECAL
		vec3 decalcoord = lightnormalmatrix * lightvector;
		decalcoord.x /= -decalcoord.z/0.5;
		decalcoord.y /= decalcoord.z/0.5;
		decalcoord.x += 0.5;
		decalcoord.y += 0.5;
		attenuation *= texture(texture6,decalcoord.xy).r;
	#endif
		
		//----------------------------------------------------------------------
		//Final light calculation
		//----------------------------------------------------------------------
		fragData0 += attenuation * (diffuse * lightcolor + specular) * (1.0-fogeffect);
		
		//fragData0.xyz = screencoord;
	}
	
	//----------------------------------------------------------------------
	//Discard pixel if no lighting is used
	//----------------------------------------------------------------------	
	if (!uselighting) discard;
	
	fragData0 /= float(max(1,SAMPLES));
	fragData0.r = max(fragData0.r,0.0f);
	fragData0.g = max(fragData0.g,0.0f);
	fragData0.b = max(fragData0.b,0.0f);
	fragData0.a = max(fragData0.a,0.0f);
	//gl_FragDepth = 0.0;
}
