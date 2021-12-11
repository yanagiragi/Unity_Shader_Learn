Shader "Custom/StippleTransparency"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Transparency("Clip Threshold", Range(0, 1)) = 0
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                UNITY_FOG_COORDS(2)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            fixed _Transparency;

            static const float4x4 thresholdMatrix =
            {
                1.0 / 17.0,    9.0 / 17.0,    3.0 / 17.0,   11.0 / 17.0,
                13.0 / 17.0,   5.0 / 17.0,   15.0 / 17.0,    7.0 / 17.0,
                4.0 / 17.0,   12.0 / 17.0,    2.0 / 17.0,   10.0 / 17.0,
                16.0 / 17.0,   8.0 / 17.0,   14.0 / 17.0,    6.0 / 17.0
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // clip space, width range = [-width, width]
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screenPos = ComputeScreenPos(o.vertex); // screen space, width range = [0, 1]
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Calculate screenPos, width range = [0, width]
                float2 pos = i.screenPos.xy / i.screenPos.w;
                pos *= _ScreenParams.xy;

                float threshold = thresholdMatrix[fmod(pos.x, 4)][fmod(pos.y, 4)];
                clip(_Transparency - threshold);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                return col;
            }
            ENDCG
        }
    }
}
