// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "ShaderTest/ForwardRendering" {
	Properties {
		_Diffuse ("Diffuse",Color) = (1.0,1.0,1.0,1.0)
		_Specular ("Specular",Color) = (1.0,1.0,1.0,1.0)
		_Gloss ("Gloss",Range(8.0,255)) = 20
	}

	SubShader {
		Pass {
			Tags  {"LightMode" = "ForwardBase"}
			CGPROGRAM 
			
			#pragma multi_compile_fwdbase

			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float  _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TESCOORD1;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldPos = mul(unity_ObjectToWorld,i.vertex).xyz;
				
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz); //平行光的_WorldSpaceLightPos0即是光的dir
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 diffuse = _LightColor0.rgb  * _Diffuse.rgb * max(0,dot(worldNormal,worldLightDir));			
	
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);
		
				fixed atten = 1.0;  //平行光没有衰弱
				
				return fixed4(ambient+ (diffuse + specular) * atten,1.0 );
			}

			ENDCG
		}

		Pass {
			Tags {"LightMode" = "ForwardAdd"}
  			
  			Blend One One
			
			CGPROGRAM
			
			#pragma multi_compile_fwdadd

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			fixed  _Gloss;
			

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

		
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldPos = mul(unity_ObjectToWorld,i.vertex).xyz;
				return o;
			}


			fixed4 frag(v2f i):SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif

				fixed3 diffuse = _LightColor0.rgb * _Specular.rgb * max(0,dot(worldNormal,worldLightDir));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);
				
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined(POINT)
						float3 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1)).xyz;
						fixed atten = tex2D(_LightTexture0,dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#elif defined (SPOT)
						float4 lightCoord = mul(unity_WorldToLight,float4(i.worldPos,1));
						fixed atten = (lightCoord.z > 0 ) * text2D(_LightTexture0,lightCoord.xy / lightCoord.w + 0.5).w * text2D(_LightTextB0, dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#esle 
						fixed atten = 1.0;
					#endif
				#endif
				
				return fixed4((diffuse + specular) * atten,1.0);
			}
			ENDCG
		}		

	}
	FallBack "Specular"
}
