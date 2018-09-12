Shader "Unlit/LiquidWobbleSFX"
{
	Properties//variables accessible via the editor
	{
		_Tint ("Tint", Color) = (1,1,1,1)//liquid tint
		_MainTex ("Texture", 2D) = "white" {}//primary texture
		_FillAmmount("Fill Ammount",Range(-10,10)) = 0.0
		[HideInInspector] _WobbleX("Wobble", Range(-1,1)) = 0
		[HideInInspector] _WobbleZ("WobbleZ", Range(-1,1))= 0
		_TopColor("Top COlor", Color) = (1,1,1,1)
		_FoamColor("Foam Line Color", Color ) = (1,1,1,1)
		_Rim("Foam Line Width", Range(0,0.1)) = 0
		_RimColor("Rim Color", Color) = (1,1,1,1)
		_RimPower("Rim Power", Range(0,10)) = 0

	}
	SubShader
	{
		Tags { "Queue"="Geometry" "DisableBatching" = "True" }

		LOD 100

		Pass
		{
			Zwrite On
			Cull Off //get front and back faces
			AlphaToMask On //Transparency


			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float3 viewDIr :COLOR;
				float3 normal  : COLOR2;
				float fillEdge : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _FillAmmount, _WobbleX, _WobbleZ;
			float4 _TopColor, _RimColor, _FoamColor, _Tint;
			float _Rim, _RimPower;


			float4 RotateAroundYInDegrees(float4 vertex, float degrees)
			{
				float alpha = degrees * UNITY_PI / 180;
			}

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
