using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//[ExecuteInEditMode]
public class GlareEffects : MonoBehaviour {

    public int tileWidthAmmount = 16;
    public int tileHeightAmmount = 16;
    public Material _material;

    private int _textureWidth = 512;
    private int _textureHeight = 512;
    private int _tileWidth = 32;
    private int _tileHeight = 32;

    private Texture2D _texture;

    public struct glare
    {
        public int x, y;
        public float intensity;

        public glare(int p1, int p2, float a)
        {
            x = p1;
            y = p2;

            intensity = a;
        }
    }

    void Awake()
    {
        _tileWidth = _textureWidth / tileWidthAmmount;
        _tileHeight = _textureHeight / tileHeightAmmount;

        _texture = new Texture2D(_textureWidth, _textureHeight, TextureFormat.RGBA32, false);

        Color[] colors = _texture.GetPixels();
        for (int i = 0; i < colors.Length; ++i)
        {
            colors[i] = Color.white;
        }
        _texture.SetPixels(colors);
        _texture.Apply();

        _material.SetTexture("_MaskTex", _texture);
    }

    private void Update()
    {
        if (Input.GetMouseButton(0))
        {
            InitSplashTexture();
        }
        else if (Input.GetMouseButton(1))
        {
            UpdateSplashTexture();
        }
    }

    void PickPixel()
    {

    }

    void UpdatePixel()
    {

    }

    void CheckPixel()
    {
        // if more pixel should be added
        // for each i to _ShouldAmm
        //      PickPixel();
    }

    void UpdateSplashTexture()
    {
        CheckPixel();

        UpdatePixel();        
    }

    private void UpdateSplashTexture(int x, int y)
    {

    }

    private void InitSplashTexture()
    {
        
        for (int i = 0; i < tileWidthAmmount; ++i)
        {
            for (int j = 0; j < tileHeightAmmount; ++j)
            {
                int x = Random.Range(0, _tileWidth);
                int y = Random.Range(0, _tileHeight);

                Color tmp = new Color(1, 0, 0, Random.Range(0.0f, 1.0f));

                _texture.SetPixel(_tileWidth * i + x, _tileHeight * j + y, tmp);
            }
        }

        _texture.Apply();

    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, _material);
    }
}
