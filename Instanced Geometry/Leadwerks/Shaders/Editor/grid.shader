SHADER version 1
@OpenGL2.Vertex
//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform vec4 materialcolordiffuse;

//Attributes
attribute vec3 vertex_position;
attribute vec4 vertex_color;

//Outputs
varying vec4 ex_color;
varying float ex_selectionstate;

void main()
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;

	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	ex_selectionstate = 0.0;
	if (ex_color.a<-5.0)
	{
		ex_color.a += 10.0;
		ex_selectionstate = 1.0;
	}
}
@OpenGL2.Fragment
//Inputs
varying vec4 ex_color;
varying float ex_selectionstate;

void main(void)
{
	gl_FragColor = ex_color * (1.0-ex_selectionstate) + ex_selectionstate * (ex_color*0.5+vec4(0.5,0.0,0.0,0.0));
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform vec4 materialcolordiffuse;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;

//Outputs
out vec4 ex_color;

void main()
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]) * (vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse);
}
@OpenGL4.Fragment
#version 400

//Inputs
in vec4 ex_color;

out vec4 fragData0;
out vec4 fragData1;
out vec4 fragData2;
out vec4 fragData3;

void main(void)
{
	fragData0 = ex_color;
	fragData1 = vec4(0.5,0.5,1.0,0.0);	
	fragData2 = vec4(0.0,0.0,0.0,0.0);
}
