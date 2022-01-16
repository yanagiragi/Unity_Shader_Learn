// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/DepthOfField"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
	
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		UsePass "Hidden/Gaussian Blur/GAUSSIAN_BLUR_VERTICAL"

		UsePass "Hidden/Gaussian Blur/GAUSSIAN_BLUR_HORIZONTAL"

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
			half4 _MainTex_TexelSize;
			sampler2D _CameraDepthTexture;

			uniform sampler2D _BlurTex;
			half4 _BlurTex_TexelSize;

			uniform float _FocalDistance;
			uniform float _NearBlurScale;
			uniform float _FarBlurScale;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0.0)
					o.uv.y = 1.0 - o.uv.y;
				#endif
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				half2 uv = i.uv;
				
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
				float linearDepth = Linear01Depth(d);

				fixed4 originColor = tex2D(_MainTex, uv);
				fixed4 blurColor = tex2D(_BlurTex, uv);

				// blur distance far than focal
				fixed4 col = linearDepth <= _FocalDistance ? originColor : lerp(originColor, blurColor, clamp((linearDepth - _FocalDistance) * _FarBlurScale, 0, 1));
				// blur distance near than focal
				col = linearDepth > _FocalDistance ? col : lerp(originColor, blurColor, clamp((_FocalDistance - linearDepth) * _NearBlurScale, 0, 1));
				
				return col;
			}
			ENDCG
		}
	}
}
