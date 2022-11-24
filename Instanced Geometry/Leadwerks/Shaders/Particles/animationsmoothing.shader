SHADER version 1
@OpenGL2.Vertex
#version 400

//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform vec4 clipplane0 = vec4(0.0);

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec2 vertex_texcoords1;
in vec3 vertex_normal;

out vec4 color;
out vec2 texcoords0;
out vec2 texcoords1;
out float blendfunction;
out float clipdistance0;

void main ()
{
	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = vertex_position.x*clipplane0.x + vertex_position.y*clipplane0.y + vertex_position.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}		

	gl_Position = projectioncameramatrix * vec4(vertex_position, 1.0);
	color.r = 1.0 - vertex_color.r;
	color.g = 1.0 - vertex_color.g;
	color.b = 1.0 - vertex_color.b;
	color.a = vertex_color.a;
	texcoords0 = vertex_texcoords0;
	texcoords1 = vertex_texcoords1;
	blendfunction = vertex_normal.x;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform vec4 clipplane0 = vec4(0.0);

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec2 vertex_texcoords1;
in vec3 vertex_normal;

out vec4 color;
out vec2 texcoords0;
out vec2 texcoords1;
out float blendfunction;
out float clipdistance0;

void main ()
{
	//Clip planes
	if (length(clipplane0.xyz)>0.0001)
	{
		clipdistance0 = vertex_position.x*clipplane0.x + vertex_position.y*clipplane0.y + vertex_position.z*clipplane0.z + clipplane0.w;
	}
	else
	{
		clipdistance0 = 0.0;
	}		

	gl_Position = projectioncameramatrix * vec4(vertex_position, 1.0);
	color.r = 1.0 - vertex_color.r;
	color.g = 1.0 - vertex_color.g;
	color.b = 1.0 - vertex_color.b;
	color.a = vertex_color.a;
	texcoords0 = vertex_texcoords0;
	texcoords1 = vertex_texcoords1;
	blendfunction = vertex_normal.x;
}
@OpenGL4.Fragment
#version 400

//Uniforms
uniform sampler2D texture0;
uniform float currenttime;

//Inputs
in vec4 color;
in vec2 texcoords0;
in vec2 texcoords1;
in float blendfunction;
in float clipdistance0;

//Outputs
out vec4 fragdata0;

void main()
{
	//Clip plane discard
	if (clipdistance0>0.0) discard;
	
	vec4 color0 = texture(texture0,texcoords0);
	vec4 color1 = texture(texture0,texcoords1);
	//float blend = (currenttime/500.0 - (float)(int)currenttime/500.0);
	float blend = blendfunction; // mod(currentlife,333.3)/(333.3);		
	//a - (n* floor(a/n))
	//outcolor = outcolor * texture(texture0,texcoords1);
	fragdata0 = color * (color0 * (1.0-blend) + color1 * blend);
	//gl_FragColor = vec4(0.0,1.0,1.0,1.0);
}
