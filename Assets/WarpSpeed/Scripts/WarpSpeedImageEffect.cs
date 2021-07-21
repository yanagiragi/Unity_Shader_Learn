using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, RequireComponent(typeof(Camera))]
public class WarpSpeedImageEffect : MonoBehaviour
{
    [SerializeField] private Material warpMat;

    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (warpMat)
        {
            Graphics.Blit(source, destination, warpMat);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
