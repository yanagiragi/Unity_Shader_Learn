using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RenderToCubeMap : MonoBehaviour {

    public Cubemap cubemap;
    public bool GenerateNewMap = false;

	void Start () {
        Camera mainCam = GetComponent<Camera>();

        if(GenerateNewMap)
            cubemap = new Cubemap(512, TextureFormat.ARGB32, false);

        mainCam.RenderToCubemap(cubemap);

        cubemap.Apply();

	}

}
