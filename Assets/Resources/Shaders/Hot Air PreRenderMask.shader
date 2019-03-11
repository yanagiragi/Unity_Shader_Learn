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
			};

			#pragma vertex vert
			#pragma fragment frag

			v2f vert(appdata_full v)
			{
				v2f o;
				
				// Billboard
				float3 center = float3(0, 0, 0);
				float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

				float3 normalDir = viewer - center;
				normalDir = normalize(normalDir);

				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				float3 rightDir = normalize(cross(upDir, normalDir));
				upDir = normalize(cross(normalDir, rightDir));

				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

				o.pos = UnityObjectToClipPos(float4(localPos, 1));
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return fixed4(1,1,1,1);
			}

			ENDCG
		}
	}
}