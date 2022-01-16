// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/HotAirPreRenderMask"
{
	SubShader
	{
		Pass
		{
			Cull Off
			
			Tags {
				"RenderType" = "Transparent"
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"DisableBatching" = "True"
			}

			CGPROGRAM

			#include "UnityCG.cginc"
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			#pragma vertex vert
			#pragma fragment frag

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed mask = 1 - length(i.uv.xy * 2 - 1);
				mask = pow(mask, 2);
				
				return fixed4(mask, mask, mask,1);
			}

			ENDCG
		}
	}
}