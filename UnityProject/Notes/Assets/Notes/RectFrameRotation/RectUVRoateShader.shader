Shader "Game/RectRotate"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}      
        _Parameters("xSize_yCount_zSpeed",Vector) = (0.1,1,1,0 )
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "RenderPipeLine" = "UniversalRenderPipeline"}

        Blend Srcalpha OneMinusSrcAlpha
        cull off
        ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl" 

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half4 color:COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 posCS : SV_POSITION;
                half4 color :COLOR;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            float4 _Parameters;
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.posCS = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;                        
            }

            half4 frag(v2f i) : SV_Target
            {
                i.uv -=0.5;                

                /////极坐标/////
                float radians = atan2(i.uv.y,i.uv.x);
                float pi = 3.1415926;
               // half degress =radians/pi; //得到 x正方向，逆时针，0->pi,-pi->0
                //degress = abs(degress);//看范围
                //return half4(degress,degress,degress,1);//看范围
                //改成一个周期
                float degress = (radians+pi)/(2*pi) * _Parameters.y;         
                half u = frac(1- degress -_Time.x*_Parameters.z) ;       
                //return half4(u,u,u,1);
                /////极坐标/////                


                /////////变成矩形,中间挖掉///////                
                half2 absUV =abs(i.uv);
                half2 absUVSubstract = absUV-_Parameters.x;       
                half2 afterSaturate = saturate(absUVSubstract);            
                half v =  length(afterSaturate);
                //变换到{0，1}
                half d = 0.5-_Parameters.x; 
                v = smoothstep(0,d,v);
                //v= v/d; //<--试试？
                //half4 col = half4(v,v,v,1);
                /////////变成正方形///////
               
                half2 uv = half2(u,v);
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv) * i.color;   
                
                
                return col;
            }
            ENDHLSL
        }
    }
}
