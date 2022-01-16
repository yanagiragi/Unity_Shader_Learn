﻿Shader "Custom/Mosaic Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PixelSize("Pixel Size", Range(0.0, 1.0)) = 0.021
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _PixelSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				if(_PixelSize != 0)
					i.uv = fixed2((int)(i.uv.x / _PixelSize), (int)(i.uv.y / _PixelSize)) * _PixelSize;

				fixed4 col = tex2D(_MainTex, i.uv);
				
				return col;
			}
			ENDCG
		}
	}
}
