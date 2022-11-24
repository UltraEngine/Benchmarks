SHADER version 1
@OpenGL2.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];

in vec3 vertex_position;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID]+offset, 0.0, 1.0));
}
@OpenGLES2.Vertex

@OpenGLES2.Fragment

@OpenGL4.Vertex
#version 400

uniform mat4 projectionmatrix;
uniform mat4 drawmatrix;
uniform vec2 offset;
uniform vec2 position[4];

in vec3 vertex_position;

void main(void)
{
	gl_Position = projectionmatrix * (drawmatrix * vec4(position[gl_VertexID]+offset, 0.0, 1.0));
}
@OpenGL4.Fragment
//---------------------------------------------------------------------------
// Screen-Space Reflection shader by Igor Katrich, Shadmar, and Josh Klint
//---------------------------------------------------------------------------
#version 400

uniform sampler2DMS texture0;
uniform sampler2D texture1;
uniform sampler2DMS texture2;
uniform sampler2DMS texture3;
uniform sampler2DMS texture4;

uniform bool isbackbuffer;
uniform vec2 buffersize;

uniform mat4 projectioncameramatrix;
uniform vec3 cameraposition;
uniform mat3 cameranormalmatrix;
uniform mat3 camerainversenormalmatrix;

//User variables
#define reflectionfalloff 10.0f
#define raylength 1.1f
#define maxstep 10
#define edgefadefactor 0.95f
#define hitThreshold 0.1

out vec4 fragData0;

vec4 getPosition(in vec2 texCoord, out float z)
{
        float x = texCoord.s * 2.0f - 1.0f;
        float y = texCoord.t * 2.0f - 1.0f;
        z = texelFetch(texture0, ivec2(texCoord*buffersize),0).r;
        vec4 posProj = vec4(x,y,z,1.0f);
        vec4 posView = inverse(projectioncameramatrix) * posProj;
        posView /= posView.w;
        return posView;
		
		/*
		//VR Sheared mprojection
		vec4 screencoord = texelFetch(texture4,ivec2(texCoord*buffersize),0);
		screencoord.y *= -1.0f;
		return screencoord;*/
}

float LinePointDistance(in vec3 v, in vec3 w, in vec3 p)
{
  // Return minimum distance between line segment vw and point p
        vec3 d = w-v;
        float l2 = d.x*d.x+d.y*d.y+d.z*d.z;  // i.e. |w-v|^2 -  avoid a sqrt
        if (l2 == 0.0) return distance(p, v);   // v == w case
        //float t = max(0.0f, min(1.0f, dot(p - v, w - v) / l2));
        float t = dot(p - v, w - v) / l2;
        vec3 projection = v + t * (w - v);  // Projection falls on the segment
        return distance(p, projection);
}

void main(void)
{
        vec2 icoord = vec2(gl_FragCoord.xy/buffersize);
        if (isbackbuffer) icoord.y = 1.0f - icoord.y;
        
        //Get screen color
        vec4 color = texture(texture1,icoord);

        //Get normal + alpha channel.
        vec4 n=texelFetch(texture2, ivec2(icoord*buffersize),0);
        vec3 normalView = normalize(n.xyz * 2.0f - 1.0f);
        
        //Get roughness from gbuffer (normal.a)
        int materialflags = int(n.a*255.0+0.5);
        int roughness=1;
        //if ((32 & materialflags)!=0) roughness += 4;
        //if ((64 & materialflags)!=0) roughness += 2;
        
        //Get specmap from gbuffer
        float specularity = texelFetch(texture3, ivec2(icoord*buffersize),0).a;
        
        //only compute if we hvae specularity
        if (specularity > 0.0f)
        {
                //Get position and out depth (z)
                float z;
                vec3 posView = getPosition(icoord,z).xyz;
                
                //Reflect vector
                vec4 reflectedColor = color;
                vec3 reflected = normalize(reflect(normalize(posView-cameraposition), normalView));
                
                float rayLength = raylength;
                vec4 T = vec4(0.0f);
                vec3 newPos;
                
                //Raytrace
                for (int i = 0; i < maxstep; i++)
                {       
                        newPos = posView + reflected * rayLength;
                        
                        T = projectioncameramatrix * vec4(newPos, 1.0f);
                        T.xy = vec2(0.5f) + 0.5f * T.xy / T.w;
                        T.z /= T.w;
                        
                        if (abs(z - T.z) < 1.0f && T.x <= 1.0f && T.x >= 0.0f && T.y <= 1.0f && T.y >= 0.0f)
                        {
                                float depth;
                                newPos = getPosition(T.xy,depth).xyz;
                                rayLength = length(posView - newPos);
                                
                                //Check distance of this pixel to the reflection ray.  If it's close enough we count it as a hit.
                                if (LinePointDistance(posView,posView+reflected,newPos) < hitThreshold)
                                {
                                        //Get the pixel at this normal
                                        vec4 n1=texelFetch(texture2, ivec2(T.xy*buffersize),0);
                                        vec3 normalView1 = normalize(n1.xyz * 2.0f - 1.0f);
                                        
                                        //Make sure the pixel faces the reflection vector
                                        if (dot(reflected,normalView1)<0.0f || depth == 1.0f)
                                        {
                                                /*float m = max(1.0f-T.y,0.0f);
                                                          m = max(1.0f-T.x,m);
                                                          m += roughness * 0.1f;
                                                        */      
                                                float m = 0.5;
                                                vec4 rcol=texture(texture1,T.xy);
                                                reflectedColor = mix(rcol,color,clamp(m,0.0f,1.0f));
                                                //reflectedColor = rcol + color;
												//reflectedColor = max(rcol, color);

                                                //Fading to screen edges
                                                vec2 fadeToScreenEdge = vec2(1.0f);
                                                
                                                float edgedistance[2];
                                                edgedistance[1] = 0.20;
                                                edgedistance[0] = edgedistance[1] * (buffersize.y / buffersize.x);

                                                if (T.x<edgedistance[0])
                                                {
                                                        fadeToScreenEdge.x = T.x / edgedistance[0];
                                                }
                                                else if (T.x > 1.0 - edgedistance[0])
                                                {
                                                        fadeToScreenEdge.x = 1.0 - ((T.x - (1.0 - edgedistance[0])) / edgedistance[0]);
                                                }
                                                if (T.y<edgedistance[1])
                                                {
                                                        fadeToScreenEdge.y = T.y / edgedistance[1];
                                                }
                                                else if (T.y>1.0-edgedistance[1])
                                                {
                                                        fadeToScreenEdge.y = 1.0 - (T.y - (1.0-edgedistance[1])) / edgedistance[1];
                                                }
                                                
                                                float fresnel =  reflectionfalloff * (1.0f-(pow(dot(normalize(posView-cameraposition), normalize(normalView)), 2.0f)));
                                                fresnel = clamp(fresnel,0.0f,1.0f);
                                                color = mix(color, reflectedColor,clamp(fresnel * fadeToScreenEdge.x * fadeToScreenEdge.y * specularity, 0.0f, 1.0f));
                                                
                                                //We hit the pixel, so we're done, right?
                                                break;
                                        }
                                }
                        }
                        else
                        {
                                break;//exit because we're out of the texture
                        }
                }               
        }
        fragData0 = color;
}
