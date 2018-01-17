Shader "Unity Shaders Book/Chapter 11/Water Sprite Animation"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1,1,1,1)
		_Magnitude ("Distortion Magnitude", float) = 1
		_Frequency ("Distortion Frequency", float) = 1
		_InvWaveLength ("Distortion Inverse Wave Length", float) = 10
		_Speed ("Speed", float) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True"}
		LOD 100

		Pass
		{
			Tags { "LightMode"="ForwardBase" }
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;
			
			
			v2f vert (appdata v)
			{
				v2f o;
				
				float4 offset;
				offset.yzw = float3(0, 0, 0);
				offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength ) * _Magnitude;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex + offset);
				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv += float2(0.0, _Time.y * _Speed);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				
				col.rgb *= _Color.rgb;
				return col;
			}
			ENDCG
		}

		Pass
		{
			Tags { "LightMode"="ShadowCaster" }
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				V2F_SHADOW_CASTER;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;
			
			
			v2f vert (appdata v)
			{
				v2f o;
				
				float4 offset;
				offset.yzw = float3(0, 0, 0);
				offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength ) * _Magnitude;
				v.vertex = v.vertex + offset;

				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);				
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i);
			}
			ENDCG
		}

	}
	Fallback "Transparent/VertexLit"
}
