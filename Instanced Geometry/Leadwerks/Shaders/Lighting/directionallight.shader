SHADER version 1
@OpenGL2.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];

in vec3 vertex_position;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID], 0.0, 1.0));
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];

in vec3 vertex_position;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID], 0.0, 1.0));
}
@OpenGL4.Fragment
#version 400
#define PI 3.14159265359
#define HALFPI PI/2.0
#define LOWERLIGHTTHRESHHOLD 0.001
#ifndef SHADOWSTAGES
	#define SHADOWSTAGES 4
#endif
#ifndef SAMPLES
	#define SAMPLES 1
#endif
#ifndef KERNEL
	#define KERNEL 3
#endif
#define KERNELF float(KERNEL)
#define GLOSS 10.0

#if SAMPLES==0
	uniform sampler2D texture0;//depth
	uniform sampler2D texture1;//diffuse.rgba
	uniform sampler2D texture2;//normal.xyz, diffuse.a
	uniform sampler2D texture3;//specular, ao, flags, diffuse.a
	uniform sampler2D texture4;//emission.rgb, diffuse.a
#else
	uniform sampler2DMS texture0;//depth
	uniform sampler2DMS texture1;//diffuse.rgba
	uniform sampler2DMS texture2;//normal.xyz, diffuse.a
	uniform sampler2DMS texture3;//specular, ao, flags, diffuse.a
	uniform sampler2DMS texture4;//emission.rgb, diffuse.a
#endif

//Fog parameters
uniform bool fogmode = true;
uniform vec4 fogcolor = vec4(1.0);
uniform vec2 fogrange = vec2(0.0,100.0);
uniform vec2 fogangle = vec2(90.0,90.0);
uniform bool multipass = false;
uniform sampler2DShadow texture5;//shadowmap

/* Possible future optimization:
uniform sampler2DMS texture0;//depth
uniform sampler2DMS texture1;//diffuse.rgba
uniform sampler2DMS texture2;//normal.xyz, specular
uniform sampler2DMS texture4;//emission.rgb, flags
*/

uniform mat3 cameranormalmatrix;
uniform mat3 camerainversenormalmatrix;
uniform vec2[4] shadowstagepositon;
uniform vec2 shadowstagescale;
uniform vec4 ambientlight;
uniform vec2 buffersize;
uniform vec3 lightdirection;
uniform vec4 lightcolor;
uniform vec4 lightspecular;
uniform vec2 camerarange;
uniform float camerazoom;
uniform vec2[SHADOWSTAGES] lightshadowmapoffset;
uniform mat4 lightmatrix;
uniform mat3 lightnormalmatrix0;
uniform mat3 lightnormalmatrix1;
uniform mat3 lightnormalmatrix2;
uniform mat3 lightnormalmatrix3;
uniform vec2 shadowmapsize;
uniform vec2 lightrange;
uniform vec3[SHADOWSTAGES] lightposition;
//uniform vec3 lightposition0;
//uniform vec3 lightposition1;
//uniform vec3 lightposition2;
//uniform vec3 lightposition3;
uniform float[SHADOWSTAGES] shadowstagearea;
uniform float[SHADOWSTAGES] shadowstagerange;
uniform bool isbackbuffer;
uniform vec2 texcoordoffset;
uniform mat4 camerainversematrix;
uniform vec3 cameraposition;

out vec4 fragData0;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float depthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x)) * depthrange.y;
}

