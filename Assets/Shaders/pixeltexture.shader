Shader "Unlit/pixeltexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Resolution ("Resolution", vector) = (0, 0, 0, 0)
        _ColorLevels ("ColorLevels", vector) = (0, 0, 0, 0)
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
            vector _Resolution;
            vector _ColorLevels;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                float2 uv = i.uv;
                //*
                uv *= _Resolution.xy;
                uv = floor(uv);
                uv /= _Resolution.xy;
                //*/

                float2 chunkPos = i.uv;
                chunkPos *= _Resolution.xy;
                chunkPos %= 1;
                //uv /= _Resolution.xy;

                float centerDist = 1.2 - length(chunkPos - float2(0.5, 0.5));

                //centerDist *= 20;
                centerDist = pow(centerDist, 20);

                //fixed4 col = float4(centerDist, centerDist, centerDist, 1.0);
                fixed4 col = tex2D(_MainTex, uv);

                _ColorLevels = abs(_ColorLevels);
                col.xyz *= _ColorLevels.xyz;
                col = floor(col);
                col.xyz /= _ColorLevels.xyz;
                col.a = 1.0;
                
                //col = float4(uv.x, uv.y, 0.0, 1.0);
                
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
