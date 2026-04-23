Shader "Hidden/ColorPallete"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PalleteHSVWeight ("_PalleteHSVWeight", vector) = (1, 1, 1, 0)
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
            float4 _ColorSet[64];
            float _ColorSetSize;
            vector _PalleteHSVWeight;

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float3 hsvCol = RGBtoHSV(col.xyz);

                //return float4(_ColorSetSize, _ColorSetSize, _ColorSetSize, 1);

                //col = _ColorSet[0];
                float maxPalleteDist = length(float3(1, 1, 1));
                float minPalleteDist = maxPalleteDist + 1;
                uint closestColID = 0;
                [loop]
                for (int j = 0; j <= _ColorSetSize; j++)
                {
                    float3 hsvCurPallete = RGBtoHSV(_ColorSet[j].xyz);

                    float3 distVect = float3(0, hsvCol.y - hsvCurPallete.y, hsvCol.z - hsvCurPallete.z);
                    distVect.x = min(abs(hsvCol.x - hsvCurPallete.x), 1 - abs(hsvCol.x - hsvCurPallete.x));
                    distVect *= _PalleteHSVWeight;
                    float curPalleteDist = length(distVect);
                    if (curPalleteDist < minPalleteDist)
                    {
                        minPalleteDist = curPalleteDist;
                        closestColID = j;
                    }

                    //col = lerp(_ColorSet[j], col, curPalleteDist / maxPalleteDist);
                }

                //col = lerp(_ColorSet[closestColID], col, minPalleteDist / maxPalleteDist);
                col = _ColorSet[closestColID];

                return col;
            }
            ENDCG
        }
    }
}
