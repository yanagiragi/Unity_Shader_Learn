Shader "Custom/ReflectPlane"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_ReflTex ("Reflection Texture", 2D) = "white" {}
		_BumpMap ("Bump Map", 2D) = "bump" {}
		_BumpAmp("Bump Amplitude", Range(0,9999)) = 0
		_WaveTex("Wave",2D) = "gray" {}
		_ParallaxScale ("Parallax Scale", float) = 1
		_NormalScaleFactor("Normal Scale Factor", float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		LOD 100

		ZWrite On
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha

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
				float4 refl : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _ReflTex;
			float4 _ReflTex_ST;
			float4 _ReflTex_TexelSize;
			float4x4 _ReflM;
			float4x4 _ReflVP;
			sampler2D _BumpMap;
			float _BumpAmp;
			sampler2D _WaveTex;
			float4 _WaveTex_TexelSize;
			float _ParallaxScale;
			float _NormalScaleFactor;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.refl = mul(_ReflVP, mul(_ReflM, v.vertex));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 bump = UnpackNormal(tex2D(_BumpMap, i.uv + _Time.x / 2)).rg;

				// add bump due to result from waveTex
				float2 ShiftX = { _WaveTex_TexelSize.x, 0 };
				float2 ShiftZ = { 0, _WaveTex_TexelSize.y };
				ShiftX *= _ParallaxScale * _NormalScaleFactor;
				ShiftZ *= _ParallaxScale * _NormalScaleFactor;
				float3 texX = 2 * tex2Dlod(_WaveTex, float4(i.uv.xy + ShiftX, 0, 0)) - 1;
				float3 texx = 2 * tex2Dlod(_WaveTex, float4(i.uv.xy - ShiftX, 0, 0)) - 1;
				float3 texZ = 2 * tex2Dlod(_WaveTex, float4(i.uv.xy + ShiftZ, 0, 0)) - 1;
				float3 texz = 2 * tex2Dlod(_WaveTex, float4(i.uv.xy - ShiftZ, 0, 0)) - 1;
				float3 du = { 1, 0, _NormalScaleFactor * (texX.x - texx.x) };
				float3 dv = { 0, 1, _NormalScaleFactor * (texZ.x - texz.x) };
				bump += normalize(cross(du, dv));

				float2 offset = bump * _BumpAmp * _ReflTex_TexelSize;
				float4 refl = i.refl;
				refl.xy = offset * refl.z + refl.xy;

				float3 reflColor = tex2D(_ReflTex, refl.xy / refl.w * 0.5 + 0.5).rgb;

				return fixed4(reflColor, 1.0);
			}
			ENDCG
		}
	}
}
