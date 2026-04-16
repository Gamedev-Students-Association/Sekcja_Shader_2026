Shader "Unlit/Halo"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientScale ("_GradientScale", vector) = (1, 1, 1, 1)
        _LightCol ("_LightCol", Color) = (1, 1, 1, 1)
        _DarkCol("_DarkCol", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

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

            float PseudoRand(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float3 hash(float3 p)
            { // replace this by something better
                p = float3(dot(p, float3(127.1, 311.7, 74.7)),
                    dot(p, float3(269.5, 183.3, 246.1)),
                    dot(p, float3(113.5, 271.9, 124.6)));
                return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
            }


            float GradientNoise(in float3 p)
            {
                float3 i = floor(p);
                float3 f = frac(p);
                float3 u = f * f * (3.0 - 2.0 * f);
                return lerp(lerp(lerp(dot(hash(i + float3(0.0, 0.0, 0.0)), f - float3(0.0, 0.0, 0.0)),
                    dot(hash(i + float3(1.0, 0.0, 0.0)), f - float3(1.0, 0.0, 0.0)), u.x),
                    lerp(dot(hash(i + float3(0.0, 1.0, 0.0)), f - float3(0.0, 1.0, 0.0)),
                        dot(hash(i + float3(1.0, 1.0, 0.0)), f - float3(1.0, 1.0, 0.0)), u.x), u.y),
                    lerp(lerp(dot(hash(i + float3(0.0, 0.0, 1.0)), f - float3(0.0, 0.0, 1.0)),
                        dot(hash(i + float3(1.0, 0.0, 1.0)), f - float3(1.0, 0.0, 1.0)), u.x),
                        lerp(dot(hash(i + float3(0.0, 1.0, 1.0)), f - float3(0.0, 1.0, 1.0)),
                            dot(hash(i + float3(1.0, 1.0, 1.0)), f - float3(1.0, 1.0, 1.0)), u.x), u.y), u.z);
            }

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            vector _GradientScale;
            vector _LightCol;
            vector _DarkCol;

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
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);

                float2 center = i.uv - 0.5;
                float2 polarUV = float2(0, 0);
                polarUV.y = length(center) * 2;
                polarUV.x = (atan2(center.x, center.y) / 3.14f + 1) / 2;

                float res = 1;
                float threshold = (GradientNoise(float3(polarUV.x * _GradientScale.x + _Time.y, 0, _Time.y)) + 1) / 2;
                float threshold2 = (GradientNoise(float3((polarUV.x - 1) * _GradientScale.x + _Time.y, 0, _Time.y)) + 1) / 2;

                threshold = lerp(threshold, threshold2, polarUV.x);

                threshold = pow(threshold, 5);

                res = (polarUV.y - threshold + 3) / 3;
                res = 1 - res;

                //col = float4(res, res, res, 1);
                col = lerp(_DarkCol, _LightCol, res);
                //col.a = 1;
                

                return col;
            }
            ENDCG
        }
    }
}
