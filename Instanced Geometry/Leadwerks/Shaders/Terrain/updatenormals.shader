SHADER version 1
@OpenGL2.Vertex
uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];

attribute vec3 vertex_position;

varying vec2 ex_texcoords0;

void main(void)
{
	int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[i], 1.0, 1.0));
	ex_texcoords0 = texcoords[i];
}
@OpenGL2.Fragment
uniform sampler2D texture0;
uniform vec2 buffersize;
uniform vec4 drawcolor;
uniform vec3 terrainscale;
varying vec2 ex_texcoords0;

void main(void)
{
	vec3 normal;

	vec2 ps=1.0/buffersize;
	vec2 texcoord=gl_FragCoord.xy/buffersize;
	
	texcoord=vec2(texcoord.x,texcoord.y);

	float tl=texture2D(texture0,texcoord+vec2(-ps.x,-ps.y)).x;//GetHeight(grid_x-1,grid_y-1);
	float tm=texture2D(texture0,texcoord+vec2(0.0,-ps.y)).x;//GetHeight(grid_x,grid_y-1);
	float tr=texture2D(texture0,texcoord+vec2(+ps.x,-ps.y)).x;//GetHeight(grid_x+1,grid_y-1);
	float ml=texture2D(texture0,texcoord+vec2(-ps.x,0.0)).x;//GetHeight(grid_x-1,grid_y);
	float mm=texture2D(texture0,texcoord).x;//GetHeight(grid_x,grid_y);
	float mr=texture2D(texture0,texcoord+vec2(+ps.x,0.0)).x;//GetHeight(grid_x+1,grid_y);
	float bl=texture2D(texture0,texcoord+vec2(-ps.x,+ps.y)).x;//GetHeight(grid_x-1,grid_y+1);
	float bm=texture2D(texture0,texcoord+vec2(0.0,+ps.y)).x;//GetHeight(grid_x,grid_y+1);
	float br=texture2D(texture0,texcoord+vec2(+ps.x,+ps.y)).x;//GetHeight(grid_x+1,grid_y+1);
	
	float isq2=0.707106781;
	float sum=1.0+isq2+isq2;
		
	float al=(tl*isq2+ml+bl*isq2)/sum;
	float ar=(tr*isq2+mr+br*isq2)/sum;
	float at=(tl*isq2+tm+tr*isq2)/sum;
	float ab=(bl*isq2+bm+br*isq2)/sum;
	
	normal.x=(al-ar);
	normal.z=(at-ab);
	float m=max(0.0,normal.x*normal.x+normal.z*normal.z);
	m=min(m,1.0);
	
	normal.y=sqrt(1.0-m);
	
	float height = 10000.0 / 100.0 * terrainscale.y / terrainscale.x / 255.0;
	//float height = 10000.0 / 255.0;
	
	//if (height != 0.0)
	//{
		normal.y/=height;
		m=sqrt(normal.x*normal.x+normal.y*normal.y+normal.z*normal.z);
		normal.x/=m;
		normal.y/=m;
		normal.z/=m;
	//}
	//else
	//{
	//	normal = vec3(0.0,1.0,0.0);
	//}
	
	float slope = 90.0 - asin(normal.y) * 57.2957795;
	gl_FragColor = vec4( normal.xzy*0.5+0.5,slope/90.0 );
}
@OpenGLES2.Vertex
uniform mediump mat4 projectionmatrix;
uniform mediump mat4 drawmatrix;
uniform mediump vec2 offset;

attribute mediump vec3 vertex_position;
attribute mediump vec2 vertex_texcoords0;

varying mediump vec2 ex_texcoords0;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(vertex_position, 1.0) + vec4(offset,0,0));
	ex_texcoords0 = vertex_texcoords0;
}
@OpenGLES2.Fragment
precision highp float;

uniform sampler2D texture0;
uniform vec2 buffersize;
uniform vec4 drawcolor;
uniform vec3 terrainscale;
varying vec2 ex_texcoords0;

