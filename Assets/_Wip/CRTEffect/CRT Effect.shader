Shader "Custom/CRT Effect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Noise Map", 2D) = "white" {}
		_NoiseXSpeed ("Noise X Speed", Float) = 100.0
        _NoiseYSpeed ("Noise Y Speed", Float) = 100.0
        _NoiseCutoff ("Noise Cutoff", Range(0, 1.0)) = 0
		_LineTex ("Line Texture", 2D) = "white" {}
		_LineColor ("Line Color", Color) = (1,1,1,1)
		_LineScrollSpeed ("Line Scroll Speed", float) = 0.1
		_VignetteTex ("Vignette Texture", 2D) = "white" {}
		_DistortionSrength ("Distortion Srength", Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Blend SrcAlpha OneMinusSrcAlpha

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
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _NoiseTex;
			sampler2D _LineTex;
			sampler2D _VignetteTex;
			float4 _LineColor;
			float _NoiseXSpeed;
			float _NoiseYSpeed;
			float _NoiseCutoff;
			float _LineScrollSpeed;
			float _DistortionSrength;

			fixed2 LenDistortion(fixed2 uv)
			{
				// map uv to [-1,1]
				fixed2 center = (uv - 0.5) * 2;
				float r2 = dot(center, center);
				float ratio = 1 + r2 * (_DistortionSrength + sqrt(r2));

				return ratio * center / 2 + 0.5;

				// However, this will do same trick
				// fixed2 center = (uv - 0.5);
				// ... do same thing
				// return ratio * center + 0.5;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed2 distortionUV = LenDistortion(i.uv);
				
				fixed4 col = tex2D(_MainTex, distortionUV);
				
				fixed2 noiseUV = distortionUV + fixed2(_NoiseXSpeed, _NoiseYSpeed) * _SinTime.z;
				float4 noiseColor = tex2D(_NoiseTex, noiseUV);
				if(noiseColor.r < _NoiseCutoff){
					noiseColor = float4(1,1,1,1);
				}

				fixed2 lineUV = distortionUV;
				lineUV.y = lineUV.y + (_Time.y % 10) * _LineScrollSpeed;
				fixed4 lineColor = tex2D(_LineTex, lineUV) * _LineColor;

				col *= noiseColor;

				col += lineColor * noiseColor;

				fixed4 vignetteColor = tex2D(_VignetteTex, i.uv);
				
				col *= vignetteColor;
				
				return col;
			}
			ENDCG
		}
	}
}
