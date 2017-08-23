// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 6/Diffuse Pixel-Level" {
	
	Properties {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)		
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
				fixed3 worldNormal : TEXCOORD0;
			};

			fixed4 _Diffuse;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				
				o.worldNormal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// _WorldSpaceLightPos may not able to deal getting info from multiple light in single scene
				// Other method is recommended
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				// use saturate() to mimic "max(0, dot(n, l)"
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal, worldLight));

				fixed3 color3 = ambient + diffuse;

				return fixed4(color3, 1.0);
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}