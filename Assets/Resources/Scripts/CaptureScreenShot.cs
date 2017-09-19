using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class CaptureScreenShot : MonoBehaviour {

	public int superSize = 1;

	void Update () {

		/*
		*  if you want to use printScreen as well, you may check:
		*  http://answers.unity3d.com/questions/581347/inputgetkeydownkeycodeprint-doesnt-work.html
		*/

		if (Input.GetKeyDown (KeyCode.P)) {
			string filename = Time.time.ToString().Replace(".","");

			while (File.Exists (filename + ".png")) {
				filename = (float.Parse (filename) + 1.0).ToString ();
			}

			filename += ".png";
			Debug.Log (string.Format("Capture ScreenShot {0}", filename));
			Application.CaptureScreenshot (filename, superSize);
		}
	}
}
