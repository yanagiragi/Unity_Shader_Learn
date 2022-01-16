using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class Aspect : MonoBehaviour {

    public GameObject fourtothree;
    public GameObject hexttonine;
    public GameObject tentonine;
    public Camera OriginCamera;
    private float thres = 0.001f;

    void Start () {
        Resolution res = Screen.currentResolution;
        float ratio = (float)res.width / (float)res.height;

        //Debug.Log(ratio);

        if(ratio < ((4.0f / 3.0f) + thres) && ratio > ((4.0f / 3.0f) - thres))
        {
            fourtothree.SetActive(true);
            hexttonine.SetActive(false);
            tentonine.SetActive(false);
        }
        else if (ratio < ((16.0f / 9.0f) + thres) && ratio > ((16.0f / 9.0f) - thres))
        {
            fourtothree.SetActive(false);
            hexttonine.SetActive(true);
            tentonine.SetActive(false);
        }
        else if (ratio < ((16.0f / 10.0f) + thres) && ratio > ((16.0f / 10.0f) - thres))
        {
            fourtothree.SetActive(false);
            hexttonine.SetActive(false);
            tentonine.SetActive(true);
        }
        else
        {
            fourtothree.SetActive(false);
            hexttonine.SetActive(false);
            tentonine.SetActive(false);

            OriginCamera.targetDisplay = 0;
            OriginCamera.targetTexture = null;

            gameObject.SetActive(false);
        }
    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
