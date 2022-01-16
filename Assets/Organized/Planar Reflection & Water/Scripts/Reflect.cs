using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Reflect : MonoBehaviour {

    [SerializeField]
    private Camera reflectCamera;

    private new Renderer renderer;
    private Material sharedMaterial;

    void Start()
    {
        renderer = GetComponent<Renderer>();
        sharedMaterial = renderer.sharedMaterial;
        reflectCamera.targetTexture = new RenderTexture(Screen.width, Screen.height, 16);
        sharedMaterial.SetTexture("_ReflTex", reflectCamera.targetTexture);
    }

    void OnWillRenderObject()
    {
        Camera cam = Camera.current;
        if(cam == reflectCamera)
        {
            var reflVMatrix = cam.worldToCameraMatrix;
            var reflPMatrix = GL.GetGPUProjectionMatrix(cam.projectionMatrix, false);
            var reflVP = reflPMatrix * reflVMatrix;
            var reflM = renderer.localToWorldMatrix;
            sharedMaterial.SetMatrix("_ReflVP", reflVP);
            sharedMaterial.SetMatrix("_ReflM", reflM);

            if(Screen.width != reflectCamera.targetTexture.width || Screen.height != reflectCamera.targetTexture.height)
            {
                reflectCamera.targetTexture = new RenderTexture(Screen.width, Screen.height, 16);
                sharedMaterial.SetTexture("_ReflTex", reflectCamera.targetTexture);
            }

            if(!Application.isPlaying && sharedMaterial.GetTexture("_ReflTex") == null)
            {
                sharedMaterial.SetTexture("_ReflTex", reflectCamera.targetTexture);
            }

        }
    }

    /* Below is for CineMachine */
    /* A little bit adjust due to the behaviour of cinemachine camera brain */
    /*
        public Camera target;
        private Camera p_target;
        public Cinemachine.CinemachineBrain brain;

        private void Start()
        {
            p_target = target;
        }

        void Update ()
        {
            if(brain.ActiveVirtualCamera != null)
            {
                // force update reflect camera to real main camera
                target = brain.ActiveVirtualCamera.VirtualCameraGameObject.GetComponent<Camera>();
            }
            else
            {
                target = p_target;
            }


            if (target)
            {
                Vector3 pos = target.transform.position;
                Vector3 rot = target.transform.eulerAngles;

                pos.y *= -1;
                rot.x *= -1;
                rot.z *= -1;

                transform.position = pos;
                transform.rotation = Quaternion.Euler(rot);
            }
        }
    */
}
