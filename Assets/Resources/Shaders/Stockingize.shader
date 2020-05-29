Shader "Custom/Stockingize "
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_StockingTexture ("Stocking Texture", 2D) = "white" {}
		_Diffuse ("Diffuse", Color) = (1,1,1,1)
		_Specular ("Specular", Color) = (1,1,1,1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
		_GAUSSIAN_A("Denier", Range(0.1, 1)) = 1
		_GAUSSIAN_SIGMA("Gradation", Range(0.1, 2.3)) = 1.4		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase" }
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
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _StockingTexture;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			float _GAUSSIAN_A;
			float _GAUSSIAN_SIGMA;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			#define ALPHA_BLEND(bg, fg, a1, a2)  (a2*fg+(1.0f - a2)*a1*bg)/(a1+a2 - a1*a2)
			float4 AlphaBlend (float4 bg, float4 fg)
			{
				return float4(ALPHA_BLEND(bg.r, fg.r, bg.a, fg.a),
							  ALPHA_BLEND(bg.g, fg.g, bg.a, fg.a),
							  ALPHA_BLEND(bg.b, fg.b, bg.a, fg.a),
							  bg.a + fg.a - bg.a*fg.a);
			}

			float Gaussian (float x) 
			{
				return _GAUSSIAN_A*exp(-(x*x)/(2*_GAUSSIAN_SIGMA*_GAUSSIAN_SIGMA));
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDirection = normalize(_WorldSpaceLightPos0.xyz);								
				fixed3 reflectDirection = normalize(reflect(-worldLightDirection, worldNormal));
				fixed3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDirection = normalize(viewDirection + worldLightDirection);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(dot(worldNormal, worldLightDirection), 0);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDirection)), _Gloss);

				float u = 1 - Gaussian(dot(viewDir, worldNormal));
				fixed4 StockingColor = tex2D(_StockingTexture, float2(u, i.uv.y));
				
				fixed4 Color = tex2D(_MainTex, i.uv) + fixed4(specular, 1.0);
		
				fixed4 finalColor = AlphaBlend(Color, StockingColor);
				return finalColor;
			}
			ENDCG
		}
	}
}
