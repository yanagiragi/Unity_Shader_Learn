// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DirectionOffset" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Scale ("Scale", Range(0,0.025)) = 0.0125
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			fixed _Scale;

			struct appdata {
				fixed4 vertex : POSITION;
				fixed4 normal : NORMAL;
				fixed2 uv : TEXCOORD0;
			};

			struct v2f {
				fixed4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0;
			};

			v2f vert(appdata v){
				v2f o;
				v.vertex.xyz += v.normal * _Scale;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f IN) : SV_TARGET
			{
				return tex2D(_MainTex, IN.uv);
			}
			
			ENDCG
		}
		
	}
	FallBack "Diffuse"
}
