 Shader "Custom/OwnShader"
 {
    Properties
    {
        _Color("Example color", Color) = (.25, .5, .5, 1)
        _ExampleName ("Texture2D display name", 2D) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalRenderPipeline"
            "LightMode"="UniversalForward"
        }
        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            
            sampler2D _ExampleName;
            float4 _Color;
            static  const float4 Speccolorer =(1,1,1,1);
            static  const float4 ambient = (0.5,0.5,0.5,1);
            static  const float smoothness = 32;
            
            struct VertexInput
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            struct FragmentInput
            {
                float4 position : SV_POSITION;
                float3 normal : TEXCOORD1;
                float4 uv : TEXCOORD0;
                float4 shadowCoords : TEXCOORD2;
            };
            
            FragmentInput vert(VertexInput v)
            {
                FragmentInput o;
                o.position = TransformObjectToHClip(v.vertex);
                o.normal = TransformObjectToWorldNormal(v.normal);
                o.uv = v.uv;

                //Shadows
                VertexPositionInputs positions = GetVertexPositionInputs(v.vertex.xyz);
                float4 shadowCoordinates = GetShadowCoord(positions);
                o.shadowCoords = shadowCoordinates;
                
                return o;
            }
            
            float4 frag(FragmentInput i) : SV_Target
            {
                float shadow = MainLightRealtimeShadow(i.shadowCoords);
                
                float3 viewDir = normalize(GetCameraPositionWS() - i.position.xyz);
                
                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);
                float NdotL = saturate(dot(i.normal, lightDir)); // Lambertian reflection

                float3 diffuse = _Color.rgb * mainLight.color * NdotL;
                float3 localAmb = _Color.rgb * ambient.rgb;
               
                float3 reflectDir = reflect(-lightDir, normalize(i.normal));
                float RdotV = saturate(dot(reflectDir, viewDir));
                float3 localSpec = mainLight.color * Speccolorer * pow(RdotV, smoothness) * max(0, NdotL);
                
                float3 finalColor = diffuse * shadow + localAmb + localSpec;
                return float4(finalColor, 1);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
 }