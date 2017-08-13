// Tutorial from 
// "Unite Europe 2016 - A Crash Course to Writing Custom Unity Shaders!"

// Special Thanks: Colin Leung for correcting my code
// link: https://paste.ofcode.org/ShAHXKtfVdZxKukRRMDB85

Shader "Custom/Refraction Invisible"
{
	Properties
	{
		_BumpMap ("Bump Map", 2D) = "bump" {}
		_Magnitude ("Magnitude", Range(0,1)) = 0.05
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Opaque" }

		Blend One Zero

		GrabPass{"_GrabTexture"}
		// Avoid using "GrabPass {}" for low performance

		LOD 300

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
				float4 uvgrab : TEXCOORD0;
				float2 uv : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _GrabTexture;
			sampler2D _BumpMap;
			float _Magnitude;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uvgrab = ComputeGrabScreenPos(o.vertex);
				o.uv = v.uv;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half4 bump = tex2D(_BumpMap, i.uv); // use uv instead of ubgrab to get texture color
				half2 distortion = UnpackNormal(bump).rg;
				
				i.uvgrab.xy += distortion * _Magnitude;
				
				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
				// alternative way:
				// fixed4 col = tex2D(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab).xy / UNITY_PROJ_COORD(i.uvgrab).ww);
				return col;
			}
			ENDCG
		}
	}
}
