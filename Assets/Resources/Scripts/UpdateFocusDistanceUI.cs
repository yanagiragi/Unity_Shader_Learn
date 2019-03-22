using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdateFocusDistanceUI : MonoBehaviour {

    UnityEngine.UI.Text text;

    public FocusDistanceManger focusDistanceManger;

    void Start () {
        text = GetComponent<UnityEngine.UI.Text>();
    }
	
	void LateUpdate () {
        text.text = "Focus Distance: " + focusDistanceManger.distance;
    }
}
