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
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID]+offset, 0.0, 1.0));
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
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID]+offset, 0.0, 1.0));
}
@OpenGL4.Fragment
#version 400

uniform sampler2DMS texture0;
uniform sampler2D texture1;
uniform bool isbackbuffer;
uniform vec2 buffersize;
uniform float currenttime;
uniform vec2 camerarange;
uniform float camerazoom;
uniform mat4 inversecameramatrix;
uniform mat4 cameramatrix;
uniform mat3 cameranormalmatrix;
uniform mat4 projectionmatrix;
uniform sampler3D texture10;

//Water params
uniform bool watermode = true;
uniform float waterheight = 42.3;

//Fog parameters
uniform bool fogmode = true;
uniform vec2 fogrange = vec2(0.0,100.0);
uniform vec4 fogcolor = vec4(1.0);

out vec4 fragData0;

#define AO_DOWNSAMPLING 1.0f

mat3 vec3tomat3( in vec3 z )
{
	mat3 mat;
	mat[2]=z;
	vec3 v=vec3(z.z,z.x,-z.y);//make a random vector that isn't the same as vector z
	mat[0]=cross(z,v);//cross product is the x axis
	mat[1]=cross(mat[0],z);//cross product is the y axis
	return mat;
}

float depthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x)) * depthrange.y;
}

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 screenToWorld(in vec3 screencoord)
{
	if (isbackbuffer) screencoord.y = 1.0 - screencoord.y;
	vec4 coord = vec4(((screencoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-screencoord.y/buffersize.y)+0.5) * 2.0,screencoord.z,1.0f);
	coord.x *= coord.z / camerazoom;
	coord.y *= coord.z / camerazoom;
	return (cameramatrix * coord).xyz;
}

const int passes = 8;
const int nSamplesNum = 8;

void main( void )
{
	vec2 texcoord = vec2(gl_FragCoord.xy/buffersize);
	if (isbackbuffer) texcoord.y = 1.0 - texcoord.y;
	
	vec4 outputcolor = texture(texture1,texcoord);
	//outputcolor = outputcolor * 0.5 + 0.5 * vec4(1.0);
	
	float depth = texelFetch(texture0, ivec2((texcoord*buffersize*AO_DOWNSAMPLING)), 0).x;
	vec3 worldCoord = screenToWorld(vec3(gl_FragCoord.xy,depthToPosition(depth,camerarange)));
	
	//-----------------------------------------------------
	//Remove underwater artifacts
	//-----------------------------------------------------
	vec3 screencoord = vec3(((gl_FragCoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-gl_FragCoord.y/buffersize.y)+0.5) * 2.0,depthToPosition(depth,camerarange));
	screencoord.x *= screencoord.z / camerazoom;
	screencoord.y *= -screencoord.z / camerazoom;
	if (!isbackbuffer) screencoord.y *= -1.0;
	vec3 worldpos = cameranormalmatrix * screencoord + cameramatrix[3].xyz;
	
	if (watermode)
	{
		if (sign(cameramatrix[3][1] - waterheight) != sign(worldpos.y - waterheight))
		{
			fragData0 = outputcolor;
			return;				
		}
	}
	
	float fogeffect = 0.0f;
	if (fogmode==true)
	{
		fogeffect = clamp( 1.0 - (fogrange.y - length(worldCoord - cameramatrix[3].xyz)) / (fogrange.y - fogrange.x) , 0.0, 1.0 );
		fogeffect*=fogcolor.a;
		if (fogeffect==1.0f)
		{
			fragData0 = outputcolor;
			return;
		}
	}	
	
	float sumao = 0.0f;
	
	if (depth<1.0)
	{
		for (int i=0; i<passes; ++i)
		{
			vec2 rotationTC=texcoord*buffersize/4.0;
			
			float scale = 0.01;
			worldCoord *= scale;
			worldCoord = texture(texture10,worldCoord/1.0).rgb;
			worldCoord += texture(texture10,worldCoord*1.0).rgb;
			worldCoord += texture(texture10,worldCoord*1.0).rgb;
			worldCoord /= 3.0;
			worldCoord = vec3(ivec3(worldCoord/scale))*scale * 100.0;
			
			vec3 vRotation;
			//vRotation=vec3(rand(gl_FragCoord.xy*gl_FragCoord.zx*float(i+1)),rand(gl_FragCoord.zy*-gl_FragCoord.xz*float(i+1)),rand(gl_FragCoord.xz*gl_FragCoord.yx*float(i+1)));
			vRotation.x = rand(gl_FragCoord.xy*gl_FragCoord.zx+cameramatrix[0].xy*float(i+1.0f));
			vRotation.y = rand(gl_FragCoord.xz*gl_FragCoord.xy+cameramatrix[0].zx*float(i+1.0f));
			vRotation.z = rand(gl_FragCoord.yz*gl_FragCoord.zx+cameramatrix[0].yz*float(i+1.0f));
			//vRotation.x = rand(gl_FragCoord.xy);
			//vRotation.y = rand(gl_FragCoord.xz);
			//vRotation.z = rand(gl_FragCoord.yx);
			//vRotation=vec3(rand(worldCoord.xy+worldCoord.z),rand(worldCoord.zy+worldCoord.x),rand(worldCoord.xz-worldCoord.y));
			
			mat3 rotMat=vec3tomat3(vRotation);
			
			float fSceneDepthP = depthToPosition(depth,camerarange);
			
			float offsetScale = 0.01;
			const float offsetScaleStep = 1.0 + 2.4/nSamplesNum;
			
			float Accessibility = 0.0;
			
			for ( int i = 0 ; i < nSamplesNum/8; i ++ )
			{
				for ( int x = -1 ; x <= 1 ; x +=2 )
				{
					for ( int y = -1 ; y <= 1 ; y +=2 )
					{
						for ( int z = -1 ; z <= 1 ; z +=2 )
						{
							vec3 vOffset = normalize ( vec3 ( x , y , z ) ) *
											( offsetScale *= offsetScaleStep );
											
							vec3 vRotatedOffset = rotMat * vOffset;
							
							vec3 vSamplePos = vec3 ( texcoord , fSceneDepthP );
							
							vSamplePos += vec3 ( vRotatedOffset.xy,
												vRotatedOffset.z * fSceneDepthP * 2.0 );
												
							float fSceneDepthS = depthToPosition(texelFetch( texture0, ivec2(vSamplePos.xy * buffersize*AO_DOWNSAMPLING), 0).x, camerarange);
							
							float fRangeIsInvalid = clamp ( ( ( fSceneDepthP - 
																fSceneDepthS ) / fSceneDepthS ) , 0.0 , 1.0 );
							
							Accessibility += mix ( clamp(ceil(fSceneDepthS-vSamplePos.z),0.0,1.0) , 0.5 , fRangeIsInvalid );
						}
					}
				}
			}
			Accessibility /= nSamplesNum;
			
			float ao = Accessibility*Accessibility+Accessibility;
			sumao += min(ao,0.75)+0.25;
			
			//outputcolor = vec4(ao,ao,ao,1.0f);
			//outputcolor.rgb *= vRotation;
		}
		fragData0 = outputcolor * fogeffect + outputcolor * (sumao / float(passes)) * (1.0 - fogeffect);
	}
	else
	{
		fragData0 = outputcolor;
	}
	//fragData0.rgb=worldCoord / 5.0;
}
