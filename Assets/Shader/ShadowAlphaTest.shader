﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "ShaderTest/ShadowAlphaTest" {
	Properties {
		_Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Main Tex", 2D) = "white" {}
		_Cutoff ("Cut off",Range(0,1)) = 0.5
	}

	SubShader {
		Tags {"Queue" = "AlphaTest" 
				"IgnoreProjector" = "True"
				"RenderType" = "TransparentCutout"
			}
		Pass {
			Tags {"LightMode" = "ForwardBase"}

			cull off

			CGPROGRAM
			#pragma multi_compile_fwdbase

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			}; 

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldPos = mul(unity_ObjectToWorld,i.vertex);
				o.uv = TRANSFORM_TEX(i.texcoord,_MainTex);

				TRANSFER_SHADOW(o);

				return o;
				
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed4 texColor = tex2D(_MainTex,i.uv);
				clip(texColor.a - _Cutoff);

				fixed3 worldNormal = normalize(i.worldNormal);

				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(worldNormal,worldLightDir));

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				return fixed4(ambient + diffuse * atten, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Transparent/Cutout/VertexLit"
}