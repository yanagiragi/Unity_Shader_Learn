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
public class AnalogGlitch : PostEffectsBase {

    public Shader Shader;
    private Material m_Material;

    [Range(0, 1)]
    public float scanLineJitter = 0;

    [Range(0, 1)]
    public float verticalJump = 0;

    [Range(0, 1)]
    public float horizontalShake = 0;

    [Range(0, 1)]
    public float colorDrift = 0;

    float verticalJumpTime;

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
            verticalJumpTime += Time.deltaTime * verticalJump * 11.3f;
            float thres = Mathf.Clamp01(1.0f - scanLineJitter * 1.2f);
            float displacement = 0.002f + Mathf.Pow(scanLineJitter, 3) * 0.05f;
            material.SetVector("_ScanLineJitter", new Vector2(displacement, thres));

            Vector2 jump = new Vector2(verticalJump, verticalJumpTime);
            material.SetVector("_VerticalJump", jump);

            material.SetFloat("_HorizontalShake", horizontalShake * 0.2f);

            Vector2 drift = new Vector2(colorDrift * 0.04f, Time.time * 606.11f);
            material.SetVector("_ColorDrift", drift);

            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
