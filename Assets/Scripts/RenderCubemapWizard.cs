
// C#
// Editor Script that lets you "Select" all the GameObjects that have a certain Component.
//编辑器脚本让你"Select"所有带有一定组件的游戏物体，
using UnityEngine;
using UnityEditor;
using System.Collections;

public class RenderCubemapWizard : ScriptableWizard {
	public Transform renderFrom;
	public Cubemap cubemap;

	[MenuItem ("Wizard/Render Cubemap")]
	public static void SelectAllOfTypeMenuIem() {
		ScriptableWizard.DisplayWizard(
			"Select objects of type ...",
			typeof(RenderCubemapWizard),
			"Select");
	}

	void OnWizardCreate() {
		GameObject go = new GameObject("CubeMapCamera");
		go.AddComponent<Camera> ();
		go.transform.position = renderFrom.position;
		go.GetComponent<Camera> ().RenderToCubemap (cubemap);
		DestroyImmediate (go); 
	}
}
