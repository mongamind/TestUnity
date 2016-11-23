Shader "ShaderTest/Refraction" {
	Properties {
		_Color ("Tint Color", Color) = (1,1,1,1)
		_RefractColor("Refract Color",Color) = (1,1,1,1)
		_RefractAmount("Refract Amount",Range(0,1)) = 1
		_RefractRatio("Refract Ratio", Range(0.1,1)) = 0.5
		_Cubemap("Refract Cubemap",Cube) = "_Skybox" {}
	}

	Subshader {
		Tags {"RenderType" = "Opaque" "Queue" = "Geometry"}

		Pass {
			Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _RefractColor;
			half _RefractAmount;
			half _RefractRatio;
			samplerCUBE _Cubemap;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TexCOORD1;
				float3 worldViewDir : TexCOORD2;
				fixed3 worldRefr : TEXCOORD3;
				SHADOW_COORDS(4)
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);
				o.worldPos = mul(unity_ObjectToWorld,i.vertex);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefr = refract(-normalize(o.worldViewDir),normalize(o.worldNormal),_RefractRatio);

				TRANSFER_SHADOW(o);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(i.worldViewDir);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir));

				fixed3 refraction = texCUBE(_Cubemap,i.worldRefr).rgb * _RefractColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				fixed3 color = ambient + lerp(diffuse,refraction,_RefractAmount) * atten;

				return fixed4(color,1.0);
			}
			ENDCG
		}
	}

	Fallback "Reflective/VertexLit"
}