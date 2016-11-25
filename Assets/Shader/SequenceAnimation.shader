Shader "ShaderTest/SequenceAnimation" {
	Properties {
		_Color ("Tint Color",Color) = (1,1,1,1)
		_MainTex ("Sequence Image",2D) = "White" {}
		_HorizontalAmount ("Horizontal Amount",Float) = 4
		_VerticalAmount ("Vertical Amount",Float) = 4
		_Speed ("Speed",Range(1,100)) = 30
	}

	SubShader {
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

		Pass {
			Tags {"RenderType" = "ForwardBase"}

			ZWrite Off

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _HorizontalAmount;
			float _VerticalAmount;
			float _Speed;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);
				o.uv = TRANSFORM_TEX(i.texcoord.xy,_MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				float time = floor(_Time.y * _Speed);

				float row = floor(time / _HorizontalAmount);
				float culumn = time - row * _HorizontalAmount;
				half2 uv = i.uv + half2(culumn,-row);		//i.uv用于定位放大后的每个像素对应的一帧画面的哪一个像素. row,culumn计算用的是哪一张.
				uv.x /= _HorizontalAmount;		//上面的i.uv / _HorizontalAmount,_VerticalAmount是为了让图片放大以聚焦在第一章那里。
				uv.y /= _VerticalAmount;		//至于为什么row,culumn也要/ _HorizontalAmount,_VerticalAmount 是因为uv.xy 都是(0,1)范围超过了就是循环的. 所以culumn是(0,_HorizontalAmountt)的所以要保证row,culumn在(0,1)之间.

				float4 c = tex2D(_MainTex,uv);
				c.rgb *= _Color;

				return c;
			}


			ENDCG
		}
	}
}