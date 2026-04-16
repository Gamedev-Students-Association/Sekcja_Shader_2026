using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ImageEffectGate : MonoBehaviour
{
    [SerializeField]
    private Material EffectMat;

	private void Start()
	{
		Camera.main.depthTextureMode = DepthTextureMode.Depth;
	}
	void OnRenderImage(RenderTexture ScreenImage, RenderTexture Destination)
    {

        Graphics.Blit(ScreenImage, Destination, EffectMat);
    }
}
