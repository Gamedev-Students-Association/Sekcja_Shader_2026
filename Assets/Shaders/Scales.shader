Shader "Example/URPUnlitShaderBasic"
{
    Properties
    {   
        ScaleColFirst("Color One", Color) = (1,1,1,1)
        ScaleColSecond("Color Two", Color) = (1,1,1,1)
        BreakScaleFirstCol("BreakScaleFirstCol", Color) = (1, 1, 1, 1)
        BreakScaleSecondCol("BreakScaleSecondCol", Color) = (1, 1, 1, 1)
        squareScale("square Scale", vector) = (1,1,1,1)
        HexagonRatio("Hexagon Ratio", Range(0, 1)) = 0.5
        GradientHalo ("GradientHalo", float) = 0
        BrokenTheshold ("BrokenThreshold", Range(0, 1)) = 0
        GradientReduction ("GradientReduction", float) = 1
        _BaseMap("Python ssie Base Map", 2D) = "green"
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"   
            #include "UnityCG.cginc"

            vector ScaleColFirst;
            vector ScaleColSecond;
            vector BreakScaleFirstCol;
            vector BreakScaleSecondCol;
            vector squareScale;
            float HexagonRatio;
            float GradientHalo;
            float BrokenTheshold;
            float GradientReduction;

            struct Attributes
            {
                float4 positionOS   : POSITION; 
                float2 uv           : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
            };     
            sampler2D _BaseMap;
            float4 _BaseMap_ST;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                //OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionHCS = UnityObjectToClipPos(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            float square(float2 position) {
                float result = 0;

                position = abs(position);
                result = max(position.x, position.y) - 1;
                return result;
                //python srajton
            }

            float diamond(float2 position)
            {
                float result = 0;
                position = abs(position);
                result = position.x + position.y;
                return result;
            }

            float enlongedDiamond(float2 pos, float height)
            {
                float res = 0;
                pos = abs(pos);
                if (pos.y < height) //main enlonged body
                {
                    res = pos.x;
                }
                else
                {
                    res = pos.x + max(0, pos.y - height) / (1 - height) / 2;
                }
                res -= 1;
                return res;
            }

            /*
            float2 pointy_hex_corner(center, size, i)
            {
                float angle_deg = 60 * i - 30°
                float angle_rad = PI / 180 * angle_deg
                return Point(center.x + size * cos(angle_rad),
                        center.y + size * sin(angle_rad))
            }
            */

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
            

            float2 WhiteNoise2d(float2 data, float2 seed)
            {
                return float2(PseudoRand(float2(data.x, seed.x)), PseudoRand(float2(data.y, seed.y)));
            }

            float2 LinearCombineNoise2d(float2 pos, float2 seed)
            {
                return WhiteNoise2d(float2((pos.x * pos.y) * pos.y, (pos.x * pos.y) * pos.x), seed);
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float4 color = tex2D(_BaseMap, IN.uv);
                float2 uv = IN.uv;

                //pseudo random epsilon
                float epsilon = 64;

                float2 pos = uv;
                float2 chunkId = floor(pos * squareScale.xy);
                float2 hexId = chunkId;
                //*
                if (chunkId.y % 2 == 1)
                {
                    pos.x += 1.0 / squareScale.x / 2.0;
                    hexId = floor(pos * squareScale.xy);
                }
                //*/

                float2 innerPos = (pos * squareScale.xy) % float2(1, 1);
                innerPos -= float2(0.5, 0.5);
                innerPos *= 2.0;

                //creating dumbass hexagon
                color = float4(innerPos.x, innerPos.y, 0, 1);
                //*
                float shapeScale = enlongedDiamond(innerPos, 0.5);
                if (shapeScale < 0) //main square
                {
                }
                else //not hitted, neighbour chunk
                {
                    //chunk combination
                    float2 neighbourChunkShift = float2(max(-1, sign(innerPos.x)), sign(innerPos.y));
                    neighbourChunkShift *= 2.0;
                    neighbourChunkShift.x -= 1 * sign(innerPos.x);

                    float2 neighbourChunkIdShift = float2(max(-1, sign(innerPos.x) - 1), sign(innerPos.y)); //max(-1, sign(innerPos.x))
                    if (chunkId.y % 2 == 0)
                    {
                        neighbourChunkIdShift.x += 1;
                    }
                    //change chunkId and pos BASED on neighbour chunk
                    hexId = float2(hexId.x + neighbourChunkIdShift.x, hexId.y + neighbourChunkIdShift.y);
                    innerPos -= neighbourChunkShift;

                    shapeScale = enlongedDiamond(innerPos, HexagonRatio);
                }
                //*/

                /*
                if ()
                {

                }
                */

                /*
                if (innerPos.x > 0.9 || innerPos.y > 0.9)
                {
                    color = float4(0, 0, 0, 1);
                }
                */

                //pseudo random testing
                float noise = LinearCombineNoise2d(hexId + float2(epsilon, epsilon), float2(0, 0));
                noise = (noise + 1) / 2;

                //shapeScale = pow(shapeScale, 6);
                shapeScale = -shapeScale;

                if (BrokenTheshold < noise)
                {

                    float4 boxColor = lerp(BreakScaleFirstCol, BreakScaleSecondCol, max(0, (-shapeScale - GradientHalo) / GradientHalo));
                    float4 sphereColor = lerp(BreakScaleSecondCol, BreakScaleFirstCol, length(innerPos));
                    color = lerp(BreakScaleSecondCol, BreakScaleFirstCol, shapeScale);
                    color *= boxColor;

                    color *= lerp(1, 100, pow(1 - shapeScale, 36));
                    //color *= pow(1 - shapeScale, 12));
                }
                else
                {
                    float4 boxColor = lerp(ScaleColSecond, ScaleColFirst, max(0, (shapeScale - GradientHalo) / GradientHalo));
                    float4 sphereColor = lerp(ScaleColSecond, ScaleColFirst, length(innerPos));
                    color = lerp(ScaleColSecond, ScaleColFirst, shapeScale);
                    color *= boxColor; //* sphereColor
                    color = clamp(color, 0, 1);
                }

                //color = lerp(ScaleColFirst, ScaleColSecond, scale * 8);
                //color = float4(noise, noise, noise, 1);

                //color = float4(hexId.x / squareScale.x, hexId.y / squareScale.y, 0, 1); //hexId.x / squareScale.x
                
                //return float4(int3(10 * color.xyz) / 10.0, color.w);
                //float4 curGradient = float4(round(GradientReduction * color.xyz) / GradientReduction, color.w);
                //float4 nextGradient = float4((round(GradientReduction * color.xyz) + 1) / GradientReduction, color.w);
                //color = lerp(curGradient, nextGradient, 0.2);
                //color = float4(round(GradientReduction * color.xyz) / GradientReduction, color.w);

                return color;
            }
            ENDHLSL
        }
    }
}