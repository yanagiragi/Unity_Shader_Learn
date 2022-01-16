﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoFBokehDemo : MonoBehaviour
{
    public FocusDistanceManger focalManager;
    public Material BlueMaterial;
    public Material RedMaterial;

    public ApproximateBokeh bokeh;
    public DepthOfField dof;

    public Camera mainCam;

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = mainCam.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit)) {

                StartCoroutine(ClickAnim(hit.collider.gameObject));

                float distance = hit.collider.gameObject.transform.position.z - transform.position.z;
                focalManager.distance = distance;
            }
        }
    }

    IEnumerator ClickAnim(GameObject g)
    {
        g.GetComponent<Renderer>().material = RedMaterial;
        yield return new WaitForSeconds(.2f);
        g.GetComponent<Renderer>().material = BlueMaterial;
    }

    public void Swap()
    {
        if (bokeh.enabled)
        {
            dof.enabled = true;
            bokeh.enabled = false;
        }
        else
        {
            dof.enabled = false;
            bokeh.enabled = true;
        }
    }
}
