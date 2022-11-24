SHADER version 1
@OpenGL2.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
//uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0 = vec4(0.0);

//Inputs
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;

//Outputs
out vec4 ex_color;
out vec2 texcoords0;
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
	
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	gl_Position = projectioncameramatrix * vec4(vertex_position, 1.0);
	ex_color.r = 1.0 - vertex_color.r;
	ex_color.g = 1.0 - vertex_color.g;
	ex_color.b = 1.0 - vertex_color.b;
	ex_color.a = vertex_color.a;
	
	ex_color.r *= entitymatrix[0][3];
	ex_color.g *= entitymatrix[1][3];
	ex_color.b *= entitymatrix[2][3];
	ex_color.a *= entitymatrix[3][3];
	
	texcoords0 = vertex_texcoords0;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
//uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0 = vec4(0.0);

//Inputs
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;

//Outputs
out vec4 ex_color;
out vec2 texcoords0;
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
	
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	gl_Position = projectioncameramatrix * vec4(vertex_position, 1.0);
	ex_color.r = 1.0 - vertex_color.r;
	ex_color.g = 1.0 - vertex_color.g;
	ex_color.b = 1.0 - vertex_color.b;
	ex_color.a = vertex_color.a;
	
	ex_color.r *= entitymatrix[0][3];
	ex_color.g *= entitymatrix[1][3];
	ex_color.b *= entitymatrix[2][3];
	ex_color.a *= entitymatrix[3][3];
	
	texcoords0 = vertex_texcoords0;
}
@OpenGL4.Fragment
#version 400

//Uniforms
uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture10;
uniform vec4 materialcolordiffuse;
uniform vec2 buffersize;
uniform vec2 camerarange;
uniform float camerazoom;
uniform bool isbackbuffer;

//Inputs
in vec4 ex_color;
in vec2 texcoords0;
in float clipdistance0;

//Outputs
out vec4 fragData0;

float depthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x)) * depthrange.y;
}

float positionToDepth(in float z, in vec2 depthrange) {
	return (depthrange.x / (z / depthrange.y) - depthrange.y) / -(depthrange.y - depthrange.x);
}

void main()
{
	//Clip plane discard
	if (clipdistance0>0.0) discard;
	
	vec4 color = texture(texture0,texcoords0);
	vec3 normal = (color.rgb*2.0-1.0).xyz;
	
	vec3 screencoord = vec3(((gl_FragCoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-gl_FragCoord.y/buffersize.y)+0.5) * 2.0,depthToPosition(gl_FragCoord.z,camerarange));
	screencoord.x *= screencoord.z / camerazoom;
	screencoord.y *= -screencoord.z / camerazoom;
	vec3 screennormal = normalize(screencoord);
	vec3 refractdir = screennormal;
	
	vec4 refractionvector = vec4( gl_FragCoord.x/buffersize.x, gl_FragCoord.y/buffersize.y, gl_FragCoord.z, 1.0 );
	if (isbackbuffer) refractionvector.y = 1.0f - refractionvector.y;
	
	//refractionvector.xyz = refractionvector.xyz - normal * 0.05;
	refractionvector.z = positionToDepth(refractionvector.z, camerarange);
	
	//Refraction
	vec2 texcoord = gl_FragCoord.xy / buffersize;
	if (isbackbuffer) texcoord.y = 1.0f - texcoord.y;
	//vec4 screencolor = textureProj(texture10,refractionvector);
	
	vec4 screencolor = texture(texture10,texcoord + normal.xy * 0.05 * color.a * ex_color.a);
	
	

	fragData0 = screencolor;//ex_color * texture(texture0,texcoords0) * materialcolordiffuse;
	//fragData0 = vec4(1.0*,0,0,1);//screencolor;
}
