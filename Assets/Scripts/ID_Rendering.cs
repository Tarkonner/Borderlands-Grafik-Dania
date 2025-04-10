using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;

public class ID_Rendering : ScriptableRendererFeature
{
    [SerializeField] private Shader objectIdShader;
    [SerializeField] private CustomSettings settings;
    private Material material;
    private CustomRenderPass customRenderPass;

    public override void Create()
    {
        // Initialize material and pass
        material = new Material(objectIdShader);
        customRenderPass = new CustomRenderPass(material, settings);
        customRenderPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer,
        ref RenderingData renderingData)
    {
        renderer.EnqueuePass(customRenderPass);
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        if (material != null)
        {
            DestroyImmediate(material);
        }
    }
}

// CustomSettings.cs
[System.Serializable]
public class CustomSettings
{
    public float objectIdScale = 1f;
    public bool enableDebugColors = false;
}

public class CustomRenderPass : ScriptableRenderPass
{
    private Material material;
    private CustomSettings settings;

    public CustomRenderPass(Material material, CustomSettings settings)
    {
        this.material = material;
        this.settings = settings;
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        var universalData = frameData.Get<UniversalCameraData>();
        var cameraColor = universalData.backgroundColor;

        using var builder = renderGraph.AddRasterRenderPass<PassData>("Object ID Pass", out var passData);

        // Output directly to the backbuffer
        builder.UseTextureFragment(cameraColor, 0);

        passData.material = material;
        passData.settings = settings;

        builder.SetRenderFunc((PassData data, RasterGraphContext ctx) =>
        {
            var cmd = ctx.cmd;
            cmd.SetGlobalFloat("_ObjectIdScale", data.settings.objectIdScale);
            CoreUtils.DrawFullScreen(cmd, data.material);
        });
    }

    private class PassData
    {
        public Material material;
        public CustomSettings settings;
    }
}
