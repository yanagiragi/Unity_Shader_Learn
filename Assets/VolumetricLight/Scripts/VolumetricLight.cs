using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
[AddComponentMenu("Effects/Volumetric Light")]
public class VolumetricLight : MonoBehaviour
{
    [SerializeField]
    private Shader _RayMarchShader;

    public Light SunLight;

    public Camera CurrentCamera
    {
        get
        {
            if (!_CurrentCamera)
                _CurrentCamera = GetComponent<Camera>();
            return _CurrentCamera;
        }
    }

    [Header("Material Controls")]

    [Range(0, 1024)]
    public int rayMarchSteps = 64;

    public bool enableNoise;

    public Texture2D noiseTexture;
    
    [Range(0, 1)]
    public float noiseSpeed;

    [Range(0, 1)]
    public float extinctionCoefficient = 0.04f;

    [Range(0, 2)]
    public float rayleighScatteringCoefficient = 0.003f;

    [Range(0, 2)]
    public float mieScatteringCoefficient = 0.01f;

    [Range(-1, 2)]
    public float henyeyGreensteinCoefficient = -0.3f;

    [Range(0, 100)]
    public float fogDensity = 2;

    public Color shadowColor = new Color(0.368f, 0.368f, 0.368f);

    public Color fogColor = new Color(1f, 0.94f, 0.92f);

    [Range(0, 1)]
    public float ambientFog = 0.138f;

    private Material _EffectMaterial;
    
    private Camera _CurrentCamera;

    private Material EffectMaterial
    {
        get
        {
            if (!_EffectMaterial && _RayMarchShader)
            {
                _EffectMaterial = new Material(_RayMarchShader);
                _EffectMaterial.hideFlags = HideFlags.HideAndDontSave;
            }

            return _EffectMaterial;
        }
    }

    private CommandBuffer _afterShadowPass;

    void AddLightCommandBuffer()
    {
        _afterShadowPass = new CommandBuffer { name = "Volumetric Fog ShadowMap" };

        _afterShadowPass.SetGlobalTexture("ShadowMap", new RenderTargetIdentifier(BuiltinRenderTextureType.CurrentActive));

        if (SunLight)
        {
            SunLight.AddCommandBuffer(LightEvent.AfterShadowMap, _afterShadowPass);
        }
    }

    void RemoveLightCommandBuffer()
    {
        if (SunLight && _afterShadowPass != null)
        {
            SunLight.RemoveCommandBuffer(LightEvent.AfterShadowMap, _afterShadowPass);
        }
    }

    private void Start()
    {
        AddLightCommandBuffer();
    }

    private void OnDestroy()
    {
        RemoveLightCommandBuffer();
    }

    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (!EffectMaterial)
        {
            Graphics.Blit(source, destination);
            return;
        }

        if (enableNoise)
        {
            EffectMaterial.EnableKeyword(@"ENABLE_NOISE");
        }
        else
        {
            EffectMaterial.DisableKeyword(@"ENABLE_NOISE");
        }

        // pass frustum rays to shader
        EffectMaterial.SetMatrix("_CameraInvViewMatrix", CurrentCamera.cameraToWorldMatrix);
        EffectMaterial.SetMatrix("_CameraInvProjectionMatrix", CurrentCamera.projectionMatrix.inverse);
        EffectMaterial.SetVector("_LightDir", SunLight.transform.forward);
        EffectMaterial.SetFloat("_ExtinctionCoefficient", extinctionCoefficient);
        EffectMaterial.SetFloat("_RayleighScatteringCoefficient", rayleighScatteringCoefficient);
        EffectMaterial.SetFloat("_MieScatteringCoefficient", mieScatteringCoefficient);
        EffectMaterial.SetFloat("_Anisotropy", henyeyGreensteinCoefficient);
        EffectMaterial.SetFloat("_FogDensity", fogDensity);
        EffectMaterial.SetFloat("_FogSpeed", noiseSpeed);
        EffectMaterial.SetFloat("_AmbientFog", ambientFog);
        EffectMaterial.SetFloat("_LightIntensity", SunLight.intensity);
        EffectMaterial.SetFloat("_RayMarchSteps", rayMarchSteps);
        EffectMaterial.SetTexture("_NoiseTex", noiseTexture);
        EffectMaterial.SetColor("_ShadowColor", shadowColor);
        EffectMaterial.SetColor("_FogColor", fogColor);

        //CustomGraphicsBlit(source, destination, EffectMaterial, 0); // Replace Graphics.Blit with CustomGraphicsBlit
        Graphics.Blit(source, destination, EffectMaterial, 0); // Replace Graphics.Blit with CustomGraphicsBlit
    }
}
