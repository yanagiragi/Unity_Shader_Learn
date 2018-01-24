using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class rotate : MonoBehaviour {
    public Vector3 Speed;

    private float frame;

	void Start () {
        frame = 0;
	}
	
	void Update () {
        ++frame;
        transform.localRotation = Quaternion.Euler(new Vector3(Speed.x * frame, Speed.y * frame, Speed.z * frame));
	}
}
