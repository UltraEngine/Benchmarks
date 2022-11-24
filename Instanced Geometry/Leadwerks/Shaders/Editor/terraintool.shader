SHADER version 1
@OpenGL2.Vertex
#version 120

//Uniforms
uniform mat4 entitymatrix;
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform sampler2D texture1;
uniform vec3 terrainscale;
uniform float terrainresolution=1024.0;

//Attributes
attribute vec3 vertex_position;
attribute vec4 vertex_color;
attribute vec2 vertex_texcoords0;
attribute vec2 vertex_texcoords1;
attribute vec3 vertex_normal;

//Outputs
varying vec4 ex_color;
varying vec2 ex_texcoords0;
varying vec2 ex_texcoords1;
varying float ex_selectionstate;
varying vec3 ex_VertexCameraPosition;
varying vec3 ex_normal;

void main()
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	//entitymatrix_[3][1]+=0.1;
	
	ex_VertexCameraPosition = vec3(camerainversematrix * entitymatrix_ * vec4(vertex_position, 1.0));
	
	vec4 v = entitymatrix_ * vec4(vertex_position, 1.0);
	v.y = texture2D(texture1,v.xz/terrainscale.x/terrainresolution+0.5).r * terrainscale.y;
	
	gl_Position = projectioncameramatrix * v;
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);	

	ex_texcoords0 = vertex_texcoords0;
	ex_texcoords1 = vertex_texcoords1;
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	ex_selectionstate = 0.0;
	if (ex_color.a<-5.0)
	{
		ex_color.a += 10.0;
		ex_selectionstate = 1.0;
	}
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGL2.Fragment
//Uniforms
uniform sampler2D texture0;	
uniform int lightingmode;
uniform vec2 buffersize;
uniform vec2 camerarange;
uniform float camerazoom;
uniform vec4 materialcoloruniform;
uniform vec4 materialcolorspecular;
uniform vec4 lighting_ambient;

//Lighting
uniform vec3 lightdirection[4];
uniform vec4 lightcolor[4];
uniform vec4 lightposition[4];
uniform float lightrange[4];
uniform vec3 lightingcenter[4];
uniform vec2 lightingconeanglescos[4];
uniform vec4 lightspecular[4];

//Inputs
varying vec2 ex_texcoords0;
varying vec2 ex_texcoords1;
varying vec4 ex_color;
varying float ex_selectionstate;
varying vec3 ex_VertexCameraPosition;
varying vec3 ex_normal;

float DepthToZPosition(in float depth) {
	return camerarange.x / (camerarange.y - depth * (camerarange.y - camerarange.x)) * camerarange.y;
}

void main(void)
{
	vec4 outcolor = ex_color;
	vec4 color_specular = materialcolorspecular;
	
	outcolor *= texture2D(texture0,ex_texcoords0);
	
	//Blend with selection color if selected
	gl_FragColor = outcolor * (1.0-ex_selectionstate) + ex_selectionstate * (outcolor*0.5+vec4(0.5,0.0,0.0,0.0));
}
@OpenGLES2.Vertex
//Uniforms
uniform mediump mat4 camerainversematrix;
uniform mediump mat4 projectioncameramatrix;
uniform mediump mat4 entitymatrix;
uniform mediump vec4 materialcolor;
uniform mediump mat4 cameramatrix;

//Attributes
attribute mediump vec3 vertex_position;
attribute mediump vec3 vertex_normal;
attribute mediump vec4 vertex_color;
attribute mediump vec2 vertex_texcoords0;
attribute mediump vec3 vertex_binormal;
attribute mediump vec3 vertex_tangent;

//Outputs
varying mediump vec4 ex_color;
varying mediump vec2 ex_texcoords0;
varying mediump vec3 ex_normal;
varying mediump vec3 ex_tangent;
varying mediump vec3 ex_binormal;
varying mediump vec3 ex_vertexposition;
varying mediump vec3 ex_motion;
varying mediump vec3 ex_eyevec;
varying mediump vec4 vertexcameraposition;
varying mediump vec3 VertexCameraPosition;

