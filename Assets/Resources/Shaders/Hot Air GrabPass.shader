Shader "Custom/HotAirBillboard"
{
    Properties
    {
		_NoiseTex("Noise Map", 2D) = "white" {}
		_DistortionStrength("Distortion Strength", Range(0,1)) = 1
		_DistortionTimeFactor("Distortion Time Factor", Range(0,1)) = 1
		_VerticalBillBoarding("Vertical Restraints", Range(0,1)) = 1
    }
    SubShader
    {
		GrabPass {
			"_GrabPass"
		}

        Tags {
			"RenderType"="Transparent"
			"Queue"="Transparent" 
			"IgnoreProjector" = "True"
			"DisableBatching" = "True"
		}
        LOD 100

        Pass
        {
			Zwrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

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
				float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
				float4 grabPos : TEXCOORD1;                
            };

			sampler2D _GrabPass;
			float4 _GrabPass_ST;

            sampler2D _NoiseTex;
			float4 _NoiseTex_ST;

			fixed _DistortionStrength;
			fixed _DistortionTimeFactor;

			fixed _VerticalBillBoarding;

            v2f vert (appdata v)
            {
                v2f o;
                
				// Billboard
				float3 center = float3(0,0,0);
				float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
				
				float3 normalDir = viewer - center;
				normalDir.y = normalDir.y * _VerticalBillBoarding;
				normalDir = normalize(normalDir);
				
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0, 0, 1) : float3(0, 1, 0);
				float3 rightDir = normalize(cross(upDir, normalDir));
				upDir = normalize(cross(normalDir, rightDir));
				
				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;
				
				o.vertex = UnityObjectToClipPos(float4(localPos, 1));

				o.grabPos = ComputeGrabScreenPos(o.vertex);

				o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float2 offset = tex2D(_NoiseTex,i.uv - _Time.xy * _DistortionTimeFactor);

				i.grabPos.xy -= offset.xy * _DistortionStrength;

				fixed4 col = tex2Dproj(_GrabPass, i.grabPos);

				return col;
			}
            ENDCG
        }
    }
}
