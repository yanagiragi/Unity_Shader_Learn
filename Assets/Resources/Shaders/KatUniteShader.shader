// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Tutorals from
// "Unite Europe 2016 - A Crash Course to Writing Custom Unity Shaders!"

Shader "Custom/KatUniteShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color (RGBA)", COLOR) = (255, 255, 255, 255)

		_DissolveRTexture("Cheese", 2D) = "white" {}
		_DissolveAmmount ("Cheese Cut Out Ammount", Range(0, 1)) = 1

		_ExtrudeAmmount ("Extrude Ammount", Range(-0.1, 0.1)) = 0
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
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _Color;

			sampler2D _DissolveRTexture;
			float _DissolveAmmount;
			
			float _ExtrudeAmmount;

			v2f vert (appdata v)
			{
				v2f o;
				
				// _Time.y stands for actual time
				v.vertex.xyz += v.normal.xyz * _ExtrudeAmmount * sin(_Time.y);

				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv = v.uv;
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float4 dissolveColor = tex2D(_DissolveRTexture, i.uv);

				// kills the current pixel output if any component 
				// of the given vector, or the given scalar, is negative
				clip(dissolveColor.rgb - _DissolveAmmount);
				
				return col * _Color;
			}

			ENDCG
		}
	}
}
