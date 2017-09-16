// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Unity Shaders Book/Chapter 9/Forward Rendering With Shadows" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20	
	}
	
	SubShader
	{
		Pass
		{
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct a2f
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
				fixed3 worldPos : TEXCOORD1;
				SHADOW_COORDS(2)
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (a2f v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				// change to same coodinate system of light direction so that dot is meaningful
				o.worldNormal = mul(v.normal, (float3x3) unity_WorldToObject);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				TRANSFER_SHADOW(o);

				return o;
			}
			
			fixed4 frag (v2f v) : SV_Target
			{
				// assume object does not have emission
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				// normalize until fragment stage
				fixed3 worldNormal = normalize(v.worldNormal);

				// _WorldSpaceLightPos may not able to deal getting info from multiple light in single scene
				// Other method is recommended
				fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 reflectDirection = normalize(reflect(-worldLightDirection, worldNormal));

				fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - v.worldPos.xyz);

				fixed3 halfDirection = normalize(viewDirection + worldLightDirection);

				// use saturate() to mimic "max(0, dot(n, l)"
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDirection));
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDirection)), _Gloss);

				fixed atten = 1.0;

				fixed shadow = SHADOW_ATTENUATION(v);

				fixed3 color = ambient + (diffuse + specular) * atten * shadow;

				return fixed4(color, 1.0);;
			}
			ENDCG
		}

		Pass
		{
			Tags { "LightMode"="ForwardAdd" }
			Blend One One
		
			CGPROGRAM
			#pragma multi_compile_fwdadd
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

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
				// normalize until fragment stage
				fixed3 worldNormal = normalize(i.worldNormal);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif
				
				fixed3 reflectDirection = normalize(reflect(-worldLightDirection, worldNormal));

				fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

				fixed3 halfDirection = normalize(viewDirection + worldLightDirection);

				// use saturate() to mimic "max(0, dot(n, l)"
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDirection));
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDirection)), _Gloss);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
					fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				#endif 

				fixed3 color = (diffuse + specular) * atten;

				return fixed4(color, 1.0);;
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}
