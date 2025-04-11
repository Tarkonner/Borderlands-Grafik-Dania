Shader "Unlit/LayerOutline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl" // needed to sample scene depth

            float4 _MainTex_TexelSize;
            float4x4 unity_MatrixMVP;

            half _MinDepth;
            half _MaxDepth;
            half _Thickness;
            half _EdgeColor;

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 screen_pos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            inline float4 ComputeScreenPos(float4 pos)
            {
                float4 o = pos * 0.5f;
                o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
                o.zw = pos.zw;
                return o;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = float4(v.vertex.xy, 0.0, 1.0);
                o.uv = TransformTriangleVertexToUV(v.vertex.xy);
                o.screen_pos = ComputeScreenPos(o.vertex);
                o.uv = o.uv * float2(1.0, -1.0) + float2(0.0, 1.0);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Screen-space coordinates which we will use to sample.
                float2 uv = IN.texcoord;
                float2 texel_size = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);
                
                // Generate 4 diagonally placed samples.
                const float half_width_f = floor(_OutlineThickness * 0.5);
                const float half_width_c = ceil(_OutlineThickness * 0.5);

                float2 uvs[4];
                uvs[0] = uv + texel_size * float2(half_width_f, half_width_c) * float2(-1, 1);  // top left
                uvs[1] = uv + texel_size * float2(half_width_c, half_width_c) * float2(1, 1);   // top right
                uvs[2] = uv + texel_size * float2(half_width_f, half_width_f) * float2(-1, -1); // bottom left
                uvs[3] = uv + texel_size * float2(half_width_c, half_width_f) * float2(1, -1);  // bottom right

                float depth_samples[4];
                for (int i = 0; i < 4; i++) {
                    depth_samples[i] = SampleSceneDepth(uvs[i]);
                }

                float d = length(float(depth_samples[1] - depth_samples[0], depth_samples[3] - depth_samples[2]))
                d = smoothstep(_MinDepth, _MaxDepth, d);
                half4 output = d;

                return coloutput
            }
            ENDHLSL
        }
    }
}
