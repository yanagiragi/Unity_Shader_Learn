// Ref:
// https://www.shadertoy.com/view/4sd3WB
// https://www.shadertoy.com/view/Xsd3DB

Shader "Custom/Wave" {
	Properties {
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_RippleRadius ("Ripple Radius", Range(0,0.3)) = 0.05
		Mouse("mouse", Vector) = (0, 0, 0, 0)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _bufferB;
			float _RippleRadius;
			float4 Mouse;

			fixed4 frag(v2f_img i) : SV_Target{

				fixed4 fragColor = fixed4(0,0,0,1);
			
				// Mouse Detection
				float2 r = i.uv.xy * _ScreenParams.xy - Mouse.xy;
				float d = 0.001 * dot(r, r);
				if(Mouse.z > 0.0 && d < _RippleRadius) {
					fragColor = fixed4(0.0, 0.2, 0.0, 0.0);
					return fragColor;
				}
				
				// Periodic excitation
				/*r = i.uv.xy * _ScreenParams.xy- float2(50, 70);
				d = 0.001 * dot(r, r);
				if (fmod(_Time.y, 0.5) < 0.1 && d < _RippleRadius) {
					fragColor = fixed4(1.0, 0.1, 0.0, 0.0);
					return fragColor;
   				}*/

				// Simulate rain drops
				float t = _Time.y * 2.0;
				float2 pos = frac(floor(t) * float2(0.456665,0.708618)) * _ScreenParams.xy;
				float amp = 1.0 - step(0.05, frac(t));
				d = -amp * smoothstep(2.5, 0.5, length(pos - i.uv * _ScreenParams.xy));
				
				// just copy
				fragColor = tex2D(_bufferB, i.uv) + d;

				return fragColor;
			}
			ENDCG
		}
		
		GrabPass{ "_bufferA" }
		Pass {
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "UnityCG.cginc"
			
			sampler2D _bufferA;
			float4 _bufferA_TexelSize;
			
			fixed4 frag(v2f_img i) : SV_Target{
				float dx = _bufferA_TexelSize.x;
				float dy = _bufferA_TexelSize.y;

				float2 uv = i.uv;
				float2 udu = tex2D(_bufferA, uv).xy;
				
				// old elevation
				float u = udu.x;
				// old velociy
				float du = udu.y;
				
				// Finite differences
				float ux  = tex2D(_bufferA, float2(uv.x + dx, uv.y)).x; // →
				float umx = tex2D(_bufferA, float2(uv.x - dx, uv.y)).x; // ←
				float uy  = tex2D(_bufferA, float2(uv.x, uv.y + dy)).x; // ↑
				float umy = tex2D(_bufferA, float2(uv.x, uv.y - dy)).x; // ↓

				// new elevation
				float nu = u + du + 0.5*(umx+ux+umy+uy - 4.0 * u);
				
				// times 0.99 for convergence, for faster convergence simply decrease the value
				nu = 0.99 * nu;

				// clamp for limit the range, or it may become unstable
				nu = clamp(nu, -1.0, 1.0);
			
				// store elevation and velocity
				return fixed4(nu,nu-u,0.0,0.0);
			}
			ENDCG
		}
		
		GrabPass{ "_bufferB" }
		Pass{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _bufferB;
			float4 _bufferB_TexelSize;
			
			#define TEXTURED

			fixed4 frag(v2f_img i) : SV_Target {

				#ifdef TEXTURED
					
					float3 delta = float3(_bufferB_TexelSize.xy, 0.0);					
					float p10 = tex2D(_bufferB, i.uv - delta.zy).x; // ↓					
					float p01 = tex2D(_bufferB, i.uv - delta.xz).x; // ←					
					float p21 = tex2D(_bufferB, i.uv + delta.xz).x; // →					
					float p12 = tex2D(_bufferB, i.uv + delta.zy).x; // ↑
    
					// Totally fake displacement and shading
					// displament = (horizontal diff, vertical diff, 1)
					float3 grad = normalize(float3(p21 - p01, p12 - p10, 1.0));					
					fixed4 mainColor = tex2D(_MainTex, i.uv + grad.xy * 0.35);
					fixed4 baseColor = float4(0.7, 0.8, 1.0, 1.0);

					float3 light = normalize(float3(0.2, -0.5, 0.7));
					float diffuse = dot(grad,light);
					float spec = pow(max(0.,-reflect(light,grad).z), 32.0); // gloss = 32
					fixed4 fragColor = lerp(mainColor, baseColor, 0.25) * max(diffuse, 0.0) + spec;

					return fragColor;
				#else
					float h = tex2D(_bufferB, i.uv).x;
					float sh = 1.35 - h*2.;
					float3 c =
					   float3(exp(pow(sh-.75,2.)*-10.),
							  exp(pow(sh-.50,2.)*-20.),
							  exp(pow(sh-.25,2.)*-10.));
					return float4(c, 1.0);		
				#endif
				
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
