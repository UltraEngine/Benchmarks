SHADER version 1
@OpenGL2.Vertex
#version 400
#define MAX_BONES 256

//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform bonematrices { mat4 matrix[MAX_BONES];} bone;

//Attributes
in vec3 vertex_position;
in vec4 vertex_boneweights;
in ivec4 vertex_boneindices;
in vec2 vertex_texcoords0;

out vec2 ex_texcoords0;

void main()
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	ex_texcoords0 = vertex_texcoords0;

	vec4 wt = vertex_boneweights;
	float m = wt[0]+wt[1]+wt[2]+wt[3];
	wt[0]/=m; wt[1]/=m; wt[2]/=m; wt[3]/=m;

	mat4 animmatrix = bone.matrix[(vertex_boneindices[0])] * wt[0];
	animmatrix += bone.matrix[(vertex_boneindices[1])] * wt[1];
	animmatrix += bone.matrix[(vertex_boneindices[2])] * wt[2];
	animmatrix += bone.matrix[(vertex_boneindices[3])] * wt[3];	
	
	animmatrix[0][3]=0.0;
	animmatrix[1][3]=0.0;
	animmatrix[2][3]=0.0;
	animmatrix[3][3]=1.0;
	
	entitymatrix_ *= animmatrix;
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	gl_Position = projectioncameramatrix * modelvertexposition;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define MAX_BONES 256

//Uniforms
uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform bonematrices { mat4 matrix[MAX_BONES];} bone;

//Attributes
in vec3 vertex_position;
in vec4 vertex_boneweights;
in ivec4 vertex_boneindices;
in vec2 vertex_texcoords0;

out vec2 ex_texcoords0;

void main()
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	ex_texcoords0 = vertex_texcoords0;

	vec4 wt = vertex_boneweights;
	float m = wt[0]+wt[1]+wt[2]+wt[3];
	wt[0]/=m; wt[1]/=m; wt[2]/=m; wt[3]/=m;

	mat4 animmatrix = bone.matrix[(vertex_boneindices[0])] * wt[0];
	animmatrix += bone.matrix[(vertex_boneindices[1])] * wt[1];
	animmatrix += bone.matrix[(vertex_boneindices[2])] * wt[2];
	animmatrix += bone.matrix[(vertex_boneindices[3])] * wt[3];	
	
	animmatrix[0][3]=0.0;
	animmatrix[1][3]=0.0;
	animmatrix[2][3]=0.0;
	animmatrix[3][3]=1.0;
	
	entitymatrix_ *= animmatrix;
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	gl_Position = projectioncameramatrix * modelvertexposition;
}
@OpenGL4.Fragment
#version 400

uniform sampler2D texture0;

in vec2 ex_texcoords0;

void main()
{
	if (texture(texture0,ex_texcoords0).a<0.5) discard;
}
