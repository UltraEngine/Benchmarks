SHADER version 1
@OpenGL2.Vertex
#version 400

//APPENDED_DATA

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];

in vec3 vertex_position;
in vec2 vertex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID], 0.0, 1.0));
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

//APPENDED_DATA

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];

in vec3 vertex_position;
in vec2 vertex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID], 0.0, 1.0));
}
@OpenGL4.Fragment
#version 400
#ifndef SAMPLES
	#define SAMPLES 1
#endif

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

//Fog parameters
uniform bool fogmode = true;
uniform vec4 fogcolor = vec4(1.0);
uniform vec2 fogrange = vec2(0.0,100.0);
uniform vec2 fogangle = vec2(25.0,35.0);

uniform vec2 texcoordoffset;
uniform vec4 ambientlight;
uniform vec2 buffersize;
uniform vec2 camerarange;
uniform bool isbackbuffer;
uniform mat4 cameramatrix;
uniform mat3 cameranormalmatrix;
uniform float camerazoom;

in vec2 vTexCoord;

out vec4 fragData0;

float DepthToZPosition(in float depth)
{
	return camerarange.x / (camerarange.y - depth * (camerarange.y - camerarange.x)) * camerarange.y;
}

float depthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x)) * depthrange.y;
}

void main(void)
{
	//----------------------------------------------------------------------
	//Calculate screen texcoord
	//----------------------------------------------------------------------
	vec2 coord = texcoordoffset + gl_FragCoord.xy / buffersize;	
	if (isbackbuffer) coord.y = 1.0 - coord.y;
	
	ivec2 icoord = ivec2(texcoordoffset*buffersize + gl_FragCoord.xy);
	if (isbackbuffer) icoord.y = int(buffersize.y) - icoord.y;
	
	vec4 diffuse = vec4(0.0);
	vec4 emission = vec4(0.0);
	
	float ao = 1.0;
	
	fragData0 = vec4(0.0);
	
	for (int i=0; i<max(1,SAMPLES); i++)
	{
#if SAMPLES==0
		vec4 samplediffuse = texture(texture1,coord);
		vec4 samplenormal = texture(texture2,coord);
		emission = texture(texture3,coord);
		vec4 materialdata = texture(texture3,coord);
#else
		vec4 samplediffuse = texelFetch(texture1,icoord,i);
		vec4 samplenormal = texelFetch(texture2,icoord,i);
		emission = texelFetch(texture3,icoord,i);
		vec4 materialdata = texelFetch(texture3,icoord,i);
#endif
		ao=max(0.25,materialdata[1]);
		int materialflags = int(samplenormal.a * 255.0 + 0.5);
		bool uselighting = false;
		if ((1 & materialflags)!=0) samplediffuse *= ambientlight;
		if ((2 & materialflags)!=0)
		{
			samplediffuse = (samplediffuse + vec4(1.0,0.0,0.0,0.0))/2.0;
		}
		
		//Simple shading
		//if ((1 & materialflags)!=0) {
		//	vec4 lightdir = vec4(-0.4,-0.45,0.5,1.0);
		//	float intensity = abs(dot(normalize(samplenormal.xyz),lightdir.xyz))*0.5+0.75;
		//	samplediffuse *= intensity;
		//}
		
		//---------------------------------------------------------
		//Fog
		float fogeffect = 0.0f;
		if (fogmode)
		{
			float depth = texelFetch(texture0,icoord,i).x;
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
			if (!isbackbuffer) screencoord.y *= -1.0;		
			
			vec3 worldpos = cameranormalmatrix * screencoord;
			vec3 cubecoord = normalize(worldpos.xyz);
			
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
			//fogeffect=0.0;
		}
		
		//---------------------------------------------------------		
		
		fragData0 += (samplediffuse + emission) * (1.0-fogeffect) + fogeffect * fogcolor;
	}
	
	//fragData0 = vec4(10.0f);

	//----------------------------------------------------------------------
	//Calculate lighting
	//----------------------------------------------------------------------	
	fragData0 /= float(max(1,SAMPLES));
	fragData0 = max(fragData0,0.0);
	
	//fragData0 = ambientlight;
	
#if SAMPLES==0
	gl_FragDepth = texture(texture0,coord).r;
#else
	gl_FragDepth = texelFetch(texture0,icoord,0).r;
#endif
}
