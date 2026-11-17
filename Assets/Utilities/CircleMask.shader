Shader "HAM Particles/CRT 2D/Circle Mask"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _MaskTex("Mask Texture", 2D) = "red" {}
        _Radius("Radius", Range(-1,2)) = 0.5
        _Radius2("Smooth", Range(-1,2)) = 0.5
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
            #include "Assets/VivifyTemplate/Utilities/Shader Functions/Colors.cginc"
            #include "Assets/VivifyTemplate/Utilities/Shader Functions/Noise.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            
            float _Radius;
            float _Smooth;
            
            float4 frag(crt_v2f i) : SV_Target
            {
                float4 mainColor = tex2D(_MainTex, i.crt_uv.xy);
                float4 mask = tex2D(_MaskTex, i.crt_uv.xy); // use alpha for clearing thing out
                
                float mask2 = 
                    //circle(i.crt_uv.xy, _Radius);
                    //polar(i.crt_uv.xy, 16*sin(_Time.y));
                    //triangle1(i.crt_uv.xy);
                    circle2(i.crt_uv.xy, _Radius, _Smooth);
                
                float totalMask = saturate(mask2*saturate(mask.a*50));
                
                //float3 r = rainbow((length(float2(0.5,0.5) - i.crt_uv.xy)+_Time.x));
                //float3 r = hueShift(float3(1,0,0), _Time.x);
                
                
                float3 parameter = float3(i.crt_uv.xy*10 //+ float2(_Time.x, -_Time.x)*_Speed
                    , _Time.x*1);
                float noise_simplex = simplex(parameter);
                float noise_voronoi = voronoi(parameter);
                //mainColor = float4(rainbow(noise_simplex+_Time.x)*smoothstep(0,1,noise_simplex),1);
                //mainColor = float4(smoothstep(0.5,1,noise_simplex)*rainbow(_Time.x),1);
                //mainColor += noise_simplex*_Power;//_Time.y;
                
                float4 outColor = float4(mainColor.xyz*totalMask//*r
                    ,1);
                
                return saturate(outColor*_Color);
            }

            ENDCG
        }
    }
}
