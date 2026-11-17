Shader "HAM Particles/CRT 2D/Texture Sampling"
{
    Properties
    {
        [NoScaleOffset] _UV1Tex("HAM Particles UV1", 2D) = "white" {}
        //[Toggle(SHOW_UV1)]
        _ShowUV1("Show HAM Particles UV1", Range(0,1)) = 0
        [NoScaleOffset] _ColorTex("HAM Particles Color", 2D) = "white" {}
        [NoScaleOffset] _DepthTex("HAM Particles Depth", 2D) = "white" {}
        [NoScaleOffset] _XYZBiasTex("HAM Particles XYZ Bias", 2D) = "white" {}
        _Offset("Offset", Range(0,1)) = 0
        _UVMode("UV Mode (View 1, Drones)", Range(0,1)) = 0
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
            #include "Assets/_OwenTheProgrammer/ShaderGrimoire/CRT2D/Shaders/CRTStandard2D.cginc"

            float _ShowUV1;
            float _Offset;
            sampler2D _UV1Tex;
            sampler2D _ColorTex;
            sampler2D _DepthTex;
            sampler2D _XYZBiasTex;
            
            #define OUTPUT_W 1920.0
            #define OUTPUT_H 1080.0
            
            #define INPUT_W 568.0
            #define INPUT_H 568.0
            
            bool is_valid_bounds(float2 target, float2 min, float2 max)
            {
                // upper
                if (target.x > max.x) return false;
                if (target.y > max.y) return false;
                
                // lower
                if (target.x < min.x) return false;
                if (target.y < min.y) return false;
                // pass
                return true;
            }
            
            inline bool is_valid_bounds(float2 target)
            {
                return is_valid_bounds(target, 0, 1);
            }

            float4 frag(crt_v2f i) : SV_Target
            {
                // x: 0.2958, y: 0.526 (input/output), pixel input zw
                float4 ham_size = float4(INPUT_W/OUTPUT_W, INPUT_H/OUTPUT_H, INPUT_W, INPUT_H);
                
                // THAT IS IF WE GO FROM TOP LEFT CORNER. NO WE DONT.
                // ITS BOTTOM LEFT CORNER TO TOP RIGHT CORNER.
                //float height_offset = (208.0+304.0)/OUTPUT_H; // 0.474
                //float height_offset_with_size = height_offset + ham_size.y;
                
                // convert CRT coords to ham-sized coords
                // ex.: 0.25 / .2958
                float2 crt_uv = i.crt_uv.xy / ham_size.xy;
                
                // Color
                float2 color_uv = float2(0,0) + crt_uv;
                float4 color = tex2D(_ColorTex, color_uv);
                
                // Depth
                float2 depth_uv = float2(-1,.0) + crt_uv;
                float4 depth = tex2D(_DepthTex, depth_uv);
                
                // Bias
                float2 bias_uv = float2(-2,.0) + crt_uv;
                float4 bias = tex2D(_XYZBiasTex, bias_uv);
                
                float4 preview_uv1 = tex2D(_UV1Tex, i.crt_uv.xy);
                
                // clear color if it's behind the bounds
                color = is_valid_bounds(color_uv) ? color : (float4)0;
                //return color;
                depth = is_valid_bounds(depth_uv) ? depth : (float4)0;
                //return depth;
                bias = is_valid_bounds(bias_uv) ? bias : (float4)0;
                //return bias;
                
                float4 outColor = color + depth + bias;
                
                outColor = (outColor * (1-_ShowUV1)) + (preview_uv1 * _ShowUV1);
                
                return outColor;
            }

            ENDCG
        }
    }
}
