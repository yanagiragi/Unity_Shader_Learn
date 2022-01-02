using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectsBase : MonoBehaviour {

    protected void CheckResources()
    {
        bool isSupported = CheckSupport();

        if (isSupported == false)
            NotSupported();
    }

    protected bool CheckSupport()
    {
        if(SystemInfo.supportsImageEffects == false)
        {
            Debug.LogWarning("No Support to Image Effect");
            return false;
        }

        return true;
    }

    protected void NotSupported()
    {
        enabled = false;
    }

    protected Material CheckShaderAndCreateMaterial(Shader shader, Material mat)
    {
        if (shader == null)
            return null;

        if (shader.isSupported && mat && mat.shader == shader)
            return mat;

        if (!shader.isSupported)
        {
            return null;
        }
        else
        {
            mat = new Material(shader);
            mat.hideFlags = HideFlags.DontSave;
            if (mat)
                return mat;
            else
                return null;
        }
    }

	// Use this for initialization
	void Start () {
        CheckResources();
	}
	
}
