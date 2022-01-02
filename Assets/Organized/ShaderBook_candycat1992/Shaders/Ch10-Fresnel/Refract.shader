// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 10/Refract"
{
	Properties
	{
		//_MainTex ("Texture", 2D) = "white" {}
		_Color("Color Tint", Color) = (1,1,1,1)
		_RefractColor("Refract Color", Color) = (1,1,1,1)
		_RefractAmount("Refract Amount", Range(0,1)) = 1
		_RefractRatio ("Refraction Ratio", Range(0.1, 1)) = 0.5
		_Cubemap("Reflection CubeMap", Cube) = "_Skybox" {}
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
				float3 worldRefr : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(4)
			};

			float4 _Color;
			float4 _RefractColor;
			fixed _RefractAmount;
			fixed _RefractRatio;
			samplerCUBE _Cubemap;

			v2f vert(a2f v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefr = refract(-normalize(worldViewDir), normalize(o.worldNormal), _RefractRatio);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f v) : SV_Target
			{
				fixed3 worldNormal = normalize(v.worldNormal);

				fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDirection));

				fixed3 refraction = texCUBE(_Cubemap, v.worldRefr).rgb * _RefractColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten, v, v.worldPos);

				fixed shadow = SHADOW_ATTENUATION(v);

				fixed3 color;

				// Original Version cannot deal lightning
				color = ambient + lerp(diffuse, refraction, _RefractAmount);

				//color = ambient + diffuse * lerp(diffuse, refraction, _RefractAmount) * atten;

				return fixed4(color, 1.0);;
			}

			ENDCG
		}

		/*Pass
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

				fixed3 color = lerp(diffuse, reflection, _ReflectAmount) * atten;

				color = diffuse * lerp(diffuse, reflection, _ReflectAmount) * atten;

				return fixed4(color, 1.0);
			}

			ENDCG
		}*/
	}

	Fallback "VertexLit"
}
