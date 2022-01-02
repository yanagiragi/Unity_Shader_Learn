// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unity Shaders Book/Chapter 7/Ramp Texture"
{
	Properties {
		_RampTex ("Ramp Map", 2D) = "white" {}
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
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.uv, _RampTex);				

				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));				
				fixed3 worldNormal = normalize(i.worldNormal);
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed halfLambert = 0.5 * dot(worldLightDir, worldNormal) + 0.5;

				fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Diffuse.rgb;

				fixed3 diffuse = _LightColor0.rgb * diffuseColor.rgb;

				fixed3 viewDirection = normalize(UnityWorldSpaceViewDir(i.worldPos));

				fixed halfDirection = normalize(worldLightDir + viewDirection);
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDirection)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);;
			}
			ENDCG
		}
	}
}
