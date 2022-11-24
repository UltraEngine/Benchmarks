SHADER version 1
@OpenGL2.Vertex
#version 400
#define VIRTUAL_TEXTURE_STAGES 7
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform vec3 cameraposition;
uniform float terrainsize;
uniform float texturerange[VIRTUAL_TEXTURE_STAGES];
uniform vec2 renderposition[VIRTUAL_TEXTURE_STAGES];
uniform sampler2D texture0;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
//uniform sampler2D texture17;
uniform sampler2D texture8;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec3 vertex_normal;

//Varyings
out vec3 vertexposminuscamerapos;
out vec4 ex_color;
out vec3 ex_normal;
//out vec2 ex_texcoords[VIRTUAL_TEXTURE_STAGES];
out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out vec2 ex_texcoords2;
out vec2 ex_texcoords3;
out vec2 ex_texcoords4;
out vec2 ex_texcoords5;
out vec2 ex_texcoords6;
out vec2 ex_texcoords7;


void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vec4 modelvertexposition = entitymatrix_ * (vec4(vertex_position,1.0));
	
	ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;
	ex_texcoords1 = (modelvertexposition.xz - renderposition[1]) / texturerange[1] + 0.5;
	ex_texcoords2 = (modelvertexposition.xz - renderposition[2]) / texturerange[2] + 0.5;
	ex_texcoords3 = (modelvertexposition.xz - renderposition[3]) / texturerange[3] + 0.5;
	ex_texcoords4 = (modelvertexposition.xz - renderposition[4]) / texturerange[4] + 0.5;
	ex_texcoords5 = (modelvertexposition.xz - renderposition[5]) / texturerange[5] + 0.5;
	ex_texcoords6 = (modelvertexposition.xz - renderposition[6]) / texturerange[6] + 0.5;	

	/*ex_texcoords[0] = (modelvertexposition.xz) / terrainsize + 0.5;
	for (int i=1; i<VIRTUAL_TEXTURE_STAGES; i++)
	{
		ex_texcoords[i] = (modelvertexposition.xz - renderposition[i]) / texturerange[i] + 0.5;
	}*/
	
	float terrainheight = length(entitymatrix_[1].xyz);
	modelvertexposition.y = texture(texture0, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * terrainheight;
	vertexposminuscamerapos = modelvertexposition.xyz - cameraposition;
	
	vec2 ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;
	vec3 normal = normalize( texture(texture8,ex_texcoords0).xzy * 2.0 - 1.0 );
	normal.y=0;
	normal=normalize(normal);
	//vec3 offset = normal * texture(texture17, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * 8.0;
	//modelvertexposition += vec4(offset,0.0);	
	
	gl_Position = projectioncameramatrix * modelvertexposition;
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);	
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400
#define VIRTUAL_TEXTURE_STAGES 7
#define MAX_INSTANCES 256

//Uniforms
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
uniform vec3 cameraposition;
uniform float terrainsize;
uniform float texturerange[VIRTUAL_TEXTURE_STAGES];
uniform vec2 renderposition[VIRTUAL_TEXTURE_STAGES];
uniform sampler2D texture0;
uniform instancematrices { mat4 matrix[MAX_INSTANCES];} entity;
//uniform sampler2D texture17;
uniform sampler2D texture8;

//Attributes
in vec3 vertex_position;
in vec4 vertex_color;
in vec3 vertex_normal;

//Varyings
out vec3 vertexposminuscamerapos;
out vec4 ex_color;
out vec3 ex_normal;
//out vec2 ex_texcoords[VIRTUAL_TEXTURE_STAGES];
out vec2 ex_texcoords0;
out vec2 ex_texcoords1;
out vec2 ex_texcoords2;
out vec2 ex_texcoords3;
out vec2 ex_texcoords4;
out vec2 ex_texcoords5;
out vec2 ex_texcoords6;
out vec2 ex_texcoords7;


