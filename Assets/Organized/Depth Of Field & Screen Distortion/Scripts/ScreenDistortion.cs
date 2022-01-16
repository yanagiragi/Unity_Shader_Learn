using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenDistortion : PostEffectsBase {

    public Shader Shader;
    private Material m_Material;

    public Vector2 _DistortionCenter;

    [Range(0, 1)]
    public float _DistortionStrength;
    
    [Range(0, 1)]
    public float _NoiseStrength = 0;

    public float _NoiseSpeed;

    public Texture NoiseMap;

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
            material.SetVector("_DistortionCenter", _DistortionCenter);
            material.SetFloat("_DistortionStrength", _DistortionStrength);
            material.SetFloat("_NoiseStrength", _NoiseStrength);
            material.SetFloat("_NoiseSpeed", _NoiseSpeed);
            material.SetTexture("_NoiseTex", NoiseMap);            
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
