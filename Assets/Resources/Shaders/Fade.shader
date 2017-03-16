Shader "Custom/Fade"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TRANS ("Transparency", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
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
			fixed _TRANS;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.uv = v.uv;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col.a = _TRANS ;
				return col;
			}
			ENDCG
		}
	}
}
