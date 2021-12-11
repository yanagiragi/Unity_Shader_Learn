// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/TransparentGaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurScale ("Blur Scale", float) = 1.0
	}
	SubShader
	{
		CGINCLUDE

		#include "UnityCG.cginc"
		
		struct v2f
		{
			half2 uv[5] : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};
		
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		float _BlurScale;

		v2f vertBlurVertical(appdata_img v)
		{
			v2f o;

			o.vertex = UnityObjectToClipPos(v.vertex);

			half2 uv = v.texcoord;

			o.uv[0] = uv;
			o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurScale;
			o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurScale;
			o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurScale;
			o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurScale;

			return o;
		}

		v2f vertBlurHorizontal(appdata_img v)
		{
			v2f o;

			o.vertex = UnityObjectToClipPos(v.vertex);

			half2 uv = v.texcoord;

			o.uv[0] = uv;
			o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0) * _BlurScale;
			o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0) * _BlurScale;
			o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0) * _BlurScale;
			o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0) * _BlurScale;

			return o;
		}

		fixed4 fragBlur(v2f i) : SV_Target
		{
			float weight[3] = {0.4026, 0.2442, 0.0545};

			fixed4 sum = tex2D(_MainTex, i.uv[0]).rgba * weight[0];

			float4 orig = tex2D(_MainTex, i.uv[0]);

			for(int it = 1; it < 3; ++it)
			{
				sum += tex2D(_MainTex, i.uv[ it * 2 - 1]).rgba * weight[it];
				sum += tex2D(_MainTex, i.uv[ it * 2]).rgba * weight[it];
			}

			return fixed4(sum);
		}

		float4 fragBlurTrans(v2f i) : SV_Target
		{
			float weight[3] = {0.4026, 0.2442, 0.0545};
			float gamma = 2.2; // no gamma correction since we change the color space to linear in Unity Project Settings

			float4 orig = tex2D(_MainTex, i.uv[0]);
			
			float3 sum = orig.rgb * orig.a * weight[0];
			float alphaSum = orig.a * weight[0];
			float4 temp;

			for(int it = 1; it < 3; ++it)
			{
				temp = tex2D(_MainTex, i.uv[it * 2 - 1]);				
				sum += (temp.rgb * temp.a) * weight[it];
				alphaSum += temp.a * weight[it];
				
				temp = tex2D(_MainTex, i.uv[it * 2]);
				sum += (temp.rgb * temp.a) * weight[it];
				alphaSum += temp.a * weight[it];
			}
			
			sum /= alphaSum;

			return float4(sum, alphaSum);
		}

		ENDCG

		Cull Off ZWrite Off ZTest Always

		Pass
		{
			NAME "GAUSSIAN_BLUR_VERTICAL"
			
			CGPROGRAM
			
			#pragma vertex vertBlurVertical
			#pragma fragment fragBlurTrans
			
			ENDCG
		}

		Pass
		{
			NAME "GAUSSIAN_BLUR_HORIZONTAL"
			
			CGPROGRAM
			
			#pragma vertex vertBlurHorizontal
			#pragma fragment fragBlurTrans
			
			ENDCG
		}
	}

	Fallback Off
}
