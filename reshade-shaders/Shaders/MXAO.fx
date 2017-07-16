//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ReShade 3.0 effect file
// visit facebook.com/MartyMcModding for news/updates
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Ambient Obscurance with Indirect Lighting "MXAO" 2.1.015 by Marty McFly
// CC BY-NC-ND 3.0 licensed.
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Preprocessor Settings
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef MXAO_MIPLEVEL_AO
#define MXAO_MIPLEVEL_AO		0	//[0 to 2]      Miplevel of AO texture. 0 = fullscreen, 1 = 1/2 screen width/height, 2 = 1/4 screen width/height and so forth. Best results: IL MipLevel = AO MipLevel + 2
#endif

#ifndef MXAO_MIPLEVEL_IL
 #define MXAO_MIPLEVEL_IL		2	//[0 to 4]      Miplevel of IL texture. 0 = fullscreen, 1 = 1/2 screen width/height, 2 = 1/4 screen width/height and so forth.
#endif

#ifndef MXAO_ENABLE_IL
#define MXAO_ENABLE_IL			0	//[0 or 1]	Enables Indirect Lighting calculation. Will cause a major fps hit.
#endif

#ifndef MXAO_ENABLE_BACKFACE
#define MXAO_ENABLE_BACKFACE		1	//[0 or 1]	Enables back face check so surfaces facing away from the source position don't cast light. Will cause a major fps hit.
#endif

#ifndef MXAO_TWO_LAYER
 #define MXAO_TWO_LAYER                 1       //[0 or 1]      Splits MXAO into two separate layers that allow for both large and fine AO.
#endif

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// UI variables
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

uniform float fMXAOAmbientOcclusionAmount <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 10.00;
        ui_label = "Ambient Occlusion Amount";
	ui_tooltip = "Intensity of AO effect. Can cause pitch black clipping if set too high.";
> = 2.00;

uniform float fMXAOIndirectLightingAmount <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 12.00;
        ui_label = "Indirect Lighting Amount";
	ui_tooltip = "Intensity of IL effect. Can cause overexposured white spots if set too high.\nEnable SSIL in preprocessor section.";
> = 4.00;

uniform float fMXAOIndirectLightingSaturation <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 3.00;
        ui_label = "Indirect Lighting Saturation";
	ui_tooltip = "Controls color saturation of IL effect.\nEnable SSIL in preprocessor section.";
> = 1.00;

uniform float fMXAOSampleRadius <
	ui_type = "drag";
	ui_min = 1.00; ui_max = 20.00;
        ui_label = "Sample Radius";
	ui_tooltip = "Sample radius of MXAO, higher means more large-scale occlusion with less fine-scale details.";
> = 2.50;

uniform int iMXAOSampleCount <
	ui_type = "drag";
	ui_min = 8; ui_max = 255;
        ui_label = "Sample Count";
	ui_tooltip = "Amount of MXAO samples. Higher means more accurate and less noisy AO at the cost of performance.";
> = 24;

#if (MXAO_TWO_LAYER != 0)
           uniform float fMXAOSampleRadiusSecondary <
           	ui_type = "drag";
           	ui_min = 0.1; ui_max = 1.00;
                   ui_label = "Fine AO scale";
           	ui_tooltip = "Multiplier of Sample Radius for fine geometry. A setting of 0.5 scans the geometry at half the radius of the main AO.";
           > = 0.2;

           uniform float2 fMXAOMultFineCoarse <
             ui_type = "drag";
             ui_min = 0.00; ui_max = 1.00;
                   ui_label = "Coarse / Fine AO intensity";
             ui_tooltip = "Intensity of large and small scale AO / IL.";
           > = 1.0;
#endif

uniform float fMXAONormalBias <
	ui_type = "drag";
	ui_min = 0.0; ui_max = 0.8;
        ui_label = "Normal Bias";
	ui_tooltip = "Occlusion Cone bias to reduce self-occlusion of surfaces that have a low angle to each other.";
> = 0.2;

uniform bool bMXAOSmoothNormalsEnable <
        ui_label = "Enable Smoothed Normals";
	ui_tooltip = "Enable smoothed normals. WIP.";
> = false;

