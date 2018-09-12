Shader "Custom/Tess" {
	Properties {
		_Tess("Tessalation", Range(1,32)) = 4
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_MainTex2("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_WaveSpeed("Wave Speed",float) = 30
		_WaveAmp("Wave Amplitude",float) = 1
		_NoiseTex("Noise Tex", 2D) = "white" {}
		_NormalMap("Normal Map",2D) = "white"{}
		_NormalMap2("Normal Map 2",2D) = "white"{}
		_ScrollSpeed("Normal Scroll Speed", float) = 0.1
		_ScrollSpeed2("Normal Scroll Speed 2", float) = 0.1
		_NormalLerp("Normal Lerp Val", Range(0, 1)) = 0
		_VectorPos("Vector Position", vector) = (0,0,0,0)
		//_WorldPos("World Position", vector) = (0,0,0,0)
		_Radius("Radius",float) = 5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows tessellate:tessFixed

		// Use shader model 3.0 target, to get nicer looking lighting

		#pragma target 3.0
			float _Radius;
		float4 _VectorPos;
		float _NormalLerp;
		sampler2D _NormalMap;
		sampler2D _NormalMap2;
		sampler2D _MainTex;
		sampler2D _MainTex2;
		sampler2D _NoiseTex;
		float _WaveAmp;
		float _WaveSpeed;
		float _ScrollSpeed;
		float _ScrollSpeed2;


		sampler2D _MainTex;

		uniform float _Tess;

		float4 tessFixed()
		{
			return _Tess;
		}

		struct Input {
			float2 uv_MainTex; 
			float2 uv_MainTex2;
			float4 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;




		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
