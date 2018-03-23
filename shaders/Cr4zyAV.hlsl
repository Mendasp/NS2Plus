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
    float       startTime;
    float       amount;
    float       closeR;
    float       closeG;
    float       closeB;
    float       distantR;
    float       distantG;
    float       distantB;
    float       fogR;
    float       fogG;
    float       fogB;
    float       modeAV;
    float       modeAVoff;
    float       avEdge;
    float       edgeSize;
    float       closeIntensity;
    float       distantIntensity;
    float       fogIntensity;
    float       avDesat;
    float       desatIntensity;
    float       avViewModelStyle;
    float       avViewModel;
    float       avWorldIntensity;
    float       avAspect;
    float       avToggle;
    float       avSky;
    float       avBlend;
    float       avDesatBlend;
    float       marineColor;
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
    
    const float frontMovementPower = 2.0;
    const float pulseWidth = 20.0;    
    const float frontSpeed = 12.0;
    
    float4 alienVision = float4(0,0,0,1);
    float2 texCoord = input.texCoord;
    float4 inputPixel = tex2D(baseTexture, texCoord);
    float  depth = tex2D(depthTexture, texCoord).r;
    float modelvm = tex2D(depthTexture,texCoord).g;
    float  model = max(0, tex2D(depthTexture, texCoord).g * 2 - 1);
    float3 normal = tex2D(normalTexture, texCoord).xyz;
    float  intensity = pow((abs(normal.z) * 1.4), 2);
    float4 edge = 0;
    float2 depth1 = tex2D(depthTexture, input.texCoord).rg;
    
    float x = (input.texCoord.x - 0.5) * 20;
    float y = (input.texCoord.y - 0.5) * 20;
    float distanceSq    = (x * x + y * y)/100;    
    float invertDistSq    = (x / x - y / y)*100;    
    float sineX  = sin(-x * .1) * sin(-x * .1);
    float sineY = sin(-y * .1) * sin(-y * .1);
    float avAreaX  = clamp(sineX * avAspect*1.5,0,1);
    float avAreaY = clamp(sineY ,0,1);
    
    float infestedMask = 0;
    float alienMask = 0;
    float marineMask = 0;
    
//>0.7 & <0.8 = marines and aliens
//>0.8 = aliens and infested structures
//>0.9 = infested structures and gorges
//>=1 = nothing

//these masks create an infested/gorge, alien and marine mask
    if (depth1.g > 0.9) {
        infestedMask = 1;
    }
    else {
        infestedMask = 0;
    }
    
    if (depth1.g > 0.8 && depth1.g < 0.9) {
        alienMask = 1;
    }
    else {
        alienMask = 0;
    }
    
    if (depth1.g > 0.5 && depth1.g < 0.8) {
        marineMask = 1;
    }
    else {
        marineMask = 0;
    }
//combine marine and infested masks for complete marine mask
    marineMask = clamp(marineMask + (infestedMask*0.1),0,1);
    alienMask = clamp(alienMask + infestedMask,0,1);
    
//VIEWMODEL mask
    float myAlien = 0;
    float4 realvm = inputPixel;
    float vmdepth = max(0.12, pow(2, max(depth - 0.5, 0) * -0.2));

    if (modelvm < .6){
        if (depth < 2.2){
            myAlien = 1 * modelvm;
        }
        else{
            myAlien = 0;
        }
    }
    myAlien = clamp(myAlien*5,0,1);

//select vm to display
    if (avViewModelStyle >= 1){
        realvm = clamp(modelvm * 2 * myAlien * pow(vmdepth,10),0,1);
    }
    else{
        model = model + clamp(modelvm * 2 * myAlien * pow(vmdepth,10),0,1) * avViewModel;
        realvm = 0;
    }

