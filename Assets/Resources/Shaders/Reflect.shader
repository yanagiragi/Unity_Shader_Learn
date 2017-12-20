// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// define USE_SHADOW to Enable Shadow fx
// line 23 & 30 & 115

Shader "Unity Shaders Book/Chapter 10/Reflect"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1,1,1,1)
		_ReflectColor ("Reflect Color", Color) = (1,1,1,1)
		_ReflectAmount("Reflect Amount", Range(0,1)) = 1
		_Cubemap("Reflection CubeMap", Cube) = "_Skybox" {}
	}
	SubShader
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			//#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			//#define USE_SHADOW

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
				SHADOW_COORDS(4)
			};

			float4 _Color;
			float4 _ReflectColor;
			fixed _ReflectAmount;
			samplerCUBE _Cubemap;
			
			v2f vert (a2f v)
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
			
			fixed4 frag (v2f v) : SV_Target
			{
				fixed3 worldNormal = normalize(v.worldNormal);
				
				fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDirection));

				fixed3 reflection = texCUBE(_Cubemap, v.worldRefl).rgb * _ReflectColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten, v, v.worldPos);

				fixed3 color;

				// Original Version cannot deal lightning
				#ifdef USE_SHADOW
					color = ambient + diffuse * lerp(diffuse, reflection, _ReflectAmount) * atten;
				#else
					color = ambient + lerp(diffuse, reflection, _ReflectAmount) * atten;
				#endif
				
				
				
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

			//#define USE_SHADOW

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

			float4 _Color;
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
					
				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDirection));

				fixed3 reflection = texCUBE(_Cubemap, v.worldRefl).rgb * _ReflectColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten, v, v.worldPos);

				#ifdef USE_SHADOW
					fixed3 color = diffuse * lerp(diffuse, reflection, _ReflectAmount) * atten;
				#else
					fixed3 color = fixed3(0,0,0);
				#endif

				return fixed4(color, 1.0);

			}
				
			ENDCG
		}

	}
	
	Fallback "Diffuse"
}
