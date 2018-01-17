using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectsBase {


    public Shader edgeShader;
    private Material edgeMaterial;

    [Range(0.0f, 1.0f)]
    public float edgeOnly = 1.0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    public Material material
    {
        get
        {
            edgeMaterial = CheckShaderAndCreateMaterial(edgeShader, edgeMaterial);
            return edgeMaterial;
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            material.SetFloat("_EdgeOnly", edgeOnly);
            material.SetColor("_EdgeColor", edgeColor);
            material.SetColor("_BackgorundColor", backgroundColor);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