uniform float fMXAOBlurSharpness <
	ui_type = "drag";
	ui_min = 0.00; ui_max = 5.00;
        ui_label = "Blur Sharpness";
	ui_tooltip = "MXAO sharpness, higher means AO blurs less across geometry edges but may leave some noisy areas.";
> = 2.00;

uniform int fMXAOBlurSteps <
	ui_type = "drag";
	ui_min = 0; ui_max = 5;
        ui_label = "Blur Steps";
	ui_tooltip = "Offset count for MXAO bilateral blur filter. Higher means smoother but also blurrier AO.";
> = 2;

uniform bool bMXAODebugViewEnable <
        ui_label = "Enable Debug View";
	ui_tooltip = "Enables raw MXAO output for debugging and tuning purposes.";
> = false;

uniform float fMXAOFadeoutStart <
	ui_type = "drag";
        ui_label = "Fade Out Start";
	ui_min = 0.00; ui_max = 1.00;
	ui_tooltip = "Distance where MXAO starts to fade out. 0.0 = camera, 1.0 = sky. Must be less than Fade Out End.";
> = 0.2;

uniform float fMXAOFadeoutEnd <
	ui_type = "drag";
        ui_label = "Fade Out End";
	ui_min = 0.00; ui_max = 1.00;
	ui_tooltip = "Distance where MXAO completely fades out. 0.0 = camera, 1.0 = sky. Must be greater than Fade Out Start.";
> = 0.4;

uniform float fMXAOSizeScale <
	ui_type = "drag";
        ui_label = "AO Resolution";
	ui_min = 0.50; ui_max = 1.00;
        ui_tooltip = "Adjust resolution of AO. A value of 1 means AO will be rendered at full resolution.\nA value of 0.5 means AO will be rendered at half resolution\n(Feel free to experiment based on your screen res).";
> = 1.0;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Textures, Samplers
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#include "ReShade.fxh"

texture2D texColorBypass 	{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; MipLevels = 5+MXAO_MIPLEVEL_IL;};
texture2D texDistance 		{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R16F;  MipLevels = 5+MXAO_MIPLEVEL_AO;};
texture2D texSurfaceNormal	{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RGBA8; MipLevels = 5+MXAO_MIPLEVEL_IL;};

sampler2D SamplerColorBypass	{ Texture = texColorBypass;	};
sampler2D SamplerDistance	{ Texture = texDistance;	};
sampler2D SamplerSurfaceNormal	{ Texture = texSurfaceNormal;	};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Functions
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/* Fetches linearized depth value. depth data ~ distance from camera
   and 0 := camera, 1:= "infinite" distance, e.g. sky. */
float GetLinearDepth(float2 coords)
{
	return ReShade::GetLinearizedDepth(coords);
}

/* Fetches position relative to camera. This is somewhat inaccurate
   as it assumes FoV == 90 degrees but yields good enough results.
   Axes are multiplied with far plane to better scale the occlusion
   falloff and save instruction in AO main pass. Also using a bigger
   data range seems to reduce precision artifacts for logarithmic
   depth buffer option. */
float3 GetPosition(float2 coords)
{
	return float3(coords.xy*2.0-1.0,1.0)*GetLinearDepth(coords.xy)*RESHADE_DEPTH_LINEARIZATION_FAR_PLANE;
}

/* Same as above, except linearized and scaled data is already stored
   in dedicated texture and we're sampling mipmaps here. */
float3 GetPositionLOD(float2 coords, int mipLevel)
{
	return float3(coords.xy*2.0-1.0,1.0)*tex2Dlod(SamplerDistance, float4(coords.xy,0,mipLevel)).x;
}

/* Calculates normals based on partial depth buffer derivatives.
   Does a similar job to ddx/ddy but this is higher quality and
   it also takes care for object borders where usual ddx/ddy produce
   inaccurate normals.*/
float3 GetNormalFromDepth(float2 coords)
{
	float3 offs = float3(ReShade::PixelSize.xy,0);

	float3 f 	 =       GetPosition(coords.xy);
	float3 d_dx1 	 = - f + GetPosition(coords.xy + offs.xz);
	float3 d_dx2 	 =   f - GetPosition(coords.xy - offs.xz);
	float3 d_dy1 	 = - f + GetPosition(coords.xy + offs.zy);
	float3 d_dy2 	 =   f - GetPosition(coords.xy - offs.zy);

	d_dx1 = lerp(d_dx1, d_dx2, abs(d_dx1.z) > abs(d_dx2.z));
	d_dy1 = lerp(d_dy1, d_dy2, abs(d_dy1.z) > abs(d_dy2.z));

	return normalize(cross(d_dy1,d_dx1));
}

