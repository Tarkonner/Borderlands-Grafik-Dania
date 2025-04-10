Shader "Unlit/ObjectID_Outline"
{
    Properties
    {
        _ObjectIdScale("Object ID Scale", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalRenderPipeline" }
        Pass
        {
            Name "ObjectIDPass"
            ZWrite Off
            ZTest Always
            Cull Off
            Blend Off

            HLSLINCLUDE
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            float _ObjectIdScale;
            float _ObjectId;

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // Encode Object ID into red channel
                return half4(_ObjectId * _ObjectIdScale, 0.0, 0.0, 1.0);
            }
            ENDHLSL

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDHLSL
        }
    }
}
