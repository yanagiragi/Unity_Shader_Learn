using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AdjustReflectPosition : MonoBehaviour {

    public Camera target;

	void Update ()
    {
	    if(target)
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
}
