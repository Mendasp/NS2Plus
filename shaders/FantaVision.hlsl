#include <renderer/RenderSetup.hlsl>

struct VS_INPUT
{
   float3 ssPosition   : POSITION;
   float2 texCoord     : TEXCOORD0;
   float4 color        : COLOR0;
};

struct VS_OUTPUT
{
   float2 texCoord     : TEXCOORD0;
   float4 color        : COLOR0;
   float4 ssPosition   : SV_POSITION;
};

struct PS_INPUT
{
   float2 texCoord     : TEXCOORD0;
   float4 color        : COLOR0;
};

sampler2D       baseTexture;
sampler2D       depthTexture;
sampler2D       normalTexture;

cbuffer LayerConstants
{
    float        startTime;
    float        amount;
};

/**
* Vertex shader.
*/  
VS_OUTPUT SFXBasicVS(VS_INPUT input)
{

   VS_OUTPUT output;

   output.ssPosition = float4(input.ssPosition, 1);
   output.texCoord   = input.texCoord + texelCenter;
   output.color      = input.color;

   return output;

}    

float4 SFXDarkVisionPS(PS_INPUT input) : COLOR0
{

	const float4 edgeColor = float4(1, 0.2, 0.01, 0);

	float2 texCoord = input.texCoord;

	float normalColor = 0;
	float4 inputPixel = tex2D(baseTexture, texCoord);
	float2 depth = tex2D(depthTexture, texCoord).rg;
	float3 normal = tex2D(normalTexture, texCoord).xyz;
	float intensity = pow((abs(normal.z - 0.5) + abs(normal.y - 0.5) + abs(normal.x - 0.5)) * 1.3, 8);

	float4 edge = 0;
	
	float2 screenCenter = float2(0.5, 0.5);
	float darkened = 1 - clamp(length(texCoord - screenCenter) - 0.35, 0, 1);
	darkened = pow(darkened, 25);

	normalColor = intensity * amount * darkened * (0.07 + inputPixel[0] * 0.5 + inputPixel[1] * 6 + inputPixel[2] * 6);
	
	const float offset = (0.0008 - amount * 0.0003);
	float2  depth2 = tex2D(depthTexture, texCoord + float2( offset, 0)).rg;
	float2  depth3 = tex2D(depthTexture, texCoord + float2(-offset, 0)).rg;
	float2  depth4 = tex2D(depthTexture, texCoord + float2( 0,  offset)).rg;
	float2  depth5 = tex2D(depthTexture, texCoord + float2( 0, -offset)).rg;
	
	edge = abs(depth2.r - depth.r) + 
		   abs(depth3.r - depth.r) + 
		   abs(depth4.r - depth.r) + 
		   abs(depth5.r - depth.r);
				 
	edge = min(1, pow(edge, 1.7 + amount * 0.3)) * edgeColor;
	
	float4 tint = float4(max(0.3, 2 - normalColor), 0.2, 0.03, 1);  
	float model = 0;
	if (depth.g > 0.5) 
	{
		model = 1;
		tint = float4(5, 2, 1.8, 1);
	}
	
	return (inputPixel + edge * model * clamp((depth.r - 0.5) * 5, 0, 1)) * (1-amount) + (normalColor * tint + edge) * amount;
    
}