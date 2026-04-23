using UnityEngine;

[ExecuteInEditMode]
public class ColorPalleteData : MonoBehaviour
{
    [SerializeField]
    protected Material material;

    protected int colorsPropertyID;
    protected int colorsSizePropertyID;

    [SerializeField]
    protected Color[] colors;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        colorsPropertyID = Shader.PropertyToID("_ColorSet");
        colorsSizePropertyID = Shader.PropertyToID("_ColorSetSize");
    }

    // Update is called once per frame
    void Update()
    {
        material.SetColorArray(colorsPropertyID, colors);
        material.SetFloat(colorsSizePropertyID, colors.Length);
    }
}
