Shader "Custom/Lotion Original" {
	Properties{
		_MainTex("Main Tex", 2D) = "white" {}
		_LotionMap("Lotion Map", 2D) = "white" {}
		_Diffuse("Diffuse", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags{ "LightMode" = "ForwardBase" }
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed3 worldNormal : TEXCOORD1;
				fixed3 worldPos : TEXCOORD2;
				float2 sphereUV : TEXCOORD3;
			};

			fixed4 _Diffuse;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _LotionMap;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = mul(v.normal, (float3x3) unity_WorldToObject);
				o.worldNormal = normalize(o.worldNormal);

				float3 viewNormal = mul(o.worldNormal, (float3x3)UNITY_MATRIX_V);
				viewNormal = normalize(viewNormal);
				o.sphereUV = viewNormal.xy;
				o.sphereUV.x = o.sphereUV.x * 0.5f + 0.5f;
				o.sphereUV.y = o.sphereUV.y * 0.5f + 0.5f;
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
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

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDirection));

				fixed3 LotionColor = tex2D(_LotionMap, i.sphereUV).rgb;

				fixed3 color = ambient + diffuse + LotionColor;

				return fixed4(color, 1.0);

			}
			
			ENDCG
		}
	}

	Fallback "Diffuse"
}
