﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 6/Specular Vertex-Level" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
		
	}
	
	SubShader
	{
		Tags { "LightMode"="ForwardBase" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				fixed3 color : COLOR;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// change to same coodinate system of light direction so that dot is meaningful
				fixed3 worldNormal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));

				// _WorldSpaceLightPos may not able to deal getting info from multiple light in single scene
				// Other method is recommended
				fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 worldReflect = normalize(reflect(-worldLightDirection, worldNormal));

				fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);

				// use saturate() to mimic "max(0, dot(n, l)"
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDirection));
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(viewDirection, worldReflect)), _Gloss);

				o.color = ambient + diffuse + specular;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = fixed4(i.color, 1.0);
				return col;
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}
