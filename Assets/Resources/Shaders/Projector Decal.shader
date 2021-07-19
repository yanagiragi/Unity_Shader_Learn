// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'

// Note: Set Texture warp mode to clamped
// Note: Use light cookie texture, i.e. black parts are invisible in the scene

Shader "Custom/ProjectorDecal"
{
	Properties
	{
		[Hdr] _Color("Main Color", Color) = (1,1,1,1)
		_DecalTex("Cookie", 2D) = "" {}
		_FallOffTex("Cookie FallOff", 2D) = "" {}
	}
	
	SubShader
	{
		Pass
		{
			ZWrite Off
			ColorMask RGB
			
			// Additive Blend
			Blend DstColor One 	
			
			// Force Draw Above Object, Avoid Z-Fighting
			// https://docs.unity3d.com/Manual/SL-CullAndDepth.html
			// Offset 0, -1 pulls the polygon closer to the camera ignoring the polygon’s slope
			// Offset -1, -1 will pull the polygon even closer when looking at a grazing angle.
			Offset -1, -1

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uvDecal: TEXCOORD0;
				float4 uvFallOff: TEXCOORD1;
			};
			float4 _Color;

			sampler2D _DecalTex;
			half4 _DecalTex_ST;

			sampler2D _FallOffTex;
			half4 _FallOff_ST;

			float4x4 unity_Projector;
			float4x4 unity_ProjectorClip; // calculates the distance between projector and position

			v2f vert(float4 vertex : POSITION)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(vertex);
				o.uvDecal = mul(unity_Projector, vertex);
				o.uvFallOff = mul (unity_ProjectorClip, vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2Dproj(_DecalTex, UNITY_PROJ_COORD(i.uvDecal));
				col.rgb *= _Color.rgb;
				col.a = 1 - col.a;

				fixed4 fallOff = tex2Dproj(_FallOffTex, UNITY_PROJ_COORD(i.uvFallOff));
				
				return col * fallOff.a;
			}
			ENDCG
		}
	}
}