//make a mask that gets dark rooms/areas
    float ipColour = inputPixel.g + inputPixel.b ;
    float redRoom = 0;
    float enableRedRoom = 0;
    
    //only impacts av offmodes and minimal av
    if (modeAV == 0) {
        enableRedRoom = 1;
    }
    if (amount < 1 && modeAVoff > 1){
        enableRedRoom = 1;
    }

    if (enableRedRoom == 1) {
        if (ipColour >= 0 && ipColour < 0.000001){
            redRoom = redRoom + 0.2;
        }
        else{
            redRoom = 0;
        }
        if (ipColour >= 0 && ipColour < 0.0007){
            redRoom = redRoom + 0.3;
        }
        else{
            redRoom = 0;
        }
        if (ipColour >= 0 && ipColour < 0.001){
            redRoom = redRoom + 0.35;
        }
        else{
            redRoom = 0;
        }
        if (ipColour >= 0 && ipColour < 0.003){
            redRoom = redRoom + 0.15;
        }
        else{
            redRoom = 0;
        }
        if (ipColour >= 0 && ipColour < 0.006){
            redRoom = redRoom + 0.025;
        }
        else{
            redRoom = 0;
        }
    }

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
    
    float avBlendChange = avBlend;
    
    if (avBlend > 0) {
        avBlendChange = avBlend * (avBlend/0.66);
    }
    else {
        avBlendChange = avBlend;
    }
    
    float fadeDistBlend = pow(avBlendChange*.8+.2, -depth1.r * 0.23 + 0.23);
    float fadeDistDesat = pow(avDesatBlend*10+0.2, -depth1.r * 0.23 + 0.23);
    float fadedist = pow(2.6, -depth1.r * 0.23 + 0.23);
    float fadeout = max(0.0, pow(avBlendChange*.8+1, max(depth - 0.5, 0) * -0.3));
    float fadeoff = max(0.12, pow(avBlendChange*.8+1, max(depth - 0.5, 0) * -0.2));
    
//AV Colour vars
    float4 colourOne = float4(closeR, closeG, closeB, 1) * closeIntensity;
    float4 colourTwo = float4(distantR, distantG, distantB, 1) * distantIntensity;
    float4 colourAngle = lerp(colourOne, colourTwo, .75);
    
//fog colour/colour three, wont rename in code as to not reset anyones existing options
    float4 colourFog = float4(fogR, fogG, fogB, 1) * fogIntensity;
    
//enchances stronger shade so it can adjust edge and model colour slightly differently on highlights    
    float strongestColour = max(max(fogR,fogG),fogB);
    float4 colourModel = 0;
    float4 invertColourModel = 0;
    float fogShade = 0;
    float colourMulti = lerp(0,.5,fogIntensity*.5);
    float4 invertColour = float4((1-fogR),(1-fogG),(1-fogB),1);
    
//this only applies to 2 modes (1 & 3)
    if     (modeAV > 1){
        if (modeAV == 2 ) {
        }
        else {
            if (fogR == fogG){
                fogShade = fogShade + 1;
            }
            if (fogR == fogB){
                fogShade = fogShade + 2;
            }
            if (fogG == fogB){
                fogShade = fogShade + 4;
            }
            
            if (fogShade == 0) {
                if (fogR == strongestColour){
                    colourModel = colourFog * float4(1,colourMulti,colourMulti,1);
                }
                if (fogG == strongestColour){
                    colourModel = colourFog * float4(colourMulti,1,colourMulti,1);
                }
                if (fogB == strongestColour){
                    colourModel = colourFog * float4(colourMulti,colourMulti,1,1);
                }
            }
            else if (fogShade == 1) {
                if (fogB == strongestColour){
                    colourModel = colourFog * float4(colourMulti,colourMulti,1,1);
                }
                else{
                colourModel = colourFog * float4(1,1,colourMulti,1);
                }
            }
            else if (fogShade == 2) {
                if (fogG == strongestColour){
                    colourModel = colourFog * float4(colourMulti,1,colourMulti,1);
                }
                else{
                colourModel = colourFog * float4(1,colourMulti,1,1);
                }
            }
            else if (fogShade == 4) {
                if (fogR == strongestColour){
                    colourModel = colourFog * float4(1,colourMulti,colourMulti,1);
                }
                else{
                colourModel = colourFog * float4(colourMulti,1,1,1);
                }
            }
            else{
                colourModel = colourFog;
            }
                    
                    
            strongestColour = max(max(invertColour.r,invertColour.g),invertColour.b);
            fogShade = 0;
            
            if (invertColour.r == invertColour.g){
                fogShade = fogShade + 1;
            }
            if (invertColour.r == invertColour.b){
                fogShade = fogShade + 2;
            }
            if (invertColour.g == invertColour.b){
                fogShade = fogShade + 4;
            }
            
            if (fogShade == 0) {
                if (invertColour.r == strongestColour){
                    invertColourModel = invertColour * float4(1,colourMulti,colourMulti,1);
                }
                if (invertColour.g == strongestColour){
                    invertColourModel = invertColour * float4(colourMulti,1,colourMulti,1);
                }
                if (invertColour.b == strongestColour){
                    invertColourModel = invertColour * float4(colourMulti,colourMulti,1,1);
                }
            }
            else if (fogShade == 1) {
                if (invertColour.b == strongestColour){
                    invertColourModel = invertColour * float4(colourMulti,colourMulti,1,1);
                }
                else{
                invertColourModel = invertColour * float4(1,1,colourMulti,1);
                }
            }
            else if (fogShade == 2) {
                if (invertColour.g == strongestColour){
                    invertColourModel = invertColour * float4(colourMulti,1,colourMulti,1);
                }
                else{
                invertColourModel = invertColour * float4(1,colourMulti,1,1);
                }
            }
            else if (fogShade == 4) {
                if (invertColour.r == strongestColour){
                    invertColourModel = invertColour * float4(1,colourMulti,colourMulti,1);
                }
                else{
                invertColourModel = invertColour * float4(colourMulti,1,1,1);
                }
            }
            else{
                invertColourModel = invertColour;
            }
        }
    }
    
