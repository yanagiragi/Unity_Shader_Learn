// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 10/Fresnel"
{
	Properties
	{
		_Color("Color Tint", Color) = (1,1,1,1)
		_FresnelScale ("Fresnel Scale", Range(0.1,1)) = 0.5
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
				float3 worldViewDir : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			float4 _Color;
			fixed _FresnelScale;
			samplerCUBE _Cubemap;

			v2f vert(a2f v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefl = reflect(-o.worldViewDir, o.worldNormal);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f v) : SV_Target
			{
				fixed3 worldNormal = normalize(v.worldNormal);

				fixed3 worldViewDir = normalize(v.worldViewDir);

				fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * saturate(dot(worldNormal, worldLightDirection));

				fixed3 reflection = texCUBE(_Cubemap, v.worldRefl).rgb;

				fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);

				UNITY_LIGHT_ATTENUATION(atten, v, v.worldPos);

				fixed3 color = ambient + lerp(diffuse, reflection, saturate(fresnel)) * atten;
				
				return fixed4(color, 1.0);;
			}

			ENDCG
		}

	}

		Fallback "Diffuse"
}
