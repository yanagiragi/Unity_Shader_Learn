using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MenuButtonGenerator : MonoBehaviour {

    public Transform canvas;
    public GameObject buttonPrefab;
    public HideMenuButtons hideButton;
    public float yPositionInc;
    public float yPositionLimit;
    public float xOffsetInc;
    

    private void Awake()
    {
        DontDestroyOnLoad(canvas.gameObject);
        hideButton.gameObject.SetActive(false);

        int sceneCount = UnityEngine.SceneManagement.SceneManager.sceneCountInBuildSettings;
        float xOffset = 0;
        int yOffset = 0;

        // 0 for MenuScene
        for (int i = 1; i < sceneCount; ++i)
        {
            GameObject g = GameObject.Instantiate(buttonPrefab, canvas, false);
            RectTransform trans = g.GetComponent<RectTransform>();
            trans.position = new Vector3(trans.position.x + xOffset, yPositionInc * yOffset + 15, 0);
            
            yOffset++;
            if (yOffset * yPositionInc > yPositionLimit)
            {
                yOffset = 0;
                xOffset += xOffsetInc;
            }

            string scenePath = UnityEngine.SceneManagement.SceneUtility.GetScenePathByBuildIndex(i);
            string sceneName = scenePath.Substring(scenePath.LastIndexOf("/") + 1, scenePath.Length - scenePath.LastIndexOf("/") - 1 - ".unity".Length);

            UnityEngine.UI.Button btn = g.GetComponent<UnityEngine.UI.Button>();
            btn.GetComponentInChildren<UnityEngine.UI.Text>().text = sceneName;

            btn.GetComponent<ChangeScene>().sceneName = sceneName;

            hideButton.btnList.Add(btn);

        }

        hideButton.gameObject.SetActive(true);
    }
    
}
