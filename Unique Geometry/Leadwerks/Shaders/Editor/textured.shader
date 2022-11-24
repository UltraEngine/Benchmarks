SHADER version 1
@OpenGL2.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform vec4 materialcolordiffuse;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;

//Attributes
in vec3 vertex_position;
in vec3 vertex_normal;
in vec2 vertex_texcoords0;

//Outputs
out vec4 ex_color;
out float ex_selectionstate;
out vec3 ex_normal;
out vec2 ex_texcoords0;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);
	
	ex_texcoords0 = vertex_texcoords0;
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]) * materialcolordiffuse;
	
	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	ex_selectionstate = 0.0;
	if (ex_color.a<-5.0)
	{
		ex_color.a += 10.0;
		ex_selectionstate = 1.0;
	}
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform vec4 materialcolordiffuse;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;

//Attributes
in vec3 vertex_position;
in vec3 vertex_normal;
in vec2 vertex_texcoords0;

//Outputs
out vec4 ex_color;
out float ex_selectionstate;
out vec3 ex_normal;
out vec2 ex_texcoords0;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);
	
	ex_texcoords0 = vertex_texcoords0;
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]) * materialcolordiffuse;
	
	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	ex_selectionstate = 0.0;
	if (ex_color.a<-5.0)
	{
		ex_color.a += 10.0;
		ex_selectionstate = 1.0;
	}
}
@OpenGL4.Fragment
#version 400

//Uniforms
uniform mat4 cameramatrix;
uniform sampler2D texture0;

//Inputs
in vec4 ex_color;
in float ex_selectionstate;
in vec3 ex_normal;
in vec2 ex_texcoords0;

out vec4 fragdata0;

void main(void)
{
	vec4 outcolor = ex_color;
	
	//Diffuse texture
	outcolor *= texture(texture0,ex_texcoords0);
	
	//Simple shading
	vec4 lightdir = vec4(-0.4,-0.7,0.5,1.0);
	lightdir = lightdir * cameramatrix;
	float intensity = -dot(normalize(ex_normal),lightdir.xyz);
	outcolor *= 0.75 + intensity * 0.25;
	
	if (ex_selectionstate>0.0) outcolor = (outcolor + vec4(1.0,0.0,0.0,1.0))/2.0;
	
	fragdata0 = outcolor;
}
