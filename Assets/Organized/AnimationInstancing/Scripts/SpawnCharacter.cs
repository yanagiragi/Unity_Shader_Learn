using UnityEngine;
using System.Linq;

public class SpawnCharacter : MonoBehaviour
{
    [SerializeField] private bool useAnimationInstancing;
    [SerializeField] private GameObject baseGameObject;

    [SerializeField] private int amount;
    [SerializeField] private float gapDistance;

    void Start()
    {
        Spawn(baseGameObject, amount, new Vector3(gapDistance, 0, gapDistance));
    }

    private void Spawn(GameObject baseGameObject, int amount, Vector3 gapDistance)
    {
        var materials = baseGameObject.GetComponentsInChildren<SkinnedMeshRenderer>().Select(el => el.sharedMaterials).SelectMany(el => el);
        foreach (var material in materials)
        {
            if (useAnimationInstancing)
            {
                material.EnableKeyword("_USEINSTANCING_ON");
            }
            else
            {
                material.DisableKeyword("_USEINSTANCING_ON");
            }
        }

        var animation = baseGameObject.GetComponent<Animator>();
        animation.enabled = !useAnimationInstancing;

        for (var i = 0; i < amount; ++i)
        {
            for (var j = 0; j < amount; ++j)
            {
                var position = new Vector3(gapDistance.x * i, gapDistance.y, gapDistance.z * j);
                var gameObject = Instantiate(baseGameObject, position, Quaternion.identity, null);
            }
        }
    }
}
