Shader "Hidden/HotAirImageEffects"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
		_NoiseTex("Noise Map", 2D) = "white" {}
    }

	CGINCLUDE

	#include "UnityCG.cginc"

	uniform sampler2D _MainTex;

	uniform sampler2D _GrabPass;
	float4 _GrabPass_ST;

	uniform sampler2D _NoiseTex;
	float4 _NoiseTex_ST;

	uniform sampler2D _MaskTex;
	float4 _MaskTex_ST;

	uniform fixed _DistortionStrength;
	uniform fixed _DistortionTimeFactor;

	fixed4 frag(v2f_img i) : SV_Target
	{
		float4 noise = tex2D(_NoiseTex, i.uv - _Time.xy * _DistortionTimeFactor);
		float2 offset = noise.xy * _DistortionStrength;
		float2 uv = offset * tex2D(_MaskTex, i.uv).r + i.uv;
		//return float4(tex2D(_MaskTex, i.uv).rrrr);
		return tex2D(_MainTex, uv);
	}

	ENDCG

	SubShader 
	{
		Pass
		{
			Cull Off
			ZWrite Off
			ZTest Always
			Fog { Mode Off }

			CGPROGRAM
			
			#pragma vertex vert_img
			#pragma fragment frag

			ENDCG
		}			
	}
	
	Fallback off

}
