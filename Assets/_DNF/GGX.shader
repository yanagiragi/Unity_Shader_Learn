// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/GGX" {
	// non-linear calculate specular
	Properties {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Roughness ("Roughness", Range(8.0, 256)) = 20
        _F0 ("F0", Range(8.0, 256)) = 20
		
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
			float _Roughness;
            float _F0;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				// change to same coodinate system of light direction so that dot is meaningful
				o.worldNormal = mul(v.normal, (float3x3) unity_WorldToObject);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                float alpha = _Roughness * _Roughness;
                float alphaSqr = alpha * alpha;
                				
				// normalize until fragment stage
				fixed3 worldNormal = normalize(i.worldNormal);
                
				// _WorldSpaceLightPos may not able to deal getting info from multiple light in single scene
				// Other method is recommended
				fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

				fixed3 halfDirection = normalize(worldLightDirection - viewDirection);

                float dotLH = saturate(dot(halfDirection, worldLightDirection));
                float dotNH = saturate(dot(worldNormal, halfDirection));
                float dotNL = saturate(dot(worldNormal, worldLightDirection));

                float denom = dotNH * dotNH * (alphaSqr - 1.0) + 1.0;
                float D = alphaSqr / (3.141592653589793 * denom * denom);
                float F = _F0 + (1.0 - _F0) * pow(1.0 - dotLH, 5.0);                
                float k = alpha * 0.5;
                float kSqr = k * k;

				// use saturate() to mimic "max(0, dot(n, l)"
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDirection));
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * (dotNL * D * F / (dotLH * dotLH * (1.0 - kSqr) + kSqr));

				fixed3 color = ambient + diffuse + specular;

				return fixed4(color, 1.0);;
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}
