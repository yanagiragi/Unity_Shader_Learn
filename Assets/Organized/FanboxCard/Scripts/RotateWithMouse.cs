using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateWithMouse : MonoBehaviour
{
    [SerializeField] private Transform Target;

    [SerializeField, Range(0, 100)] private float rotateScalar = 10.0f;

    [SerializeField] private bool isRevertX = true;

    [SerializeField] private bool isRevertY = true;

    [SerializeField] private Material material;

    void Update()
    {
        var position = new Vector3 (
            (Input.mousePosition.y / Screen.height - 0.5f),
            0.0f,
            (Input.mousePosition.x / Screen.width - 0.5f)
        );

        if (isRevertX) {
            position.z *= -1;
        }

        if (isRevertY) {
            position.x *= -1;
        }

        Target.localRotation = Quaternion.Euler(position * rotateScalar);
        
        material.SetFloat("_Displacement", position.magnitude);
    }
}
