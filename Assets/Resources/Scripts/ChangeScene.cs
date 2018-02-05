using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeScene : MonoBehaviour {
    public string sceneName;

    public void click()
    {
        UnityEngine.SceneManagement.SceneManager.LoadSceneAsync(sceneName);

        GameObject Canvas = GameObject.Find("MenuCanvas");

        if (Canvas.GetComponentInChildren<UnityEngine.UI.Image>().enabled)
            Canvas.GetComponentInChildren<UnityEngine.UI.Image>().enabled = false;
        UnityEngine.UI.Text[] txt = Canvas.GetComponentsInChildren<UnityEngine.UI.Text>();
        for(int i = 0; i < 2; ++i)
            if(txt[i].enabled)
                txt[i].enabled = false;
    }

}
