Shader "Hidden/Motion Blur With Depth Texture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurSize ("Blur Size", float) = 1.0
	}
	SubShader
	{
		CGINCLUDE
		
		#include "UnityCG.cginc"

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float2 uv_depth : TEXCOORD1;
			float4 pos : SV_POSITION;
		};
	
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		half _BlurSize;
		float4x4 _CurrentViewProjectionInverseMatrix;
		float4x4 _PreviousViewProjectionMatrix;
		
		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;

			#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y < 0.0)
				o.uv_depth.y = 1.0 - o.uv_depth.y;
			#endif

			return o;
		}

		fixed4 frag(v2f i) : SV_Target 
		{
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
			
			// viewport position at this pixel in the range -1 to 1
			float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
			// Transform by view-projection inverse
			float4 D = mul(_CurrentViewProjectionInverseMatrix, H);

			float4 worldPos = D / D.w;

			// current viewport position
			float4 currentPos = H;

			float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
			previousPos /= previousPos.w;

			float2 velocity = (currentPos.xy - previousPos.xy) / 2.0f;

			float2 uv = i.uv;
			float4 c = tex2D(_MainTex, uv);

			for(int it = 1; it < 3; ++it, uv += velocity * _BlurSize)
			{
				float4 currentColor = tex2D(_MainTex, uv);
				c += currentColor;
			}

			c/=3;
			return fixed4(c.rgb, 1.0);
		}

		ENDCG

		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}

	Fallback Off
}
