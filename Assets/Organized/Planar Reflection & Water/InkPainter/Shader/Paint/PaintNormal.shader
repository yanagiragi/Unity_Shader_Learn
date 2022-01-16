﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Es/InkPainter/PaintNormal"{
	Properties{
		[HideInInspector]
		_MainTex("MainTex", 2D) = "white"
		[HideInInspector]
		_Brush("Brush", 2D) = "white"
		[HideInInspector]
		_BrushNormal("BrushNormal", 2D) = "white"
		[HideInInspector]
		_BrushScale("BrushScale", FLOAT) = 0.1
		[HideInInspector]
		_BrushRotate("Rotate", FLOAT) = 0
		[HideInInspector]
		_PaintUV("Hit UV Position", VECTOR) = (0,0,0,0)
		[HideInInspector]
		_NormalBlend("NormalBlend", FLOAT) = 1
		[HideInInspector]
		[KeywordEnum(USE_BRUSH, ADD, SUB MIN, MAX)]
		INK_PAINTER_NORMAL_BLEND("Normal Blend Keyword", FLOAT) = 0
		[KeywordEnum(USE, UNUSE)]
		DXT5NM_COMPRESS("use DXT5nm compressed", FLOAT) = 0
	}

	SubShader{
		CGINCLUDE

#include "../Lib/InkPainterFoundation.cginc"

			struct app_data {
				float4 vertex:POSITION;
				float4 uv:TEXCOORD0;
			};

			struct v2f {
				float4 screen:SV_POSITION;
				float4 uv:TEXCOORD0;
			};

			sampler2D _MainTex;
			sampler2D _Brush;
			sampler2D _BrushNormal;
			float4 _PaintUV;
			float _BrushScale;
			float _BrushRotate;
			float _NormalBlend;
		ENDCG

		Pass{
			CGPROGRAM
#pragma multi_compile INK_PAINTER_NORMAL_BLEND_USE_BRUSH INK_PAINTER_NORMAL_BLEND_ADD INK_PAINTER_NORMAL_BLEND_SUB INK_PAINTER_NORMAL_BLEND_MIN INK_PAINTER_NORMAL_BLEND_MAX
#pragma multi_compile DXT5NM_COMPRESS_USE DXT5NM_COMPRESS_UNUSE
#pragma vertex vert
#pragma fragment frag

			v2f vert(app_data i) {
				v2f o;
				o.screen = UnityObjectToClipPos(i.vertex);
				o.uv = i.uv;
				return o;
			}

			float4 frag(v2f i) : SV_TARGET {
				float h = _BrushScale;
				float4 base = SampleTexture(_MainTex, i.uv.xy);

				if (IsPaintRange(i.uv, _PaintUV, h, _BrushRotate)) {
					float2 uv = CalcBrushUV(i.uv, _PaintUV, h, _BrushRotate);
					float4 brushColor = SampleTexture(_Brush, uv.xy);

					if (brushColor.a > 0) {
						float2 normalUV = CalcBrushUV(i.uv, _PaintUV, h, _BrushRotate);
						float4 normal = SampleTexture(_BrushNormal, normalUV.xy);
						return INK_PAINTER_NORMAL_BLEND(base, normal, _NormalBlend, brushColor.a);
					}
				}

				return base;
			}

			ENDCG
		}
	}
}