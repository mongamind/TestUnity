// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderTest/FrameLevelDiffuse"{
	Properties {
		_Diffuse ("Diffuse",Color) = (1.0,1.0,1.0,1.0)
	}

	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM 
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;

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
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(i.worldNormal,worldLight));

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				return fixed4(diffuse + ambient,1.0);
			}

			ENDCG
		}

	}

	Fallback "Diffuse"
}