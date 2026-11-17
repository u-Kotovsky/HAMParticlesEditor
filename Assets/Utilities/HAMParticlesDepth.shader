Shader "HAM Particles/CRT 2D/Depth"
{
    Properties
    {
        _Offset("Offset", Range(0,1)) = 0
        _Amplitude ("Amplitude", Range(0, .02)) = .01
        _Frequency ("Frequency", Float) = 1
        _Speed ("Speed", Float) = 1
        _Power ("Power", Range(0,3)) = 1
        _Scale ("Scale", Range(0,15)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "PreviewType" = "Skybox"
        }

        Blend One Zero
        Lighting Off
        ZTest Always
        ZWrite Off

        Pass
        {
            Name "CRT Texture Sampler"
            CGPROGRAM
            #pragma vertex crt_vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Util.cginc"
            #include "Assets/_OwenTheProgrammer/ShaderGrimoire/CRT2D/Shaders/CRTStandard2D.cginc"
            #include "Assets/VivifyTemplate/Utilities/Shader Functions/Math.cginc"
            #include "Assets/VivifyTemplate/Utilities/Shader Functions/Noise.cginc"

            float _Offset;
            float _Amplitude;
            float _Frequency;
            float _Speed;
            float _Power;
            float _Scale;
            
            float4 frag(crt_v2f i) : SV_Target
            {
                float depth = _Offset;
                
                float3 parameter = float3(i.crt_uv.xy*_Scale //+ float2(_Time.x, -_Time.x)*_Speed
                    , _Time.x*_Speed);
                
                float noise_simplex = simplex(parameter);
                float noise_voronoi = voronoi(parameter);
                //depth += saturate(wave(i.crt_uv.xy, _Frequency, _Amplitude, _Time.x * _Speed*5)*_Power)*10;
                depth += noise_voronoi*_Power;//_Time.y;
                depth += noise_simplex*_Power;//_Time.y;
                
                //depth = 1.5- length(1.5 - i.crt_uv.y); // angle
                // the wall
                //depth = 1- length(.5 - i.crt_uv.y)*2;
                
                float4 outColor = float4(depth,depth,depth,1);
                
                return saturate(outColor); // alpha is used for HAM color shader to determine, draw color here or not
            }

            ENDCG
        }
    }
}
