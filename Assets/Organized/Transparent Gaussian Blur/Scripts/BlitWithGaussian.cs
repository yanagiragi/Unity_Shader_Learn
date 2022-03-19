using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlitWithGaussian : MonoBehaviour
{
    public Shader Shader;
    private Material m_Material;

    public Texture2D inputTexture;
    public RenderTexture outputTexture;

    [Range(0, 4)]
    public int iterations = 3;

    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;

    [Range(1, 8)]
    public int downSample = 2;

    public Material material
    {
        get
        {
            m_Material = new Material(Shader);
            return m_Material;
        }
    }

    private void Update()
    {
        // blit to render texture in update is not a good idea.
        // This script is only for debug purpose.

        Render(inputTexture, outputTexture);
    }

    private void Render(Texture2D source, RenderTexture destination)
    {
        if (material)
        {
            outputTexture.Release();

            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;

            Graphics.Blit(source, buffer0);

            for(int i = 0; i < iterations; ++i)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // vertical pass
                Graphics.Blit(buffer0, buffer1, material, 0);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // horiztonal pass
                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            // Bilt to Screen
            Graphics.Blit(buffer0, destination);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
