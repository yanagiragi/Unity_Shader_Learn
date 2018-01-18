Shader "Unity Shaders Book/Chapter 14/Toon Shading"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color Tint", Color) = (1,1,1,1)
		_Ramp("Ramp Texture", 2D) = "white" {}
		_Outline ("Outline", Range(0, 1)) = 1
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_Specular("Specular", Color) = (1,1,1,1)
		_SpecularScale("Specular Scale", Range(0, 0.1)) = 0.01
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			NAME "OUTLINE"
			Cull Front

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Outline;
			fixed4 _OutlineColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
				float3 normal = mul((float3x3) UNITY_MATRIX_IT_MV, v.normal);
				normal.z = -0.5;
				pos = pos + float4(normalize(normal), 0) * _Outline;
				o.vertex = mul(UNITY_MATRIX_P, pos);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return float4(_OutlineColor.rgb, 1);
			}
			ENDCG
		}

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;				
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			sampler2D _Ramp;
			fixed4 _Specular;
			fixed _SpecularScale;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				o.worldNormal = mul(v.normal, (float3x3) unity_WorldToObject);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				TRANSFER_SHADOW(o);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDirection = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDirection = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 worldHalfDirection = normalize(worldLightDirection + worldViewDirection);
				
				fixed4 c = tex2D(_MainTex, i.uv);
				fixed3 albedo = c.rgb * _Color.rgb;

				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				fixed diff = dot(worldNormal, worldLightDirection);
				diff = (diff * 0.5 + 0.5) * atten;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp, float2(diff, diff)).rgb;
				
				fixed spec = dot(worldNormal, worldHalfDirection);
				fixed w = fwidth(spec) * 2.0;
				fixed3 specular = _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1) * step(0.0001, _SpecularScale));

				return fixed4(ambient + diffuse + specular, 1.0);;
			}
			ENDCG
		}
	}

	FallBack "Diffuse"
}
