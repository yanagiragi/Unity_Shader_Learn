// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DirectionOffsetClamp"
{
	Properties {
		_MainTex("Texture", 2D) = "white"{}
		_Color("Color", Color) = (1,1,1,1)
		_Pos("Pos", Range(-1, 1)) = 0.1
		_Range("Range", Range(0, 2)) = 0.2
		_Scale("Scale", Range(0,0.05)) = 0.02
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Pass{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			sampler2D _MainTex;
			fixed4 _Color;
			fixed _Scale;
			fixed _Range;
			fixed _Pos;

			struct appdata {
				fixed4 vertex : POSITION;
				fixed4 normal : NORMAL;
				fixed2 uv : TEXCOORD0;
			};

			struct v2f {
				fixed4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				fixed2 uv : TEXCOORD0;
			};

			v2f vert(appdata v){
				v2f o;
				if(v.vertex.x <= _Pos && v.vertex.x >= _Pos - _Range){
					v.vertex.xyz += v.normal * _Scale;
					o.color = _Color;
				}
				else{
					o.color = fixed4(1,1,1,1);
				}
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f IN) : SV_TARGET
			{
				return tex2D(_MainTex, IN.uv) * IN.color;
			}
			
			ENDCG
		}
		
	}
}
