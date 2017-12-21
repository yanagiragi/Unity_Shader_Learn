// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// define USE_SHADOW to Enable Shadow fx
// line 23 & 30 & 115

Shader "Unity Shaders Book/Chapter 10/Custom Reflect"
{
	Properties
	{
		_DiffuseColor("Diffuse Color Tint", Color) = (1,1,1,1)
		_SpecularColor("Specular Color Tint", Color) = (1,1,1,1)
		_ReflectColor("Reflect Color", Color) = (1,1,1,1)
		_ReflectAmount("Reflect Amount", Range(0,1)) = 1
		_Cubemap("Reflection CubeMap", Cube) = "_Skybox" {}
		_Gloss("Gloss", Range(8.0, 256)) = 20
	}
	
	SubShader
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

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
				float3 worldNormal : TEXCOORD0;
				float3 worldRefl : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			float4 _DiffuseColor;
			float4 _SpecularColor;
			float _Gloss;
			float4 _ReflectColor;
			fixed _ReflectAmount;
			samplerCUBE _Cubemap;

			v2f vert(a2f v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefl = reflect(-worldViewDir, o.worldNormal);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f v) : SV_Target
			{
				fixed3 worldNormal = normalize(v.worldNormal);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz - v.worldPos.xyz);
				#endif

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * saturate(dot(worldNormal, worldLightDirection));

				fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - v.worldPos.xyz);

				fixed3 halfDirection = normalize(viewDirection + worldLightDirection);

				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(saturate(dot(worldNormal, halfDirection)), _Gloss);

				fixed3 reflection = texCUBE(_Cubemap, v.worldRefl).rgb * _ReflectColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten, v, v.worldPos);

				fixed3 color;

				color = ambient + lerp((diffuse + specular), reflection, _ReflectAmount) * atten;

				return fixed4(color, 1.0);;
			}

			ENDCG
		}

		Pass
		{
			Tags{ "LightMode" = "ForwardAdd" }
			Blend One One
			
			CGPROGRAM
			#pragma multi_compile_fwdadd_fullshadows
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
				float3 worldNormal : TEXCOORD0;
				float3 worldRefl : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			float _Gloss;
			float4 _DiffuseColor;
			float4 _SpecularColor;
			float4 _ReflectColor;
			fixed _ReflectAmount;
			samplerCUBE _Cubemap;

			v2f vert(a2f v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefl = reflect(-worldViewDir, o.worldNormal);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f v) : SV_Target
			{
				fixed3 worldNormal = normalize(v.worldNormal);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz - v.worldPos.xyz);
				#endif

				float3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * saturate(dot(worldNormal, worldLightDirection));

				fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - v.worldPos.xyz);

				fixed3 halfDirection = normalize(viewDirection + worldLightDirection);

				fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(saturate(dot(worldNormal, halfDirection)), _Gloss);

				fixed3 reflection = texCUBE(_Cubemap, v.worldRefl).rgb * _ReflectColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten, v, v.worldPos);

				fixed3 color = diffuse * lerp(specular, reflection, _ReflectAmount) * atten;

				return fixed4(color, 1.0);

			}

			ENDCG
		}

	}

	Fallback "Diffuse"
}
