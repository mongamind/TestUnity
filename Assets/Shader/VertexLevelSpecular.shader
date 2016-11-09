// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderTest/VertexLevelSpecular" {
	Properties {
		_Diffuse ("Diffuse",Color) = (1.0,1.0,1.0,1.0)
		_Specular ("Specular",Color) = (1.0,1.0,1.0,1.0)
		_Gloss ("Gloss",Range(1,256.0)) = 20
	}

	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			#pragma vertex vert
			#pragma fragment frag

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : POSITION;
				fixed3 color : COLOR;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);

				fixed3 worldNormal = normalize(mul(unity_ObjectToWorld,i.normal));
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,i.vertex).xyz);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir,viewDir)),_Gloss);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				o.color = ambient + diffuse + specular;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET {
				return fixed4(i.color,1.0);
			}



			ENDCG

		}
	}

	Fallback "Specular"
}