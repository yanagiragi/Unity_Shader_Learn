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
//

Shader "Custom/Digital Glitch"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "" {}
		_NoiseTex ("Noise Texture", 2D) = "" {}
		_TrashTex ("Trash Texture", 2D) = "" {}
		_Intensity("Intensity", float) = 1
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
			sampler2D _TrashTex;
			sampler2D _NoiseTex;
			float _Intensity;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 glitch = tex2D(_NoiseTex, i.uv);

				float thres = 1.001 - _Intensity * 1.001;
				float w_d = step(thres, pow(glitch.z, 2.5)); // displacement glitch
				float w_f = step(thres, pow(glitch.w, 2.5)); // frame glitch
				float w_c = step(thres, pow(glitch.z, 3.5)); // color glitch

				float2 uv = frac(i.uv + glitch.xy * w_d);
				fixed4 source = tex2D(_MainTex, uv);

				fixed3 color = lerp(source, tex2D(_TrashTex, uv), w_f).rgb;

				float3 neg = saturate(color.grb + (1 - dot(color, 1)) * 0.5);
				color = lerp(color, neg, w_c);

				return fixed4(color.rgb, source.a);
			}
			ENDCG
		}
	}
}
