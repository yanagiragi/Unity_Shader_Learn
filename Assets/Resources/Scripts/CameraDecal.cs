using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CameraDecal : MonoBehaviour
{
    public Camera projectorCam = null;
    public Material projectorMaterial = null;

    private void Awake()
    {
        projectorCam = GetComponent<Camera>();
    }

    void Update()
    {
        Matrix4x4 projectionMatrix = projectorCam.projectionMatrix;
        projectionMatrix = GL.GetGPUProjectionMatrix(projectionMatrix, false);
        Matrix4x4 ViewMatrix = projectorCam.worldToCameraMatrix;
        projectorMaterial.SetMatrix("_ProjectorVP", projectionMatrix * ViewMatrix);
    }
}
