// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Fog With Depth Noise"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FogDensity("Fog Density", float) = 1.0
		_FogColor("Fog Color", Color) = (1,1,1,1)
		_FogStart("Fog Start", float) = 0.0
		_FogEnd("Fog End", float) = 1.0
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_FogXSpeed("Fog Horizontal Speed", float) = 0.1
		_FogYSpeed("Fog Vertical Speed", float) = 0.1
		_NoiseAmount("Noise Amount", float) = 1
	}
	SubShader
	{
		CGINCLUDE
		
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		fixed4 _FogColor;
		float _FogDensity;
		float _FogStart;
		float _FogEnd;
		float4x4 _FrustumCornersRay;
		sampler2D _CameraDepthTexture;
		sampler2D _NoiseTex;
		fixed _FogXSpeed;
		fixed _FogYSpeed;
		float _NoiseAmount;

		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
			float4 interpolatedRay : TEXCOORD2;
		};

		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;

			#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y < 0.0)
				o.uv_depth.y = 1.0 - o.uv_depth.y;
			#endif
			
			int index = 0;
			
			if(v.texcoord.x < 0.5 && v.texcoord.y < 0.5){
				index = 0;
			}			
			else if(v.texcoord.x > 0.5 && v.texcoord.y < 0.5){
				index = 1;
			}
			else if(v.texcoord.x > 0.5 && v.texcoord.y > 0.5){
				index = 2;
			}
			else{
				index = 3;
			}

			#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y < 0.0)
				index = 3 - index;
			#endif

			o.interpolatedRay = _FrustumCornersRay[index];
			
			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth));

			float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

			half2 speed = _Time.y * float2(_FogXSpeed, _FogYSpeed);
			float noise = (tex2D(_NoiseTex, i.uv + speed).r - 0.5) * _NoiseAmount;

			float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
			fogDensity = saturate(fogDensity * _FogDensity * (1 + noise));

			fixed4 finalColor = tex2D(_MainTex, i.uv);
			finalColor.rgb = lerp(finalColor.rgb, _FogColor.rgb, fogDensity);

			return finalColor;
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
