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
    float2 texCoord = input.texCoord;

    float2 depth1    = tex2D(depthTexture, input.texCoord).rg;
    float4 inputPixel = tex2D(baseTexture, input.texCoord);
    
    if (amount == 0) {
        return inputPixel;
    }

    const float offset = 0.0005 + depth1.g * 0.00001;
	float  depth2 = tex2D(depthTexture, input.texCoord + float2(-offset, -offset)).r;
	float  depth3 = tex2D(depthTexture, input.texCoord + float2(-offset, offset)).r;
	float  depth4 = tex2D(depthTexture, input.texCoord + float2(offset,  -offset)).r;
	float  depth5 = tex2D(depthTexture, input.texCoord + float2(offset, offset)).r;
	
    float4 edgeColor; 
   
    if (depth1.g > 0.5) // entities
    {
        float edge = (abs(depth2 - depth1.r) +
                abs(depth3 - depth1.r) +
                abs(depth4 - depth1.r) +
                abs(depth5 - depth1.r ));
                
        if (depth1.r < 0.4) // view model
        {
            edgeColor = float4(0.1, 0.1, 0.1, 0);
            return lerp(inputPixel, (edgeColor * edge), 0.5);
        }
        
        // world entities
        
        edgeColor = float4(1.0, 0.05, 0.0, 0) * 8.0;
        float4 fog = float4(1, 1.0, 0, 0) * 8.0;
        float fogDensity = 0.001;
        float fogAmount = pow(depth1.r * fogDensity, 1.7 + amount * 0.3); //saturate();
        return lerp(inputPixel, lerp(inputPixel, (edgeColor * edge) + (fog * fogAmount), 0.2 + edge), 1);
    }
    else // world geometry
    {
        float edge = abs(depth5 - depth1.r );
        return lerp(inputPixel, edge, 0.01);
    }
}