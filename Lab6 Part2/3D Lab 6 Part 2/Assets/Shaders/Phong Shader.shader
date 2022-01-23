Shader "Phong Shader" {
    Properties{
        _Color("Color", Color) = (1, 1, 1, 1) // The color of our object
        _Tex("Pattern", 2D) = "white" {} // setting a white texture
        _Shininess("Shininess", Float) = 10 
        _SpecColor("Specular Color", Color) = (1, 1, 1, 1) // Specular highlights color
    }
        SubShader{

            Pass {
                Tags { "LightMode" = "ForwardBase" } // makes sure they have the right values

              // pass for ambient light and first light source.
              // e.g directional light

                CGPROGRAM
                    #pragma vertex vert
                    #pragma fragment frag

                    #include "UnityCG.cginc" //Provides us with data such as light and camera

                    uniform float4 _LightColor0; //From UnityCG

                    sampler2D _Tex; // texture
                    float4 _Tex_ST; //For tiling

                    uniform float4 _Color; //Use the above variables in here
                    uniform float4 _SpecColor;
                    uniform float _Shininess;

                    struct appdata
                    {
                        float4 vertex : POSITION;
                        float3 normal : NORMAL; // surface normal vector
                        float2 uv : TEXCOORD0;
                    };

                    struct v2f
                    {
                        float4 pos : POSITION;
                        float3 normal : NORMAL;
                        float2 uv : TEXCOORD0;
                        float4 posWorld : TEXCOORD1;
                    };

                    v2f vert(appdata v)
                    {
                        v2f o;

                        o.posWorld = mul(unity_ObjectToWorld, v.vertex); //Calculate the world position for our point
                        o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz); // normal calculation
                        o.pos = UnityObjectToClipPos(v.vertex); //calculate position
                        o.uv = TRANSFORM_TEX(v.uv, _Tex);

                        return o;
                    }

                    fixed4 frag(v2f i) : COLOR
                    {
                        float3 normalDirection = normalize(i.normal);
                        float3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                        float3 vert2LightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
                        float oneOverDistance = 1.0 / length(vert2LightSource);
                        float attenuation = lerp(1.0, oneOverDistance, _WorldSpaceLightPos0.w); // attenuation is the change in intensity based on distance
                        float3 lightDirection = _WorldSpaceLightPos0.xyz - i.posWorld.xyz * _WorldSpaceLightPos0.w;

                        float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb; //Ambient 
                        float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection)); //Diffuse
                        float3 specularReflection;
                        if (dot(i.normal, lightDirection) < 0.0) //Light on the wrong side - no specular
                        {
                            specularReflection = float3(0.0, 0.0, 0.0);
                          }
                        else
                        {
                            //Specular
                            specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
                        }

                        float3 color = (ambientLighting + diffuseReflection) * tex2D(_Tex, i.uv) + specularReflection; //dont use texture on specular reflection
                        return float4(color, 1.0);
                    }
                ENDCG
            }
            Pass {
              Tags { "LightMode" = "ForwardAdd" } 
              // pass for ambient light and first light source.
              // e.g directional light
                Blend One One //Additive blending

                CGPROGRAM
              #pragma vertex vert
              #pragma fragment frag

              #include "UnityCG.cginc" //Provides us with data such as light and camera

              uniform float4 _LightColor0; //From UnityCG

              sampler2D _Tex; // texture
              float4 _Tex_ST; // tiling

              uniform float4 _Color; 
              uniform float4 _SpecColor;
              uniform float _Shininess;

              struct appdata
              {
                  float4 vertex : POSITION;
                  float3 normal : NORMAL; // surface normal vector
                  float2 uv : TEXCOORD0;
              };

              struct v2f
              {
                  float4 pos : POSITION;
                  float3 normal : NORMAL; // surface normal vector
                  float2 uv : TEXCOORD0;
                  float4 posWorld : TEXCOORD1;
              };

              v2f vert(appdata v)
              {
                  v2f o;

                  o.posWorld = mul(unity_ObjectToWorld, v.vertex); //Calculate world position 
                  o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz); //Calculate the normal
                  o.pos = UnityObjectToClipPos(v.vertex); // calculate position
                  o.uv = TRANSFORM_TEX(v.uv, _Tex);

                  return o;
              }

              fixed4 frag(v2f i) : COLOR
              {
                  float3 normalDirection = normalize(i.normal);
                  float3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);

                  float3 vert2LightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
                  float oneOverDistance = 1.0 / length(vert2LightSource);
                  float attenuation = lerp(1.0, oneOverDistance, _WorldSpaceLightPos0.w); // attenuation is the change in intensity based on distance
                  float3 lightDirection = _WorldSpaceLightPos0.xyz - i.posWorld.xyz * _WorldSpaceLightPos0.w;

                  float3 diffuseReflection = attenuation * _LightColor0.rgb * _Color.rgb * max(0.0, dot(normalDirection, lightDirection)); //Diffuse
                  float3 specularReflection;
                  if (dot(i.normal, lightDirection) < 0.0) //Light on the wrong side - no specular
                  {
                    specularReflection = float3(0.0, 0.0, 0.0);
                  }
                  else
                  {
                      //Specular
                      specularReflection = attenuation * _LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess);
                  }

                  float3 color = (diffuseReflection)*tex2D(_Tex, i.uv) + specularReflection; //No ambient
                  return float4(color, 1.0);
              }
          ENDCG
            }
        }
}