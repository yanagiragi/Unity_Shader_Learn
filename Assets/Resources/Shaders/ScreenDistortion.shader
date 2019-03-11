Shader "Hidden/ScreenDistortion"
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			uniform float2 _DistortionCenter;
			uniform float _DistortionStrength;
			uniform sampler2D _NoiseTex;
			uniform float _NoiseStrength;
			uniform float _NoiseSpeed;

            fixed4 frag (v2f i) : SV_Target
            {
				fixed2 direction = (i.uv.xy - _DistortionCenter);
				float distance = length(direction);
				direction = normalize(direction);

				float2 scaleOffset = (1 - distance) * _DistortionStrength * direction;

				float2 noiseOffset = tex2D(_NoiseTex, i.uv * _Time.xy * _NoiseSpeed).xy * _NoiseStrength * direction;

				float2 offset = scaleOffset - noiseOffset;

                fixed4 col = tex2D(_MainTex, i.uv + offset);
                
                return col;
            }
            ENDCG
        }
    }
}