/* Box blur on normal map texture. Yes, it's as stupid as it sounds
   but helps nicely to get rid of too obvious geometry lines in
   landscape where a plain normal bias doesn't cut it. After all
   we're doing approximations over approximations. */
float3 GetSmoothedNormals(float2 texcoord, float3 ScreenSpaceNormals, float3 ScreenSpacePosition)
{
	float4 blurnormal = 0.0;
	[loop]
	for(float x = -3; x <= 3; x++)
	{
		[loop]
		for(float y = -3; y <= 3; y++)
		{
			float2 offsetcoord 	= texcoord.xy + float2(x,y) * ReShade::PixelSize.xy * 3.5;
			float3 samplenormal 	= normalize(tex2Dlod(SamplerSurfaceNormal,float4(offsetcoord,0,2)).xyz * 2.0 - 1.0);
			float3 sampleposition	= GetPositionLOD(offsetcoord.xy,2);
			float weight 		= saturate(1.0 - distance(ScreenSpacePosition.xyz,sampleposition.xyz)*1.2);
			weight 		       *= smoothstep(0.5,1.0,dot(samplenormal,ScreenSpaceNormals));
			blurnormal.xyz += samplenormal * weight;
			blurnormal.w += weight;
		}
	}

	return normalize(blurnormal.xyz / (0.0001 + blurnormal.w) + ScreenSpaceNormals*0.05);
}

/* Calculates weights for bilateral AO blur. Using only
   depth is surely faster but it doesn't really cut it, also
   areas with a flat angle to the camera will have high depth
   differences, hence blur will cause stripes as seen in many
   AO implementations, even HBAO+. Taking view angle into
   account greatly helps to reduce these problems. */
void GetBlurWeight(in float4 tempKey, in float4 centerKey, in float surfacealignment, inout float weight)
{
        float depthdiff = abs(tempKey.w - centerKey.w);
        float normaldiff = saturate(1.0 - dot(tempKey.xyz,centerKey.xyz));

        float biggestdiff = 1e-6 + fMXAOBlurSharpness * max(depthdiff*surfacealignment,normaldiff*2.0);
        weight = saturate(0.2 / biggestdiff) * 2.0;
}

/* Fetches normal,depth and AO/IL data from the respective buffers.
   AO only: backbuffer rgb - normal, backbuffer alpha - AO.
   IL enabled: backbuffer rgb - IL, backbuffer alpha - AO. */
void GetBlurKeyAndSample(in float2 texcoord, in float inputscale, in sampler inputsampler, inout float4 tempsample, inout float4 key)
{
        float4 lodcoord = float4(texcoord.xy,0,0);
        tempsample = tex2Dlod(inputsampler,lodcoord * inputscale);
        #if(MXAO_ENABLE_IL != 0)
                key = float4(tex2Dlod(SamplerSurfaceNormal,lodcoord).xyz*2-1, tex2Dlod(SamplerDistance,lodcoord).x);
        #else
                key = float4(tempsample.xyz                             *2-1, tex2Dlod(SamplerDistance,lodcoord).x);
        #endif
}

/* Bilateral blur, exploiting bilinear filter
   for sample count reduction by sampling 2 texels
   at once.*/
