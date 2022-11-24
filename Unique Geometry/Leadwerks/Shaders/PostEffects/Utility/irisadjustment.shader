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
//This shader should not be attached directly to a camera. Instead, use the bloom script effect.
#version 400

//-------------------------------------
//MODIFIABLE UNIFORMS
//-------------------------------------
uniform float cutoff=0.25;//The lower this value, the more blurry the scene will be
uniform float overdrive=1.0;//The higher this value, the brighter the bloom effect will be
//-------------------------------------
//
//-------------------------------------

uniform sampler2D texture0;//Diffuse
uniform sampler2D texture1;//Bloom
uniform bool isbackbuffer;
uniform vec2 buffersize;
uniform float currenttime;

out vec4 fragData0;

void main(void)
{
	vec2 texcoord = vec2(gl_FragCoord.xy/buffersize);
	if (isbackbuffer) texcoord.y = 1.0 - texcoord.y;
	
	vec4 scene = texture(texture0, texcoord);
	
	vec4 exposurecolor = texture(texture1,vec2(0.5));
	float avgLuminance = exposurecolor.r * 0.3 + exposurecolor.g * 0.59 + exposurecolor.b * 0.11;	
	float irisadjustment = 1.0 / (avgLuminance/0.25);
	irisadjustment = clamp(irisadjustment,1.0,3.0);
	scene *= irisadjustment;
	
	fragData0 = scene;
}
