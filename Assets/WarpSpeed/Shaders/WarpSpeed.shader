Shader "Custom/Image Effect/WarpSpeed"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "white" {}
        _Speed("Speed", float) = 0.5
        _Power("Power", Range(0, 5)) = 1
        _Scale("Scale", float) = 1
        _Alpha("_Alpha", Range(0, 1)) = 0.8
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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            fixed4 _NoiseTex_ST;

            fixed _Speed = 0.5;
            fixed _Power = 1;
            fixed _Scale = 1;
            fixed _Alpha = 0.8;

            fixed4 frag(v2f i) : SV_Target
            {
                fixed2 screenUV = i.screenPos.xy / i.screenPos.w;
                screenUV = screenUV - fixed2(0.5, 0.5);



                fixed2 animatedUV = normalize(screenUV) + _Time.y * _Speed;
                fixed4 color = tex2D(_NoiseTex, TRANSFORM_TEX(animatedUV, _NoiseTex) * _Scale);
                
                fixed mask = pow(dot(screenUV, screenUV), _Power);
                color = color * mask;

                fixed4 mainColor = tex2D(_MainTex, i.uv);
                fixed alpha = color.a * _Alpha;

                return fixed4(mainColor.xyz * (1 - alpha) + color.xyz * alpha, 1);
            }
            ENDCG
        }
    }
}
