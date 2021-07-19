Shader "Custom/CameraDecal"
{
    Properties
    {
		[Hdr] _Color("Main Color", Color) = (1,1,1,1)
		_DecalTex("Cookie", 2D) = "" {}
    }
    SubShader
    {
        Pass
        {

            ZWrite Off
            ColorMask RGB
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
            };            
            float4 _Color;

			sampler2D _DecalTex;
			half4 _DecalTex_ST;

			uniform float4x4 _ProjectorVP;

			v2f vert(float4 vertex : POSITION)
            {
                v2f o;
				o.vertex = UnityObjectToClipPos(vertex);
                float4x4 ProjectorMVP = mul(_ProjectorVP, unity_ObjectToWorld);
				float4 ProjectorPos = mul(ProjectorMVP, vertex);
				
				o.uvDecal = ComputeScreenPos(ProjectorPos);
				o.uvDecal.xy = TRANSFORM_TEX(o.uvDecal.xy, _DecalTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2Dproj(_DecalTex, UNITY_PROJ_COORD(i.uvDecal));
            
				col.rgb *= _Color.rgb;

				col.a = 1 - col.a;

				return col;// *_Color;
            }
            ENDCG
        }
    }
}
