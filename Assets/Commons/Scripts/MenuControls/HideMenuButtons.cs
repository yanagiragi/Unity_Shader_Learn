using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HideMenuButtons : MonoBehaviour {
    public List<UnityEngine.UI.Button> btnList = new List<UnityEngine.UI.Button>();

    public void click () {
        btnList.ForEach(x => x.gameObject.SetActive(!x.gameObject.activeSelf));
	}
}
