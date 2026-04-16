Shader "GSA/CloudsSkybox"
{
    Properties
    {
        _NoiseScale("_NoiseScale", vector) = (1, 1, 1, 1)
        _CloudThreshold("_CloudThreshold", Range(0, 1)) = 1
        _TimeScale("_TimeScale", float) = 1
        _RainIntensity("_RainIntensity", float) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "PreviewType" = "Skybox" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 positionOS   : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float4 screenPosDupa : TEXTCOORD0;
            };

            float3 hash(float3 p)
            {
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

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = UnityObjectToClipPos(IN.positionOS.xyz);
                OUT.screenPosDupa = ComputeScreenPos(OUT.positionHCS);
                return OUT;
            }


            uniform vector _NoiseScale; //float3
            uniform float _CloudThreshold;
            uniform float _TimeScale;
            uniform float _RainIntensity;

            float4 frag(Varyings IN) : SV_Target
            {
                float2 uv = IN.screenPosDupa.xy/IN.screenPosDupa.w;
                float4 col = float4(0, 0, 0, 1);

                float noise3 = GradientNoise(float3((uv.x) * _NoiseScale.x, 0, 0 * _NoiseScale.z));
                noise3 = (noise3 + 1) / 2;

                float noise2 = GradientNoise(float3((uv.x) * _NoiseScale.x, uv.y * _NoiseScale.y, 0)); //(_Time.y / _TimeScale) * _NoiseScale.z
                noise2 = (noise2 + 1) / 2;

                float noise = GradientNoise(float3((uv.x + noise3 * _Time.y * _RainIntensity) * _NoiseScale.x, pow(uv.y, _Time.y / _TimeScale) * _NoiseScale.y, 0 * _NoiseScale.z));
                noise = (noise + 1) / 2;


                if (noise < _CloudThreshold)
                {
                    col = float4(0, 0, 0, 1);
                }
                else
                {
                    col = float4(1, 1, 1, 1);
                }

                return col;
            }
            ENDHLSL
        }
    }
}