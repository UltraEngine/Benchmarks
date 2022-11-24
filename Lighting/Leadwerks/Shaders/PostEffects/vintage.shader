SHADER version 1
@OpenGL2.Vertex
uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];

attribute vec3 vertex_position;

varying vec2 ex_texcoords0;

void main(void)
{
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i], 1.0, 1.0));
	ex_texcoords0 = texcoords[i];
}
@OpenGL2.Fragment
uniform sampler2D texture0;
uniform vec2 buffersize;
uniform vec4 drawcolor;

varying vec2 ex_texcoords0;

void main(void)
{
	gl_FragColor = texture2D(texture0,ex_texcoords0) * drawcolor;
}
@OpenGLES2.Vertex
uniform mediump mat4 projectionmatrix;
uniform mediump mat4 drawmatrix;
uniform mediump vec2 offset;

attribute mediump vec3 vertex_position;
attribute mediump vec2 vertex_texcoords0;

varying mediump vec2 ex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(vertex_position, 1.0) + vec4(offset,0,0));
	ex_texcoords0 = vertex_texcoords0;
}
@OpenGLES2.Fragment
uniform sampler2D texture0;
uniform mediump vec2 buffersize;
uniform mediump vec4 drawcolor;

varying mediump vec2 ex_texcoords0;

void main(void)
{
	gl_FragData[0] = texture2D(texture0,ex_texcoords0) * drawcolor;
}
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
//--------------------------------------
// Vintage shader by Shadmar
//--------------------------------------

#version 400

uniform sampler2D texture1;
uniform bool isbackbuffer;
uniform vec2 buffersize;
uniform float currenttime;

out vec4 fragData0;

float contrast(float c)
{
	float a = 0.09;
	return (c - a) / (1 - 2 * a);
}
 
void main(void)
{
	vec2 tcoord = vec2(gl_FragCoord.xy/buffersize);
	if (isbackbuffer) tcoord.y = 1.0 - tcoord.y;

	vec4 pixel = texture(texture1, tcoord);

	pixel.r = contrast(pixel.r * 1.3);
	pixel.g = contrast(pixel.g + 0.05);
	pixel.b = contrast(pixel.b * 0.4 + 0.3);
	 
	fragData0 = vec4(pixel.rgb,1.0);
}