//marineColor adjustments
    if (marineColor == 2) {
        //adds viewmodel mask to alienMask and removes any marines
        alienMask = clamp(alienMask + (model - marineMask),0,1);
        if (modeAV >= 1){
            if (modeAV > 1){
                if (modeAV > 2){
                    //seperate world, edge and model colours
                    colourModel = (alienMask * colourModel) + (marineMask * invertColourModel);
                    colourFog = (alienMask * colourFog) + (marineMask * invertColour);
                    }
                else{
                    //depth fog
                    colourAngle = (alienMask * lerp(colourOne,colourTwo,.25)) + (marineMask * lerp(colourOne,colourTwo,.75));
                    colourOne = (alienMask * colourOne) + (marineMask * colourTwo);
                    colourTwo = (alienMask * clamp(lerp(colourOne,colourTwo,.15) / 1.25,0,1)) + (marineMask * clamp(lerp(colourOne,colourTwo,.85) / 1.25,0,1));
                }
            } 
            else {
                //original 
                colourModel = (alienMask * colourModel) + (marineMask * invertColourModel);
                colourFog = (alienMask * colourFog) + (marineMask * invertColour);
            }
        }
        else {
            //minimal
            colourAngle = (alienMask * lerp(colourOne,colourTwo,.25)) + (marineMask * lerp(colourOne,colourTwo,.75));
            colourOne = (alienMask * colourOne) + (marineMask * colourTwo);
            colourTwo = (alienMask * clamp(lerp(colourOne,colourTwo,.15) / 1.25,0,1)) + (marineMask * clamp(lerp(colourOne,colourTwo,.85) / 1.25,0,1));
        }
    }
    //marines only
    else if (marineColor == 1) {
        if (modeAV >= 1){
            if (modeAV > 1){
                if (modeAV > 2){
                    //seperate world, edge and model colours
                    model = model * marineMask;
                    colourModel = marineMask * colourModel;
                    colourFog = marineMask * colourFog;
                    }
                else{
                    //depth fog
                    model = model * marineMask;
                    colourAngle = marineMask * lerp(colourOne,colourTwo,.75);
                    colourOne = marineMask * colourOne;
                    colourTwo = marineMask * colourTwo;
                }
            } 
            else {
                //original 
                colourModel = marineMask * colourModel;
                colourFog = marineMask * colourFog;
            }
        }
        else {
            //minimal
            colourAngle = marineMask * lerp(colourOne,colourTwo,.75);
            colourOne = marineMask * colourOne;
            colourTwo = marineMask * colourTwo;
        }
    }

//do colour intensity now so inverted colours dont end up white/black
    colourFog = colourFog * fogIntensity;
    colourModel = colourModel * fogIntensity;
    
//offset colour when models are at an angle to camera
    float4 angleBlend = clamp(1-fadedist*5,0,1)*distantIntensity*.8 + clamp(fadedist*.5,0,1)*closeIntensity*.5;
    colourAngle = colourAngle * .6 * angleBlend;

