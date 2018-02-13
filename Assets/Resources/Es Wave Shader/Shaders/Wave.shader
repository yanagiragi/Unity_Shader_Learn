Shader "Custom/Wave"
{
	Properties
	{
		_InputTex ("Texture", 2D) = "black" {}
		_PrevTex ("Prev Texture", 2D) = "black" {}
		_Prev2Tex ("Prev2 Texture", 2D) = "black" {}
		_RoundAdjuster ("Adjuster", float) = 0
		_Stride ("Stride", float) = 0.5
		_Attenuation ("Attenuation", float) = 0.96
		_C ("C", float) = 0.1
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

			sampler2D _InputTex;
			sampler2D _PrevTex;
			float4 _PrevTex_TexelSize;
			sampler2D _Prev2Tex;
			float _RoundAdjuster;
			float _Stride;
			float _Attenuation;
			float _C;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// Solve 波動方程式
				
				// stride = (DeltaX, DeltaY)
				float2 stride = float2(_Stride, _Stride) * _PrevTex_TexelSize.xy;
				
				// map r(波の高さ) from [-1 ~ 1] to [0 ~ 1]
				half4 prev =( tex2D(_PrevTex, i.uv) * 2) - 1;

				half value = 
					(prev.r * 2 -
						(tex2D(_Prev2Tex, i.uv).r * 2 - 1) + (
						(tex2D(_PrevTex, half2(i.uv.x + stride.x, i.uv.y)).r * 2 - 1) + 
						(tex2D(_PrevTex, half2(i.uv.x - stride.x, i.uv.y)).r * 2 - 1) + 
						(tex2D(_PrevTex, half2(i.uv.x, i.uv.y + stride.y)).r * 2 - 1) + 
						(tex2D(_PrevTex, half2(i.uv.x, i.uv.y - stride.y)).r * 2 - 1) -
						prev.r * 4) * 
					_C);

				float4 input = tex2D(_InputTex, i.uv);

				value += input.r;
				value *= _Attenuation;
				value = (value + 1) * 0.5;
				value += _RoundAdjuster * 0.01;
				
				return fixed4(value, 0, 0, 1);
			}
			ENDCG
		}
	}
}
