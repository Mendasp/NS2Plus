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
	float        closeR;
	float        closeG;
	float        closeB;
	float        distantR;
	float        distantG;
	float        distantB;
	float        fogR;
	float        fogG;
	float        fogB;
	float		 modeAV;
	float		 modeAVoff;
	float		 avEdge;
	float		 edgeSize;
	float		 closeIntensity;
	float		 distantIntensity;
	float		 fogIntensity;
	float		 avDesat;
	float		 desatIntensity;
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
	
	const float frontMovementPower     = 2.0;
    const float frontSpeed            = 12.0;
    const float pulseWidth            = 20.0;

	
	float2 texCoord = input.texCoord;
	float normalColor = 0;
	float4 inputPixel = tex2D(baseTexture, texCoord);
	float  depth = tex2D(depthTexture, texCoord).r;
	float  model = max(0, tex2D(depthTexture, texCoord).g * 2 - 1);
	float3 normal = tex2D(normalTexture, texCoord).xyz;
	float  intensity = pow((abs(normal.z) * 1.4), 2); //abs(normal.y) + 
	float4 edge = 0;
	float2 depth1 = tex2D(depthTexture, input.texCoord).rg;
	
	float red = inputPixel.r;
	float green = inputPixel.g;
	float blue = inputPixel.b;
	
	float x = (input.texCoord.x - 0.5) * 20;
    float y = (input.texCoord.y - 0.5) * 20;
	float distanceSq	= (x * x + y * y)/100;	
	float sineX  = sin(-x * .1) * sin(-x * .1);
	float sineY = sin(-y * .02) * sin(-y * .02);
	float avAreaX  = clamp((sineX * 2),0 ,1);
	float avAreaY = clamp((sineY * 20),0 ,1);

		 
//vignette the screen
	float2 screenCenter = float2(0.5, 0.5);
	float darkened = 1 - clamp(length(texCoord - screenCenter) - 0.45, 0, 1);
	darkened = pow(darkened, 4);	
	

	float edgeSetting = 0;
	if (avEdge < 1) {
		edgeSetting = edgeSize + depth1.g * 0.00001;
	}
	else{
		edgeSetting = (edgeSize / 10) + distanceSq * (edgeSize * 2.5) * (1 + depth1.g);
	}
	
	const float offset = edgeSetting;
	
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
	float fadeclose = pow(2.6, (-depth1.r * -10) * 0.23 + 0.23);
	float fadeout = max(0.0, pow(2, max(depth - 0.5, 0) * -0.3));
	float fadeoff = max(0.12, pow(2, max(depth - 0.5, 0) * -0.2));
	
//AV Colouring

	float4 colourOne = float4(closeR, closeG, closeB, 1) * closeIntensity;
	float4 colourTwo = float4(distantR, distantG, distantB, 1) * distantIntensity;
					
				
//fog colour
	float4 colourFog = float4(fogR, fogG, fogB, 1) * fogIntensity;
	float4 colourFogNorm = float4(fogR, fogG, fogB, 1);

		
//offset colour when models are at an angle to camera
	float4 colourAngle = lerp(colourOne, colourTwo, .8) * .65;
		

	
//set up screen center colouring
	float4 mainColour = 
	model * edge * colourOne * 2 * clamp(fadedist*5,0.02,1) +
	model * edge * colourTwo * .9 * clamp(1-fadedist*7,0,1) * clamp(fadedist*300,0.02,1)  +
	model * edge * colourTwo * .4 * clamp(1-fadedist*60,0,1);
		
	
//set up screen edge colouring
	float4 edgeColour = 
	model * edge * colourOne * 2 * clamp(fadedist*.5,0,1) + 
	model * edge * colourTwo * .9 * clamp(1-fadedist*2.5,0,1) * clamp(fadedist*10,0.02,1) + 
	model * edge * colourTwo * .5 * (1-clamp(fadedist*1.2,0.02,1));

//outlines for when av is off, edges only
	float4 offOutline = model * (
	((edge * edge) * 3) * colourOne * 2 * clamp(fadedist*2.25,0,1) + 
	((edge * edge) * 2) * colourTwo * 1.2 * clamp(1-fadedist*4.5,0,1) * clamp(fadedist*500,0.02,1) + 
	(edge * edge) * colourTwo * .4 * (1-clamp(fadedist*60,0.02,1)) * 3);
	
//lerp it together
	float4 outline = lerp(mainColour, edgeColour, clamp(avAreaX + avAreaY, 0, 1));
		
//WORLD colours
	float4 environment = (lerp(float4(0.2, 0.2, .2, 1), inputPixel, edge) * edge*edge * .8 );
	float4 world = lerp(inputPixel / float4(-1, -1, -1, 1) * .5 + edge * float4(0.02, 0.02, 0.02, 1), environment, model);


