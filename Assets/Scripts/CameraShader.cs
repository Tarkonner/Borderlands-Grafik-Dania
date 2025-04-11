using UnityEngine;

[RequireComponent (typeof(Camera))]
public class CameraShader : MonoBehaviour
{
    [SerializeField] Material shaderMaterial;

    private void Start()
    {
        Debug.Log("Sa");
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Debug.Log("Render");
        if(shaderMaterial == null)
        {
            Graphics.Blit (source, destination);
        }
        else
            Graphics.Blit (source, destination, shaderMaterial);
    }
}
