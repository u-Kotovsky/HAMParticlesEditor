Shader "HAM Particles/CRT 2D/XYZ Bias Texture Sampling"
{
    Properties
    {
        _Offset("Offset", Vector) = (0,0,0,0)
        _Amplitude ("Amplitude", Float) = 1
        _Frequency ("Frequency", Float) = 1
        _Speed ("Speed", Float) = 1
        _Power ("Power", Range(-1,1)) = 1
        
        _Slider1 ("Slider 1", Range(-1,1)) = 1
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
            #include "Assets/_OwenTheProgrammer/ShaderGrimoire/CRT2D/Shaders/CRTStandard2D.cginc"
            #include "Util.cginc"
            #include "Assets/VivifyTemplate/Utilities/Shader Functions/Colors.cginc"

            float3 _Offset;
            float _Amplitude;
            float _Frequency;
            float _Speed;
            float _Power;
            float _Slider1;
            
            float2 TrochoidalWave(float a, float b, float t)
            {
                // x and y are positions
                // (x,y) = (a,b)
                
                // constant speed c exp(kb)
                // k=2PI/Lambda - wavenumber
                // Lambda - wavelength
                // c - phase speed
                
                return (float2)0;
            }
            
            float4 frag(crt_v2f i) : SV_Target
            {
                // Z is UP
                //float3 bias = (float3).5 + _Offset.xzy; // middle (color)
                float3 bias = (float3)0 + _Offset.xzy; // middle (color)
                
                // todo: pulse particles from center to edges
                
                float2 diff = (float2).5 - i.crt_uv.xy;
                float dist = length(diff);
                //float2 dir = dot(i.crt_uv.xy, (float2).5);
                
                // Trochoidal wave / Gerstner wave
                
                // -1,1
                float mult = 8;
                float pixelId = i.crt_uv.x + i.crt_uv.y;
                float t = _Time.x;
                // this is not trochoidal wave technically, I just make circles here
                float3 trochoidal_wave = float3(
                    sin((t+i.crt_uv.x)*mult),
                    cos((t+pixelId)*mult),
                    sin((t+i.crt_uv.y)*mult)
                    );
                /*float3 trochoidal_wave = float3(
                    cos(_Time.y+pixelId*i.crt_uv.x*mult),
                    sin(_Time.y+pixelId*mult),
                    sin(_Time.y+pixelId*i.crt_uv.y*mult)
                    );*/
                
                //trochoidal_wave += (float3)1;
                //trochoidal_wave /= (float3)2;
                
                //trochoidal_wave = normalize(trochoidal_wave); // it looks cool combined w/ below
                //trochoidal_wave = normalize(trochoidal_wave);
                
                //trochoidal_wave*=.1;
                
                //bias.xyz +=  trochoidal_wave.xyz;//(trochoidal_wave.xyz+1.)/2.;
                
                float3 normalized_wave = float3(
                    (trochoidal_wave.x+1)/2,
                    (trochoidal_wave.y+1)/2,
                    (trochoidal_wave.z+1)/2);
                
                bias += normalized_wave;
                
                // calculate distance of current texel to the center and put difference in bias
                //float2 diff1 = (float2)1 - i.crt_uv.xy;
                //float len1 = length(diff1);
                //float t1 = .2;//(sin(_Time.y)+1)/2;
                //bias.xy = lerp((float2).5, diff1, _Slider1);
                //bias.z = .5;
                
                //bias.xy += sin(_Time.x+pixelId)*.1;
                //bias = 0;
                
                // reset to default
                //bias.xyz = (float3).5+_Offset;
                
                
                //bias.x += (trochoidal_wave.x+1)*8/2;
                //bias.y += (trochoidal_wave.y+1)*8/2;
                //bias.z += (trochoidal_wave.z+1)*8/2;
                
                // the wall
                // move points near each other to form a thick line
                //bias.y = length(1 - i.crt_uv.y)*.9; // *.9 is to reduce color loss
                // adjust height 
                //bias.z = 1 - length(.5 - i.crt_uv.y); // height
                
                //bias.z -= length(1.5 - i.crt_uv.y);
                
                // todo: spin around
                // weird
                //bias.x = lerp(bias.x,(sin(_Time.y)+1)/2,dist); // -1,1
                //bias.y = lerp(bias.y,(cos(_Time.y)+1)/2,dist); // -1,1
                
                //bias.z = 1;
                // cone
                //bias.z -= (sin(dist*5)+1/2)*.35;
                //bias.z += sin(_Time.y+dist*128)*.015;
                
                // in and out deformation
                //bias.xy += diff * lerp(0,dist,sin(_Time.y)+1/2)*10;
                //bias.xy += diff * lerp(0,dist,_Slider1)*10;
                
                //bias.xy += diff * dist*5;
                
                //float2 circle = float2(sin(_Time.x), cos(_Time.x))*.5;
                
                //bias.x += circle.x;
                //bias.z += circle.x;
                //bias.y += circle.y;
                
                //bias.z += wave(i.crt_uv.xy, _Frequency, _Amplitude, _Time.x * _Speed);
                
                float4 outColor = float4(saturate(bias),1);
                
                //outColor.xyz = LinearToGammaSpace(outColor);
                //outColor.xyz = GammaToLinearSpace(outColor);
                //outColor.xyz = LinearToGammaSpaceExact(outColor);
                //outColor.xyz = gammaCorrect(outColor.xyz);
                
                return saturate(outColor);
            }

            ENDCG
        }
    }
}
