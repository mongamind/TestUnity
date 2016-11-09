// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderTest/HalfFragmentLevelSpecular" {
	Properties {
		_Diffuse ("Diffuse", Color) = (1.0,1.0,1.0,1.0)
		_Specular ("Specular",Color) = (1.0,1.0,1.0,1.0)
		_Gloss ("Gloss",Range(2,256)) = 20
	}

	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v i ){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);
				o.worldNormal = mul(unity_ObjectToWorld,i.normal);
				o.worldPos = mul(unity_ObjectToWorld,i.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				fixed3 halfDir = normalize(worldLightDir + viewDir);//normalize(reflect(-worldLightDir,i.worldNormal));
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(halfDir,worldNormal)),_Gloss);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				return fixed4(diffuse + specular + ambient,1.0);
			}

			ENDCG
		}
	}

	Fallback "Specular"
}