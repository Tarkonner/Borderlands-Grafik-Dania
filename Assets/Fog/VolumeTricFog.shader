Shader "Fog/VolumetricFog"
{
    Properties
    {
        _MainColor ("Fog Color", Color) = (0.7, 0.8, 1, 1)
        _FogDensity ("Fog Density", Float) = 3
        _ObjectRadius ("Object Radius", Float) = 3000
        _NoiseScale ("Noise Scale", Float) = 0.03
        _Speed ("Noise Speed", Float) = 0.1
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

            float hash(float3 p)
            {
                return frac(sin(dot(p, float3(12.9898, 78.233, 37.719))) * 43758.5453);
            }

            float noise(float3 p)
            {
                return lerp(hash(floor(p)), hash(ceil(p)), frac(p.x + p.y + p.z));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // Center of object in world space
                float3 center = GetObjectToWorldMatrix()[3].xyz;

                // Distance from point in world space to object center
                float dist = distance(i.worldPos, center);

                // Normalize falloff by object radius
                float falloff = saturate(1.0 - dist / _ObjectRadius);

                // Add animated noise
                float n = noise(i.worldPos * _NoiseScale + _Time.y * _Speed);

                // Final fog alpha
                float alpha = falloff * saturate(n + 0.2) * _FogDensity;

                return half4(_MainColor.rgb, alpha);
            }

            ENDHLSL
        }
    }
}
