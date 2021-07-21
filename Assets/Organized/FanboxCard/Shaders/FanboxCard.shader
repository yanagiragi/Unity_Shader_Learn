Shader "Custom/FanboxCard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlingTex1 ("BlingTex1", 2D) = "white" {}
        _PatternTex1 ("_PatternTex1", 2D) = "white" {}
        _BlingTex2 ("BlingTex2", 2D) = "white" {}
        _PatternTex2 ("PatternTex2", 2D) = "white" {}
        
        _Displacement ("_Displacement", float) = 0
        _DisplacementScalar ("_DisplacementScalar", Range(1, 10)) = 1
        
        _MainTexStrength ("_MainTexStrength", Range(0, 1)) = 1
        _PatternStrength1 ("_PatternStrength1", Range(0, 1)) = 1
        _PatternStrength2 ("_PatternStrength2", Range(0, 1)) = 1
        _BlingStrength ("_BlingStrength", Range(0, 1)) = 1
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
            
            sampler2D _BlingTex1;
            float4 _BlingTex1_ST;
            
            sampler2D _BlingTex2;
            float4 _BlingTex2_ST;
            
            sampler2D _PatternTex1;
            sampler2D _PatternTex2;

            fixed _MainTexStrength;

            fixed _PatternStrength1;
            fixed _PatternStrength2;

            fixed _BlingStrength;

            fixed _Displacement;
            fixed _DisplacementScalar;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                fixed2 displacedUV1 = i.uv + fixed2(0, _Displacement * _DisplacementScalar);
                fixed2 displacedUV2 = i.uv + fixed2(_Displacement * _DisplacementScalar, 0);

                fixed4 mainColor = tex2D(_MainTex, TRANSFORM_TEX(i.uv, _MainTex));

                fixed4 col1 = tex2D(_BlingTex1, TRANSFORM_TEX(displacedUV1, _BlingTex1));
                fixed4 col2 = tex2D(_BlingTex2, TRANSFORM_TEX(displacedUV2, _BlingTex2));

                fixed4 mask1 = tex2D(_PatternTex1, i.uv);
                fixed4 mask2 = tex2D(_PatternTex2, i.uv);

                fixed3 layer1 = mainColor.xyz * _MainTexStrength;
                
                // step 0.8 for clip uncleaned alphas
                fixed3 layer2 = col1.xyz * col1.a * step(0.8, mask1.a) * _PatternStrength1;
                fixed3 layer3 = col2.xyz * col2.a * step(0.8, mask2.a) * _PatternStrength2;

                fixed3 final = layer1 + (layer2 + layer3) * _BlingStrength;

                return fixed4(final.xyz, 1);
            }
            ENDCG
        }
    }
}