using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthMap : PostEffectsBase
{

    public Shader Shader;
    private Material m_Material;

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
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
