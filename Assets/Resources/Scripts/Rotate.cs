using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{

    public float smoothFactor = 1;
    public Vector3 axis;
    float time = 0;

    void Start()
    {
        time = 0;
    }

    void Update()
    {
        time += Time.deltaTime * smoothFactor;

        transform.localRotation = Quaternion.Euler(axis.x * time, axis.y * time, axis.z * time);
    }
}