float shadowLookup(in sampler2DShadow shadowmap, in vec3 shadowcoord, in vec2 offset)
{
	if (shadowcoord.y<0.0) return 0.5;
	if (shadowcoord.y>1.0) return 0.5;
	if (shadowcoord.x<0.0) return 0.5;
	if (shadowcoord.x>1.0) return 0.5;
	
	float f=0.0;
	int x,y;
	vec2 sampleoffset;
	
	for (x=0; x<KERNEL; ++x)
	{
		sampleoffset.x = float(x) - KERNELF*0.5 + 0.5;
		for (y=0; y<KERNEL; ++y)
		{
			sampleoffset.y = float(y) - KERNELF*0.5 + 0.5;
			f += texture(shadowmap,vec3(shadowcoord.x+sampleoffset.x*offset.x,shadowcoord.y+sampleoffset.y*offset.y,shadowcoord.z));
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
	
	float depth;
	vec4 diffuse;
	vec3 normal;
	vec4 materialdata;
	float specularity;
	float ao;
	bool uselighting;
	vec4 emission;	
	vec4 sampleoutput;
	vec4 stagecolor;
	vec3 screencoord;
	vec3 screennormal;
	float attenuation;
	vec4 specular;
	vec3 lightreflection;
	float fade;
	vec3 shadowcoord;
	float dist;
	vec3 offset;
	mat3 lightnormalmatrix;
	vec2 sampleoffset;
	vec3 lp;
	vec4 normaldata;
	int materialflags;
	
	fragData0 = vec4(0.0);
	
	for (int i=0; i<max(1,SAMPLES); i++)
	{
		//----------------------------------------------------------------------
		//Retrieve data from gbuffer
		//----------------------------------------------------------------------
#if SAMPLES==0
		depth = 		texture(texture0,coord).x;
		diffuse = 		texture(texture1,coord);
		normaldata =	texture(texture2,coord);
		emission = 		texture(texture3,coord);
#else
		depth = 		texelFetch(texture0,icoord,i).x;
		diffuse = 		texelFetch(texture1,icoord,i);
		normaldata =	texelFetch(texture2,icoord,i);
		emission = 		texelFetch(texture3,icoord,i);
#endif
		normal = 			camerainversenormalmatrix * normalize(normaldata.xyz*2.0-1.0);
		specularity =		emission.a;
		materialflags = 	int(normaldata.a * 255.0 + 0.5);
		uselighting =		false;
		if ((1 & materialflags)!=0) uselighting=true;
		sampleoutput = 		diffuse + emission;
		stagecolor =		vec4(1.0,0.0,1.0,1.0);
		
		//Calculate gloss
		float gloss=70.0;
		if ((32 & materialflags)!=0) gloss -= 40.0;
		if ((64 & materialflags)!=0) gloss -= 20.0;
		
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
		
		screennormal = normalize(screencoord);
		if (!isbackbuffer) screencoord.y *= -1.0;
		
		if (multipass)
		{
			if (uselighting==false || depth==1.0f) continue;
		}
		
		//---------------------------------------------------------
		//Fog
		//---------------------------------------------------------
		
		vec3 worldpos = cameranormalmatrix * screencoord;
		vec3 cubecoord = normalize(worldpos.xyz);
		float fogeffect = 0.0f;
		
		if (fogmode)
		{
			if (depth == 1.0f) //no geometry rendered --> background
			{
				vec3 normal=normalize(cubecoord);
				normal.y = max(normal.y,0.0);
				float angle=asin(normal.y)*57.2957795-fogangle.x;
				fogeffect = 1.0-clamp(angle/(fogangle.y-fogangle.x),0.0,1.0);
			}
			else // no background - render input + fog to output
			{
				fogeffect = clamp( 1.0 - (fogrange.y - length(screencoord.xyz)) / (fogrange.y - fogrange.x) , 0.0, 1.0 );
					
			}
			fogeffect*=fogcolor.a;	
		}
		
		//---------------------------------------------------------
		
		if (uselighting)
		{
			//----------------------------------------------------------------------
			//Calculate lighting
			//----------------------------------------------------------------------		
			
			attenuation = max(0.0,-dot(lightdirection,normal));
			lightreflection = normalize(reflect(lightdirection,normal));
			if (!isbackbuffer) lightreflection.y *= -1.0;
			specular = lightspecular * specularity * vec4( pow(clamp(-dot(lightreflection,screennormal),0.0,1.0),gloss) * 0.5);
			specular *= lightcolor.r * 0.299 + lightcolor.g * 0.587 + lightcolor.b * 0.114;

#ifdef USESHADOW
			fade=1.0;
			if (attenuation>LOWERLIGHTTHRESHHOLD)
			{
				//----------------------------------------------------------------------
				//Shadow lookup
				//----------------------------------------------------------------------
				dist = clamp(length(screencoord)/shadowstagerange[0],0.0,1.0);
				offset = vec3(0.0);
				//vec3 lightposition;
				lightnormalmatrix = mat3(0);
				sampleoffset = shadowstagepositon[0];
				fade=1.0;
				lp = vec3(0);
				
				if (dist<1.0)
				{
					//offset.x = 0.0;
					offset.z = -lightshadowmapoffset[0].x;
					lp = lightposition[0];
					lightnormalmatrix = lightnormalmatrix0;
					fade=0.0;
					stagecolor=vec4(1.0,0.0,0.0,1.0);
				}
				else
				{
					//fade=0.0;
					dist = clamp(length(screencoord)/shadowstagerange[1],0.0,1.0);
					if (dist<1.0)
					{
						//offset.x = 1.0;
						offset.z = -lightshadowmapoffset[1].x;
						lp = lightposition[1];
						lightnormalmatrix = lightnormalmatrix1;
						fade=0.0;
						sampleoffset = shadowstagepositon[1];
						stagecolor=vec4(0.0,1.0,0.0,1.0);
	#if SHADOWSTAGES==2
						fade = clamp((dist-0.75)/0.25,0.0,1.0);// gradually fade out the last shadow stage
	#endif
					}
	#if SHADOWSTAGES>2
					else
					{	
						dist = clamp(length(screencoord)/shadowstagerange[2],0.0,1.0);
						if (dist<1.0)
						{
							//offset.x = 2.0;
							offset.z = -lightshadowmapoffset[2].x;
							lp = lightposition[2];
							lightnormalmatrix = lightnormalmatrix2;
							stagecolor=vec4(0.0,0.0,1.0,1.0);
							fade=0.0;
							sampleoffset = shadowstagepositon[2];
		#if SHADOWSTAGES==3
							fade = clamp((dist-0.75)/0.25,0.0,1.0);// gradually fade out the last shadow stage
		#endif
						}
		#if SHADOWSTAGES==4
						else
						{
							dist = clamp(length(screencoord)/shadowstagerange[3],0.0,1.0);
							if (dist<1.0)
							{
								stagecolor=vec4(0.0,1.0,1.0,1.0);
								//offset.x = 3.0;
								offset.z = -lightshadowmapoffset[3].x;
								lp = lightposition[3];
								lightnormalmatrix = lightnormalmatrix3;
								fade = clamp((dist-0.75)/0.25,0.0,1.0);// gradually fade out the last shadow stage
								sampleoffset = shadowstagepositon[3];
							}
							else
							{
								fade = 1.0;
							}
						}
		#endif
					}
	#endif
				}
				if (fade<1.0)
				{
					shadowcoord = lightnormalmatrix * (screencoord - lp);
					shadowcoord += offset;
					shadowcoord.z = (shadowcoord.z - lightrange.x) / (lightrange.y-lightrange.x);	
					shadowcoord.xy += 0.5;
					shadowcoord.xy *= shadowstagescale;
					shadowcoord.xy += sampleoffset;
					attenuation = attenuation * fade + attenuation * shadowLookup(texture5,shadowcoord,1.0/shadowmapsize) * (1.0-fade);
				}
			}
#endif			

			//----------------------------------------------------------------------
			//Final light calculation
			//----------------------------------------------------------------------
			sampleoutput = (diffuse * lightcolor + specular) * attenuation + emission + diffuse * ambientlight;
			
			//sampleoutput = (sampleoutput + stagecolor) / 2.0;
		}
		//Blend with red if selected
		if ((2 & materialflags)!=0)
		{
			sampleoutput = (sampleoutput + vec4(1.0,0.0,0.0,0.0))/2.0;
		}
		sampleoutput = sampleoutput * (1.0-fogeffect) + fogcolor * fogeffect;
		fragData0 += sampleoutput * 1.0;	
	}
	
	fragData0 /= float(max(1,SAMPLES));
	fragData0 = max(fragData0,0.0f);
	
	//fragData0 = fragData0 * (ambientlight.a);
	
	//fragData0 = lightcolor;
	
	gl_FragDepth = depth;	
}
