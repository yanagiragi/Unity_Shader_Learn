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
			};

			struct v2f
			{
				float4 uvgrab : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _GrabTexture;
			sampler2D _BumpMap;
			float4 _Magnitude;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uvgrab = ComputeGrabScreenPos(o.vertex);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half4 bump = tex2D(_BumpMap, i.uvgrab);
				half2 distortion = UnpackNormal(bump).rg;
				
				i.uvgrab.xy += distortion * _Magnitude;
				
				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
				return col;
			}
			ENDCG
		}
	}
}
