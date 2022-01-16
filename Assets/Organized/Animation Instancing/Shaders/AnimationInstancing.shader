Shader "Custom/AnimationInstancing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tint("Texture", Color) = (1,1,1,1)
        _AnimationTex ("Animation Texture", 2D) = "white" {}
        _AnimationLength ("Animation Length", float) = 0

        [Toggle]_UseInstancing("Use Animation Instancing", Int) = 0
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
            #pragma shader_feature _USEINSTANCING_ON

            #pragma multi_compile_instancing // GPU instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _AnimationTex;
            float4 _AnimationTex_TexelSize;
            
            float _AnimationLength;
            fixed4 _Tint;

            v2f vert (appdata v, uint vertexId: SV_VertexID)
            {
                UNITY_SETUP_INSTANCE_ID(v);

                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                #ifdef _USEINSTANCING_ON
                    float time = _Time.y / _AnimationLength;
                    fmod(time, 1.0);

                    float vertexCount = (vertexId + 0.5) * _AnimationTex_TexelSize.x; // x = 1/width
                    float4 vertex = tex2Dlod(_AnimationTex, float4(vertexCount, time, 0, 0));

                    o.vertex = UnityObjectToClipPos(vertex);
                #else
                    o.vertex = UnityObjectToClipPos(v.vertex);
                #endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Tint;
                return col;
            }
            ENDCG
        }
    }
}
