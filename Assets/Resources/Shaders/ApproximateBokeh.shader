Shader "Hidden/ApproximateBokeh"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_MaxBlurSize("Max Blur Size", float) = 20.0
		_RadiusScale("Radius Scale", Range(0, 1)) = 0.5
	}

	SubShader
	{
		Pass
		{
			Cull Off

			CGPROGRAM

			#include "UnityCG.cginc"
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			half4 _MainTex_TexelSize;

			// depth texture
			sampler2D _CameraDepthTexture;

			float _MaxBlurSize;
			float _RadiusScale;			
			float _FocusPoint;
			float _FocusScale;
			const float _GoldenAngle = 2.39996323;

			v2f vert(appdata_full v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				return o;
			}

			float GetBlurSize(float depth, float focusPoint, float focusScale)
			{
				float toCenter = (1.0 / focusPoint - 1.0 / depth) * focusScale;
				toCenter = clamp(toCenter, -1.0, 1.0);
				return abs(toCenter) * _MaxBlurSize;
			}

			float3 ApproximateBokeh(fixed2 uv, float focusPoint, float focusScale)
			{
				fixed centerDepth = LinearEyeDepth(tex2D(_CameraDepthTexture, uv).r);				
				float centerBlurSize = GetBlurSize(centerDepth, focusPoint, focusScale);

				float3 color = tex2D(_MainTex, uv).rgb;
				float total = 1.0; // amount of accumulation

				float radius = _RadiusScale;

				float2 pixelSize = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);
				// or _ScreenParams.zw - 1.0

				[unroll(64)]
				for (float angle = 0.0; radius < _MaxBlurSize; angle += _GoldenAngle) {
					fixed2 sampleUV = uv + fixed2(cos(angle), sin(angle)) * pixelSize * radius;
					fixed3 sampleColor = tex2D(_MainTex, sampleUV).rgb;
					fixed sampleDepth = LinearEyeDepth(tex2D(_CameraDepthTexture, sampleUV).r);
					float sampleBlurSize = GetBlurSize(sampleDepth, focusPoint, focusScale);

					if (sampleDepth > centerDepth) { // blur farer objects
						sampleBlurSize = clamp(sampleBlurSize, 0.0, centerBlurSize * 2.0);
					}
					
					float m = smoothstep(radius - 0.5, radius + 0.5, sampleBlurSize);
						
					color += lerp(color / total, sampleColor, m);
					total += 1.0;
					radius += _RadiusScale / radius;
				}
				
				return color /= total;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed3 bokeh = ApproximateBokeh(i.uv, _FocusPoint, _FocusScale);

				return float4(bokeh, 1.0);
			}

			ENDCG
		}
	}
}