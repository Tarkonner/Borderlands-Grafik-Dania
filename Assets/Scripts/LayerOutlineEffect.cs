using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.Universal;
using static EdgeDetection;
public class LayerOutlineEffect : ScriptableRendererFeature
{
    [Serializable]
    public class LayerOutlineEffectSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
        [Range(0, 1)] public float outlineThickness = 1;
        [Range(0, 1)] public float depthMin = 0;
        [Range(0, 1)] public float depthMax = 1;
        public Material outlineMaterial;
        //public Color outlineColor = Color.black;
    }

    [SerializeField] private LayerOutlineEffectSettings settings;
    private OutlinePass outlinePass;


    public override void Create()
    {
        outlinePass = new OutlinePass(RenderPassEvent.AfterRendering, settings.outlineMaterial);
    }


    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        // Don't render for some views.
        if (renderingData.cameraData.cameraType == CameraType.Preview
            || renderingData.cameraData.cameraType == CameraType.Reflection
            || UniversalRenderer.IsOffscreenDepthTexture(ref renderingData.cameraData))
            return;

        


        outlinePass.ConfigureInput(ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Normal | ScriptableRenderPassInput.Color);


        renderer.EnqueuePass(outlinePass);
    }


    private class OutlinePass : ScriptableRenderPass
    {
        private Material outlineMaterial;

        public OutlinePass(RenderPassEvent renderPassEvent, Material material)
        {
            outlineMaterial = material;
        }

        private class PassData
        {

        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            var resourceData = frameData.Get<UniversalResourceData>();

            using var builder = renderGraph.AddRasterRenderPass<PassData>("Outline Detection", out _);

            builder.SetRenderAttachment(resourceData.activeColorTexture, 0);
            builder.UseAllGlobalTextures(true);
            builder.AllowPassCulling(false);
            builder.SetRenderFunc((PassData _, RasterGraphContext context) => { Blitter.BlitTexture(context.cmd, Vector2.one, outlineMaterial, 0); });
        }
    }
}
