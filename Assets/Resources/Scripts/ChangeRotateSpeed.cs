using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeRotateSpeed : MonoBehaviour {

    public Rotate target;

    public float initSpeed;
    public float toggleSpeed;

    private void Start()
    {
        target.smoothFactor = initSpeed;
    }

    public void click () {
        target.smoothFactor = (target.smoothFactor == initSpeed) ? toggleSpeed : initSpeed;
	}
}
