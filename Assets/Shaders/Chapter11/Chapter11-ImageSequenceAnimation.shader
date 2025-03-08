Shader "Unity Shaders Book/Chapter 11/Image Sequence Animation" {
	Properties {
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Image Sequence", 2D) = "white" {}
    	_HorizontalAmount ("Horizontal Amount", Float) = 4
    	_VerticalAmount ("Vertical Amount", Float) = 4
    	_Speed ("Speed", Range(1, 100)) = 30
	}
	SubShader {
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		
		Pass {
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			
			#pragma vertex vert  
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _HorizontalAmount;
			float _VerticalAmount;
			float _Speed;
			  
			struct a2v {  
			    float4 vertex : POSITION; 
			    float2 texcoord : TEXCOORD0;
			};  
			
			struct v2f {  
			    float4 pos : SV_POSITION;
			    float2 uv : TEXCOORD0;
			};  
			
			v2f vert (a2v v) {  
				v2f o;  
				o.pos = UnityObjectToClipPos(v.vertex);  
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);  
				return o;
			}  
			
			fixed4 frag (v2f i) : SV_Target {
				float time = floor(_Time.y * _Speed);  //_Time.y自该场景加载后所经过的时间,乘以_Speed得到模拟的时间，取整得到整数时间
				float row = floor(time / _HorizontalAmount);//当前对应的行索引
				float column = time - row * _HorizontalAmount;//当前对应的列索引

				//利用行列索引值构建真正的采样坐标
				// half2 uv = float2(i.uv.x /_HorizontalAmount, i.uv.y / _VerticalAmount);
				// uv.x += column / _HorizontalAmount;//_HorizontalAmount水平方向关键帧图像个数
				// uv.y -= row / _VerticalAmount;
				// half2 uv = i.uv + half2(column, -row);
				// uv.x /=  _HorizontalAmount;
				// uv.y /= _VerticalAmount;
				
				// fixed4 c = tex2D(_MainTex, uv);
				// c.rgb *= _Color;

				
				// int totalFrames = _HorizontalAmount * _VerticalAmount;
				// float time = _Time.y * _Speed;
				// int frameIndex = (int)time % totalFrames;
				//
				// // 计算行列位置
				// float row = frameIndex / _HorizontalAmount;    // 当前行
				// float column = frameIndex % _HorizontalAmount; // 当前列
				//
				// 计算每个子帧的 UV 偏移
				float2 uv = i.uv; // 原始 UV
				uv.x = (uv.x + column) / _HorizontalAmount;    // 水平偏移
				uv.y = 1.0 - (uv.y + row) / _VerticalAmount;    // 垂直偏移（Unity 的 UV 原点在左下角）
				
				fixed4 c = tex2D(_MainTex, uv);
				c.rgb *= _Color;

				return c;
			}
			
			ENDCG
		}  
	}
	FallBack "Transparent/VertexLit"
}
