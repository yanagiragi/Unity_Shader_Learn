using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UpdateFocusDistanceUI : MonoBehaviour {

    UnityEngine.UI.Text text;

    public FocusDistanceManger focusDistanceManger;
    public ApproximateBokeh bokeh;
    public DepthOfField dof;

    void Start () {
        text = GetComponent<UnityEngine.UI.Text>();
    }
	
	void LateUpdate () {
        text.text = (dof.enabled ? "Depth Of Field" : "Single Pass Bokeh") + "\nFocus Distance: " + focusDistanceManger.distance;
    }
}
