Shader "Hidden/DepthMap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				
				#if UNITY_UV_STARTS_AT_TOP
				if(_MainTex_TexelSize.y < 0.0)
					o.uv.y = 1.0 - o.uv.y;
				#endif
				return o;
			}
			
		

			fixed4 frag (v2f i) : SV_Target
			{
				half2 uv = i.uv;
				//uv.y = 1- uv.y;
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
				float linearDepth = Linear01Depth(d);
				fixed4 col = fixed4(linearDepth, linearDepth, linearDepth, 1.0);
				return col;
			}
			ENDCG
		}
	}
}
