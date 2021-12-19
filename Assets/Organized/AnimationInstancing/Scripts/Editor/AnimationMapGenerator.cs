using System.Collections.Generic;
using UnityEngine;
using System.Linq;

#if UNITY_EDITOR
using System.IO;
using UnityEditor;
#endif

public class AnimationMapGenerator : EditorWindow
{
    private static GameObject target;
    private static List<AnimationClip> animationClips = new List<AnimationClip>();
    private static int animationClipsCount;

    [MenuItem("Window/AnimationMapGenerator")]
    public static void ShowWindow()
    {
        GetWindow(typeof(AnimationMapGenerator));
    }

    private void OnGUI()
    {
        target = (GameObject)EditorGUILayout.ObjectField(target, typeof(GameObject), true);

        animationClipsCount = EditorGUILayout.IntField("Clip Amount", animationClipsCount);
        if (animationClips != null && animationClips.Count != animationClipsCount)
        {
            Resize(animationClips, animationClipsCount);
        }

        EditorGUI.indentLevel += 1;
        for (int i = 0; i < animationClipsCount; i++)
        {
            animationClips[i] = EditorGUILayout.ObjectField($"Clip {i}", animationClips[i], typeof(AnimationClip), false) as AnimationClip;
        }
        EditorGUI.indentLevel -= 1;

        if (!GUILayout.Button("Bake")) return;
        if (target == null)
        {
            EditorUtility.DisplayDialog("AnimationMapGenerator", "target is not assigned!", "OK");
            return;
        }

        Generate();
    }

    private static void Generate()
    {
        Texture2D animationTexture = new Texture2D(1, 1, TextureFormat.RGBAHalf, false);

        var targetSkinnedMeshRenderers = target.GetComponentsInChildren<SkinnedMeshRenderer>();

        foreach (var clip in animationClips)
        {
            Debug.Log(clip);
            for (var j = 0; j < targetSkinnedMeshRenderers.Length; ++j)
            {
                var targetSkinnedMeshRenderer = targetSkinnedMeshRenderers[j];

                var progress = (float)(j + 1) / (float)targetSkinnedMeshRenderers.Length;
                var isCanceled = EditorUtility.DisplayCancelableProgressBar($"Baking Animation ...", $"Start Baking {j + 1} skinnedMesh - [{targetSkinnedMeshRenderer.name}]", progress);
                if (isCanceled)
                {
                    break;
                }

                PrepareAnimationTexture(ref animationTexture, target, clip, targetSkinnedMeshRenderer, $"{j + 1} / {targetSkinnedMeshRenderers.Length} ...");
                var localAssetPath = Path.Combine("Assets", "_Wip", "AnimationInstancing", "AnimationMaps", $"{clip.name}_{target.name}_{targetSkinnedMeshRenderer.name}.asset");

                // Save as Raw Image
                AssetDatabase.CreateAsset(animationTexture, localAssetPath);
            }
        }

        AssetDatabase.Refresh();
        EditorUtility.ClearProgressBar();
    }

    private static void PrepareAnimationTexture(ref Texture2D animationTexture, GameObject gameObject, AnimationClip clip, SkinnedMeshRenderer skinnedMeshRenderer, string additionInfo = "")
    {
        var animationLength = clip.length;
        var frameRate = clip.frameRate;
        var frameCount = Mathf.ClosestPowerOfTwo((int)(animationLength * frameRate));
        var vertexCount = Mathf.ClosestPowerOfTwo((int)(skinnedMeshRenderer.sharedMesh.vertexCount));
        
        var bakedMesh = new Mesh();

        animationTexture = new Texture2D(vertexCount, frameCount, TextureFormat.RGBAHalf, false);

        for (var frame = 0; frame < frameCount; ++frame)
        {
            var progress = (float)(frame + 1) / (float)frameCount;
            var isCanceled = EditorUtility.DisplayCancelableProgressBar($"Baking Animation {additionInfo}", $"Baking [{skinnedMeshRenderer.name}] - {frame} / {frameCount} frame ...", progress);
            if (isCanceled)
            {
                break;
            }

            var time = frame / frameRate;
            clip.SampleAnimation(gameObject, time);

            skinnedMeshRenderer.BakeMesh(bakedMesh);

            for (int i = 0; i < bakedMesh.vertexCount; i++)
            {
                Vector3 vertex = bakedMesh.vertices[i];
                animationTexture.SetPixel(i, frame, new Color(vertex.x, vertex.y, vertex.z));
            }
        }

        animationTexture.Apply();        
        EditorUtility.ClearProgressBar();
    }

    private static void Resize<T>(List<T> list, int sz, T c)
    {
        int cur = list.Count;
        if (sz < cur)
            list.RemoveRange(sz, cur - sz);
        else if (sz > cur)
        {
            if (sz > list.Capacity)//this bit is purely an optimisation, to avoid multiple automatic capacity changes.
                list.Capacity = sz;
            list.AddRange(Enumerable.Repeat(c, sz - cur));
        }
    }

    private static void Resize<T>(List<T> list, int sz) where T : new()
    {
        Resize(list, sz, new T());
    }
}
