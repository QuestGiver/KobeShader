Shader "Unlit/Lighting"
{
	Properties
	{
		
		_MainTex ("Albedo", 2D) = "white" {}
		_BumpMap("Bump Map",2D) = "white"{}
		_Color("Color",Color) = (1,1,1,1)
		_Ambient("Ambient", Range(0,1)) = 1
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
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;

				//float3 worldNormal : TEXCOORD1;

				half3 tspace0 : TEXCOORD2;
				half3 tspace1 : TEXCOORD3;
				half3 tspace2 : TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float4 _Color;
			float _Ambient;



			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				half3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				half3 tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBitTangent = cross(worldNormal, worldTangent) * tangentSign;

				

				o.tspace0 = half3(worldTangent.x, worldBitTangent.x, worldNormal.x);
				o.tspace1 = half3(worldTangent.y, worldBitTangent.y, worldNormal.y);
				o.tspace2 = half3(worldTangent.z, worldBitTangent.z, worldNormal.z);

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			

			fixed4 frag (v2f i) : SV_Target
			{
				half3 tNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				half3 worldNormal;
				worldNormal.x = dot(i.tspace0, tNormal);
				worldNormal.y = dot(i.tspace1, tNormal);
				worldNormal.z = dot(i.tspace2, tNormal);

				float4 col = tex2D(_MainTex, i.uv);

				float3 normalDirection = normalize(worldNormal);
				float nl = max(_Ambient, dot(normalDirection, _WorldSpaceLightPos0.xyz));
				float4 diffuseTerm = nl * (_Color * col) * _LightColor0;

				// sample the texture




				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, diffuseTerm);
				return diffuseTerm;
			}
			ENDCG
		}
	}
}
