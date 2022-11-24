SHADER version 1
@OpenGL2.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
//uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;

//Attributes
in vec3 vertex_position;

//Outputs
out vec4 ex_color;
out float ex_selectionstate;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	//entitymatrix_=mat4(1.0);
	
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
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
//uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;

//Attributes
in vec3 vertex_position;

//Outputs
out vec4 ex_color;
out float ex_selectionstate;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	//entitymatrix_=mat4(1.0);
	
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
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

//Inputs
in vec4 ex_color;
in float ex_selectionstate;

out vec4 fragData0;
out vec4 fragData1;
out vec4 fragData2;

void main(void)
{
	fragData0 = ex_color * (1.0-ex_selectionstate) + ex_selectionstate * vec4(0.5,0.0,0.0,0.0);
	fragData1=vec4(0.0);
	fragData2=vec4(0.0);
}
