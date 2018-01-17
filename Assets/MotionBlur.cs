using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectsBase
{
    public Shader Shader;
    private Material m_Material;

    private RenderTexture accumulationTexutre;

    [Range(0.0f, 0.9f)]
    public float blurAmount = 0.5f;

    private void OnDisable()
    {
        DestroyImmediate(accumulationTexutre);
    }

    public Material material
    {
        get
        {
            m_Material = CheckShaderAndCreateMaterial(Shader, m_Material);
            return m_Material;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            if (accumulationTexutre == null || accumulationTexutre.width != source.width || accumulationTexutre.height != source.height)
            {
                DestroyImmediate(accumulationTexutre);
                accumulationTexutre = new RenderTexture(source.width, source.height, 0);
                accumulationTexutre.hideFlags = HideFlags.HideAndDontSave;
                Graphics.Blit(source, accumulationTexutre);
            }

            accumulationTexutre.MarkRestoreExpected();

            material.SetFloat("_BlurAmount", 1.0f - blurAmount);

            Graphics.Blit(source, accumulationTexutre, material);
            Graphics.Blit(accumulationTexutre, destination);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
