using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(GetDepthMap))]
public class DepthOfField : PostEffectsBase {

    public Shader Shader;
    private Material m_Material;

    [Range(0, 4)]
    public int iterations = 3;

    [Range(0.2f, 3.0f)]
    public float blurSpread = 0.6f;

    [Range(1, 8)]
    public int downSample = 1;

    public float focalDistance;

    [Range(0, 1000)]
    public float _NearBlurScale = 0;

    [Range(0, 1000)]
    public float _FarBlurScale = 50;

    public Camera MainCam
    {
        get
        {
            if (!m_MainCam)
                m_MainCam = Camera.main;
            return m_MainCam;
        }
    }

    private Camera m_MainCam;

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
            // Prepare Data For Guassian Blur
            int rtW = source.width / downSample;
            int rtH = source.height / downSample;
            RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
            buffer0.filterMode = FilterMode.Bilinear;
            Graphics.Blit(source, buffer0);

            // Do Guassian Blur
            for (int i = 0; i < iterations; ++i)
            {
                material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

                RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // Vertical Blur
                Graphics.Blit(buffer0, buffer1, material, 0);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
                buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

                // Horizontal Blur
                Graphics.Blit(buffer0, buffer1, material, 1);

                RenderTexture.ReleaseTemporary(buffer0);
                buffer0 = buffer1;
            }

            //  Final Pass, Do DoF
            focalDistance = Mathf.Clamp(focalDistance, MainCam.nearClipPlane, MainCam.farClipPlane);
            material.SetFloat("_FocalDistance", FocalDistance01(focalDistance));
            material.SetFloat("_NearBlurScale", _NearBlurScale);
            material.SetFloat("_FarBlurScale", _FarBlurScale);
            material.SetTexture("_BlurTex", buffer0);
            Graphics.Blit(source, destination, material, 2);
            RenderTexture.ReleaseTemporary(buffer0);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

    // convert focalDistance to [0-1]
    public float FocalDistance01(float distance)
    {
        float posZ = MainCam.WorldToViewportPoint((distance - MainCam.nearClipPlane) * MainCam.transform.forward + MainCam.transform.position).z;
        //return posZ / (MainCam.farClipPlane - MainCam.nearClipPlane);
        return MainCam.WorldToViewportPoint((distance - MainCam.nearClipPlane) * MainCam.transform.forward + MainCam.transform.position).z / (MainCam.farClipPlane - MainCam.nearClipPlane);
    }
}
