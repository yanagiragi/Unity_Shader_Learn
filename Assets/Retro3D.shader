Shader "Custom/Retro3D"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (0.5, 0.5, 0.5, 1)
		_GeoRes("Geometric Resolution", float) = 40
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float3 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _GeoRes;
			
			v2f vert (appdata v)
			{
				v2f o;

				float4 wp = mul(UNITY_MATRIX_MV, v.vertex);
				wp.xyz = floor(wp.xyz * _GeoRes) / _GeoRes;

				float4 sp = mul(UNITY_MATRIX_P, wp);
				o.vertex = sp;

				float2 uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = float3(uv * sp.w, sp.w);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv.xy / i.uv.z);
				return col * _Color * 2;
			}
			ENDCG
		}
	}
}
