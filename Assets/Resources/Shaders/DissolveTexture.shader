// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Tutorals from
// "Unite Europe 2016 - A Crash Course to Writing Custom Unity Shaders!"

Shader "Custom/DissoveTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SecondaryTex ("Texture", 2D) = "white" {}
		_Color ("Color (RGBA)", COLOR) = (255, 255, 255, 255)

		_DissolveTexture("Dissolve Map", 2D) = "white" {}
		_DissolveAmmount ("Dissolve Cut Out Ammount", Range(0, 1)) = 1

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
			sampler2D _SecondaryTex;
			float4 _Color;

			sampler2D _DissolveTexture;
			float _DissolveAmmount;
			
			float _ExtrudeAmmount;

			v2f vert (appdata v)
			{
				v2f o;
				
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv = v.uv;
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 mainTex = tex2D(_MainTex, i.uv);
				fixed4 secTex = tex2D(_SecondaryTex, i.uv);
				float4 dissolveColor = tex2D(_DissolveTexture, i.uv);

				float4 col = mainTex;
				if(distance(normalize(mainTex.rgb), normalize(dissolveColor.rgb)) > _DissolveAmmount)
					col = secTex;
				else
					;
				return col;
			}

			ENDCG
		}
	}
}
