Shader "Fog/VolumetricFog"
{
    Properties
    {
        _MainColor ("Fog Color", Color) = (0.7, 0.8, 1, 1)
        _FogDensity ("Fog Density", Float) = 3
        _ObjectRadius ("Object Radius", Float) = 3000
        _NoiseScale ("Noise Scale", Float) = 0.01
        _Speed ("Noise Speed", Float) = 0.1
        _FogNoiseTex ("Noise Texture", 3D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100

        Pass
        {
            Tags { "LightMode"="UniversalForward" }

            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            float4 _MainColor;
            float _FogDensity;
            float _ObjectRadius;
            float _NoiseScale;
            float _Speed;

            TEXTURE3D(_FogNoiseTex);
            SAMPLER(sampler_FogNoiseTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // World-space center of object
                float3 center = GetObjectToWorldMatrix()[3].xyz;

                // Distance from pixel to center
                float dist = distance(i.worldPos, center);
                float falloff = saturate(1.0 - dist / _ObjectRadius);

                // Animated 3D noise sampling
                float3 noiseUV = i.worldPos * _NoiseScale + _Time.y * _Speed;
                float n = SAMPLE_TEXTURE3D(_FogNoiseTex, sampler_FogNoiseTex, noiseUV).r;

                // Final alpha based on falloff and noise
                float alpha = falloff * n * _FogDensity;

                return half4(_MainColor.rgb, alpha);
            }

            ENDHLSL
        }
    }
}
