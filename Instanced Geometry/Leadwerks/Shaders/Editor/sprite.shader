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
	
	ex_VertexCameraPosition = vec3(camerainversematrix * entitymatrix_ * vec4(vertex_position, 1.0));
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
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

//Inputs
varying vec2 ex_texcoords0;
varying vec2 ex_texcoords1;
varying vec4 ex_color;
varying float ex_selectionstate;
varying vec3 ex_VertexCameraPosition;
varying vec3 ex_normal;

void main(void)
{
	vec4 outcolor = texture2D(texture0,ex_texcoords0);
	if (outcolor.a<0.5) discard;
	outcolor *= ex_color;
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
#define diffusemap texture0
#define normalmap texture1
#define specularmap texture2
#define cubemap texture4

//Uniforms
uniform sampler2D texture0; //diffuse
uniform sampler2D texture1; //normal
uniform sampler2D texture2; //specular
uniform sampler2D texture3; //height
uniform samplerCube texture4; //environment
uniform sampler2D texture5; //emission
uniform sampler2D texture6; //opacity
uniform sampler2D texture7; //ambient
uniform samplerCube texture8; //refraction

uniform mediump float materialid;
uniform mediump vec4 Color;//=vec4(1,1,1,1);//expose color
uniform mediump float Bumpiness;//=1.0;//expose slider,0,0.9
uniform mediump float Shininess;//=1.0;//expose slider,0,4
uniform mediump float Gloss;//=0.5;//expose slider,0.1,1
uniform mediump float Flip_Normals_X;//=0.0;//expose checkbox
uniform mediump float Flip_Normals_Y;//=0.0;//expose checkbox
uniform mediump float Offset;//=1.0;//expose slider,0,2
uniform mediump float Invert_Height;//=0.0;//expose checkbox
uniform mediump float Chromatic_Aberration;//=1.0;//expose slider,0,5
uniform mediump vec3 cameraposition;
uniform mediump mat3 camerainversenormalmatrix;
uniform mediump float camerazoom;
uniform mediump vec2 camerarange;
uniform mediump vec2 buffersize;

uniform mediump float texturestrength0;// = 1.0;
uniform mediump float texturestrength1;// = 1.0;
uniform mediump float texturestrength2;// = 1.0;
uniform mediump float texturestrength3;// = 1.0;
uniform mediump float texturestrength4;// = 1.0;
uniform mediump float texturestrength5;// = 1.0;
uniform mediump float texturestrength6;// = 1.0;
uniform mediump float texturestrength7;// = 1.0;
uniform mediump float texturestrength8;// = 1.0;
uniform mediump float texturestrength9;// = 1.0;
uniform mediump float texturestrength10;// = 1.0;
uniform mediump float texturestrength11;// = 1.0;
uniform mediump float texturestrength12;// = 1.0;
uniform mediump float texturestrength13;// = 1.0;
uniform mediump float texturestrength14;// = 1.0;
uniform mediump float texturestrength15;// = 1.0;

//Lighting
#define LIGHTCOUNT 4
/*
uniform mediump vec3 lightdirection[4];
uniform mediump vec4 lightcolor[4];
uniform mediump vec4 lightposition[4];
uniform mediump float lightrange[4];
uniform mediump vec3 lightingcenter[4];
uniform mediump vec2 lightingconeanglescos[4];
uniform mediump vec4 lightspecular[4];
uniform mediump vec3 lightdirection0;
*/
uniform mediump vec3 lightdirection0; uniform mediump vec3 lightdirection1; uniform mediump vec3 lightdirection2; uniform mediump vec3 lightdirection3;
uniform mediump vec4 lightcolor0; uniform mediump vec4 lightcolor1; uniform mediump vec4 lightcolor2; uniform mediump vec4 lightcolor3;
uniform mediump vec4 lightposition0; uniform mediump vec4 lightposition1; uniform mediump vec4 lightposition2; uniform mediump vec4 lightposition3;
uniform mediump float lightrange0; uniform mediump float lightrange1; uniform mediump float lightrange2; uniform mediump float lightrange3;
uniform mediump vec3 lightingcenter0; uniform mediump vec3 lightingcenter1; uniform mediump vec3 lightingcenter2; uniform mediump vec3 lightingcenter3;
uniform mediump vec2 lightingconeanglescos0; uniform mediump vec2 lightingconeanglescos1; uniform mediump vec2 lightingconeanglescos2; uniform mediump vec2 lightingconeanglescos3;
uniform mediump vec4 lightspecular0; uniform mediump vec4 lightspecular1; uniform mediump vec4 lightspecular2; uniform mediump vec4 lightspecular3;

//Inputs
varying mediump vec3 VertexCameraPosition;
varying mediump vec2 ex_texcoords0;
varying mediump vec3 ex_normal;
varying mediump vec3 ex_tangent;
varying mediump vec3 ex_binormal;
varying mediump vec4 ex_color;
varying mediump vec3 ex_vertexposition;
varying mediump vec3 ex_motion;
varying mediump vec3 ex_eyevec;
varying mediump vec4 vertexcameraposition;

//
// fresnel approximation
// F(a) = F(0) + (1- cos(a))^5 * (1- F(0))
//
// Calculate fresnel term. You can approximate it with 1.0-dot(normal, viewpos).	
//
/*
mediump float fast_fresnel(mediump vec3 I, mediump vec3 N, mediump vec3 fresnelValues)
{
	mediump float bias = fresnelValues.x;
	mediump float power = fresnelValues.y;
	mediump float scale = 1.0 - bias;
	return bias + pow(1.0 - dot(I, N), power) * scale;
}
*/

//mediump float DepthToZPosition(mediump float depth)
//{
//	return camerarange.x / (camerarange.y - depth * (camerarange.y - camerarange.x)) * camerarange.y;
//}

void main(void)
{
	mediump float specular;
	mediump vec3 n;
	mediump float ambient;
	mediump vec4 reflection;
	mediump float opacity;
	mediump vec4 refraction;
    mediump vec4 out_diffuse;
    mediump vec4 lighting_ambient = vec4(0.125);
    mediump vec4 lighting_diffuse;
    mediump vec3 screencoord;
    
    //Calculate screen coordinate
	//screencoord = vec3(((gl_FragCoord.x/buffersize.x)-0.5) * 2.0 * (buffersize.x/buffersize.y),((-gl_FragCoord.y/buffersize.y)+0.5) * 2.0,DepthToZPosition( gl_FragCoord.z ));
	//screencoord.x *= screencoord.z / camerazoom;
	//screencoord.y *= -screencoord.z / camerazoom;      
    
    out_diffuse = ex_color;
    
	//Diffuse
	#ifdef TEXTURE_DIFFUSE
    out_diffuse *= texture2D(texture0,ex_texcoords0 * 4.0);
	#endif
	
	//Lighting
#ifdef TEXTURE_LIGHT
		out_diffuse *= texture2D(texture6,ex_texcoords1);
#endif
	
	//Opacity
	#ifdef TEXTURE_OPACITY
		opacity = texture2D(texture6,ex_texcoords0).r * ex_color.a * Color.a * gl_FragData[0].a;
		opacity = gl_FragData[0].a * (1.0-texturestrength6) + opacity * texturestrength6;
	#else
		opacity = gl_FragData[0].a;
	#endif
	
	//Normal
	#ifdef TEXTURE_NORMAL
		n = ex_normal;
		n = texture2D(texture1,ex_texcoords0 * 4.0).xyz * 2.0 - 1.0;
		n = ex_tangent*n.x + ex_binormal*n.y + ex_normal*n.z;		
	#else
		n = ex_normal;
	#endif
    
	//Ambient
	#ifdef TEXTURE_AMBIENT
		ambient = texture2D(texture7,ex_texcoords0).x;
		ambient = (1.0-texturestrength7) + ambient * texturestrength7;
	#else
		ambient = n.z;
	#endif
	
	//mediump vec3 incident = normalize(ex_vertexposition-cameraposition);
	//mediump vec3 worldnormal = n * camerainversenormalmatrix;
	
	//Reflection
	#ifdef TEXTURE_REFLECTION	
		reflection = textureCube(texture4,reflect( normalize(ex_vertexposition - cameraposition ), n * camerainversenormalmatrix ));
		//reflection = textureCube(texture4,reflect( normalize( vertexcameraposition.xyz*vec3(1,-1,-1) ), n));
		//reflection = reflection * (1.0 - opacity) * texturestrength4;
        //reflection = vec4(1,0,0,1);
        gl_FragData[0] = reflection;
	#else
		reflection = vec4(0);
	#endif
	
	//Refraction
	#ifdef TEXTURE_REFRACTION
		mediump vec3 IoR_Values = vec3(1.14,1.12,1.10);
		IoR_Values.x = IoR_Values.y + 0.02 * Chromatic_Aberration;
		IoR_Values.z = IoR_Values.y - 0.02 * Chromatic_Aberration;
	//	refraction.r = textureCube(texture8,refract(normalize(ex_vertexposition-cameraposition),n*camerainversenormalmatrix,IoR_Values.x)).r;
	//	refraction.g = textureCube(texture8,refract(normalize(ex_vertexposition-cameraposition),n*camerainversenormalmatrix,IoR_Values.y)).g;
	//	refraction.b = textureCube(texture8,refract(normalize(ex_vertexposition-cameraposition),n*camerainversenormalmatrix,IoR_Values.z)).b;
        //refraction = textureCube(texture8,refract(normalize(ex_vertexposition-cameraposition),n*camerainversenormalmatrix,IoR_Values.x)).r;
        //refraction = refraction * (1.0 - opacity) * texturestrength8;
		
		//Mix refraction and reflection
		//#ifdef TEXTURE_REFLECTION
		//	mediump vec3 fresnelValues = vec3(0.15,2.0,0.0);
		//	mediump float fresnelterm = fast_fresnel(-incident, worldnormal, fresnelValues);
		//	refraction = vec4(mix(refraction, reflection, fresnelterm));
		//	reflection = vec4(0);
		//#endif
    #else
		refraction = vec4(0);
	#endif
    
    //Calculate lighting
	lighting_diffuse = vec4(0);
    mediump vec4 lighting_specular = vec4(0);
    mediump float attenuation;
    mediump vec3 lightdir;
    mediump vec3 lightreflection;    
    //int i = 0;
    mediump float anglecos;
    //mediump vec3 screennormal = normalize(screencoord);
    
	//----------------------------------------------------------------------------
    //Light 0
	//----------------------------------------------------------------------------
	
    //lightdir = normalize(VertexCameraPosition - lightposition0.xyz) * lightposition0.w + lightdirection0 * (1.0 - lightposition0.w);        
	
	//Distance attenuation:
	//attenuation = lightposition0.w * max(0.0, 1.0 - distance(lightposition0.xyz,VertexCameraPosition) / lightrange0) + (1.0 - lightposition0.w);
	
	//Normal attenuation:
	attenuation = 1.0;
	attenuation *= max(0.0,dot(n,lightdirection0));
	
	//Spot attenuation:
	//anglecos = max(0.0,dot(lightdirection0,lightdir));
	//attenuation *= 1.0 - clamp((lightingconeanglescos0.y-anglecos)/(lightingconeanglescos0.y-lightingconeanglescos0.x),0.0,1.0);
	
	//Diffuse lighting
	lighting_diffuse += lightcolor0 * attenuation;
	
	//Specular lighting
	//lightreflection = reflect(lightdir,n);
	//lighting_specular += pow(clamp(-dot(lightreflection,screennormal),0.0,1.0),20.0) * attenuation * lightspecular0;
    
	/*
	//----------------------------------------------------------------------------
    //Light 1
	//----------------------------------------------------------------------------
	lightdir = normalize(VertexCameraPosition - lightposition1.xyz) * lightposition1.w + lightdirection1 * (1.0 - lightposition1.w);        
	
	//Distance attenuation:
	attenuation = lightposition1.w * max(0.0, 1.0 - distance(lightposition1.xyz,VertexCameraPosition) / lightrange1) + (1.0 - lightposition1.w);
	
	//Normal attenuation:
	attenuation = 1.0;
	attenuation *= max(0.0,dot(n,-lightdir));
	
	//Spot attenuation:
	anglecos = max(0.0,dot(lightdirection1,lightdir));
	attenuation *= 1.0 - clamp((lightingconeanglescos1.y-anglecos)/(lightingconeanglescos1.y-lightingconeanglescos1.x),0.0,1.0);
	
	//Diffuse lighting
	lighting_diffuse += lightcolor1 * attenuation;
	
	//Specular lighting
	//lightreflection = reflect(lightdir,n);
	//lighting_specular += pow(clamp(-dot(lightreflection,screennormal),0.0,1.0),20.0) * attenuation * lightspecular1;
	
	//----------------------------------------------------------------------------
    //Light 2
	//----------------------------------------------------------------------------
	lightdir = normalize(VertexCameraPosition - lightposition2.xyz) * lightposition2.w + lightdirection2 * (1.0 - lightposition2.w);        
	
	//Distance attenuation:
	attenuation = lightposition2.w * max(0.0, 1.0 - distance(lightposition2.xyz,VertexCameraPosition) / lightrange2) + (1.0 - lightposition2.w);
	
	//Normal attenuation:
	attenuation = 1.0;
	attenuation *= max(0.0,dot(n,-lightdir));
	
	//Spot attenuation:
	anglecos = max(0.0,dot(lightdirection2,lightdir));
	attenuation *= 1.0 - clamp((lightingconeanglescos2.y-anglecos)/(lightingconeanglescos2.y-lightingconeanglescos2.x),0.0,1.0);
	
	//Diffuse lighting
	lighting_diffuse += lightcolor2 * attenuation;
	
	//Specular lighting
	//lightreflection = reflect(lightdir,n);
	//lighting_specular += pow(clamp(-dot(lightreflection,screennormal),0.0,1.0),20.0) * attenuation * lightspecular2;	
	
	//----------------------------------------------------------------------------
    //Light 3
	//----------------------------------------------------------------------------
	lightdir = normalize(VertexCameraPosition - lightposition3.xyz) * lightposition3.w + lightdirection3 * (1.0 - lightposition3.w);        
	
	//Distance attenuation:
	attenuation = lightposition3.w * max(0.0, 1.0 - distance(lightposition3.xyz,VertexCameraPosition) / lightrange3) + (1.0 - lightposition3.w);
	
	//Normal attenuation:
	attenuation = 1.0;
	attenuation *= max(0.0,dot(n,-lightdir));
	
	//Spot attenuation:
	anglecos = max(0.0,dot(lightdirection3,lightdir));
	attenuation *= 1.0 - clamp((lightingconeanglescos3.y-anglecos)/(lightingconeanglescos3.y-lightingconeanglescos3.x),0.0,1.0);
	
	//Diffuse lighting
	lighting_diffuse += lightcolor3 * attenuation;
	
	//Specular lighting
	//lightreflection = reflect(lightdir,n);
	//lighting_specular += pow(clamp(-dot(lightreflection,screennormal),0.0,1.0),20.0) * attenuation * lightspecular3;	
	
	//----------------------------------------------------------------------------
	*/
    
	//gl_FragData[0] = vec4(n.x/2.0+0.5, n.y/2.0+0.5, n.z/2.0+0.5, 1.0);
    gl_FragData[0] = (lighting_diffuse + lighting_ambient) * out_diffuse + lighting_specular;
}
@OpenGL4.Vertex
#version 400
#define MAX_INSTANCES 256

//Uniforms
//uniform mat4 entitymatrix;
uniform vec4 materialcolordiffuse;
uniform mat4 projectioncameramatrix;
uniform mat4 camerainversematrix;
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
	
	ex_VertexCameraPosition = vec3(camerainversematrix * entitymatrix_ * vec4(vertex_position, 1.0));
	gl_Position = projectioncameramatrix * entitymatrix_ * vec4(vertex_position, 1.0);
	
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

//Inputs
in vec2 ex_texcoords0;
in vec2 ex_texcoords1;
in vec4 ex_color;
in float ex_selectionstate;
in vec3 ex_VertexCameraPosition;
in vec3 ex_normal;

out vec4 fragData0;
out vec4 fragData1;
out vec4 fragData2;
out vec4 fragData3;

void main(void)
{
	vec4 outcolor = texture(texture0,ex_texcoords0);
	if (outcolor.a<0.5) discard;
	outcolor *= ex_color;
	//Blend with selection color if selected
	fragData0 = outcolor * (1.0-ex_selectionstate) + ex_selectionstate * (outcolor*0.5+vec4(0.5,0.0,0.0,0.0));
	fragData1 = vec4(0.5,0.5,1.0,0.0);
	fragData2 = vec4(0.0,0.0,0.0,0.0);
}
