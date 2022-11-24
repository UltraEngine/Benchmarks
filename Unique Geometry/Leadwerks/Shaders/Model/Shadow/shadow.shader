SHADER version 1
@OpenGL2.Vertex
//Uniforms
uniform mat4 entitymatrix;
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
 
//Attributes
attribute vec3 vertex_position;
attribute vec4 vertex_color;
attribute vec3 vertex_normal;

//Outputs
varying vec4 ex_color;
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
	//entitymatrix_ * 
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);
	gl_Position = projectioncameramatrix * modelvertexposition;
	//ex_VertexCameraPosition = vec3(camerainversematrix * vec4(vertex_position, 1.0));
	//gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);	

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
uniform int lightingmode;
uniform vec2 buffersize;
uniform vec2 camerarange;
uniform float camerazoom;
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
varying vec4 ex_color;
varying float ex_selectionstate;
varying vec3 ex_VertexCameraPosition;
varying vec3 ex_normal;

void main(void)
{
	vec4 outcolor = ex_color;
	vec4 color_specular = materialcolorspecular;
	vec3 normal = normalize(ex_normal);	
	
	//Calculate lighting
	vec4 lighting_diffuse = vec4(0);
	vec4 lighting_specular = vec4(0);
	float attenuation=1.0;
	vec3 lightdir;
	vec3 lightreflection;
	int i;
	float denom;
	float anglecos;
	
	//One equation, three light types
	for (i=0; i<4; i++)
	{
		lightdir = normalize(ex_VertexCameraPosition - lightposition[i].xyz) * lightposition[i].w + lightdirection[i] * (1.0 - lightposition[i].w);        
		
		attenuation = lightposition[i].w * max(0.0, 1.0 - distance(lightposition[i].xyz,ex_VertexCameraPosition) / lightrange[i]) + (1.0 - lightposition[i].w);        
		
		attenuation *= max(0.0,dot(normal,-lightdir));
		
		denom = lightingconeanglescos[i].y-lightingconeanglescos[i].x;	
		if (denom>-1.0)
		{
			anglecos = max(0.0,dot(lightdirection[i],lightdir));
			attenuation *= 1.0 - clamp((lightingconeanglescos[i].y-anglecos)/denom,0.0,1.0);
		}
		
		lighting_diffuse += lightcolor[i] * attenuation;
		lightreflection = normalize(reflect(lightdir,normal));
	}
	
	outcolor = (lighting_diffuse + lighting_ambient) * outcolor;	
	
	//Blend with selection color if selected
	gl_FragData[0] = outcolor * (1.0-ex_selectionstate) + ex_selectionstate * (outcolor*0.5+vec4(0.5,0.0,0.0,0.0));
}
@OpenGLES2.Vertex
//Uniforms
uniform mat4 entitymatrix;
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;

//Attributes
attribute vec3 vertex_position;
attribute vec4 vertex_color;
attribute vec3 vertex_normal;

//Outputs
varying highp vec4 ex_color;
varying highp float ex_selectionstate;
varying highp vec3 ex_VertexCameraPosition;
varying highp vec3 ex_normal;

void main()
{
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	//entitymatrix_ * 
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	ex_VertexCameraPosition = vec3(camerainversematrix * modelvertexposition);
	gl_Position = projectioncameramatrix * modelvertexposition;
	//ex_VertexCameraPosition = vec3(camerainversematrix * vec4(vertex_position, 1.0));
	//gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);	
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGLES2.Fragment
//Uniforms	
uniform highp vec2 buffersize;
uniform highp vec2 camerarange;
uniform highp float camerazoom;
uniform highp vec4 materialcolorspecular;
uniform highp vec4 lighting_ambient;

#define MAXLIGHTS 2

//Lighting
uniform highp vec3 lightdirection[MAXLIGHTS];
uniform highp vec4 lightcolor[MAXLIGHTS];
uniform highp vec4 lightposition[MAXLIGHTS];
uniform highp float lightrange[MAXLIGHTS];
uniform highp vec3 lightingcenter[MAXLIGHTS];
uniform highp vec2 lightingconeanglescos[MAXLIGHTS];
uniform highp vec4 lightspecular[MAXLIGHTS];

//Inputs
varying highp vec4 ex_color;
varying highp vec3 ex_VertexCameraPosition;
varying highp vec3 ex_normal;

void main(void)
{
	highp vec4 outcolor = ex_color;
	highp vec4 color_specular = materialcolorspecular;
	highp vec3 normal = normalize(ex_normal);	
	
	//Calculate lighting
	highp vec4 lighting_diffuse = vec4(0);
	highp vec4 lighting_specular = vec4(0);
	highp float attenuation=1.0;
	highp vec3 lightdir;
	highp vec3 lightreflection;
	int i;
	highp float anglecos;
	highp float diffspotangle;
	highp float denom;
	
	//One equation, three light types
	for (i=0; i<MAXLIGHTS; i++)
	{
		//Get light direction to this pixel
		lightdir = normalize(ex_VertexCameraPosition - lightposition[i].xyz) * lightposition[i].w + lightdirection[i] * (1.0 - lightposition[i].w);
		
		//Distance attenuation
		attenuation = lightposition[i].w * max(0.0, 1.0 - distance(lightposition[i].xyz,ex_VertexCameraPosition) / lightrange[i]) + (1.0 - lightposition[i].w);
		
		//Normal attenuation
		attenuation *= max(0.0,dot(normal,-lightdir));
		
		//Spot cone attenuation
		denom = lightingconeanglescos[i].y-lightingconeanglescos[i].x;	
		if (denom>-1.0)
		{
			anglecos = max(0.0,dot(lightdirection[i],lightdir));
			attenuation *= 1.0 - clamp((lightingconeanglescos[i].y-anglecos)/denom,0.0,1.0);
		}

		lighting_diffuse += lightcolor[i] * attenuation;
	}
	
	//Write final output color
	gl_FragData[0] = (lighting_diffuse + lighting_ambient) * outcolor;
}
@OpenGL4.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
//uniform mat4 entitymatrix;
uniform mat4 projectioncameramatrix;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;

//Attributes
in vec3 vertex_position;

void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vec4 modelvertexposition = entitymatrix_ * vec4(vertex_position,1.0);
	gl_Position = projectioncameramatrix * modelvertexposition;
}
