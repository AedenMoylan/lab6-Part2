Shader "Gouraud Shader" {
    Properties{
       _Color("Diffuse Material Color", Color) = (1,1,1,1)
       _SpecColor("Specular Material Color", Color) = (1,1,1,1)
       _Shininess("Shininess", Float) =  10
        // the color of the texture assigned to the object
       _MainTex("Texture Image", 2D) = "white" {}
       
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

 // User-specified properties
 uniform float4 _Color;
 uniform float4 _SpecColor;
 uniform float _Shininess;
 uniform sampler2D _MainTex; // texture
 uniform float4 _MainTex_ST; // tiles

 struct vertexInput {
    float4 vertex : POSITION;
    float3 normal : NORMAL; // surface normal vector
    float4 texcoord : TEXCOORD0;
 };
 struct vertexOutput {
    float4 pos : SV_POSITION;
    float4 col : COLOR;
    float4 tex : TEXCOORD0;
 };

 vertexOutput vert(vertexInput input)
 {
    vertexOutput output;

    output.tex = input.texcoord;
    float4x4 modelMatrix = unity_ObjectToWorld;
    float3x3 modelMatrixInverse = unity_WorldToObject;
    float3 normalDirection = normalize(
       mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);

    float3 viewDirection = normalize(_WorldSpaceCameraPos
       - mul(modelMatrix, input.vertex).xyz);
    float3 lightDirection;
    float attenuation;

    if (0.0 == _WorldSpaceLightPos0.w) // directional light?
    {
       attenuation = 1.0; // no attenuation
       lightDirection = normalize(_WorldSpaceLightPos0.xyz);
    }
    else // point or spot light
    {
       float3 vertexToLightSource = _WorldSpaceLightPos0.xyz
          - mul(modelMatrix, input.vertex).xyz;
       float distance = length(vertexToLightSource);
       attenuation = 1.0 / distance; // linear attenuation 
       lightDirection = normalize(vertexToLightSource);
    }

    // set ambient lighting
    float3 ambientLighting =
       UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;

    // 
    float3 diffuseReflection =
       attenuation * _LightColor0.rgb * _Color.rgb
       * max(0.0, dot(normalDirection, lightDirection));

    float3 specularReflection;
    if (dot(normalDirection, lightDirection) < 0.0)
        // light source on the wrong side?
     {
        specularReflection = float3(0.0, 0.0, 0.0);
        // no specular reflection
  }
  else // light source on the right side
  {
     specularReflection = attenuation * _LightColor0.rgb
        * _SpecColor.rgb * pow(max(0.0, dot(
        reflect(-lightDirection, normalDirection),
        viewDirection)), _Shininess);
  }

  output.col = float4(ambientLighting + diffuseReflection
     + specularReflection, 1.0);
  output.pos = UnityObjectToClipPos(input.vertex);
  return output;
}

 float4 frag(vertexOutput input) : COLOR
 {
    return input.col * tex2D(_MainTex, _MainTex_ST.xy * input.tex.xy + _MainTex_ST.zw);
}

ENDCG
}

Pass {
   Tags { "LightMode" = "ForwardAdd" }
   // pass for additional light sources
   // e.g point light
Blend One One // additive blending 

CGPROGRAM

#pragma vertex vert  
#pragma fragment frag 

#include "UnityCG.cginc"
uniform float4 _LightColor0;
// color of light source (from "Lighting.cginc")

// User-specified properties
uniform float4 _Color;
uniform float4 _SpecColor;
uniform float _Shininess;
uniform sampler2D _MainTex;
uniform float4 _MainTex_ST;

struct vertexInput {
   float4 vertex : POSITION;
   float3 normal : NORMAL;
   float4 texcoord : TEXCOORD0;
};
struct vertexOutput {
   float4 pos : SV_POSITION;
   float4 col : COLOR;
   float4 tex : TEXCOORD0;
};

vertexOutput vert(vertexInput input)
{
   vertexOutput output;
   output.tex = input.texcoord;

   float4x4 modelMatrix = unity_ObjectToWorld;
   float3x3 modelMatrixInverse = unity_WorldToObject;
   float3 normalDirection = normalize(
      mul(input.normal, modelMatrixInverse));
   float3 viewDirection = normalize(_WorldSpaceCameraPos
      - mul(modelMatrix, input.vertex).xyz);
   float3 lightDirection;
   // loss of light intensity over distance
   float attenuation;

   // calculate direction to the light source in world space
   if (0.0 == _WorldSpaceLightPos0.w) // directional light?
   {
      attenuation = 1.0; // no attenuation
      lightDirection = normalize(_WorldSpaceLightPos0.xyz);
   }
   else // point or spot light
   {
      float3 vertexToLightSource = _WorldSpaceLightPos0.xyz
         - mul(modelMatrix, input.vertex).xyz;
      float distance = length(vertexToLightSource);
      attenuation = 1.0 / distance; // linear attenuation 
      lightDirection = normalize(vertexToLightSource);
   }

   float3 diffuseReflection =
      attenuation * _LightColor0.rgb * _Color.rgb
      * max(0.0, dot(normalDirection, lightDirection));

   float3 specularReflection;
   if (dot(normalDirection, lightDirection) < 0.0)
       // light source on the wrong side?
    {
       specularReflection = float3(0.0, 0.0, 0.0);
       // no specular reflection
 }
 else // light source on the right side
 {
    specularReflection = attenuation * _LightColor0.rgb
       * _SpecColor.rgb * pow(max(0.0, dot(
       reflect(-lightDirection, normalDirection),
       viewDirection)), _Shininess);
 }

 output.col = float4(diffuseReflection
    + specularReflection, 1.0);
 // no ambient contribution in this pass
output.pos = UnityObjectToClipPos(input.vertex);
return output;
}

float4 frag(vertexOutput input) : COLOR
{
   return input.col * tex2D(_MainTex, _MainTex_ST.xy * input.tex.xy + _MainTex_ST.zw);
}

ENDCG
}
    }
        Fallback "Specular"
}