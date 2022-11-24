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
uniform vec3 lightposition=vec3(0.5,0.5,0.5);
uniform vec3 lightvector=vec3(0.5,0.5,-0.5);
uniform vec4 lightcolor=vec4(1.0);
uniform vec4 scenecolor=vec4(1.0);
uniform float maxraylength=0.8;

out vec4 fragData0;

#define RAYSAMPLES 32
#define exposure 1.0
#define NOISEAMOUNT 1.0

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() 
{
	vec2 texcoord = vec2(gl_FragCoord.xy/buffersize);
	if (isbackbuffer) texcoord.y = 1.0 - texcoord.y;
	
	vec4 scene = texture(texture1, texcoord) * scenecolor;
	
	vec3 screenlightcoord=lightposition;
	vec2 deltaTexCoord = ( screenlightcoord.xy - texcoord );
	
	deltaTexCoord *= sign(lightposition.z);

	float length = length( deltaTexCoord );
	deltaTexCoord /= length;
	length = min(length,maxraylength);
	deltaTexCoord *= length;

	vec2 godraycoord = texcoord;// make a modifiable variable	
	
	float d;
	
	if ((texcoord.x + deltaTexCoord.x - 1.0) > 0.0) {
		d = (1.0 - godraycoord.x)/deltaTexCoord.x;
		deltaTexCoord *= d;	
	}
	if ((texcoord.y + deltaTexCoord.y - 1.0) > 0.0) {
		d = (1.0 - godraycoord.y)/deltaTexCoord.y;
		deltaTexCoord *= d;
	}	
	if ((texcoord.x + deltaTexCoord.x) < 0.0) {
		d = godraycoord.x/-deltaTexCoord.x;
		deltaTexCoord *= d;
	}
	if ((texcoord.y + deltaTexCoord.y)<0.0) {
		d = godraycoord.y/-deltaTexCoord.y;
		deltaTexCoord *= d;
	}
	
	deltaTexCoord /= RAYSAMPLES;
	
	float illuminationDecay = 1.0;
	
	vec4 sample_;
	float weight = 1.0;
	float decay = 1.0;
	
	float b;
	float godray = 0.0;
	float avg=0.0;
	
	float ok=0.0;
	
	vec2 dc;
	float dd;
	float randomnoise;
	
	randomnoise = 1.0 - NOISEAMOUNT * 0.5 + NOISEAMOUNT * rand(gl_FragCoord.xy * lightvector.xy);
	godraycoord += deltaTexCoord * randomnoise;
	
	float aspect = buffersize.x / buffersize.y;
	
	for ( int i = 0; i < RAYSAMPLES; i++ )
	{
		godraycoord += deltaTexCoord;
		godray += illuminationDecay * 0.5*(texture2D( texture1, godraycoord ).x);
		illuminationDecay *= decay;
		
		//dc=godraycoord-screenlightcoord.xy;
		//dd=sqrt(dc.x*dc.x+dc.y*dc.y);
		//dd=1.0-clamp(0.05-dd,0.0,1.0);
		//ok=1.0;
		//ok=max(ok,dd);
	}
	godray /= RAYSAMPLES;
	godray *= exposure;
	
	//Darken the ray if it is in the foreground and camera faces away from light source
	//Enable the depth check if you want rays to appear when facing away from the camera.
	//However, due to the reduced size buffer, this will cause jaggies to appear along the skyline
	//so I commented it out.  :(
	//if (depth<1.0) {
		godray = godray * max(-lightvector.z,0.0);
	//}
	
	godray = max(godray,0.0);
	
	fragData0 = scene + lightcolor * godray;
}
