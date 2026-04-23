Shader "Unlit/SimpleGradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FirstCol ("_FirstCol", Color) = (0, 0, 0, 1)
        _SecondCol("_SecondCol", Color) = (1, 1, 1, 1)
        _UseHSV ("_UseHSV", float) = 0
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
            #ifndef COLOR_CONVERSION_LIB
            #include "ColorConversion.cginc"
            #endif

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _FirstCol;
            float4 _SecondCol;
            float _UseHSV;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float gradient = i.uv.y;

                col = lerp(_FirstCol, _SecondCol, gradient);

                if (_UseHSV > 0)
                {
                    col = float4(HSVtoRGB(float3(i.uv.x, 1, i.uv.y)), 1);
                }

                return col;
            }
            ENDCG
        }
    }
}
