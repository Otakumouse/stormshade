/**
 * Lift Gamma Gain version 1.1
 * by 3an and CeeJay.dk
 */

uniform float3 RGB_Lift <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 2.0;
	ui_label = "RGB Lift";
	ui_tooltip = "Adjust shadows for Red, Green and Blue.";
> = float3(1.0, 1.0, 1.0);
uniform float3 RGB_Gamma <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 2.0;
	ui_label = "RGB Gamma";
	ui_tooltip = "Adjust midtones for Red, Green and Blue.";
> = float3(1.0, 1.0, 1.0);
uniform float3 RGB_Gain <
	ui_type = "slider";
	ui_min = 0.0; ui_max = 2.0;
	ui_label = "RGB Gain";
	ui_tooltip = "Adjust highlights for Red, Green and Blue.";
> = float3(1.0, 1.0, 1.0);


#include "ReShade.fxh"

float3 LiftGammaGainPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
	
	// -- Lift --
	color = color * (1.5 - 0.5 * RGB_Lift) + 0.5 * RGB_Lift - 0.5;
	color = saturate(color); // Is not strictly necessary, but does not cost performance
	
	// -- Gain --
	color *= RGB_Gain; 
	
	// -- Gamma --
	color = pow(abs(color), 1.0 / RGB_Gamma);
	
	return saturate(color);
}


technique LiftGammaGain
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = LiftGammaGainPass;
	}
}
