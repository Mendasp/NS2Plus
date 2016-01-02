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

	float normalColor = 0;
	float4 inputPixel = tex2D(baseTexture, texCoord);
	float  depth = tex2D(depthTexture, texCoord).r;
	float  model = max(0, tex2D(depthTexture, texCoord).g * 2 - 1);
	float3 normal = tex2D(normalTexture, texCoord).xyz;
	float  intensity = pow((abs(normal.z) * 1.4), 2); //abs(normal.y) + 
	float4 edge = 0;
	float2 depth1    = tex2D(depthTexture, input.texCoord).rg;
	
	float x     = (input.texCoord.x - 0.5) * 20;
    float y     = (input.texCoord.y - 0.5) * 20;	
	float sineX  = sin(-x * .1) * sin(-x * .1);
	float sineY = sin(-y * .02) * sin(-y * .02);
	float biteAreaX  = clamp((sineX * 5),0 ,1);
	float biteAreaY = clamp((sineY * 40),0 ,1);
	float avAreaX  = clamp((sineX * 2),0 ,1);
	float avAreaY = clamp((sineY * 20),0 ,1);

	//set depth for bite range marker
	float meleeRange = max(1.8 - depth, 0);

	
	//vignette the screen
	float2 screenCenter = float2(0.5, 0.5);
	float darkened = 1 - clamp(length(texCoord - screenCenter) - 0.45, 0, 1);
	darkened = pow(darkened, 4);
	

	const float offset = 0.0004 + depth1.g * 0.00001;

	float  depth2 = tex2D(depthTexture, texCoord + float2( offset, 0)).r;
	float  depth3 = tex2D(depthTexture, texCoord + float2(-offset, 0)).r;
	float  depth4 = tex2D(depthTexture, texCoord + float2( 0,  offset)).r;
	float  depth5 = tex2D(depthTexture, texCoord + float2( 0, -offset)).r;
	
	edge = abs(depth2 - depth) + 
		   abs(depth3 - depth) + 
		   abs(depth4 - depth) + 
		   abs(depth5 - depth);
		     
	edge = min(1, pow(edge + 0.12, 2));
	

	float fadedist = pow(2.6, -depth1.r * 0.23 + 0.23);
	float fadeout = max(0.0, pow(2, max(depth - 0.5, 0) * -0.3));
	float fadeoff = max(0.12, pow(2, max(depth - 0.5, 0) * -0.2));

	//AV Colouring
	//green to blue | red bite
		float4 colourOne = float4(0.1, 0.95, -0.2, 1);
		float4 colourTwo = float4(.05, .8, .2, 1);
		float4 colourThree = float4(0, .7, .5, 0);
		float4 colourFour = float4(0, 0.6, 2, 0);
		//float4 colourBite = float4(10, 0, 0, 1);
	//colour for bite when av disabled
		//float4 disabledBite = float4(10, 2, 1, 1);
	
	//set up screen center colouring
		float4 mainColour = model * edge * colourOne * 2 * clamp(fadedist*2.25,0,1) + model * edge * colourTwo * 1.2 * clamp(1-fadedist*2.5,0,1) * clamp(fadedist*11,0.02,1) + model * edge * colourThree * 1 * (1-clamp(fadedist*9,0.02,1)) * clamp(fadedist*25,0.02,1)  *  1.5 + model * edge * colourFour * 1 * (1-clamp(fadedist*30,0.02,1)) * 2; 

	
	//set up screen edge colouring
		float4 edgeColour = model * edge * colourOne * 2 * clamp(fadedist*.5,0,1) + model * edge * colourTwo * 1.2 * clamp(1-fadedist*.75,0,1) * clamp(fadedist*2.5,0.02,1) + model * edge * colourThree * 1 * (1-clamp(fadedist*2.25,0.02,1)) * clamp(fadedist*3,0.02,1) * 1.5 + model * edge * colourFour * 1 * (1-clamp(fadedist*4,0.02,1)) * 2;

	
	//outlines for when av is off, edges only
		float4 offOutline = model * (edge * edge * colourOne * 2 * clamp(fadedist*2.25,0,1) + edge * edge * colourTwo * 1.2 * clamp(1-fadedist*2.5,0,1) * clamp(fadedist*11,0.02,1) + edge * edge * colourThree * 1 * (1-clamp(fadedist*9,0.02,1)) * clamp(fadedist*25,0.02,1) * 1.5 + edge * edge * colourFour * 1 * (1-clamp(fadedist*30,0.02,1)) * 2);

	
	//lerp it together
		float4 outline = lerp(mainColour, edgeColour, clamp(avAreaX + avAreaY, 0, 1));

	
	
	//WORLD colours
		float4 environment = (lerp(float4(0.2, 0.2, .2, 1), inputPixel, edge) * edge*edge * .8 );
		float4 world = lerp(inputPixel / float4(-1, -1, -1, 1) * .5 + edge * float4(0.02, 0.02, 0.02, 1), environment, model);


		
	float red = inputPixel.r;
	float green = inputPixel.g;
	float blue = inputPixel.b;
	
	
	//desaturate
	//float4 desaturate = float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0);
	
	//desaturate more at range
		float4 desaturate = float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * 0.03 * clamp(fadedist*2.25,0,1) + float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * .09 *clamp(1-fadedist*2.5,0,1) * clamp(fadedist*9,0.02,1) + float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * .15 * (1-clamp(fadedist*9,0.02,1)) * clamp(fadedist*30,0.02,1) + float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * .2 * (1-clamp(fadedist*30,0.02,1));
	
	//av off effects   
		if (amount < 1){
			return inputPixel + desaturate * .25 * (1 + edge) + offOutline * .4 + world;
		}
	
	
	//fog colour
		float4 fog = clamp(pow(depth * 0.012, 1), 0, 1.2) * float4(0.07, 0.02, 0.13, 1) * (0.6 + edge);
		

	//put it all together
		// the colour that pulses when objests at the side of player
		float4 colourAngle = float4(0, .1, .3, .1);
	
    return pow(inputPixel * .9 * darkened, 1.3) + desaturate * 2 + fog * (2 + edge * .2) + outline * 1.75 + model * intensity * colourAngle * (0.5 + 0.2 * pow(0.1 + sin(time * 5 + intensity * 3), 2)) * fadeoff;
}