//set up screen center colouring
    float4 mainColour = 
    model * edge * colourOne * 2 * clamp(fadeDistBlend*5,0.02,1) +
    model * edge * colourTwo * 1 * clamp(1-fadeDistBlend*7,0,1) * clamp(fadeDistBlend*300,0.02,1)  +
    model * edge * colourTwo * .6 * clamp(1-fadeDistBlend*60,0,1);
        
//set up screen edge colouring
    float4 edgeColour = 
    model * edge * colourOne * 2 * clamp(fadeDistBlend*.5,0,1) + 
    model * edge * colourTwo * 1 * clamp(1-fadeDistBlend*2.5,0,1) * clamp(fadeDistBlend*10,0.02,1) + 
    model * edge * colourTwo * .6 * (1-clamp(fadeDistBlend*1.2,0.02,1));

//outlines for when av is off, edges only
    float4 offOutline = model * (
    ((edge * edge) * 3) * colourOne * 2 * clamp(fadeDistBlend*2.25,0,1) + 
    ((edge * edge) * 2) * colourTwo * 1.2 * clamp(1-fadeDistBlend*4.5,0,1) * clamp(fadeDistBlend*500,0.02,1) + 
    (edge * edge) * colourTwo * .4 * (1-clamp(fadeDistBlend*60,0.02,1)) * 3) ;
    
//lerp it together
    float4 outline = lerp(mainColour, edgeColour, clamp(avAreaX + avAreaY, 0, 1));
    
//set up original mode model colouring
    float4 modelColour =
    (model * (0.5 + 0.1 * pow(0.1 + sin(time * 5 + intensity * 4), 2)) * clamp(fadedist*.5,.5,1)) * colourModel +
    ((model * pow(edge,2)) * (colourFog * (clamp(fadedist *60,.25,1)))) +
    (model * pow(edge,2) * 10 + model * pow(edge,2.5) * 200) * (colourFog * clamp(fadedist * 20,2,10));

//WORLD edges
// redRoom detection means outlines in dark rooms are much more pronounced
    float4 world = (pow(edge,1.5) * .05 * redRoom) + edge * 0.02;
    
//FOG setup
    float4 fog = clamp(pow(depth * 0.012, 1), 0, 1.2) * colourFog * (0.6 + edge);
    
