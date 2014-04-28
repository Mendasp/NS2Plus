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

sampler2D     outlineTex0;
sampler2D     outlineTex1;
sampler2D     outlineTex2;
sampler2D     outlineTex3;

    
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
	float equip0 = tex2D( outlineTex0, input.texCoord ).r;
	float equip1 = tex2D( outlineTex1, input.texCoord ).r;
	float equip2 = tex2D( outlineTex2, input.texCoord ).r;
	float equip3 = tex2D( outlineTex3, input.texCoord ).r;

	if ( equip3 > 0 ) {
        return float4(1, 0, 0, 1);
	} else if ( equip2 > 0 ) {
		return float4(0, 1, 0, 1 );
	} else if ( equip1 > 0 ) {
		return float4(0, 0, 1, 1 );
	} else if ( equip0 > 0 ) {
		return float4(0,0,0,1 );	
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
    if (glow.a > 0)
    {
		float4 mask = tex2D( inputTexture2, input.texCoord);
		float4 glowColor = mask;
		if ( glow.r > 0 ) {
			glowColor = float4(3, 3, 0, glow.a);
		} else if( glow.g > 0 ) {
			glowColor = float4(0, 4, 0, glow.a);
		} else if( glow.b > 0 ) {
			glowColor = float4(3, 0, 3, glow.a);
		} else {
			glowColor = float4(0, 3, 5, glow.a);
		}
		
		glow.rgb = glow.aaa;
		
        float opacity = 1 - mask.a;
        result += glow * glowColor * opacity * 0.2;  
    }

    return result;

}