//desaturate
	float4 desaturate = 0;

	if (avDesat >= 1){
				if (avDesat > 1){
				//distance desat
				desaturate = float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * 0.03 * clamp(fadedist*2.25,0,1) + 
				float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * .09 *clamp(1-fadedist*2.5,0,1) * clamp(fadedist*9,0.02,1) + 
				float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * .15 * (1-clamp(fadedist*9,0.02,1)) * clamp(fadedist*30,0.02,1) + 
				float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * .2 * (1-clamp(fadedist*30,0.02,1)) * (desatIntensity * 5);
				}
				else {
					//scene desat	
					desaturate = float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) ;
				}
			}
			else {
				//no desat
				float4 desaturate = 1;
			}
	
	
	
	
	
	
	
//FOG setup
	float4 fog = clamp(pow(depth * 0.012, 1), 0, 1.2) * colourFog * (0.6 + edge);
	
//lets make some edges stronger based on brightest colour
	float4 colourModel = colourFog;
	float strongestColour = max(max(colourFog.r,colourFog.g),colourFog.b);
	
	float fogShade = 0;
	
	if (fogR == fogG){
		if (fogG == fogB){	
			fogShade = 1;
		}
	}
	if (fogShade == 1){
		colourModel = clamp(colourFog * float4(1.2,1.2,1.2,0),0,1);
	}
	else {
		if (strongestColour > .1){
			if (colourFog.r == strongestColour){
				colourModel = clamp(colourFog * float4(1.5,0,0,0),0,1);
			}
			if (colourFog.g == strongestColour){
				colourModel = clamp(colourFog * float4(0,1.5,0,0),0,1);
			}
			if (colourFog.b == strongestColour){
				colourModel = clamp(colourFog * float4(0,0,1.5,0),0,1);
			}
		}
	}
	
	
		
//av off effects   
	if (amount < 1){
			if (modeAVoff >= 1){
				if (modeAVoff > 1){
				//coloured outlines
				return inputPixel * (1 + edge) + offOutline * .4 + world;
				}
				else {
					//minimal world	
					return inputPixel + world * .2;
				}
			}
			else {
				//nothing av off
				return inputPixel;
			}
			
	}

//put it all together

    // Compute a pulse "front" that sweeps out from the viewer when the effect is activated.
    float wave  = cos(4 * (x/20)) + sin(4 * (x/20));
    float front = pow( (time - startTime) * frontSpeed, frontMovementPower) + wave;
    float pulse = saturate((front - depth1.r * 1) / pulseWidth);
   
    if (pulse > 0)
    {
		const float kPulseFreq = 4;
		const float kEntityPulseSpeed = 1.5;
		const float kBaseMotionScalar = 0.5;
		const float kEntityMotionScalar = 1;
		
		float movement = (sin(time * kPulseFreq * (1.0 - depth1.g * kEntityPulseSpeed) - depth1.r * (kBaseMotionScalar + depth1.g * kEntityMotionScalar)) + 2) * 0.2;
		float saturation = max( max(abs(inputPixel.r - inputPixel.g), abs(inputPixel.r - inputPixel.b)), abs(inputPixel.b - inputPixel.g) );
		
		//get mode and create final shader
		if (modeAV >= 1){
			if (modeAV > 1){
				//foggy world
				return pow(inputPixel * .9 * darkened, 1.3) + desaturate * desatIntensity + fog * (2 + edge * .2) + (outline  * (model * 1.5)) * 2 + model * intensity * colourAngle * (0.5 + 0.2 * pow(0.1 + sin(time * 5 + intensity * 3), 2)) * fadeoff;
			}
			else {
				//old style coloured
				return (max(inputPixel,edge) + desaturate * desatIntensity) * clamp(((colourOne * (fadedist * 10)) + (colourTwo * (.75-fadedist))),0,1) +	( ((model *  2 * (0.2 + 0.2 * pow(0.1 + sin(time * 5 + intensity * 2), 2)) * fadedist*.5 ) * colourModel) + ((model * edge * edge) * (colourFog * (fadedist *60))) + ((model * edge * edge * 80) * (colourModel * (fadedist * 20))) );
			}
		}
		else {
			//minimal
			return pow(inputPixel * .9 * darkened, 1.4) + desaturate * desatIntensity + (outline * (model * 1.5)) * 2 + model * intensity * colourAngle * (0.5 + 0.2 * pow(0.1 + sin(time * 5 + intensity * 3), 2)) * fadeoff + (inputPixel + world * .75);

		}
    }
    else
    {
        return inputPixel;
    }
	
	

}