void main(void)
{
	vec3 normal;

	vec2 ps=1.0/buffersize;
	vec2 texcoord=gl_FragCoord.xy/buffersize;
	
	texcoord=vec2(texcoord.x,texcoord.y);

	float tl=texture2D(texture0,texcoord+vec2(+ps.x,+ps.y)).x;//GetHeight(grid_x-1,grid_y-1);
	float tm=texture2D(texture0,texcoord+vec2(0.0,-ps.y)).x;//GetHeight(grid_x,grid_y-1);
	float tr=texture2D(texture0,texcoord+vec2(+ps.x,-ps.y)).x;//GetHeight(grid_x+1,grid_y-1);
	float ml=texture2D(texture0,texcoord+vec2(-ps.x,0.0)).x;//GetHeight(grid_x-1,grid_y);
	float mm=texture2D(texture0,texcoord).x;//GetHeight(grid_x,grid_y);
	float mr=texture2D(texture0,texcoord+vec2(+ps.x,0.0)).x;//GetHeight(grid_x+1,grid_y);
	float bl=texture2D(texture0,texcoord+vec2(-ps.x,+ps.y)).x;//GetHeight(grid_x-1,grid_y+1);
	float bm=texture2D(texture0,texcoord+vec2(0.0,+ps.y)).x;//GetHeight(grid_x,grid_y+1);
	float br=texture2D(texture0,texcoord+vec2(+ps.x,+ps.y)).x;//GetHeight(grid_x+1,grid_y+1);
	
	float isq2=0.707106781;
	float sum=1.0+isq2+isq2;
		
	float al=(tl*isq2+ml+bl*isq2)/sum;
	float ar=(tr*isq2+mr+br*isq2)/sum;
	float at=(tl*isq2+tm+tr*isq2)/sum;
	float ab=(bl*isq2+bm+br*isq2)/sum;
	
	normal.x=(al-ar);
	normal.z=(at-ab);
	float m=max(0.0,normal.x*normal.x+normal.z*normal.z);
	m=min(m,1.0);
	
	normal.y=sqrt(1.0-m);
	
	float height = 10000.0 / 100.0 * terrainscale.y / terrainscale.x / 255.0;
	//float height = 10000.0 / 255.0;
	
	//if (height != 0.0)
	//{
		normal.y/=height;
		m=sqrt(normal.x*normal.x+normal.y*normal.y+normal.z*normal.z);
		normal.x/=m;
		normal.y/=m;
		normal.z/=m;
	//}
	//else
	//{
	//	normal = vec3(0.0,1.0,0.0);
	//}
	
	gl_FragData[0] = vec4( normal.xzy*0.5+0.5,1.0 );
	gl_FragData[0] = texture2D(texture0,texcoord);
}
@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];
uniform vec2 texcoords[4];

in vec3 vertex_position;

out vec2 ex_texcoords0;

void main(void)
{
	//int i = int(vertex_position.x);//gl_VertexID was implemented in GLSL 1.30, not available in 1.20.
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID], 1.0, 1.0));
	ex_texcoords0 = texcoords[gl_VertexID];
}
@OpenGL4.Fragment
#version 400

uniform sampler2D texture0;
uniform vec2 buffersize;
uniform vec4 drawcolor;
uniform vec3 terrainscale;

in vec2 ex_texcoords0;

out vec4 fragData0;

void main(void)
{
	vec3 normal;

	vec2 ps=1.0/buffersize;
	vec2 texcoord=gl_FragCoord.xy/buffersize;
	
	texcoord=vec2(texcoord.x,texcoord.y);

	float tl=texture(texture0,texcoord+vec2(-ps.x,-ps.y)).x;//GetHeight(grid_x-1,grid_y-1);
	float tm=texture(texture0,texcoord+vec2(0.0,-ps.y)).x;//GetHeight(grid_x,grid_y-1);
	float tr=texture(texture0,texcoord+vec2(+ps.x,-ps.y)).x;//GetHeight(grid_x+1,grid_y-1);
	float ml=texture(texture0,texcoord+vec2(-ps.x,0.0)).x;//GetHeight(grid_x-1,grid_y);
	float mm=texture(texture0,texcoord).x;//GetHeight(grid_x,grid_y);
	float mr=texture(texture0,texcoord+vec2(+ps.x,0.0)).x;//GetHeight(grid_x+1,grid_y);
	float bl=texture(texture0,texcoord+vec2(-ps.x,+ps.y)).x;//GetHeight(grid_x-1,grid_y+1);
	float bm=texture(texture0,texcoord+vec2(0.0,+ps.y)).x;//GetHeight(grid_x,grid_y+1);
	float br=texture(texture0,texcoord+vec2(+ps.x,+ps.y)).x;//GetHeight(grid_x+1,grid_y+1);
	
	float isq2=0.707106781;
	float sum=1.0+isq2+isq2;
		
	float al=(tl*isq2+ml+bl*isq2)/sum;
	float ar=(tr*isq2+mr+br*isq2)/sum;
	float at=(tl*isq2+tm+tr*isq2)/sum;
	float ab=(bl*isq2+bm+br*isq2)/sum;
	
	normal.x=(al-ar);
	normal.z=(at-ab);
	float m=max(0.0,normal.x*normal.x+normal.z*normal.z);
	m=min(m,1.0);
	
	normal.y=sqrt(1.0-m);
	
	float height = 10000.0 / 100.0 * terrainscale.y / terrainscale.x / 255.0;
	//float height = 10000.0 / 255.0;
	
	//if (height != 0.0)
	//{
		normal.y/=height;
		m=sqrt(normal.x*normal.x+normal.y*normal.y+normal.z*normal.z);
		normal.x/=m;
		normal.y/=m;
		normal.z/=m;
	//}
	//else
	//{
	//	normal = vec3(0.0,1.0,0.0);
	//}
	
	float slope = 90.0 - asin(normal.y) * 57.2957795;
	fragData0 = vec4( normal.xzy*0.5+0.5,slope/90.0 );
	//fragData0 = vec4(0.5,0.5,1.0,1.0);
}
