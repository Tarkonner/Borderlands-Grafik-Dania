Shader "Custom/Lighting"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)

    }
    SubShader
    {
        Tags 
        { 
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "ForwardPass"
            Tags {"LightMode" = "UniversalForward"}

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;

            struct Attributes{
               float3 positionLS : POSITION;
               float3 normalLS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXTCOORD0;
            };

            Varyings Vertex(Attributes input)
            {
                 Varyings output;
                 output.positionCS = TransformObjectToHClip(input.positionLS);
                 output.normalWS = TransformObjectToWorldNormal(input.normalLS);
                 return output;
            }

            half4 Fragment(Varyings v) : SV_Target
            {    
                return _Color;
            }

            ENDHLSL
        }
    }
}
