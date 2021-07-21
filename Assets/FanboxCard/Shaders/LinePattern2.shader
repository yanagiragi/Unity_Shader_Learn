Shader "Custom/LinePattern (Sin)"
{
    Properties
    {
        _LineAmount ("LineAmount", float) = 1
        _LineInnerWidth ("LineInnerWidth", Range(0.01, 2)) = 0
        _LineWidth ("LineWidth", Range(1, 10)) = 0
        _LineAngle ("LineAngle (Radian)", Range(0, 3.14)) = 0
        _DisplacementScalar ("DisplacementScalar", Range(0, 3)) = 1
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

            fixed _LineWidth;
            fixed _LineInnerWidth;
            fixed _LineAmount;
            fixed _LineAngle;
            fixed _DisplacementScalar;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed GetLineSin(fixed2 uv, fixed angle)
            {
                fixed sinBeta = sin(angle);
                fixed cosBeta = cos(angle);

                // rotate uv
                uv = fixed2(cosBeta * uv.x - sinBeta * uv.y, sinBeta * uv.x + cosBeta * uv.y);
                
                fixed p1 = (uv - fixed2(0.5, 0));

                return pow(abs(sin(p1 * _LineAmount) * _LineInnerWidth), _LineWidth);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 displacedUV = i.uv + fixed2(0, _Time.y * _DisplacementScalar);
                fixed Line = GetLineSin(displacedUV, _LineAngle);
                return fixed4(Line, Line, Line, 1);
            }
            ENDCG
        }
    }
}
