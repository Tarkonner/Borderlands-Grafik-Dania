 Shader "Custom/PhongModelAnders"
 {
    Properties
    {
        _Color("Color", Color) = (.25, .5, .5, 1)
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
            /*
            static  const float4 Speccolorer =(1,1,1,1);
            */
            static const float4 ambientColor = float4(0.5, 0.5, 0.5, 1);
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
    float3 worldPos : TEXCOORD3;
    float3 normal : TEXCOORD1;
    float4 uv : TEXCOORD0;
    float4 shadowCoords : TEXCOORD2;
};

FragmentInput vert(VertexInput v)
{
    FragmentInput o;
    VertexPositionInputs positions = GetVertexPositionInputs(v.vertex.xyz);

    o.position = positions.positionCS;
    o.worldPos = positions.positionWS; // Add this line
    o.normal = TransformObjectToWorldNormal(v.normal);
    o.uv = v.uv;

    float4 shadowCoordinates = GetShadowCoord(positions);
    o.shadowCoords = shadowCoordinates;

    return o;
}


            float4 frag(FragmentInput i) : SV_Target
            {
    float3 nor = normalize(i.normal);
    float3 viewDir = normalize(GetCameraPositionWS() - i.worldPos);
    
    Light mainLight = GetMainLight();
    float3 lightDir = normalize(mainLight.direction);
    
    float3 ambient = _Color.rgb * ambientColor.rgb;
    
    float Ndot_ = saturate(dot(nor, lightDir));
    float3 diffuse = _Color.rgb * mainLight.color * Ndot_;
    
    float3 reflected = reflect(-lightDir, nor);
    float RdotV = saturate(dot(reflected, viewDir));
    float3 specular = pow(RdotV, smoothness) * mainLight.color;

    float3 finalColor = ambient + diffuse + specular;
    return float4(finalColor, 1);
            }
            ENDHLSL
        }
    }
 }