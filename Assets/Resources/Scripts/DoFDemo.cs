using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoFDemo : MonoBehaviour
{
    public Material BlueMaterial;
    public Material RedMaterial;

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            Ray ray = GetComponent<Camera>().ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit)) {

                StartCoroutine(ClickAnim(hit.collider.gameObject));

                DepthOfField dof = GetComponent<DepthOfField>();
                if (dof) {
                    float distance = hit.collider.gameObject.transform.position.z - transform.position.z;
                    dof.focalDistance = distance;
                }
            }
        }
    }

    IEnumerator ClickAnim(GameObject g)
    {
        g.GetComponent<Renderer>().material = RedMaterial;
        yield return new WaitForSeconds(.2f);
        g.GetComponent<Renderer>().material = BlueMaterial;
    }
}
