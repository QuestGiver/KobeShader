Shader "Unlit/BasicSpecular"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,0,0,1)
		_BumpMap("Bump Map",2D) = "white"{}
		_Ambient("Ambient", Range(0,1)) = 0.25
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_Shininess("Shininess", float) = 10
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;

				float4 vertexClip : SV_POSITION;
				float4 vertexWorld : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
				float3 worldNormal2 : TEXCOORD3;
				float3 worldNormal3 : TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _BumpMap;
			float4 _Color;
			float _Ambient;
			float _Shininess;
			//float4 _SpecColor;

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertexClip = UnityObjectToClipPos(v.vertex);
				o.vertexWorld = mul(unity_ObjectToWorld, v.vertex);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				half3 tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBitTangent = cross(worldNormal, worldTangent) * tangentSign;

				o.worldNormal = half3(worldTangent.x, worldBitTangent.x, worldNormal.x);
				o.worldNormal2 = half3(worldTangent.y, worldBitTangent.y, worldNormal.y);
				o.worldNormal3 = half3(worldTangent.z, worldBitTangent.z, worldNormal.z);


				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half3 tNormal = UnpackNormal(tex2D(_BumpMap, i.uv));

				half3 worldNormal;
				worldNormal.x = dot(i.worldNormal, tNormal);
				worldNormal.y = dot(i.worldNormal2, tNormal);
				worldNormal.z = dot(i.worldNormal3, tNormal);

				float3 viewDirection = normalize(UnityWorldSpaceViewDir(i.vertexWorld));
				float3 lightDirection = normalize(UnityWorldSpaceLightDir(i.vertexWorld));
				//directional light

				float4 col = tex2D(_MainTex, i.uv);


				float3 normalDirection = normalize(worldNormal);
				float nl = max(_Ambient, dot(normalDirection, lightDirection));
				float4 diffuseTerm = nl * (_Color * col) * _LightColor0;
				//specular


				float3 reflectionDirection = reflect(-lightDirection, normalDirection);
				float3 specularDot = max(0.0, dot(viewDirection, reflectionDirection));
				float3 specular = pow(specularDot, _Shininess);
				float4 specularTerm = float4(specular, 1) * (_SpecColor * col) * _LightColor0;//(_SpecColor * col)
				//final color
				float4 finalColor = diffuseTerm + specularTerm;
				return finalColor;

			}
			ENDCG
		}
	}
}
