﻿Shader "Custom/Base"
{
	Properties//what you see in editor is connected to shader code via this section
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_MainTex2("Albedo 2", 2D) = "white"{}
		_NormalMap("Normal Map",2D) = "white"{}
		_NormalMap2("Normal Map 2",2D) = "white"{}
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Range(0,1)) = 0.0
		_AlbedoLerp("Lerp Val", Range(0,1)) = 0.0
		_NormalLerp("Normal Lerp Val", Range(0,1)) = 0

	}
		SubShader
		{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
																													// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Phong fullforwardshadows//function declaration

																													// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _MainTex2;
			sampler2D _NormalMap;
			sampler2D _NormalMap2;
			struct Input//geting values from the art asset
			{
				float2 uv_MainTex;
				float2 uv_MainTex2;
			};


			float _Shininess;
			//fixed4 _SpecColor;
			fixed4 _Color;
			float _AlbedoLerp;
			float _NormalLerp;


			inline void LightingPhong_GI(SurfaceOutput s, UnityGIInput data, UnityGI gi)
			{
				gi = UnityGlobalIllumination(data, 1.0, s.Normal);
			}

			inline fixed4 LightingPhong(SurfaceOutput s, half3 viewDir, UnityGI gi)
			{
				UnityLight light = gi.light;
				float nl = max(0.0, dot(s.Normal, light.dir));//the angle at which light hits the normal
				float3 diffuseTerm = nl * s.Albedo.rgb * light.color;//Blending the color og the light and out albedo based on the normal&Light interaction
				float3 reflectionDirection = reflect(-light.dir, s.Normal); //Light always bounces opposite of what it hits
				float3 specularDot = max(0.0, dot(viewDir, reflectionDirection));//How much specular we get based on reflection
				float3 specular = pow(specularDot, _Shininess); //increases our specular
				float3 specularTerm = specular * _SpecColor.rgb * light.color.rgb;//comining spec color with light color
				float3 finalColor = diffuseTerm.rgb + specularTerm;//Specular is always additive

				fixed4 c;
				c.rgb = finalColor;
				c.a = s.Alpha;
				#ifdef UNITY_LIGHT_FUNCTION_APPLY_INDIRECT
					c.rgb += s.Albedo + gi.indirect.diffuse;
				#endif
				return c;

			}
																													// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
																													// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
																													// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_BUFFER_START(Props)
																													// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

			void surf(Input IN, inout SurfaceOutput o)//function definition// inout returns stuff to unity
			{

				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;//returns color for one pixel
				fixed4 c2 = tex2D(_MainTex2, IN.uv_MainTex2);
				fixed4 col = lerp(c, c2, _AlbedoLerp) * _Color;

				//modifying output
				o.Albedo = col.rgb;
				
				float3 normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
				float3 normal2 = UnpackNormal(tex2D(_NormalMap2, IN.uv_MainTex2));

				o.Normal = lerp(normal,normal2,_NormalLerp);

				// Metallic and smoothness come from slider variables
				o.Specular = _SpecColor;
				
				o.Gloss = col.a;
				o.Alpha = 1;
			}
			ENDCG
		}
			FallBack "Diffuse"
}
