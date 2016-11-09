// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderTest/HalfFrameLevel" {
	Properties {
		_Diffuse ("Diffuse",color) = (1.0,1.0,1.0,1.0)
	}

	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM 
			#include "Lighting.cginc"
			fixed4 _Diffuse;

			#pragma vertex vert
			#pragma fragment frag

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				fixed3 worldNormal : TEXCOORD0;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);
				o.worldNormal = normalize(mul(unity_ObjectToWorld,i.normal));
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET {
				fixed3 worldLight = normalize(_WorldSpaceLightPos0);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(worldLight,i.worldNormal) * 0.5 + 0.5);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
				return fixed4(ambient + diffuse,1.0);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"

}