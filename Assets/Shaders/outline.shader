Shader "Hidden/outline"
{
    Properties
    {
        _MainTex ("_MainTex", 2D) = "white" {}
        _DepthTreshold ("_DepthTreshold", float) = 0
        _NormalTreshold("_NormalTreshold", float) = 0
        _OutlineThickness ("_OutlineThickness", float) = 0
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
            float4 _MainTex_TexelSize;
            sampler2D _CameraDepthNormalsTexture;

            float _DepthTreshold;
            float _NormalTreshold;
            float _OutlineThickness;

            float2 GetPosShift(uint id)
            {
                if (id == 0)
                {
                    return float2(-1, 0);
                }
                else if (id == 1)
                {
                    return float2(1, 0);
                }
                else if (id == 2)
                {
                    return float2(0, -1);
                }
                else if (id == 3)
                {
                    return float2(0, 1);
                }
                return float2(0, 0);
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);

                float3 normal = float3(1, 1, 1);
                float depth = 0;
                DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), depth, normal);

                col = float4(0, 0, 0, 1);

                for (uint g = 0; g < _OutlineThickness; g++)
                {
                    for (uint j = 0; j < 4; j++)
                    {
                        float2 NbPos = i.uv + _MainTex_TexelSize.xy * GetPosShift(j) * g;
                        float3 nbNormal = float3(1, 1, 1);
                        float nbDepth = 1;
                        DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, NbPos), nbDepth, nbNormal);
                        //depth
                        if (abs(nbDepth - depth) > _DepthTreshold)
                        {
                            col = float4(1, 1, 1, 1);
                            break;
                        }

                        //normal
                        if (dot(nbNormal, normal) < _NormalTreshold)
                        {
                            col = float4(1, 0, 1, 1);
                            break;
                        }
                    }
                }

                //return float4(normal.x, normal.y, normal.z, 1) * 3;
                return col;
            }
            ENDCG
        }
    }
}
