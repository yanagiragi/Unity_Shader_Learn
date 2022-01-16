// Ref: https://github.com/keijiro/KinoGlitch/

//
// KinoGlitch - Video glitch effect
//
// Copyright (C) 2015 Keijiro Takahashi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Shader "Custom/Analog Glitch"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float2 _ScanLineJitter; // (displacement, threshold)
			float2 _VerticalJump;   // (amount, time)
			float _HorizontalShake;
			float2 _ColorDrift;		// (amount, time)
			
			float nrand(float x, float y)
			{
				return frac(sin(dot(float2(x, y), float2(12.9898, 78.233))) * 43758.5453);
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float u = i.uv.x;
				float v = i.uv.y;

				float jitter = nrand(v, _Time.x) * 2 - 1;
				jitter *= step(_ScanLineJitter.y, abs(jitter)) * _ScanLineJitter.x;

				// vertical jump
				float jump = lerp(v, frac(v + _VerticalJump.y), _VerticalJump.x);
				
				// horizontal shake
				float shake = (nrand(_Time.x, 2) - 0.5) * _HorizontalShake;

				// color drift
				float drift = sin(jump + _ColorDrift.y) * _ColorDrift.x;

				fixed4 col1 = tex2D(_MainTex, frac(float2(u + jitter + shake, jump)));
				fixed4 col2 = tex2D(_MainTex, frac(float2(u + jitter + shake + drift, jump)));

				return fixed4(col1.r, col2.g, col1.b, 1.0);
			}
			ENDCG
		}
	}
}
