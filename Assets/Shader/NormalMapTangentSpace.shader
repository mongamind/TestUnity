Shader "ShaderTest/NormalMapTangentSpace" {
	Properties {
		_Color ("Color",color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Main Tex",2D) = "white"{}
		_BumpMap ("Normal Map",2D) = "bump" {}
		_BumpScale ("Bump Scale",Float) = 1.0
		_Specular ("Specular",Color) = (1.0,1.0,1.0,1.0)
		_Gloss ("Gloss",Range(8.0,256)) = 20
	}

	SubShader {
		Pass {
			Tags {
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM 
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			v2f vert(a2v i) {
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,i.vertex);

				//MainTex素材纹理的纹理坐标
				o.uv.xy = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				//BumpMap法线纹理的纹理坐标
				o.uv.zw = i.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				//切线空间除法线和切线外的另外一个坐标轴.
				float3 binormal = cross(normalize(i.normal),normalize(i.tangent.xyz)) * i.tangent.w;

				//模型空间到切线空间的转换矩阵，就是三个坐标轴的行排序
				float3x3 rotation = float3x3(i.tangent.xyz,binormal,i.normal);

				//在切线空间的光射线方向
				o.lightDir = mul(rotation,ObjSpaceLightDir(i.vertex));
				//在切线空间的视窗方向
				o.viewDir = mul(rotation,ObjSpaceViewDir(i.vertex));

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET {
				//把在顶点着色器中算出来的光线方向和视窗方向进行标准化.
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				//计算水平空间中的法向向量
				fixed4 packedNormal = tex2D(_BumpMap,i.uv.zw);

				//fixed3 tangentNormal;// = UnpackNormal(packedNormal); *= _BumpScale; 
				//tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale; //因为packedNormal是在纹理中采样出来的。而纹理图的像素颜色范围是（0~1），所以需要需要转换成方向向量的范围（-1~1）之间
				//tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy))); //勾股定理计算z的长度，xy值在xy平面上组成一个向量，点乘=|a||b|cos,因为夹角为0所以cos=1. 就是点成同一个向量的时候就是模平方的意思了。

				fixed3 tangentNormal = UnpackNormal(packedNormal); 
				tangentNormal.xy *= _BumpScale; //= (packedNormal.xy * 2 - 1) * _BumpScale; //因为packedNormal是在纹理中采样出来的。而纹理图的像素颜色范围是（0~1），所以需要需要转换成方向向量的范围（-1~1）之间
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy))); //勾股定理计算z的长度，xy值在xy平面上组成一个向量，点乘=|a||b|cos,因为夹角为0所以cos=1. 就是点成同一个向量的时候就是模平方的意思了。

				fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0,dot(tangentNormal,tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gloss);

				return fixed4(ambient + diffuse + specular,1.0);

			}

			ENDCG
		}
	}

	Fallback "Specular"
}