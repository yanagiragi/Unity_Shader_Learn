using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenDistortionDemo : MonoBehaviour {

    public ScreenDistortion distortion;
    public float distortionStrength;
    public float noiseStrength;

    bool isToggle = false;

    void Start () {
		
	}
	
	public void Toggle () {
        isToggle = !isToggle;
        if (isToggle)
        {
            distortion._NoiseStrength = noiseStrength;
            distortion._DistortionStrength = distortionStrength;
        }
        else
        {
            distortion._NoiseStrength = 0.0f;
            distortion._DistortionStrength = 0.0f;
        }
    }
    
}
