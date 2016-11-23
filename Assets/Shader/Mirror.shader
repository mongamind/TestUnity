Shader "TestUnity/Mirror" {
	Properties {
		_MainTex ("Main Tex",2D) = "white"{}
	}

	Subshader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			sampler2D _MainTex;
			float4 _MainTex_ST;

			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);
				o.uv = i.texcoord;
				o.uv.x = 1 - o.uv.x;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				return tex2D(_MainTex,i.uv);
			}

			ENDCG
		}
	}

	Fallback "Specular"
}