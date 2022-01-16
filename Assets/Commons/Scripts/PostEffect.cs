using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PostEffect : PostEffectsBase {

    [SerializeField] private Material m_Material;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (m_Material)
        {
            Graphics.Blit(source, destination, m_Material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
