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

uniform sampler2D texture1;
uniform bool isbackbuffer;
uniform vec2 buffersize;
uniform float currenttime;
uniform float strength=0.1;

out vec4 fragData0;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main(void)
{
	vec2 tcoord = vec2(gl_FragCoord.xy/buffersize);
	if (isbackbuffer) tcoord.y = 1.0 - tcoord.y;

	vec4 pixel = texture(texture1, tcoord);
	
	pixel.rgb += vec3( rand(gl_FragCoord.xy / buffersize / 100.0 * currenttime * pixel.rg) * strength ) - strength * 0.5;
	
	fragData0 = pixel;
}
