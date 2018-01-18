Shader "Hidden/Edge Detect Normals And Depth"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_EdgeOnly ("Edge Only", Range(0, 1)) = 1
		_EdgeColor ("Edge Color", Color) = (0,0,0,1)
		_BackgroundColor ("Background Color", Color) = (1,1,1,1)
		_SampleDistance("Sample Distance", float) = 1
		_Sensitivity("Sensitivity", Vector) = (1,1,1,1)
	}
	SubShader
	{
		CGINCLUDE

		#include "UnityCG.cginc"
		sampler2D _MainTex;
		half2 _MainTex_TexelSize;
		fixed _EdgeOnly;
		fixed4 _EdgeColor;
		fixed4 _BackgroundColor;
		float _SampleDistance;
		float4 _Sensitivity;
		sampler2D _CameraDepthNormalsTexture;

		struct v2f
		{
			half2 uv[5] : TEXCOORD0;
			float4 pos : SV_POSITION;
		};

		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			half2 uv = v.texcoord;
			
			o.uv[0] = uv;

			#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y < 0.0)
				uv.y = 1.0 - uv.y;
			#endif

			o.uv[1] = uv + _MainTex_TexelSize.xy * half2( 1, 1) * _SampleDistance; 
			o.uv[2] = uv + _MainTex_TexelSize.xy * half2(-1,-1) * _SampleDistance; 
			o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 1) * _SampleDistance; 
			o.uv[4] = uv + _MainTex_TexelSize.xy * half2( 1,-1) * _SampleDistance; 

			return o;
		}

		half CheckSame(half4 center, half4 sample)
		{
			half2 centerNormal = center.xy;
			float centerDepth = DecodeFloatRG(center.zw);
			half2 sampleNormal = sample.xy;
			float sampleDepth = DecodeFloatRG(sample.zw);

			// no need to decode normal in here
			half2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity.x;
			int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;

			half2 diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;
			int isSameDepth = diffDepth < 0.1 * centerDepth;

			return isSameNormal * isSameDepth ? 1.0 : 0.0;
		}

		fixed4 fragRobertsCrossDepthAndNormal(v2f i) : SV_Target
		{
			half4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
			half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
			half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
			half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

			half edge = 1.0;

			edge *= CheckSame(sample1, sample2);
			edge *= CheckSame(sample3, sample4);

			fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
			fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);

			return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
		}

		ENDCG

		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment fragRobertsCrossDepthAndNormal
			
			ENDCG
		}
	}

	Fallback Off
}
