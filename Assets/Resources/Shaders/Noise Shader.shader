Shader "Custom/NoiseShader"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_NoiseTex ("Noise Map", 2D) = "white" {}
		_Noise_XSpeed("Noise X Speed", Float) = 1.0
		_Noise_YSpeed("Noise X Speed", Float) = 1.0
		_CutOff("CutOff", Range(0, 1)) = 0
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
			sampler2D _NoiseTex;
			float _Noise_XSpeed;
			float _Noise_YSpeed;
			fixed _CutOff;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				
				fixed4 noiseColor = tex2D(_NoiseTex, i.uv.xy + fixed2(_Noise_XSpeed, _Noise_YSpeed) * _SinTime.z);

				if(noiseColor.r > _CutOff){
					noiseColor.a = 0.0;
				}

				return noiseColor * col;
			}
			ENDCG
		}
	}
}
