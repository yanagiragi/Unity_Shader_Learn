using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ToggleEffect : MonoBehaviour
{
    [SerializeField] private Button button;

    [SerializeField] private MonoBehaviour component;

    private void Start()
    {
        button.onClick.AddListener(Callback);
    }

    private void OnDestroy()
    {
        button.onClick.RemoveListener(Callback);
    }

    private void Callback()
    {
        component.enabled = !component.enabled;
    }
}
