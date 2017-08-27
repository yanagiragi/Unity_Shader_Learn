Shader "Custom/Mosaic Shader (Image Effects)"
{
	Properties
	{
		_PixelSize("Pixel Size", Range(0.0, 1.0)) = 0.021
	}
	SubShader
	{
		Tags { "Queue" = "Transparent+1" }
		GrabPass {}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed4 uv : TEXCOORD0;
			};

			sampler2D _GrabTexture;
			float _PixelSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = ComputeGrabScreenPos(o.vertex);				
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 uv = i.uv;

				if(_PixelSize != 0)
				{
					uv.xy = fixed2((int)(uv.x / _PixelSize), (int)(uv.y / _PixelSize)) * _PixelSize;
				}

				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(uv));
				
				return col;
			}
			ENDCG
		}
	}
}
