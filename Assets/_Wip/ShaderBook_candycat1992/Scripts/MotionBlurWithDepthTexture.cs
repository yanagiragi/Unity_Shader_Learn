using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTexture : PostEffectsBase {

    public Shader Shader;
    private Material m_Material;

    private void OnEnable()
    {
        Camera camera = GetComponent<Camera>();
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnDisable()
    {
        Camera camera = GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.None;
    }

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

    [Range(0.0f, 1.0f)]
    public float blurSize = 0.5f;

    private Matrix4x4 previousViewProjectionMatrix;

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
            material.SetFloat("_BlurSize", blurSize);
            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            Matrix4x4 currentViewProjectionMatrix = Camera.projectionMatrix * Camera.worldToCameraMatrix;
            Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
            material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
            previousViewProjectionMatrix = currentViewProjectionMatrix;

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