float4 GetBlurredAO( float2 texcoord, sampler inputsampler, float2 axisscaled, int nSteps, float inputscale)
{

	float4 tempsample;
	float4 centerkey, tempkey;
	float  centerweight = 1.0, tempweight;
	float4 blurcoord = 0.0;

        GetBlurKeyAndSample(texcoord.xy,inputscale,inputsampler,tempsample,centerkey);
	float surfacealignment = saturate(-dot(centerkey.xyz,normalize(float3(texcoord.xy*2.0-1.0,1.0)*centerkey.w)));

        #if(MXAO_ENABLE_IL != 0)
                float4 AO_IL    = tempsample;
        #else
                float AO        = tempsample.w;
        #endif

        [loop]
        for(int iStep = 1; iStep <= nSteps; iStep++)
        {
                float currentLinearstep = iStep * 2.0 - 0.5;

                GetBlurKeyAndSample(texcoord.xy + currentLinearstep * axisscaled, inputscale, inputsampler, tempsample, tempkey);
                GetBlurWeight(tempkey, centerkey, surfacealignment, tempweight);

                #if(MXAO_ENABLE_IL != 0)
                        AO_IL += tempsample * tempweight;
                #else
                        AO += tempsample.w * tempweight;
                #endif
                centerweight  += tempweight;

                GetBlurKeyAndSample(texcoord.xy - currentLinearstep * axisscaled, inputscale, inputsampler, tempsample, tempkey);
                GetBlurWeight(tempkey, centerkey, surfacealignment, tempweight);

                #if(MXAO_ENABLE_IL != 0)
                        AO_IL += tempsample * tempweight;
                #else
                        AO += tempsample.w * tempweight;
                #endif
                centerweight  += tempweight;
        }

        #if(MXAO_ENABLE_IL != 0)
                return float4(AO_IL / centerweight);
        #else
                return float4(centerkey.xyz*0.5+0.5, AO / centerweight);
        #endif
}

/* Calculates the bayer dither pattern that's used to jitter
   the direction of the AO samples per pixel.
   Why this instead of precalculated texture? BECAUSE I CAN.
   Using this ordered jitter instead of a pseudorandom one
   has 3 advantages: it seems to be more cache-aware, the AO
   is (given a fitting AO sample distribution pattern) a lot less
   noisy (better variance, see Alchemy AO) and bilateral blur
   needs a much smaller kernel: from my tests a blur kernel
   of 5x5 is fine for most settings, but using a pseudorandom
   distribution still has noticeable grain with 12x12++.
   Smaller bayer matrix sizes have more obvious directional
   AO artifacts but are easier to blur. */
float GetBayerFromCoordLevel(float2 pixelpos, int maxLevel)
{
	float finalBayer = 0.0;

	for(float i = 1-maxLevel; i<= 0; i++)
	{
		float bayerSize = exp2(i);
	        float2 bayerCoord = floor(pixelpos * bayerSize) % 2.0;
		float bayer = 2.0 * bayerCoord.x - 4.0 * bayerCoord.x * bayerCoord.y + 3.0 * bayerCoord.y;
		finalBayer += exp2(2.0*(i+maxLevel))* bayer;
	}

	float finalDivisor = 4.0 * exp2(2.0 * maxLevel)- 4.0;
	//raising all values by increment is false but in AO pass it makes sense. Can you see it?
	return finalBayer/ finalDivisor + 1.0/exp2(2.0 * maxLevel);
}

/* Main AO pass. The samples are taken in an outward spiral,
   that way a simple rotation matrix is enough to compute
   the sample locations. The rotation angle is fine-tuned,
   it yields an optimal (optimal as in "I couldn't find a better one")
   sample distribution. Vogel algorithm uses the golden angle,
   and samples are more uniformly distributed over the disc but
   AO quality suffers a lot of samples are lining up (having the
   same sampling direction). Test it yourself: make angle depending
   on texcoord.x and you'll see that AO quality is highly depending
   on angle. Mara and McGuire solve this in their Alchemy AO approach
   by providing a hand-selected rotation for each sample count,
   however my angle seems to produce better results and doesn't require
   declaring a huge constant array or any CPU side code. */
