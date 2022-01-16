//
// KinoGlitch - Video glitch effect
//
// Copyright (C) 2015 Keijiro Takahashi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DigitalGlitch : PostEffectsBase
{

    public Shader Shader;

    private Material m_Material;

    [Range(0, 1)]
    public float intensity = 0;


    Texture2D noiseTexture;
    RenderTexture trashFrame1;
    RenderTexture trashFrame2;

    static Color RandomColor()
    {
        return new Color(Random.value, Random.value, Random.value, Random.value);
    }

    public Material material
    {
        get
        {
            m_Material = CheckShaderAndCreateMaterial(Shader, m_Material);
            return m_Material;
        }
    }

    void UpdateNoiseTexture()
    {
        Color color = RandomColor();

        for(int y = 0; y < noiseTexture.height; ++y)
        {
            for(int x = 0; x < noiseTexture.width; ++x)
            {
                if (Random.value > 0.89f)
                {
                    color = RandomColor();
                }
                noiseTexture.SetPixel(x, y, color);
            }
        }

        noiseTexture.Apply();
    }

    void SetupResource()
    {
        noiseTexture = new Texture2D(64, 32, TextureFormat.ARGB32, false);
        noiseTexture.hideFlags = HideFlags.DontSave;
        noiseTexture.wrapMode = TextureWrapMode.Clamp;
        noiseTexture.filterMode = FilterMode.Point;

        trashFrame1 = new RenderTexture(Screen.width, Screen.height, 0);
        trashFrame2 = new RenderTexture(Screen.width, Screen.height, 0);
        trashFrame1.hideFlags = HideFlags.DontSave;
        trashFrame2.hideFlags = HideFlags.DontSave;

        UpdateNoiseTexture();
    }

    private void Start()
    {
        SetupResource();
    }

    private void Update()
    {
        if(Random.value > Mathf.Lerp(0.9f, 0.5f, intensity))
        {
            UpdateNoiseTexture();
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material)
        {
            float frameCount = Time.frameCount;

            if(frameCount % 13 == 0)
            {
                Graphics.Blit(source, trashFrame1);
            }

            if (frameCount % 73 == 0)
            {
                Graphics.Blit(source, trashFrame2);
            }

            material.SetFloat("_Intensity", intensity);
            material.SetTexture("_NoiseTex", noiseTexture);
            var trashFrame = Random.value > 0.5f ? trashFrame1 : trashFrame2;
            material.SetTexture("_TrashTex", trashFrame);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
