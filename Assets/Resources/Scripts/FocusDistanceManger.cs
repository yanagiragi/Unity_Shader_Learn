using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FocusDistanceManger : MonoBehaviour {

    public float distance = 5;
    public float step = 0.1f;

    public DepthOfField DOF;

	void Update () {
        if (Input.GetKey(KeyCode.W))
            distance += step;
        else if (Input.GetKey(KeyCode.S))
            distance -= step;

        DOF.focalDistance = distance;
    }
}
