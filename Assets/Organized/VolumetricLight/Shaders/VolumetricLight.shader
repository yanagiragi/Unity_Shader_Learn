Shader "Hidden/VolumetricLight"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_NoiseTex("Noise Texture", 2D) = "white" {}
		
		_RayMarchSteps("Ray Marching Steps", Range(1, 1024)) = 64

		_ExtinctionCoefficient ("Extinction Coefficient", Range(0, 1)) = 1
		_RayleighScatteringCoefficient("Rayleigh Coefficient", Range(0, 2)) = 1
		_MieScatteringCoefficient("Mie Coefficient", Range(0, 2)) = 1
		_Anisotropy("G Coefficient", Range(-1, 1)) = 1
		
		_FogDensity("Fog Density", Range(0, 100)) = 1
		_FogSpeed("Fog UV Speed", Range(0, 1)) = 1

		_ShadowColor("Shadow Color", Color) = (0,0,0,1)
		_FogColor("Fog Color", Color) = (1,1,1,1)
		
		_AmbientFog("Ambient Fog", Range(0, 1)) = 1
		_LightIntensity("Light Intensity", Float) = 1
	}

	CGINCLUDE

	#include "UnityCG.cginc"
	#include "Lighting.cginc"

	#pragma shader_feature ENABLE_NOISE 

	sampler2D _MainTex;
	float4 _MainTex_TexelSize;

	sampler2D _NoiseTex;
	float4 _NoiseTex_TexelSize;

	sampler2D _CameraDepthTexture;

	// declare shadowmap variable
	UNITY_DECLARE_SHADOWMAP(ShadowMap);

	float4x4 _FrustumCornersES;
	float4x4 _CameraInvViewMatrix;
	float4x4 _CameraInvProjectionMatrix;

	float3 _LightDir;

	float _ExtinctionCoefficient;
	float _RayleighScatteringCoefficient;
	float _MieScatteringCoefficient;
	float _FogDensity;
	float _Anisotropy;
	float _AmbientFog;
	float _FogSpeed;
	float _LightIntensity;
	float _RayMarchSteps;

	float4 _ShadowColor;
	float4 _FogColor;

	struct v2f
	{
		float4 vertex : SV_POSITION;
		float2 uv : TEXCOORD0;
		float3 ray : TEXCOORD1;
	};

	// _LightSplitsNear and _LightSplitsFar are from UnityShaderVariables.cginc
	float4 GetCascadeWeights(float depth)
	{
		float4 zNear = float4(depth >= _LightSplitsNear);
		float4 zFar = float4(depth < _LightSplitsFar);
		float4 weights = zNear * zFar;
		return weights;
	}

	float4 GetShadowCoord(float4 worldPos, float4 weights)
	{
		float3 shadowCoord = float3(0, 0, 0);
		if (weights[0] == 1)
		{
			shadowCoord += mul(unity_WorldToShadow[0], worldPos).xyz;
		}
		if (weights[1] == 1)
		{
			shadowCoord += mul(unity_WorldToShadow[1], worldPos).xyz;
		}
		if (weights[2] == 1)
		{
			shadowCoord += mul(unity_WorldToShadow[2], worldPos).xyz;
		}
		if (weights[3] == 1)
		{
			shadowCoord += mul(unity_WorldToShadow[3], worldPos).xyz;
		}
		return float4(shadowCoord, 1);
	}

	float SampleNoise(float3 position)
	{
		float3 offset = _Time.yyy * _FogSpeed;

		position += offset;

		float noise = tex2D(_NoiseTex, position);

		return noise;
	}

	float BeerLaw(float density, float stepSize)
	{
		return saturate(exp(-density * stepSize));
	}

	float RayleighScattering(float cosTheta)
	{
		return (3.0 / (16.0 * UNITY_PI)) * (1 + (cosTheta * cosTheta)) * _RayleighScatteringCoefficient;
	}

	float4 HenyeyGreenstein(float cosTheta)
	{
		float n = 1 - (_Anisotropy * _Anisotropy); // 1 - (g * g)
		float c = cosTheta; // cos(x)
		float d = 1 + _Anisotropy * _Anisotropy - 2 * _Anisotropy * c; // 1 + g^2 - 2g*cos(x)
		return n / (4 * UNITY_PI * pow(d, 1.5));
	}

	float MieScattering(float cosTheta)
	{
		return HenyeyGreenstein(cosTheta) * _MieScatteringCoefficient; // use HenyeyGreenstein Implmentation for now
	}

	v2f vert(appdata_img v)
	{
		v2f o;

		/*half index = v.vertex.z;
		v.vertex.z = 0.1;*/

		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = v.texcoord;

		/*o.ray = _FrustumCornersES[(int)index].xyz;
		o.ray /= abs(o.ray.z);
		o.ray = mul(_CameraInvViewMatrix, o.ray);*/

		//transform clip pos to view space
		float4 clipPos = float4(v.texcoord * 2.0 - 1.0, 1.0, 1.0);
		float4 cameraRay = mul(_CameraInvProjectionMatrix, clipPos);

		//o.ray = mul(unity_ObjectToWorld, v.vertex);
		o.ray = cameraRay / cameraRay.w;

		return o;
	}

	float GetScattering(float cosTheta) {

		float inScattering = 0;

		inScattering += MieScattering(cosTheta);

		inScattering += RayleighScattering(cosTheta);

		return inScattering;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		const float epsilon = 0.0000000001;

		float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);

		float linearDepth = Linear01Depth(depth);

		// view position of the pixel, avoid use normalize(i.ray.xyz)
		float3 viewPos = i.ray.xyz * linearDepth;

		float3 currentPos = _WorldSpaceCameraPos;
		float3 worldPos = mul(_CameraInvViewMatrix, float4(viewPos, 1)).xyz;
		float3 rayDir = normalize(worldPos - _WorldSpaceCameraPos.xyz);
		
		float4 shadowWeights = GetCascadeWeights(-viewPos.z);

		float stepSize = length(worldPos - _WorldSpaceCameraPos.xyz) / _RayMarchSteps;

		float4 litFogColor = _LightIntensity * _FogColor;

		float cosTheta = dot(rayDir, _LightDir);

		float3 color = float3(0, 0, 0);
		float transmittance = 1;

		[loop]
		for (int currentStep = 0; currentStep < _RayMarchSteps; ++currentStep)
		{
			if (transmittance < epsilon) {
				break;
			}

			float noise = 1;
			
			#ifdef ENABLE_NOISE
				noise = SampleNoise(currentPos);
			#endif

			float fogDensity = noise * _FogDensity;

			// Calculate Shadow
			float4 shadowCoord = GetShadowCoord(float4(currentPos, 1), shadowWeights);
			float shadowTerm = UNITY_SAMPLE_SHADOW(ShadowMap, shadowCoord);

			// Calculate Scattering
			float extinction = _ExtinctionCoefficient * fogDensity;
			transmittance *= BeerLaw(extinction, stepSize);

			float inScattering = GetScattering(cosTheta);
			inScattering *= fogDensity;

			float3 fogColor = lerp(_ShadowColor.rgb, litFogColor.rgb, shadowTerm + _AmbientFog);

			color += inScattering * fogColor * stepSize;
			currentPos += rayDir * stepSize;
		}

		float4 add = float4(color, transmittance);

		fixed4 col = tex2D(_MainTex, i.uv); // original frame color
		
		return float4(1.0, 1.0, 1.0, 1.0) * col + float4(1.0, 1.0, 1.0, 1.0) * add; //additive blending
	}

	ENDCG

	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}