float4 GetMXAO(float2 POS,
               float2 UV,
               float3 N,
               float3 P,
               float nSamples,
               float radius,
               float falloffFactor,
               float sampleJitter)
{
	float4 AO_IL = 0.0;
	float2 sampleUV, Dir;

        #if(MXAO_TWO_LAYER != 0)
                float enhanceDetails = (POS.x + POS.y) % 2;
                radius *= lerp(1.0,fMXAOSampleRadiusSecondary,enhanceDetails);
                falloffFactor *= lerp(1.0,1.0/(fMXAOSampleRadiusSecondary*fMXAOSampleRadiusSecondary),enhanceDetails);
        #endif

        sincos(6.28318548*sampleJitter, Dir.y, Dir.x);
        Dir *= radius;

	[loop]
	for(int iSample=0; iSample < nSamples; iSample++)
	{
		Dir.xy = mul(Dir.xy, float2x2(0.575,0.81815,-0.81815,0.575));
		sampleUV = UV.xy + Dir.xy * float2(1.0,ReShade::AspectRatio) * (iSample + sampleJitter);

                float sampleMIP = saturate(radius * iSample * 20.0)*5.0;

		float3 V 		= -P + GetPositionLOD(sampleUV, sampleMIP);
                float  VdotV            = dot(V, V);
                float  VdotN            = dot(V, N)*rsqrt(VdotV);

		float fAO = saturate(1.0 + falloffFactor * VdotV)  * saturate(VdotN - fMXAONormalBias);

		#if(MXAO_ENABLE_IL != 0)
                        if( fAO > 0.1)
                        {
        			float3 fIL = tex2Dlod(SamplerColorBypass, float4(sampleUV,0,sampleMIP + MXAO_MIPLEVEL_IL)).xyz;
        			#if(MXAO_ENABLE_BACKFACE != 0)
        				float3 tN = tex2Dlod(SamplerSurfaceNormal, float4(sampleUV,0,sampleMIP + MXAO_MIPLEVEL_IL)).xyz * 2.0 - 1.0;
        				fIL = fIL - fIL*saturate(dot(V,tN)*rsqrt(VdotV)*2.0);
        			#endif
                                AO_IL += float4(fIL*fAO,fAO - fAO * dot(fIL,0.333));
                        }
		#else
			AO_IL.w += fAO;
		#endif
	}

	AO_IL = saturate(AO_IL/((1.0-fMXAONormalBias)*nSamples));

        #if(MXAO_TWO_LAYER != 0)
                AO_IL = pow(AO_IL,1.0 / lerp(fMXAOMultFineCoarse.x,fMXAOMultFineCoarse.y,enhanceDetails));
        #endif

        return AO_IL;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Pixel Shaders
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/* Setup color, depth and normal data. Alpha channel of normal
   texture provides the per pixel jitter for AO sampling. */
void PS_InputBufferSetup(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target0, out float4 depth : SV_Target1, out float4 normal : SV_Target2)
{
	color 		= tex2D(ReShade::BackBuffer, texcoord.xy);
	depth 		= GetLinearDepth(texcoord.xy)*RESHADE_DEPTH_LINEARIZATION_FAR_PLANE;
	normal.xyz 	= GetNormalFromDepth(texcoord.xy).xyz * 0.5 + 0.5;
	normal.w	= 0; //GetBayerFromCoordLevel(vpos.xy,4);
}

/* Prepass to create stencil buffer that disables AO calculation for pixels
   where AO is completely attenuated. Stencil can't be done for PS_AO_Pre
   because the masked areas in the respective buffers are filled with 0
   which then affects the mipmaps of those buffers and causes artifacts.*/
void PS_StencilSetup(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 color : SV_Target0)
{
        texcoord.xy /= fMXAOSizeScale;

	if(    GetLinearDepth(texcoord.xy) >= fMXAOFadeoutEnd
            || 0.25 * fMXAOSampleRadius / (tex2D(SamplerDistance,texcoord.xy).x + 2.0) * BUFFER_HEIGHT < 1.0
            || texcoord.x > 1.0
            || texcoord.y > 1.0) discard;

        color = 1.0;
}

void PS_AmbientObscurance(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 res : SV_Target0)
{
        texcoord.xy /= fMXAOSizeScale;

	float4 normalSample = tex2D(SamplerSurfaceNormal, texcoord.xy);
        normalSample.w = GetBayerFromCoordLevel(floor(vpos.xy),4);

	float3 ScreenSpaceNormals = normalSample.xyz * 2.0 - 1.0;
	float3 ScreenSpacePosition = GetPositionLOD(texcoord.xy, 0);

	[branch]
	if(bMXAOSmoothNormalsEnable)
	{
		ScreenSpaceNormals = GetSmoothedNormals(texcoord, ScreenSpaceNormals, ScreenSpacePosition);
	}

	float scenedepth = ScreenSpacePosition.z / RESHADE_DEPTH_LINEARIZATION_FAR_PLANE;
	ScreenSpacePosition += ScreenSpaceNormals * scenedepth;

	float SampleRadiusScaled  = 0.25*fMXAOSampleRadius / (iMXAOSampleCount * (ScreenSpacePosition.z + 2.0));
        static const float falloffFactor = -1.0/(fMXAOSampleRadius*fMXAOSampleRadius);

	res = GetMXAO(vpos.xy,
                      texcoord,
		      ScreenSpaceNormals,
		      ScreenSpacePosition,
		      iMXAOSampleCount,
		      SampleRadiusScaled,
		      falloffFactor,
		      normalSample.w);

	res = sqrt(abs(res)); //AO denoise

	#if(MXAO_ENABLE_IL == 0)
		res.xyz = normalSample.xyz;
	#endif
}

/* Box blur instead of gaussian seems to produce better
   results for low kernel sizes. The offsets and weights
   here make use of bilinear sampling, hence sampling
   in 1.5 .. 3.5 ... 5.5 pixel offsets.*/
void PS_BlurX(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 res : SV_Target0)
{
        res = GetBlurredAO(texcoord.xy, ReShade::BackBuffer, float2(ReShade::PixelSize.x,0.0), fMXAOBlurSteps, fMXAOSizeScale);
}

/* Second box blur pass and AO/IL combine. The given formula
   yields to actual physical background or anything, it's just
   a lot more visually pleasing than most formulas of similar
   implementations.*/
void PS_BlurYandCombine(float4 vpos : SV_Position, float2 texcoord : TEXCOORD, out float4 res : SV_Target0)
{
        float4 MXAO = GetBlurredAO(texcoord.xy, ReShade::BackBuffer, float2(0.0,ReShade::PixelSize.y), fMXAOBlurSteps, 1.0);

        #if(MXAO_ENABLE_IL == 0)
                MXAO.rgb = 0;
        #endif

        MXAO *= MXAO; //AO denoise

	float scenedepth = GetLinearDepth(texcoord.xy);
	float4 color = tex2D(SamplerColorBypass, texcoord.xy);

	MXAO.xyz  = lerp(dot(MXAO.xyz,0.333),MXAO.xyz,fMXAOIndirectLightingSaturation) * fMXAOIndirectLightingAmount * 4;
	MXAO.w    = 1-pow(1.0-MXAO.w, fMXAOAmbientOcclusionAmount*4.0);

	MXAO    = (bMXAODebugViewEnable) ? MXAO : lerp(MXAO, 0.0, pow(dot(color.rgb,0.333),2.0));

        MXAO.w    = lerp(MXAO.w, 0.0,smoothstep(fMXAOFadeoutStart, fMXAOFadeoutEnd, scenedepth));
	MXAO.xyz  = lerp(MXAO.xyz,0.0,smoothstep(fMXAOFadeoutStart*0.5, fMXAOFadeoutEnd*0.5, scenedepth));

	float3 GI = max(0.0,1.0 - MXAO.www + MXAO.xyz);
	color.rgb *= GI;

	if(bMXAODebugViewEnable) //can't move this into ternary as one is preprocessor def and the other is a uniform
	{
		color.rgb = (MXAO_ENABLE_IL != 0) ? GI*0.5 : GI;
	}

	res = color;
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Technique
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

technique MXAO
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader  = PS_InputBufferSetup;
		RenderTarget0 = texColorBypass;
		RenderTarget1 = texDistance;
		RenderTarget2 = texSurfaceNormal;
	}
        pass
        {
                VertexShader = PostProcessVS;
		PixelShader  = PS_StencilSetup;
		/*Render Target is Backbuffer*/
                ClearRenderTargets = true;
		StencilEnable = true;
		StencilPass = REPLACE;
                StencilRef = 1;
        }
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader  = PS_AmbientObscurance;
		/*Render Target is Backbuffer*/
                ClearRenderTargets = true;
		StencilEnable = true;
		StencilPass = KEEP;
		StencilFunc = EQUAL;
                StencilRef = 1;
	}
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader  = PS_BlurX;
                /*Render Target is Backbuffer*/
	}
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader  = PS_BlurYandCombine;
                /*Render Target is Backbuffer*/
	}
}