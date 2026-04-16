Shader "Example/NetherPortal"
{
    Properties
    {  
        _FirstCol("_FirstCol", Color) = (0.800, 0.176, 0.791, 0)
        _SecondCol("_SecondCol", Color) = (0.318, 0.080, 0.445, 0)
        _GridScale("_GridScale", vector) = (0.2, 0.2, 0.0, 0.0)
        //end of learning
        _SpiralDensity("_SpiralDensity", float) = 1.880
        _SpiralDamper("_SpiralDamper", float) = 1.0
        _Resolution("_Resolution", vector) = (64.0, 64.0, 0.0, 0.0)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque"}

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "UnityCG.cginc"

            vector colorOne;
            vector colorTwo;
            float period;
            float lines;

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

            float mod(float val, float divider)
            {
                float result = val % divider;
                if (result < 0)
                {
                    result = divider + result;
                }
                return result;
            }

            float2 getChunkShift2d(float chunkId)
            {
                float2 res = float2(0, 0);
                res.x = floor(mod(chunkId, 2.0)) - 0.5;
                res.y = floor(mod(chunkId, 4.0) / 2.0) - 0.5;
                return res;
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = UnityObjectToClipPos(IN.positionOS.xyz);
                OUT.screenPosDupa = ComputeScreenPos(OUT.positionHCS);
                return OUT;
            }

            vector _FirstCol;
            vector _SecondCol;
            vector _GridScale;

            float _SpiralDensity;
            float _SpiralDamper;
            vector _Resolution;

            half4 frag(Varyings IN) : SV_Target
            {
                //float2 uv = gl_FragCoord.xy / u_resolution.xy;
                //uv.x *= u_resolution.x / u_resolution.y;
                //float2 pos = uv;
                float2 pos = IN.screenPosDupa.xy / IN.screenPosDupa.w;

                float3 col = float3(0, 0, 0);

                //*
                //later
                //simple space partitioning
                float2 localPos = pos - float2(0.5, 0.5);
                //float2 localPos = float2(mod(pos.x, _GridScale.x), mod(pos.y, _GridScale.y));
                localPos /= _GridScale;
                localPos = localPos - float2(0.5, 0.5);

                //first
                //float2 localPos = pos - float2(0.5, 0.5);
                //calculate the angle from point
                float angle = atan2(localPos.x, localPos.y) / 3.14;
                angle = (angle + 1.0) / 2.0;


                float dist = length(localPos);

                float gradient = angle + dist - _Time.y; //+= u_time;
                gradient = angle + dist - _Time.y;
                gradient = frac(gradient);

                //long distance damper //this makes it look better for some reason
                gradient = min(gradient * dist, 1.0);

                gradient = pow(gradient, 3.288);
                //remap to 05 05
                gradient = abs(gradient * 2.0 - 1.0);

                //col = float3(gradient);
                col = lerp(_FirstCol, _SecondCol, gradient);
                return float4(col, 1.0);

                //end of self work
                //*/


                //final effect
                //-----------------------------------------------------------------------------------
                /*
                //pixelation effect
                pos = floor(pos * _Resolution) / _Resolution;

                //simple space partitioning

                float2 gridNum = floor(pos / _GridScale.xy);
                float2 localPos = float2(mod(pos.x, _GridScale.x), mod(pos.y, _GridScale.y));
                localPos /= _GridScale.xy;
                localPos = localPos - float2(0.5, 0.5);

                //disable every second space
                float finalGradient = 1.0;
                //check every nearby chunk
                for (float i = 0.0; i < 9.0; i++)
                {
                    float2 chunkId = gridNum + getChunkShift2d(i);
                    float2 chunkRelativePos = localPos + getChunkShift2d(i);
                    if (mod((chunkId.x + chunkId.y), 2.0) < 1.0)
                    {
                        //first
                    //float2 localPos = pos - float2(0.5, 0.5);
                    //calculate the angle from point
                    float angle = atan2(chunkRelativePos.x, chunkRelativePos.y) / 3.14;
                    angle = (angle + 1.0) / 2.0;

                    float dist = length(chunkRelativePos);

                    float gradient = angle * sign(mod(chunkId.y, 2.0) - 1.0) + dist * _SpiralDensity - _Time.y; //this weird sign makes every second row spin in another direction
                    gradient = mod(gradient, 1.0);
                    //long distance damper
                    gradient = min(gradient * dist * _SpiralDamper, 1.0);
                    if (dist > 1.0)
                    {
                        gradient = 1.0;
                    }

                    gradient = pow(gradient, 3.288);
                    //remap to 05 05
                    gradient = abs(gradient * 2.0 - 1.0);

                    //finalGradient = min(finalGradient, gradient);
                    finalGradient *= gradient;
                }
            }




                //col = float3(gradient);
                col = lerp(_FirstCol, _SecondCol, finalGradient);

                return float4(col, 1.0);
                //gl_FragColor = vec4(col,1.0);
                */
            }
            ENDHLSL
        }
    }
}