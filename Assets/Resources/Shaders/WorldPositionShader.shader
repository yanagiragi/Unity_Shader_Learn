// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/WorldPositionShader"
{
	Properties
	{
		_StartColor ("Start Color", COLOR) = (1,1,1,1)
		_EndColor ("End Color", COLOR) = (1,1,1,1)
		_GradientBlendAmmount("Gradient Blend Ammount", float) = 1
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
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldPosition : TEXCOORD0;
			};

			float4 _StartColor;
			float4 _EndColor;
			fixed _GradientBlendAmmount;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 col = lerp(_EndColor, _StartColor, i.worldPosition.y * _GradientBlendAmmount);
				
				return col;
			}
			ENDCG
		}
	}
}
