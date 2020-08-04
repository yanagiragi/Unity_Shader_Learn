using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(getDepthMap))]
public class ApproximateBokeh : PostEffectsBase {

    public Shader Shader;
    private Material m_Material;

    public float focusPoint = 1.0f;
    public float focusScale = 1.0f;

    public float maxBlurSize = 20.0f;
    [Range(0, 1)]
    public float radiusScale = 0.5f;   

    private Camera m_camera;
    public Camera Camera
    {
        get
        {
            if (m_camera == null)
                m_camera = GetComponent<Camera>();
            return m_camera;
        }
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
            material.SetFloat("_FocusPoint", focusPoint);
            material.SetFloat("_FocusScale", focusScale);
            material.SetFloat("_MaxBlurSize", maxBlurSize);
            material.SetFloat("_RadiusScale", radiusScale);
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
