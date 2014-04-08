#include <renderer/RenderSetup.hlsl>

struct VS_INPUT
{
    float3 ssPosition   : POSITION;
    float2 texCoord     : TEXCOORD0;
};

struct VS_OUTPUT
{
    float2 texCoord     : TEXCOORD0;
    float4 ssPosition   : SV_POSITION;
};

struct PS_INPUT
{
    float2 texCoord     : TEXCOORD0;
};

sampler2D     inputTexture;
sampler2D     inputTexture1;
sampler2D     inputTexture2;
sampler2D     hiveVisionTexture;

cbuffer LayerConstants
{
    float         maxDistance;    // Maximum distance objects are visible through the walls
};
    
/**
 * Vertex shader.
 */  
VS_OUTPUT SFXBasicVS(VS_INPUT input)
{

    VS_OUTPUT output;

    output.ssPosition = float4(input.ssPosition, 1);
    output.texCoord   = input.texCoord + texelCenter;

    return output;

}

float4 MaskPS(PS_INPUT input) : COLOR0
{
    float4 hiveVision = tex2D(hiveVisionTexture, input.texCoord);
    if (hiveVision.r > 0 && hiveVision.r < maxDistance)
    {
        return float4(1, 1, 1, 1);
    }
    return float4(0, 0, 0, 0);
}
 
float4 DownSamplePS(PS_INPUT input) : COLOR0
{
    return tex2D( inputTexture, input.texCoord );
 }

float4 CompositePS(PS_INPUT input) : COLOR0
{
    return tex2D( inputTexture1, input.texCoord) + tex2D( inputTexture2, input.texCoord);
}

float4 FinalCompositePS(PS_INPUT input) : COLOR0
{

    float4 result = tex2D(inputTexture, input.texCoord);

    // Blend in the outlines of objects visible through the walls.
    float4 glow = tex2D(inputTexture1,  input.texCoord);
    if (glow.r > 0)
    {
        float opacity = 1 - tex2D( inputTexture2, input.texCoord).a;
        result += glow * float4(10, 5, 0, 1) * opacity * 0.2;  
    }

    return result;

}

