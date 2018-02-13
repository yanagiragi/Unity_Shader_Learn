using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Es.InkPainter;

public class PointPainter : MonoBehaviour {

    public Brush brush;
    public InkCanvas canvas;

    public int paintTiming = 3;
    private int count = 0;

    private void OnCollisionStay(Collision collision)
    {
        count++;
        if(count >= paintTiming)
        {
            count = 0;
            foreach(var p in collision.contacts)
            {
                var canvas = p.otherCollider.GetComponent<InkCanvas>();
                if (canvas)
                    canvas.Paint(brush, p.point);
            }
        }
    }
}
