using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateWithMouse : MonoBehaviour
{
    [SerializeField, Range(0, 100)] private float rotateScalar = 10.0f;

    [SerializeField] private bool isRevertX = true;

    [SerializeField] private bool isRevertY = true;

    [SerializeField] private Material materialRef;

    [SerializeField] private MeshRenderer cardMesh;

    private Material m_material;

    private Material Material
    {
        get
        {
            if (m_material == null)
            {
                m_material = new Material(materialRef);
                cardMesh.material = m_material;
            }

            return m_material;
        }
    }

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

        cardMesh.transform.localRotation = Quaternion.Euler(position * rotateScalar);

        Material.SetFloat("_Displacement", position.magnitude);
    }
}
