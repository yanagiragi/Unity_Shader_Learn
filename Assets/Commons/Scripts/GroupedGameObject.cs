using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GroupedGameObject : MonoBehaviour
{
    [SerializeField] private Vector3 spacing;
    [SerializeField] private Transform[] children;

    public void OnValidate()
    {
        for(int i = 0; i < children.Length; ++i)
        {
            var pos = transform.position + spacing * i;
            children[i].position = pos;
        }
    }
}
