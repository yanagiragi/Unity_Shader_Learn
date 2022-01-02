using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeCamera : MonoBehaviour {
    public List<Camera> cameraList = new List<Camera>();

    private int index = 0;

    public void click () {
        cameraList[index].gameObject.SetActive(false);

        if (++index >= cameraList.Count)
        {
            index = 0;
        }

        cameraList[index].gameObject.SetActive(true);
    }
}