void main()
{
	mat4 entitymatrix = entity.matrix[gl_InstanceID];
	mat4 entitymatrix_=entitymatrix;
	entitymatrix_[0][3]=0.0;
	entitymatrix_[1][3]=0.0;
	entitymatrix_[2][3]=0.0;
	entitymatrix_[3][3]=1.0;
	
	vec4 modelvertexposition = entitymatrix_ * (vec4(vertex_position,1.0));
	
	ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;
	ex_texcoords1 = (modelvertexposition.xz - renderposition[1]) / texturerange[1] + 0.5;
	ex_texcoords2 = (modelvertexposition.xz - renderposition[2]) / texturerange[2] + 0.5;
	ex_texcoords3 = (modelvertexposition.xz - renderposition[3]) / texturerange[3] + 0.5;
	ex_texcoords4 = (modelvertexposition.xz - renderposition[4]) / texturerange[4] + 0.5;
	ex_texcoords5 = (modelvertexposition.xz - renderposition[5]) / texturerange[5] + 0.5;
	ex_texcoords6 = (modelvertexposition.xz - renderposition[6]) / texturerange[6] + 0.5;	

	/*ex_texcoords[0] = (modelvertexposition.xz) / terrainsize + 0.5;
	for (int i=1; i<VIRTUAL_TEXTURE_STAGES; i++)
	{
		ex_texcoords[i] = (modelvertexposition.xz - renderposition[i]) / texturerange[i] + 0.5;
	}*/
	
	float terrainheight = length(entitymatrix_[1].xyz);
	modelvertexposition.y = texture(texture0, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * terrainheight;
	vertexposminuscamerapos = modelvertexposition.xyz - cameraposition;
	
	vec2 ex_texcoords0 = (modelvertexposition.xz) / terrainsize + 0.5;
	vec3 normal = normalize( texture(texture8,ex_texcoords0).xzy * 2.0 - 1.0 );
	normal.y=0;
	normal=normalize(normal);
	//vec3 offset = normal * texture(texture17, (modelvertexposition.xz+0.5)/ terrainsize + 0.5).r * 8.0;
	//modelvertexposition += vec4(offset,0.0);	
	
	gl_Position = projectioncameramatrix * modelvertexposition;
	
	mat3 nmat = mat3(camerainversematrix[0].xyz,camerainversematrix[1].xyz,camerainversematrix[2].xyz);//39
	nmat = nmat * mat3(entitymatrix[0].xyz,entitymatrix[1].xyz,entitymatrix[2].xyz);//40
	ex_normal = (nmat * vertex_normal);	
	
	ex_color = vec4(entitymatrix[0][3],entitymatrix[1][3],entitymatrix[2][3],entitymatrix[3][3]);
	ex_color *= vec4(1.0-vertex_color.r,1.0-vertex_color.g,1.0-vertex_color.b,vertex_color.a) * materialcolordiffuse;
}
@OpenGL4.Fragment
#version 400
#define VIRTUAL_TEXTURE_STAGES 7

//Varyings
in vec3 vertexposminuscamerapos;
//==========================================================
// WARNING - varying arrays will cause all other varyings to be ignored on ATI 3870
//==========================================================
//varying vec2 ex_texcoords[VIRTUAL_TEXTURE_STAGES];
in vec2 ex_texcoords0;
in vec2 ex_texcoords1;
in vec2 ex_texcoords2;
in vec2 ex_texcoords3;
in vec2 ex_texcoords4;
in vec2 ex_texcoords5;
in vec2 ex_texcoords6;
in vec2 ex_texcoords7;

//Uniforms
uniform float texturerange[VIRTUAL_TEXTURE_STAGES];
uniform vec4 lighting_ambient;
uniform vec3 lightdirection;
uniform vec4 lightcolor;
uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D texture4;
uniform sampler2D texture5;
uniform sampler2D texture6;
uniform sampler2D texture7;
uniform sampler2D texture8;
uniform sampler2D texture9;
uniform sampler2D texture10;
uniform sampler2D texture11;
uniform sampler2D texture12;
uniform sampler2D texture13;
uniform sampler2D texture14;
uniform sampler2D texture15;

out vec4 fragData0;

void main(void)
{
	vec4 outcolor = texture(texture1,ex_texcoords0);
	vec4 normalcolor = texture(texture9,ex_texcoords0);
	vec3 normal = normalize( texture(texture8,ex_texcoords0).xyz * 2.0 - 1.0 );
	
	const float magicnumber = 0.646446609 / 2.0;
	int i=0;
	float d = length(vertexposminuscamerapos);
	float blend;
	float len[VIRTUAL_TEXTURE_STAGES];
	
	len[1]=length(ex_texcoords1-0.5);
	len[2]=length(ex_texcoords2-0.5);
	len[3]=length(ex_texcoords3-0.5);
	len[4]=length(ex_texcoords4-0.5);
	len[5]=length(ex_texcoords5-0.5);
	len[6]=length(ex_texcoords6-0.5);
	i=1;
	
#if VIRTUAL_TEXTURE_STAGES > 1
	if (len[i]<0.5 && d<texturerange[i]*magicnumber)
	{
		blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
		blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
		outcolor = outcolor * blend + (1.0-blend) * texture(texture2,ex_texcoords1);
		normalcolor = normalcolor * blend + (1.0-blend) * texture(texture10,ex_texcoords1);
		i++;		
	#if VIRTUAL_TEXTURE_STAGES > 2
		if (len[i]<0.5 && d<texturerange[i]*magicnumber)
		{
			blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
			blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
			outcolor = outcolor * blend + (1.0-blend) * texture(texture3,ex_texcoords2);
			normalcolor = normalcolor * blend + (1.0-blend) * texture(texture11,ex_texcoords2);
			i++;			
		#if VIRTUAL_TEXTURE_STAGES > 3
			if (len[i]<0.5 && d<texturerange[i]*magicnumber)
			{
				blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
				blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
				outcolor = outcolor * blend + (1.0-blend) * texture(texture4,ex_texcoords3);
				normalcolor = normalcolor * blend + (1.0-blend) * texture(texture12,ex_texcoords3);
				i++;				
			#if VIRTUAL_TEXTURE_STAGES > 4
				if (len[i]<0.5 && d<texturerange[i]*magicnumber)
				{
					blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
					blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
					outcolor = outcolor * blend + (1.0-blend) * texture(texture5,ex_texcoords4);
					normalcolor = normalcolor * blend + (1.0-blend) * texture(texture13,ex_texcoords4);
					i++;
				#if VIRTUAL_TEXTURE_STAGES > 5
					if (len[i]<0.5 && d<texturerange[i]*magicnumber)
					{
						blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
						blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
						outcolor = outcolor * blend + (1.0-blend) * texture(texture6,ex_texcoords5);
						normalcolor = normalcolor * blend + (1.0-blend) * texture(texture14,ex_texcoords5);
						i++;
					#if VIRTUAL_TEXTURE_STAGES > 6
						if (len[i]<0.5 && d<texturerange[i]*magicnumber)
						{
							blend = 1.0 - clamp((0.5 - len[i])/0.05,0.0,1.0);
							blend = max(blend, 1.0 - clamp((texturerange[i]*magicnumber - d)/(texturerange[i]*magicnumber*0.1),0.0,1.0));
							outcolor = outcolor * blend + (1.0-blend) * texture(texture7,ex_texcoords6);
							normalcolor = normalcolor * blend + (1.0-blend) * texture(texture15,ex_texcoords6);
						}
					#endif
					}
				#endif
				}
			#endif
			}
		#endif
		}
	#endif
	}
#endif
	
	vec3 tangent = vec3(1,0,0);
	vec3 binormal = vec3(0,0,1);
	vec3 n = normalize( normalcolor.xyz * 2.0 - 1.0 );
	n = normalize( tangent*n.x + binormal*n.y + normal*n.z );
	
	vec3 lightdir = vec3(-0.4,-0.7,0.5);
	float intensity = max(dot(n,lightdir.xyz),0.0);
	outcolor *= 0.75 + intensity * 0.25;
	
	fragData0 = outcolor;
}
