SHADER version 1
@OpenGL2.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 cameramatrix;
uniform mat4 camerainversematrix;
uniform mat4 projectioncameramatrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0 = vec4(0.0);

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec2 vertex_texcoords1;
in vec3 vertex_normal;
in vec3 vertex_tangent;
in vec3 vertex_binormal;

//Outputs
out vec4 ex_vertexposition;
out vec4 ex_color;
out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out float ex_selectionstate;
out vec3 ex_normal;
out vec3 ex_tangent;
out vec3 ex_binormal;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	ex_vertexposition = entitymatrix_ * vec4(vertex_position, 1.0);
	
	gl_Position = projectioncameramatrix * ex_vertexposition;
	
	ex_texcoords0 = vertex_texcoords0;
	ex_texcoords1 = vertex_texcoords1;
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	//Transform vectors from local to global space
	mat3 nmat = mat3(camerainversematrix) * mat3(entitymatrix);
	ex_normal = normalize(nmat * vertex_normal);	
	ex_tangent = normalize(nmat * vertex_tangent);
	ex_binormal = normalize(nmat * vertex_binormal);
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 cameramatrix;
uniform mat4 camerainversematrix;
uniform mat4 projectioncameramatrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
uniform vec4 clipplane0 = vec4(0.0);

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec2 vertex_texcoords1;
in vec3 vertex_normal;
in vec3 vertex_tangent;
in vec3 vertex_binormal;

//Outputs
out vec4 ex_vertexposition;
out vec4 ex_color;
out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out float ex_selectionstate;
out vec3 ex_normal;
out vec3 ex_tangent;
out vec3 ex_binormal;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	ex_vertexposition = entitymatrix_ * vec4(vertex_position, 1.0);
	
	gl_Position = projectioncameramatrix * ex_vertexposition;
	
	ex_texcoords0 = vertex_texcoords0;
	ex_texcoords1 = vertex_texcoords1;
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	//Transform vectors from local to global space
	mat3 nmat = mat3(camerainversematrix) * mat3(entitymatrix);
	ex_normal = normalize(nmat * vertex_normal);	
	ex_tangent = normalize(nmat * vertex_tangent);
	ex_binormal = normalize(nmat * vertex_binormal);
}
@OpenGL4.Fragment
#version 400

//Uniforms
uniform vec4 materialcolordiffuse;
uniform samplerCube texture0;//skybox
uniform sampler2D texture1;//prev frame
uniform sampler2D texture2;//next frame
uniform mat4 cameramatrix;
uniform mat4 projectioncameramatrix;
uniform vec2 camerarange;
uniform float camerazoom;
uniform vec2 buffersize;
uniform mat4 camerainversematrix;
uniform vec4 ambientlight;
uniform vec4 materialcolorspecular;
uniform mat3 cameranormalmatrix;
uniform vec3 cameraposition;
uniform float skybox;
uniform float currenttime;
uniform float blend;
uniform bool isbackbuffer;

//Fog parameters
uniform bool fogmode = true;
uniform vec4 fogcolor = vec4(1.0);
uniform vec2 fogrange = vec2(0.0,100.0);
uniform vec2 fogangle = vec2(90.0,90.0);

//Inputs
in vec4 ex_vertexposition;
in vec2 ex_texcoords0;
in vec2 ex_texcoords1;
in vec4 ex_color;
in vec3 ex_normal;
in float ex_selectionstate;
in vec3 ex_tangent;
in vec3 ex_binormal;

out vec4 fragData0;

float DepthToZPosition(in float depth) {
	return camerarange.x / (camerarange.y - depth * (camerarange.y - camerarange.x)) * camerarange.y;
}

float depthToPosition(in float depth, in vec2 depthrange)
{
	return depthrange.x / (depthrange.y - depth * (depthrange.y - depthrange.x)) * depthrange.y;
}

void main(void)
{
	float frame = currenttime/100000.0;
	vec3 p0 = texture(texture1,ex_vertexposition.xz/4.0).xyz*2.0-1.0;
	vec3 p1 = texture(texture2,ex_vertexposition.xz/4.0).xyz*2.0-1.0;
	vec3 perturbation = normalize(p0*(1.0-blend) + p1*blend);
	
	vec3 sundir = vec3(0.707,-0.707,0.707);
	float brightness = -dot(perturbation.xzy,sundir);
	brightness = max(0.0,brightness)*0.75+0.25;
	
	perturbation.z=0.0;

	vec4 outcolor = ex_color;
	float alpha;
	
	//Normal map
	vec3 normal = ex_normal;
	normal = perturbation;
	normal = ex_tangent * normal.x + ex_binormal * normal.y + ex_normal * normal.z;	
	
	//-------------------------------------------------
	//Fog
	vec3 screennormal;
	vec3 screencoord = vec3(((gl_FragCoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-gl_FragCoord.y/buffersize.y)+0.5) * 2.0,depthToPosition(gl_FragCoord.z,camerarange));
	screencoord.x *= screencoord.z / camerazoom;
	screencoord.y *= -screencoord.z / camerazoom;
	if (!isbackbuffer) screencoord.y *= -1.0;	
	screennormal = normalize(screencoord);		
	
	vec3 worldpos = cameranormalmatrix * screencoord;
	vec3 cubecoord = normalize(worldpos.xyz);
	float fogeffect = 0.0f;
	
	if (fogmode==true)
	{
		fogeffect = clamp( 1.0 - (fogrange.y - length(screencoord.xyz)) / (fogrange.y - fogrange.x) , 0.0, 1.0 );
		fogeffect*=fogcolor.a;
	}
	//--------------------------------------------------------		
	
	fragData0 = (1.0-fogeffect) * materialcolordiffuse * brightness + fogeffect * vec4(fogcolor.rgb,1.0);
	fragData0.a = 0.75;
}
