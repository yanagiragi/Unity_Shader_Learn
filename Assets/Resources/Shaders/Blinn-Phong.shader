// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 6/Blinn-Phong" {
	// non-linear calculate specular
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
				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldPos : TEXCOORD1;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

				// change to same coodinate system of light direction so that dot is meaningful
				o.worldNormal = mul(v.normal, (float3x3) unity_WorldToObject);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				// normalize until fragment stage
				fixed3 worldNormal = normalize(i.worldNormal);

				// _WorldSpaceLightPos may not able to deal getting info from multiple light in single scene
				// Other method is recommended
				fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 reflectDirection = normalize(reflect(-worldLightDirection, worldNormal));

				fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

				fixed3 halfDirection = normalize(viewDirection + worldLightDirection);

				// use saturate() to mimic "max(0, dot(n, l)"
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDirection));
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDirection)), _Gloss);

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color, 1.0);;
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}
