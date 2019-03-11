using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HotAirEffect : PostEffectsBase
{
    public Shader maskShader;
    public Shader Shader;
    private Material m_Material;

    [Range(0, 1)]
    public float _DistortionStrength = 0.03f;

    [Range(0, 1)]
    public float _DistortionTimeFactor = 0.6f;

    public Texture noiseTex;
    
    private Camera mainCam;

    private Camera additionalCam;

    private RenderTexture mask;

    public Material material
    {
        get
        {
            m_Material = CheckShaderAndCreateMaterial(Shader, m_Material);
            return m_Material;
        }
    }

    public void Awake()
    {
        SetupAdditionalCamera();
    }

    public void SetupAdditionalCamera()
    {
        mainCam = GetComponent<Camera>();
        if (mainCam == null)
            return;

        Transform addCamTransform = transform.Find("additionalDistortionCamera");
        if (addCamTransform != null)
            DestroyImmediate(addCamTransform.gameObject);

        GameObject additionalCamObj = new GameObject("additionalDistortionCamera");
        additionalCam = additionalCamObj.AddComponent<Camera>();

        additionalCam.transform.parent = mainCam.transform;
        additionalCam.transform.localPosition = Vector3.zero;
        additionalCam.transform.localRotation = Quaternion.identity;
        additionalCam.transform.localScale = Vector3.one;
        additionalCam.farClipPlane = mainCam.farClipPlane;
        additionalCam.nearClipPlane = mainCam.nearClipPlane;
        additionalCam.fieldOfView = mainCam.fieldOfView;
        additionalCam.backgroundColor = Color.clear;
        additionalCam.clearFlags = CameraClearFlags.Color;
        additionalCam.cullingMask = 1 << LayerMask.NameToLayer("Distort");
        additionalCam.depth = -999;

        if (mask == null)
            mask = RenderTexture.GetTemporary(Screen.width, Screen.height, 0);
    }

    private void OnEnable()
    {
        SetupAdditionalCamera();
        additionalCam.enabled = true;
    }

    private void OnDisable()
    {
        additionalCam.enabled = false;
    }

    private void OnDestroy()
    {
        if (mask)
            RenderTexture.ReleaseTemporary(mask);
        DestroyImmediate(additionalCam.gameObject);
    }

    private void OnPreRender()
    {
        if(additionalCam.enabled)
        {
            additionalCam.targetTexture = mask;
            additionalCam.RenderWithShader(maskShader, "");
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            material.SetFloat("_DistortionStrength", _DistortionStrength);
            material.SetFloat("_DistortionTimeFactor", _DistortionTimeFactor);
            material.SetTexture("_NoiseTex", noiseTex);
            material.SetTexture("_MaskTex", mask);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
