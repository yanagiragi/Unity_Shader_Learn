Shader "Custom/ProjectorDecal"
{
	Properties
	{
		_Color("Main Color", Color) = (1,1,1,1)
		_DecalTex("Cookie", 2D) = "" {}
	}
		SubShader
	{
		ZWrite Off
		ColorMask RGB
		Fog { Color(0,0,0) }
		Blend SrcAlpha OneMinusSrcAlpha
		// Force Draw Above Object, Avoid Z-Fighting
		// https://docs.unity3d.com/Manual/SL-CullAndDepth.html
		// Offset 0, -1 pulls the polygon closer to the camera ignoring the polygon’s slope
		// Offset -1, -1 will pull the polygon even closer when looking at a grazing angle.
		Offset -1, -1

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uvDecal: TEXCOORD0;
			};
			float4 _Color;

			sampler2D _DecalTex;
			half4 _DecalTex_ST;

			float4x4 unity_Projector;

			v2f vert(float4 vertex : POSITION)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(vertex);
				float4 ProjectorPos = mul(unity_Projector, vertex);
				o.uvDecal = ComputeScreenPos(ProjectorPos);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2Dproj(_DecalTex, UNITY_PROJ_COORD(i.uvDecal));

				col.rgb *= _Color.rgb;

				col.a = 1 - col.a;

				return col;
			}
			ENDCG
		}
	}
}
