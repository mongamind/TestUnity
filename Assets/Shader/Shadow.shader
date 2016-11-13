
Shader "ShaderTest/Shadow" {
	Properties {
		_Diffuse ("Diffuse",Color) = (1.0,1.0,1.0,1.0)
		_Specular ("Specular",Color) = (1.0,1.0,1.0,1.0)
		_Gloss ("Gloss",Range(8.0s,255)) = 20
	}

	SubShadesr {
		Tags {"RenderType" = "Opaque"}
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM

			#pragma multi_compile_fwdbase

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct  a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				SHADOW_COORDS(2);
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldPos = mul(Unity_ObjectToWorld,i.vertex).xyz;
				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target{
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 ambient = UNTIY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0,dot(worldNormal,worldLightDir));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);

				fixed atten = 1.0;

				fixed shadow = SHADOW_ATTENUATION(i);

				return fixed4(ambient + (diffuse + specular) * atten * shadow,1.0);
			}

			ENDCG
		}
	}

}