void main(void)
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vertexcameraposition = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	gl_Position = vertexcameraposition;
	//VertexCameraPosition = vec3(camerainversematrix * entitymatrix_ * vec4(vertex_position, 1.0));
    
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);
	
	ex_normal = normalize(nmat * vertex_normal);
	//ex_tangent = normalize(nmat * vertex_tangent);
	//ex_binormal = normalize(nmat * vertex_binormal);
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);// * materialcolor;
	
	ex_texcoords0 = vertex_texcoords0;
	
	ex_vertexposition = vec3(entitymatrix_ * vec4(vertex_position, 1.0));
	
	//Parallax
	//ex_eyevec.x = dot(gl_Position.xyz, ex_tangent);
	//ex_eyevec.y = dot(gl_Position.xyz, ex_binormal);
	//ex_eyevec.z = dot(gl_Position.xyz, ex_normal);
	//ex_eyevec = normalize(ex_eyevec);
	
	//mat3 tbnmat;
	//tbnmat[0] = ex_tangent;
	//tbnmat[1] = ex_binormal;
	//tbnmat[2] = ex_normal;
	//ex_eyevec = -vec3(cameramatrix*vec4(ex_vertexposition.xyz,1)) * tbnmat;	
}
@OpenGLES2.Fragment
//Uniforms
uniform sampler2D texture0;
uniform highp vec2 buffersize;
uniform highp vec2 camerarange;
uniform highp float camerazoom;
uniform highp vec4 materialcoloruniform;
uniform highp vec4 materialcolorspecular;
uniform highp vec4 lighting_ambient;

//Lighting
uniform highp vec3 lightdirection[4];
uniform highp vec4 lightcolor[4];
uniform highp vec4 lightposition[4];
uniform highp float lightrange[4];
uniform highp vec3 lightingcenter[4];
uniform highp vec2 lightingconeanglescos[4];
uniform highp vec4 lightspecular[4];

//Inputs
varying highp vec2 ex_texcoords0;
varying highp vec2 ex_texcoords1;
varying highp vec4 ex_color;
varying highp vec3 ex_VertexCameraPosition;
varying highp vec3 ex_normal;

void main(void)
{
	gl_FragData[0] = ex_color * texture2D(texture0,ex_texcoords0);
}
@OpenGL4.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform sampler2D texture1;
uniform vec3 terrainscale;
uniform float terrainresolution=1024.0;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec2 vertex_texcoords0;
in vec2 vertex_texcoords1;
in vec3 vertex_normal;

//Outputs
out vec4 ex_color;
out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out float ex_selectionstate;
out vec3 ex_VertexCameraPosition;
out vec3 ex_normal;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	//entitymatrix_[3][1]+=0.1;
	
	ex_VertexCameraPosition = vec3(camerainversematrix * entitymatrix_ * vec4(vertex_position, 1.0));
	
	vec4 v = entitymatrix_ * vec4(vertex_position, 1.0);
	v.y = texture(texture1,v.xz/terrainscale.x/terrainresolution+0.5).r * terrainscale.y;
	
	gl_Position = projectioncameramatrix * v;
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);	

	ex_texcoords0 = vertex_texcoords0;
	ex_texcoords1 = vertex_texcoords1;
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	
	//If an object is selected, 10 is subtracted from the alpha color.
	//This is a bit of a hack that packs a per-object boolean into the alpha value.
	ex_selectionstate = 0.0;
	if (ex_color.a<-5.0)
	{
		ex_color.a += 10.0;
		ex_selectionstate = 1.0;
	}
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGL4.Fragment
#version 400

//Uniforms
uniform sampler2D texture0;	
uniform int lightingmode;
uniform vec2 buffersize;
uniform vec2 camerarange;
uniform float camerazoom;
uniform vec4 materialcoloruniform;
uniform vec4 materialcolorspecular;
uniform vec4 lighting_ambient;

//Lighting
uniform vec3 lightdirection[4];
uniform vec4 lightcolor[4];
uniform vec4 lightposition[4];
uniform float lightrange[4];
uniform vec3 lightingcenter[4];
uniform vec2 lightingconeanglescos[4];
uniform vec4 lightspecular[4];

//Inputs
in vec2 ex_texcoords0;
in vec2 ex_texcoords1;
in vec4 ex_color;
in float ex_selectionstate;
in vec3 ex_VertexCameraPosition;
in vec3 ex_normal;

out vec4 fragData0;

float DepthToZPosition(in float depth) {
	return camerarange.x / (camerarange.y - depth * (camerarange.y - camerarange.x)) * camerarange.y;
}

void main(void)
{
	vec4 outcolor = ex_color;
	vec4 color_specular = materialcolorspecular;
	
	outcolor *= texture(texture0,ex_texcoords0);
	
	//Blend with selection color if selected
	fragData0 = outcolor * (1.0-ex_selectionstate) + ex_selectionstate * (outcolor*0.5+vec4(0.5,0.0,0.0,0.0));
}
