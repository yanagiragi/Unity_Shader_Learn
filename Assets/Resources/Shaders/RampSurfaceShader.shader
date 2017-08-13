Shader "Custom/RampSurfaceShader" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Ramp("Ramp", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Ramp

		sampler2D _Ramp;

		struct Input {
			float2 uv_MainTex;
		};

		half4 LightingRamp(SurfaceOutput s, half3 lightDir, half atten) {
			half2 NdotL = dot(s.Normal, lightDir);
			half2 diff = NdotL * 0.5 + 0.5;
			half3 ramp = tex2D(_Ramp, float2(diff)).rgb;

			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * ramp * atten;

			c.a = s.Alpha;

			return c;
		}
		
		sampler2D _MainTex;

		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
