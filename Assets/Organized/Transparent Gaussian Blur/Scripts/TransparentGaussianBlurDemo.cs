using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TransparentGaussianBlurDemo : MonoBehaviour
{
    public Slider iterationSlider;

    public Slider blurSpreadSlider;

    public Slider downSampleSlider;

    public BlitWithGaussian[] BlitWithGaussians;

    private int iterations = 3;

    private float blurSpread = 0.6f;

    private int downSample = 2;

    // Update is called once per frame
    void Update()
    {
        iterations = (int)Mathf.Clamp(iterationSlider.value, 0, 4);
        blurSpread = Mathf.Clamp(blurSpreadSlider.value, 0.2f, 3f);
        downSample = (int)Mathf.Clamp(downSampleSlider.value, 1, 8);

        foreach(var gaussian in BlitWithGaussians)
        {
            gaussian.blurSpread = blurSpread;
            gaussian.downSample = downSample;
            gaussian.iterations = iterations;
        }
    }
}
