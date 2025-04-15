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
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma shader_feature _FORWARD_PLUS
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half4 _Color;
            CBUFFER_END

            struct Attributes{
               float3 positionLS : POSITION;
               float3 normalLS : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXTCOORD0;
                float3 positionWS : TEXTCOORD1;
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
                InputData lighting = (InputData) 0;
                lighting.positionWS = v.positionWS;
                lighting.normalWS = normalize(v.normalWS);
                lighting.viewDirectionWS = GetWorldSpaceViewDir(v.positionWS);

                SurfaceData surface = (SurfaceData) 0;
                surface.albedo = _Color;
                surface.alpha = 1;
                surface.smoothness = .9;
                surface.specular = .9;


                return UniversalFragmentBlinnPhong(lighting, surface) + unity.AmbientSky;
            }

            ENDHLSL
        }
    }
}
