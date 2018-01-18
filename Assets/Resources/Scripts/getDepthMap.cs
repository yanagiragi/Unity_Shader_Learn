using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class getDepthMap : MonoBehaviour {

    private void OnEnable()
    {
        Camera camera = GetComponent<Camera>();
        camera.depthTextureMode |= DepthTextureMode.Depth;
        camera.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    private void OnDisable()
    {
        Camera camera = GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.None;
    }
}
