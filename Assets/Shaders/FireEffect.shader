Shader "Unlit/FireEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseScale("CloudsScale", vector) = (1, 1, 1, 0)
        _FirePatchNoiseScale("_FirePatchNoiseScale", vector) = (1, 1, 1, 0)
        _FireWavesNoiseScale("_FireWavesNoiseScale", vector) = (1, 1, 1, 0)
        _FireSpeed("_FireSpeed", vector) = (0, 0, 0, 0)
        _FireWavesSpeed("_FireWavesSpeed", float) = 1
        _FireCol("_FireCol", Color) = (1, 1, 1, 0)
        _FireHighlightCol("_FireHighlightCol", Color) = (1, 1, 1, 0)
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "RenderQueue" = "Transparent" }
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
            #ifndef NOISE_LIB
            #include "NoiseLib.cginc"
            #endif
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
            float4 _NoiseScale;
            float4 _FirePatchNoiseScale;
            float4 _FireWavesNoiseScale;
            float4 _FireSpeed;
            float _FireWavesSpeed;
            float4 _FireCol;
            float4 _FireHighlightCol;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                float fireThreshold = 1 - i.uv.y;

                float fireNoiseOffset = GradientNoise(float3(float2(0, i.uv.y) * _FireWavesNoiseScale.xy - float2(_Time.y * _FireWavesSpeed, 0), 0));
                //fireNoiseOffset *= (1 - fireThreshold) * _FireWavesNoiseScale.z;

                float fireNoise = RemapNoise(GradientNoise(float3(i.uv * _NoiseScale.xy - float2(0, _Time.y * _FireSpeed.y) + float2(fireNoiseOffset, 0), 0)));
                //mainNoise = RemapNoise(GradientNoise(float3(i.uv.x, i.uv.y, 0) * _NoiseScale.xyz + _FireSpeed.xyz * _Time.y + float3(0, mainNoise, 0)));

                float firePatchNoise = RemapNoise(CloudNoise2D(float3(2, i.uv.x + 2, 2) * _FirePatchNoiseScale.xyz));

                //return float4(lerp(_FireHighlightCol.xyz, _FireCol.xyz, mainNoise) , 1.0f);
                fireThreshold *= 1 - pow(1 - firePatchNoise, 16);
                //fireThreshold = 1 - pow(1 - fireThreshold, 2);
                float4 finalFireCol = float4(0, 0, 0, 1);
                if (fireNoise < fireThreshold)
                {
                    finalFireCol.xyz = HSVtoRGB(lerp(RGBtoHSV(_FireHighlightCol), RGBtoHSV(_FireCol), (fireThreshold - fireNoise) / fireThreshold));
                    finalFireCol.a = lerp(_FireHighlightCol.a, _FireCol.a, (fireThreshold - fireNoise) / fireThreshold);
                    //col = lerp(_FireHighlightCol, _FireCol, (fireThreshold - fireNoise) / fireThreshold);
                }
                else
                {
                    finalFireCol.a = 0.0;
                }
                col = lerp(col, finalFireCol, finalFireCol.a);
                //col = lerp(_FireHighlightCol, _FireCol, (fireThreshold - mainNoise) / fireThreshold);

                //col.a = fireThreshold + mainNoise;
                //col.a *= fireThreshold;
                //col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
