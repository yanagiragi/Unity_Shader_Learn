Shader "Hidden/NewImageEffectShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

			float4x4 _FrustumCornersES;
			float4x4 _CameraInvViewMatrix;
			float3 _CameraWS;

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;

			sampler2D _CameraDepthTexture;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
				float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;                
				float3 ray : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;

				half index = v.vertex.z;
				v.vertex.z = 0.1;

				o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				
				o.ray = _FrustumCornersES[(int)index].xyz;
				o.ray /= abs(o.ray.z);
				o.ray = mul(_CameraInvViewMatrix, o.ray);

                return o;
            }

			// Torus
			// t.x: diameter
			// t.y: thickness
			// Adapted from: http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
			float sdTorus(float3 p, float2 t)
			{
				float2 q = float2(length(p.xz) - t.x, p.y);
				return length(q) - t.y;
			}

			float opTwist_Torus(float3 p, float2 t)
			{
				const float k = _Time.y; // or some other amount
				float c1 = cos(k*p.y);
				float s1 = sin(k*p.y);
				float2x2 m = float2x2(c1, -s1, s1, c1);
				float3 q = float3(mul(m, p.xz), p.y);
				return sdTorus(q,t);
			}


			float map(float3 p)
			{
				return sdTorus(p, float2(1, 0.2));
			}

			float3 calcNormal(float3 pos)
			{
				const float2 eps = float2(0.001, 0.0);
				float3 nor = float3(
					map(pos + eps.xyy).x - map(pos - eps.xyy).x,
					map(pos + eps.yxy).x - map(pos - eps.yxy).x,
					map(pos + eps.yyx).x - map(pos - eps.yyx).x);
				return normalize(nor);
			}

			fixed4 raymarch(float3 ro, float3 rd, float s)
			{
				fixed4 ret = fixed4(0, 0, 0, 0);

				const int maxstep = 64;

				// current distance traveled along ray
				float t = 0;

				for (int i = 0; i < maxstep; ++i)
				{
					if (t >= s)
					{
						ret = fixed4(0, 0, 0, 0);
						break;
					}

					float3 p = ro + rd * t;
					float d = map(p);

					if (d < 0.001)
					{
						float3 n = calcNormal(p);

						fixed3 lightDir = _WorldSpaceLightPos0.xyz;

						fixed NdotL = max(dot(n, lightDir), 0);

						ret = fixed4(NdotL.rrr, 1.0);
						break;
					}

					t += d;
				}

				return ret;
			}

            fixed4 frag (v2f i) : SV_Target
            {
                float3 rd = normalize(i.ray.xyz);
				float3 ro = _CameraWS;

				float2 duv = i.uv;
				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					duv.y = 1 - duv.y;
				#endif

				float depth = LinearEyeDepth(tex2D(_CameraDepthTexture, duv).r);
				depth *= length(i.ray.xyz);

				fixed3 col = tex2D(_MainTex, i.uv);

				fixed4 add = raymarch(ro, rd, depth);

				// alpha blending
				return fixed4(col*(1.0 - add.w) + add.xyz * add.w, 1.0);
            }
            ENDCG
        }
    }
}