//av off effects   
    if (amount < 1){
        if (modeAVoff >= 1){
            if (modeAVoff > 1){
                if (modeAVoff > 2){
                    return inputPixel * (1 + edge) + (offOutline * marineMask) * .4 + world * .6;
                }
            //coloured outlines
            return inputPixel * (1 + edge) + offOutline * .4 + world * .6;
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

//skybox mask
//lerp with circle masks because depth is a terrible at widescreen resolutions and this way the result is better, not perfect tho.
    float4 noSkybox = 0;
    float maskSkybox = 0;
    
    if (avSky > 0){
        if (avSky > 1){
            maskSkybox = 1;
            noSkybox = 0;
        }
        else{
            maskSkybox = lerp(step(depth1.r, 120), lerp(step(depth1.r, 90), step(depth1.r,70), clamp(avAreaX + avAreaY, 0, 1)), clamp((avAreaX + avAreaY) * 2,0,1));
            noSkybox = 0;
        }
    }
    else{
        maskSkybox = lerp(step(depth1.r, 120), lerp(step(depth1.r, 90), step(depth1.r,70), clamp(avAreaX + avAreaY, 0, 1)), clamp((avAreaX + avAreaY) * 2,0,1));
        noSkybox = lerp(1,0,maskSkybox) * inputPixel;
    }
    
        float4 inputPixelold = inputPixel;
        inputPixel = inputPixel * avWorldIntensity;
        float red = inputPixel.r;
        float green = inputPixel.g;
        float blue = inputPixel.b;
        
//desaturate
    float4 desaturate = 0;

    if (avDesat >= 1){
        if (avDesat > 1){
            if (avDesat > 2){
//close desat
                desaturate = float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * 1 * clamp(fadeDistDesat*2.25,0,1) + 
                float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * .6 *clamp(1-fadeDistDesat*2.5,0,1) * clamp(fadeDistDesat*9,0.02,1) + 
                float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * .2 * (1-clamp(fadeDistDesat*9,0.02,1)) * clamp(fadeDistDesat*30,0.02,1) + 
                float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * 0 * (1-clamp(fadeDistDesat*30,0.02,1)) * (desatIntensity * 5);
            }
            else{
//distance desat
                desaturate = float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * 0.03 * clamp(fadeDistDesat*2.25,0,1) + 
                float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * .09 *clamp(1-fadeDistDesat*2.5,0,1) * clamp(fadeDistDesat*9,0.02,1) + 
                float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * .15 * (1-clamp(fadeDistDesat*9,0.02,1)) * clamp(fadeDistDesat*30,0.02,1) + 
                float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0) * .2 * (1-clamp(fadeDistDesat*30,0.02,1)) * (desatIntensity * 5);
            }
        }
        else {
//scene desat    
            desaturate = float4(max(0, max(green, blue) - red), max(0, max(red, blue) - green), max(0, max(green, red) - blue), 0);
        }
    }
    else {
//no desat
        float4 desaturate = 1;
    }

//put it all together
//get mode and create final shader
    if (modeAV >= 1){
        if (modeAV > 1){
            if (modeAV > 2){
                //seperate world, edge and model colours
                alienVision = 
                ((pow((clamp(model + 1-pow(edge,1.8),0,1) - pow(model,0.01)),2) * (inputPixel + desaturate * desatIntensity) * clamp((clamp(model + 1-edge,0,1) - model) * colourOne *  fadeDistBlend,0,1) +
                clamp((pow(edge,2) - model) * colourTwo * fadeoff*10,0,1) + (inputPixel * model) +
                (model * colourFog) * 0.1 +
                ((normal.y * .3) * ((0.5 + 0.2 * pow(0.1 + sin(time * 5 + intensity * 3), 2)) * model * (colourModel * inputPixelold)  * clamp(fadedist*20,1,3)) *.25) +
                (pow(clamp(pow(model * edge,2.2),0,1) * (colourFog * 0.5)* (fadeoff*100),1.2)) * pow((edge + model),10)) * clamp(pow(1-realvm,12),0,1) +
                (realvm * inputPixelold)) * maskSkybox + noSkybox;
                }
            else{
                //depth fog
                alienVision = ((pow(inputPixel * .9 * darkened, 1.3) + desaturate * desatIntensity + (fog*(clamp((1-model)+0.1,0,1))) * (2 + edge * .2) + (outline  * (model * 1.5)) * 2 + model * intensity * colourAngle * (0.5 + 0.2 * pow(0.1 + sin(time * 5 + intensity * 3), 2)) ) * clamp(pow(1-realvm,12),0,1) + (realvm * inputPixelold)) * maskSkybox + noSkybox;
            }
        } 
        else {
            //original 
            alienVision = (((max(inputPixel,edge) + desaturate * desatIntensity) * clamp(((colourOne * (fadeDistBlend * 10)) + (colourTwo * (.75-fadeDistBlend))),0,1) + modelColour) * clamp(pow(1-realvm,12),0,1) + (realvm * inputPixelold)) * maskSkybox + noSkybox;
        }
    }
    else {
        //minimal
        alienVision = (((pow(inputPixel * .9 * darkened, 1.4) + desaturate * desatIntensity) + (outline * (model * 1.5)) * 2 + (model * intensity * colourAngle * (0.5 + 0.2 * pow(0.1 + sin(time * 5 + intensity * 3), 2)) * fadeoff) + ((inputPixel + desaturate * desatIntensity) + world * .75)) * clamp(pow(1-realvm,12),0,1) + (realvm * inputPixelold)) * maskSkybox + noSkybox;
    }
        
//activation effects
// Compute a pulse "front" that sweeps out from the viewer when the effect is activated.
    float wave  = cos(4 * (x/20)) + sin(4 * (x/20));
    float front = pow( (time - startTime) * frontSpeed, frontMovementPower) + wave;
    float pulse = 0;
//instant enable    
    if (avToggle > 0){
        if (avToggle > 1){
            return alienVision;
        }
        else {
            pulse = clamp((time - startTime)*1.5,0,1);
            return lerp(inputPixelold,alienVision,pulse);
        }
    }
    else{
        float pulse = saturate((front - depth1.r * 1) / pulseWidth);
        if (pulse > 0) {
        return alienVision;
        }
        else{
        return inputPixelold;
        }
    }
}
