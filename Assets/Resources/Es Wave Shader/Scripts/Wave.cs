using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Es.InkPainter;

[RequireComponent(typeof(InkCanvas))]
public class Wave : MonoBehaviour {

    public Material waveMaterial;

    private Texture2D init;
    private RenderTexture input;
    private RenderTexture prev;
    private RenderTexture prev2;
    private RenderTexture result;
    private new Renderer renderer;

    [Range(1, 10)]
    public int updateFrameTiming = 3;

    public bool debug;

    void Start ()
    {
       GetComponent<InkCanvas>().OnInitializedAfter += canvas =>
       {
           // initialize for setting up Textures
           init = new Texture2D(1, 1);
           init.SetPixel(0, 0, new Color(0, 0, 0, 0));
           init.Apply();

           input = canvas.GetPaintMainTexture("Reflect Plane");
           prev = new RenderTexture(input.width, input.height, 0, RenderTextureFormat.R8);
           prev2 = new RenderTexture(input.width, input.height, 0, RenderTextureFormat.R8);
           result = new RenderTexture(input.width, input.height, 0, RenderTextureFormat.R8);

           // brush
           var r8Init = new Texture2D(1, 1);
           r8Init.SetPixel(0, 0, new Color(0.5f, 0, 0, 1));
           r8Init.Apply();

           Graphics.Blit(r8Init, prev);
           Graphics.Blit(r8Init, prev2);
       };

        renderer = GetComponent<Renderer>();
	}

    private void OnWillRenderObject()
    {
        UpdateWave();
    }

    void UpdateWave ()
    {
        if (Time.frameCount % updateFrameTiming != 0 || input == null)
            return;

        waveMaterial.SetTexture("_InputTex", input);
        waveMaterial.SetTexture("_PrevTex", prev);
        waveMaterial.SetTexture("_Prev2Tex", prev2);

        // Store formula result to result tex
        Graphics.Blit(null, result, waveMaterial);

        // update prev
        var tmp = prev2;
        prev2 = prev;
        prev = result;
        result = tmp;

        // update to renderer
        Graphics.Blit(init, input);
        renderer.sharedMaterial.SetTexture("_WaveTex", prev);
    }

    private void OnGUI()
    {
        if (debug)
        {
            var h = Screen.height / 3;
            const int StrWidth = 20;
            GUI.Box(new Rect(0, 0, h, h * 3), "");
            GUI.DrawTexture(new Rect(0, 0 * h, h, h), Texture2D.whiteTexture);
            GUI.DrawTexture(new Rect(0, 0 * h, h, h), input);
            GUI.DrawTexture(new Rect(0, 1 * h, h, h), prev);
            GUI.DrawTexture(new Rect(0, 2 * h, h, h), prev2);
            GUI.Box(new Rect(0, 1 * h - StrWidth, h, StrWidth), "INPUT");
            GUI.Box(new Rect(0, 2 * h - StrWidth, h, StrWidth), "PREV");
            GUI.Box(new Rect(0, 3 * h - StrWidth, h, StrWidth), "PREV2");
        }
    }
}
