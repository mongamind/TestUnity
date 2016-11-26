Shader "ShaderTest/ScrollingBackground" {
	Properties {
		_BackTex ("Back Groud",2D) = "White" {}
		_FrontTex ("Front Ground",2D) = "White" {}
		_ScrollBackX ("Speed Back",Float) = 1.0
		_ScrollFrontX ("Speed Front",Float) = 1.0
	}

	SubShader {
		Tags {"Queue"= "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			sampler2D _BackTex;
			float4 _BackTex_ST;
			sampler2D _FrontTex;
			float4 _FrontTex_ST;
			float _ScrollBackX;
			float _ScrollFrontX;

			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION; 
				float4 uv : TEXCOORD1;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);
				o.uv.xy = TRANSFORM_TEX(i.texcoord,_BackTex) + frac(float2(_ScrollBackX,0.0) * _Time.y);
				o.uv.zw = TRANSFORM_TEX(i.texcoord,_FrontTex) + frac(float2(_ScrollFrontX,0.0) * _Time.y);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed4 backColor = tex2D(_BackTex,i.uv.xy);
				fixed4 frontColor = tex2D(_FrontTex,i.uv.zw);

				fixed4 colorEnd = lerp(backColor,frontColor,frontColor.a);

				return colorEnd;
			}
			ENDCG
		}
	}
}