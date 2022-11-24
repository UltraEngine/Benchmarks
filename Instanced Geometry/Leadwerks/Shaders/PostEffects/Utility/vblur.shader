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

uniform sampler2D texture0;
uniform bool isbackbuffer;
uniform vec2 buffersize;

out vec4 fragData0;

const int samples = 8;
const float pixelsize = 2.0f;

void main(void)
{
	vec2 texcoord = vec2(gl_FragCoord.xy/buffersize);
	if (isbackbuffer) texcoord.y = 1.0 - texcoord.y;
		
	fragData0 = texture(texture0,texcoord);
	float sumweights = 1.0f;
	
	for (int i=1; i<=samples; i++)
	{
		float sampleweight = (1.0 - pow(float(i) / float(samples),2.0f));
		sampleweight*=sampleweight;
		sumweights += 2.0 * sampleweight;
		fragData0 += texture(texture0, texcoord + vec2(0.0f, float(i)*pixelsize/textureSize(texture0,0).y)) * sampleweight;
		fragData0 += texture(texture0, texcoord - vec2(0.0f, float(i)*pixelsize/textureSize(texture0,0).y)) * sampleweight;
	}
	fragData0/=sumweights;
}
