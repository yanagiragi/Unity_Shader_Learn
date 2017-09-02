// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Rim" {
	// non-linear calculate specular
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
		_BumpMap ("Normal map", 2D) = "white" {}
		_BumpScale ("Bump Scale", float) = 1.0
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_RimPower ("Rim Power", float) = 1
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
				float4 tangent : TANGENT;
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float _BumpScale;
			float4 _BumpMap_ST;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			fixed4 _RimColor;
			float _RimPower;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

				o.uv.xy = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw; // or o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.uv.zw = v.uv.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
				
				// compute matrix that transform tangent space to world space
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				
				fixed3 LightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 ViewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
				
				// If Bump map is not marked as "Normal Map"
				//fixed3 bump = (packedNormal.xy * 2 - 1) * _BumpScale;
				//bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

				fixed3 bump = UnpackNormal(packedNormal);
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 halfDirection = normalize(LightDir + bump);

				fixed3 albedo = _Diffuse.rgb * tex2D(_MainTex, i.uv).rgb;

				// use saturate() to mimic "max(0, dot(n, l)"
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump, LightDir));
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDirection)), _Gloss);


				// Rim Effects
				half rim = 1.0 - saturate(dot(ViewDir, bump));

				return fixed4(ambient + diffuse + specular + _RimColor.rgb * pow(rim, _RimPower), 1.0);
			}
			ENDCG
		}
	}

	Fallback "Diffuse"
}
