Shader "Unlit/PlaneClouds"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseScale ("CloudsScale", vector) = (1, 1, 1, 0)
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            vector _NoiseScale;
            float4 _CloudCol;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                col = _CloudCol;


                float baseNoise = RemapNoise(GradientNoise(float3(i.uv.x, i.uv.y, 0.0) * _NoiseScale.xyz));

                col.a = baseNoise;

                //col = float4(baseNoise, baseNoise, baseNoise, 1.0);

                return col;
            }
            ENDCG
        }
    }
}
