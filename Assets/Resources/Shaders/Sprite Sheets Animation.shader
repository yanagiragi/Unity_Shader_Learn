Shader "Custom/Sprite Sheets Animation"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_XCellAmount ("X Cell Amount", float) = 0.0
		_YCellAmount ("Y Cell Amount", float) = 0.0
    	_Speed ("Speed", Range(0.01, 32)) = 12
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
			float _XCellAmount;  
			float _YCellAmount;  
			float _Speed;  
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			float2 transformUV(float2 uv)
			{
				float XcellUVPercentage = 1.0/_XCellAmount;
				float YcellUVPercentage = 1.0/_YCellAmount;

				float Xtime = floor(fmod(_Time.y * _Speed, _XCellAmount));
				float Ytime = ceil(fmod(_Time.y * _Speed, _XCellAmount * _YCellAmount) / _XCellAmount);

				float x = uv.x + Xtime;
				float y = uv.y - Ytime;
				x *= XcellUVPercentage;
				y *= YcellUVPercentage;

				return float2(x, y);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, transformUV(i.uv));
				return col;
			}
			ENDCG
		}
	}
}
