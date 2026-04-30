Shader "Unlit/PlaneClouds"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseScale ("CloudsScale", vector) = (1, 1, 1, 0)
        _NoiseShiftScale ("WindScale", vector) = (1, 1, 1, 0)
        _CloudCol ("CloudsColor", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "RenderQueue"="Transparent" }
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #ifndef NOISE_LIB
            #include "NoiseLib.cginc"
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
                float4 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            vector _NoiseScale;
            vector _NoiseShiftScale;
            float4 _CloudCol;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                col = _CloudCol;

                float baseNoise = RemapNoise(GradientNoise(float3(i.worldPos.x, i.worldPos.y, 0.0) * _NoiseShiftScale.xyz + float3(0.0, 0.0, 0.0)));
                float finalNoise = RemapNoise(GradientNoise((float3(i.worldPos.x, i.worldPos.y, 0.0)) *_NoiseScale.xyz + float3(baseNoise, baseNoise, 0.0) + float3(_Time.y, _Time.y, 0.0)));


                //col.a = smoothstep(0, 1, pow(finalNoise, 2)); //pow(finalNoise, 4);
                col.a = 1 - pow((1 - pow(finalNoise, 4)), 12);

                //col = float4(baseNoise, baseNoise, baseNoise, 1.0);

                return col;
            }
            ENDCG
        }
    }
}
