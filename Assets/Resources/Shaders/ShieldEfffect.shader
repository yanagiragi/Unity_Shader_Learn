// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/ShieldEfffect"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Width ("Intersect Width", float) = 1
		_Speed ("Speed", Range(0,1)) = 0.5
		_AlphaScale ("Alpha Scale", float) = 1
		_Brightness ("Brightness", float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent"}
		LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off		

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
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
				float3 worldNormal : TEXCOORD1;
				float4 worldPos : TEXCOORD2;
				fixed4 scrPos : TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			sampler2D _CameraDepthTexture;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _Speed;
			float _Width;
			float _AlphaScale;
			float _Brightness;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				
				o.scrPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.scrPos.z);

				fixed2 uv = TRANSFORM_TEX(v.uv, _MainTex);
				uv += _Time.y * fixed2(0.0, _Speed);
				o.uv = uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target			
			{

				float3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));
				float3 worldNormal = normalize(i.worldNormal);
				
				float depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r;
				depth = LinearEyeDepth(depth);
				depth -= i.scrPos.z;

				float alpha = max(0, pow(1 - abs(dot(worldView, worldNormal)),  min(depth * depth * _Width, _AlphaScale)));					
				
				fixed3 col = tex2D(_MainTex, i.uv).rgb * _Color.rgb * _Brightness;
				return fixed4(col , alpha);
			}
			ENDCG
		}
	}
}
