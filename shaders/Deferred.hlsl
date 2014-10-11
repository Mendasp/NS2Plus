#define MINIMAL_GBUFFER
#include "ReadDeferred.hlsl"
#include "Lighting.hlsl"
#include "Linear.hlsl"

struct VS_WriteDeferred_Input
{
    float3 osPosition               : POSITION;
    float2 texCoord                 : TEXCOORD0;
    float3 osNormal                 : NORMAL;
    float3 osBinormal               : BINORMAL;
    float3 osTangent                : TANGENT;
    float4 color                    : COLOR;
#if Skinned
    float4 boneWeight               : BLENDWEIGHT;
    uint4  boneIndex                : BLENDINDICES; 
#endif
#if Instanced
    float3 matrixCol0               : TEXCOORD1;
    float3 matrixCol1               : TEXCOORD2;
    float3 matrixCol2               : TEXCOORD3;
    float3 matrixCol3               : TEXCOORD4;
    float3 invScale                 : TEXCOORD5;    // 1/scale
    float4 shaderParam              : TEXCOORD6;
#endif
};

struct VS_WriteDeferred_Output
{
    float4 depth                    : TEXCOORD0;
    float2 texCoord                 : TEXCOORD1;
    float3 vsNormal                 : TEXCOORD2;
    float3 vsTangent                : TEXCOORD3;
    float3 vsBinormal               : TEXCOORD4;
    float3 wsPosition               : TEXCOORD5;
#ifdef PARAM_wsNormal
    float3 wsNormal                 : COLOR1;   // Pack into a color since we have limited texture interpolators
#endif
#ifdef PARAM_osPosition
    float3 osPosition               : TEXCOORD7;
#endif
    float4 color                    : COLOR0;
    float4 shaderParam              : TEXCOORD6;
    float4 ssPosition               : SV_POSITION;    
};

struct PS_WriteDeferred_Input
{
    float4 depth                    : TEXCOORD0;
    float2 texCoord                 : TEXCOORD1;
    float3 vsNormal                 : TEXCOORD2;
    float3 vsTangent                : TEXCOORD3;
    float3 vsBinormal               : TEXCOORD4;
    float3 wsPosition               : TEXCOORD5;
#ifdef PARAM_wsNormal
    float3 wsNormal                 : COLOR1;   // Pack into a color since we have limited texture interpolators
#endif
#ifdef PARAM_osPosition
    float3 osPosition               : TEXCOORD7;
#endif  
    float4 color                    : COLOR0;
    float4 shaderParam              : TEXCOORD6;
};

struct PS_WriteDeferred_Output
{
    float4 albedo                   : COLOR0;
    float4 normal                   : COLOR1;
    float4 specularGloss            : COLOR2;
    float4 depth                    : COLOR3;
};

struct VS_WriteDepth_Output
{
    float4 depth                    : TEXCOORD0;
    float2 texCoord                 : TEXCOORD1;
#ifdef PARAM_vsNormal
    float3 vsNormal                 : TEXCOORD4;
#endif
#ifdef PARAM_vsBinormal
    float3 vsBinormal               : TEXCOORD2;
#endif  
#ifdef PARAM_vsTangent
    float3 vsTangent                : TEXCOORD3;
#endif              
    float3 wsPosition               : TEXCOORD5;
#ifdef PARAM_wsNormal
    float3 wsNormal                 : COLOR1;   // Pack into a color since we have limited texture interpolators
#endif
#ifdef PARAM_osPosition
    float3 osPosition               : TEXCOORD7;
#endif
    float4 color                    : COLOR0;
    float4 ssPosition               : SV_POSITION;
};

struct PS_WriteDepth_Input
{
    float4 depth                    : TEXCOORD0;
    float2 texCoord                 : TEXCOORD1;
#ifdef PARAM_vsNormal
    float3 vsNormal                 : TEXCOORD4;
#endif  
#ifdef PARAM_vsBinormal
    float3 vsBinormal               : TEXCOORD2;
#endif  
#ifdef PARAM_vsTangent
    float3 vsTangent                : TEXCOORD3;
#endif      
    float3 wsPosition               : TEXCOORD5;
#ifdef PARAM_wsNormal
    float3 wsNormal                 : COLOR1;   // Pack into a color since we have limited texture interpolators
#endif
#ifdef PARAM_osPosition
    float3 osPosition               : TEXCOORD7;
#endif  
    float4 color                    : COLOR0;
};

struct VS_Particles_Output
{
    float4 color                    : COLOR0;
    float2 texCoord                 : TEXCOORD0;
    float4 ssTexCoord               : TEXCOORD1;
    float3 vsTangent                : TEXCOORD2;
    float3 vsBinormal               : TEXCOORD3;            
    float3 vsNormal                 : TEXCOORD4;    
    float3 wsPosition               : TEXCOORD5;
#ifdef PARAM_wsNormal
    float3 wsNormal                 : COLOR1;   // Pack into a color since we have limited texture interpolators
#endif
#ifdef PARAM_osPosition
    float3 osPosition               : TEXCOORD7;
#endif
    float4 ssPosition               : SV_POSITION;
};

struct VS_Particles_Input
{
    float3 osPosition               : POSITION;
    float3 osVelocity               : TEXCOORD0;
    float2 texCoord                 : TEXCOORD1;
    float4 misc                     : TEXCOORD2;    // angle, x-size, y-size, frame
    float4 color                    : COLOR0;
};

struct PS_Particles_Input
{
    float4 color                    : COLOR0;
    float2 texCoord                 : TEXCOORD0;
    float4 ssTexCoord               : TEXCOORD1;
    float3 vsTangent                : TEXCOORD2;
    float3 vsBinormal               : TEXCOORD3;            
    float3 vsNormal                 : TEXCOORD4;
    float3 wsPosition               : TEXCOORD5;
#ifdef PARAM_wsNormal
    float3 wsNormal                 : COLOR1;       // Pack into a color since we have limited texture interpolators
#endif
#ifdef PARAM_osPosition
    float3 osPosition               : TEXCOORD7;
#endif

};

struct VS_Decal_Input
{
    float3 osPosition               : POSITION;
    float3 matrixCol0               : TEXCOORD0;
    float3 matrixCol1               : TEXCOORD1;
    float3 matrixCol2               : TEXCOORD2;
    float3 matrixCol3               : TEXCOORD3;
};

struct VS_Decal_Output
{
    float4 projected                : TEXCOORD0;
    float3 scale                    : TEXCOORD1;
    float4 vsNormal                 : TEXCOORD2;
    float4 vsTangent                : TEXCOORD3;
    float4 vsBinormal               : TEXCOORD4;
    float3 wsPosition               : TEXCOORD5;
#ifdef PARAM_wsNormal
    float3 wsNormal                 : COLOR1;       // Pack into a color since we have limited texture interpolators
#endif
#ifdef PARAM_osPosition
    float3 osPosition               : TEXCOORD7;
#endif
    float4 ssPosition               : SV_POSITION;
};

struct PS_Decal_Input
{
    float4 projected                : TEXCOORD0;
    float3 scale                    : TEXCOORD1;
    float4 vsNormal                 : TEXCOORD2;
    float4 vsTangent                : TEXCOORD3;
    float4 vsBinormal               : TEXCOORD4;
    float3 wsPosition               : TEXCOORD5;
#ifdef PARAM_wsNormal
    float3 wsNormal                 : COLOR1;       // Pack into a color since we have limited texture interpolators
#endif
#ifdef PARAM_osPosition
    float3 osPosition               : TEXCOORD7;
#endif
};  

struct PS_Decal_Output
{
    float4 albedo                   : COLOR0;
    float4 normal                   : COLOR1;
    float4 specularGloss            : COLOR2;
};


struct Material
{
    float3  albedo;
    float3  tsNormal;
    float   opacity;
    float3  specular;
    float   gloss;
    float3  emissive;
    float3  wsOffset;
    float   infestationShell;
    float   scale;
    float2  ssDistortion;
    float3  transmissionColor;
    float   id;
};

struct Material_Input
{
    float2  texCoord;
    float4  color;
#ifdef PARAM_wsPosition
    float3  wsPosition;
#endif
#ifdef PARAM_wsNormal
    float3 wsNormal;
#endif
#ifdef PARAM_vsPosition
    float3  vsPosition;
#endif
#ifdef PARAM_vsNormal
    float3 vsNormal;
#endif
#ifdef PARAM_vsBinormal
    float3 vsBinormal;
#endif
#ifdef PARAM_vsTangent
    float3 vsTangent;
#endif
#ifdef PARAM_osPosition
    float3 osPosition;
#endif
#ifdef PARAM_wsOrigin
    float3 wsOrigin;
#endif
    float4 shaderParam;
    
};

struct VS_WriteInfestation_Output
{
    float4 projected                : TEXCOORD0;
    float3 vsOrigin                    : TEXCOORD1;
    float3 vsAxis0                    : TEXCOORD2;    // Axes of the infestation blob transformed into view space
    float3 vsAxis1                    : TEXCOORD3;
    float3 vsAxis2                    : TEXCOORD4;
    float4 ssPosition               : SV_POSITION;
};

struct PS_WriteInfestation_Input
{
    float4 projected                : TEXCOORD0;
    float3 vsOrigin                    : TEXCOORD1;
    float3 vsAxis0                    : TEXCOORD2;    // Axes of the infestation blob transformed into view space
    float3 vsAxis1                    : TEXCOORD3;
    float3 vsAxis2                    : TEXCOORD4;
};    

cbuffer ObjectConstants : register(b2)
{
    float4x4    objectToWorldMatrix;
    float       motionStretch;
};

cbuffer FaceSetConstants : register(b3)
{
    float4x4    meshToObjectMatrix[60];
};

cbuffer ProbeConstants : register(b5)
{
    float3        vsProbePosition;
    float        probeRadius2;
    float4        probeTint;
};

#ifdef PARAM_translucent
    samplerCUBE   environmentTexture : register(s1);
#endif

sampler2D refractionTexture;

#include "!SURFACE_SHADER"

float3 PackNormal(float3 normal)
{
    return normal * 0.5 + 0.5;
}

float3 UnpackNormal(float3 normal)
{
    return normal * 2 - 1;
}

float4 ConvertNormal(float3 vsNormal)
{
    return float4( PackNormal(vsNormal), 0);
}

float3 SkinDirection(uint4 boneIndex, float4 boneWeight, float3 direction)
{
    float4 v =
        mul(float4(direction, 0), meshToObjectMatrix[boneIndex.x]) * boneWeight.x +
        mul(float4(direction, 0), meshToObjectMatrix[boneIndex.y]) * boneWeight.y +
        mul(float4(direction, 0), meshToObjectMatrix[boneIndex.z]) * boneWeight.z +
        mul(float4(direction, 0), meshToObjectMatrix[boneIndex.w]) * boneWeight.w;
    return v.xyz;
}

Material RunMaterialShader(Material_Input input)
{   

    Material material;

    // Setup default values so that the shader can only set the values it wants to.
    material.albedo             = float3(1, 0, 1);
    material.tsNormal           = float3(0, 0, 1);
    material.opacity            = 1;
    material.specular           = float3(0, 0, 0);
    material.gloss              = 0;
    material.emissive           = float3(0, 0, 0);
    material.wsOffset           = float3(0, 0, 0);
    material.infestationShell   = 0;    // Hack to make the infestation shell pass run
    material.scale              = 1;
    material.ssDistortion       = float2(0, 0);
    material.transmissionColor  = float3(1, 1, 1);
    material.id                 = 0;

    MaterialShader(input, material);

    return material;
    
}

VS_WriteDepth_Output WriteDepthOutput(
    float2 texCoord,
    float4 color,
    float4 osPosition,
    float3 osNormal,
    float3 osBinormal,
    float3 osTangent,
    float4x4 objectToWorldMatrix,
    float4 shaderParam)
{
    
    VS_WriteDepth_Output output;

    float4 wsPosition = mul(osPosition, objectToWorldMatrix);
    
    // Run the material shader to get the vertex displacement (if any).

    Material_Input materialInput;
    materialInput.texCoord = texCoord;
    materialInput.color    = color;

    float3 wsNormal   = mul(osNormal,   (float3x3)objectToWorldMatrix);
    float3 wsBinormal = mul(osBinormal, (float3x3)objectToWorldMatrix);
    float3 wsTangent  = mul(osTangent,  (float3x3)objectToWorldMatrix);
    
#ifdef PARAM_wsPosition
    materialInput.wsPosition = wsPosition.xyz;
#endif
#ifdef PARAM_vsPosition
    materialInput.vsPosition = mul(wsPosition, worldToCameraMatrix).xyz;
#endif
#ifdef PARAM_osPosition
    materialInput.osPosition = osPosition.xyz;
#endif
#ifdef PARAM_wsNormal
    materialInput.wsNormal = wsNormal;
#endif
#ifdef PARAM_vsNormal
    float3 vsNormal = mul(wsNormal, (float3x3)worldToCameraMatrix);
    materialInput.vsNormal = vsNormal;
#endif
#ifdef PARAM_vsBinormal
    float3 vsBinormal = mul(wsBinormal, (float3x3)worldToCameraMatrix);
    materialInput.vsBinormal = vsBinormal;
#endif
#ifdef PARAM_vsTangent
    float3 vsTangent = mul(wsTangent, (float3x3)worldToCameraMatrix);
    materialInput.vsTangent = vsTangent;
#endif
#ifdef PARAM_wsOrigin
    materialInput.wsOrigin = mul( float4(0, 0, 0, 1), objectToWorldMatrix).xyz;
#endif

    materialInput.shaderParam = shaderParam;

    Material material = RunMaterialShader(materialInput);
    wsPosition = mul( float4(osPosition.xyz * material.scale, 1), objectToWorldMatrix);
    wsPosition.xyz += material.wsOffset;
    
    float4 vsPosition = mul(wsPosition, worldToCameraMatrix);
    
    output.texCoord   = texCoord;
    output.color      = color;
    
    output.wsPosition = wsPosition.xyz / wsPosition.w;

#ifdef PARAM_osPosition
    output.osPosition = osPosition.xyz;
#endif  
#ifdef PARAM_wsNormal
    output.wsNormal = PackNormal(wsNormal);
#endif
#ifdef PARAM_vsNormal
    output.vsNormal = vsNormal;
#endif
#ifdef PARAM_vsBinormal
    output.vsBinormal = vsBinormal;
#endif
#ifdef PARAM_vsTangent
    output.vsTangent = vsTangent;
#endif

    output.ssPosition = mul(wsPosition, worldToScreenMatrix);
    output.depth      = output.ssPosition;
    output.depth.z    = vsPosition.z / vsPosition.w;
    
    return output;

}

VS_WriteDepth_Output WriteDepthVS(VS_WriteDeferred_Input input)
{

#if Skinned

    uint4 boneIndex = input.boneIndex;
    
    float4 osPosition =
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.x]) * input.boneWeight.x +
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.y]) * input.boneWeight.y +
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.z]) * input.boneWeight.z +
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.w]) * input.boneWeight.w;
        
    float3 osNormal    = SkinDirection(boneIndex, input.boneWeight, input.osNormal);
    float3 osBinormal  = SkinDirection(boneIndex, input.boneWeight, input.osBinormal);
    float3 osTangent   = SkinDirection(boneIndex, input.boneWeight, input.osTangent);
    float4 shaderParam = float4(0, 0, 0, 0);

#elif Instanced

    float4x4 objectToWorldMatrix;
            
    objectToWorldMatrix._m00 = input.matrixCol0.x;
    objectToWorldMatrix._m01 = input.matrixCol0.y;
    objectToWorldMatrix._m02 = input.matrixCol0.z;
    objectToWorldMatrix._m03 = 0;
    
    objectToWorldMatrix._m10 = input.matrixCol1.x;
    objectToWorldMatrix._m11 = input.matrixCol1.y;
    objectToWorldMatrix._m12 = input.matrixCol1.z;
    objectToWorldMatrix._m13 = 0;
    
    objectToWorldMatrix._m20 = input.matrixCol2.x;
    objectToWorldMatrix._m21 = input.matrixCol2.y;
    objectToWorldMatrix._m22 = input.matrixCol2.z;
    objectToWorldMatrix._m23 = 0;
    
    objectToWorldMatrix._m30 = input.matrixCol3.x;
    objectToWorldMatrix._m31 = input.matrixCol3.y;
    objectToWorldMatrix._m32 = input.matrixCol3.z;
    objectToWorldMatrix._m33 = 1;
    
    float4 osPosition  = float4(input.osPosition, 1);
    float3 osNormal    = input.osNormal;
    float3 osBinormal  = input.osBinormal;
    float3 osTangent   = input.osTangent;
    float4 shaderParam = input.shaderParam;

#else

    float4 osPosition  = float4(input.osPosition, 1);
    float3 osNormal    = input.osNormal;
    float3 osBinormal  = input.osBinormal;
    float3 osTangent   = input.osTangent;
    float4 shaderParam = float4(0, 0, 0, 0);

#endif
    
    return WriteDepthOutput(input.texCoord, input.color, osPosition, osNormal, osBinormal, osTangent, objectToWorldMatrix, shaderParam);
}

VS_WriteDeferred_Output WriteDeferredOutput(
    float2 texCoord,
    float4 color,
    float4 osPosition,
    float3 osNormal,
    float3 osBinormal,
    float3 osTangent,
    float4x4 _objectToWorldMatrix,
    float4x4 _objectToWorldMatrixInvTrans,  // Inverse transpose of the object to world matrix
    float4 shaderParam
    )
{

    float4 wsPosition = mul(osPosition, _objectToWorldMatrix);
    float3 wsNormal   = normalize( mul(osNormal,   (float3x3)_objectToWorldMatrixInvTrans ) );
    float3 wsBinormal = normalize( mul(osBinormal, (float3x3)_objectToWorldMatrixInvTrans ) );
    float3 wsTangent  = normalize( mul(osTangent,  (float3x3)_objectToWorldMatrixInvTrans ) );

    // Run the material shader to get the vertex displacement (if any).

    Material_Input materialInput;
    materialInput.texCoord = texCoord;
    materialInput.color    = color;
    
#ifdef PARAM_wsPosition
    materialInput.wsPosition = wsPosition.xyz;
#endif
#ifdef PARAM_osPosition
    materialInput.osPosition = osPosition.xyz;
#endif
#ifdef PARAM_wsNormal
    materialInput.wsNormal = wsNormal;
#endif

    float3 vsNormal   = mul(wsNormal, (float3x3)worldToCameraMatrix );
    float3 vsTangent  = mul(wsTangent, (float3x3)worldToCameraMatrix );
    float3 vsBinormal = mul(wsBinormal, (float3x3)worldToCameraMatrix );

#ifdef PARAM_vsNormal
    materialInput.vsNormal = vsNormal;
#endif
#ifdef PARAM_vsTangent
    materialInput.vsTangent = vsTangent;
#endif
#ifdef PARAM_vsBinormal
    materialInput.vsBinormal = vsBinormal;
#endif
#ifdef PARAM_wsOrigin
    materialInput.wsOrigin = mul( float4(0, 0, 0, 1), _objectToWorldMatrix).xyz;
#endif

    materialInput.shaderParam = shaderParam;

    Material material = RunMaterialShader(materialInput);
    wsPosition = mul( float4(osPosition.xyz * material.scale, 1), _objectToWorldMatrix);
    wsPosition.xyz += material.wsOffset;
    
    VS_WriteDeferred_Output output;
    
    float vsDepth = wsPosition.x * worldToCameraMatrix[0][2] +
                    wsPosition.y * worldToCameraMatrix[1][2] +
                    wsPosition.z * worldToCameraMatrix[2][2] +  
                    worldToCameraMatrix[3][2];

    output.ssPosition   = mul(wsPosition, worldToScreenMatrix);
    output.depth        = float4( vsDepth, material.id, 0, 0 );
    output.texCoord     = texCoord;
    output.vsNormal     = vsNormal;
    output.vsBinormal   = vsBinormal;
    output.vsTangent    = vsTangent;
    output.color        = color;
    output.shaderParam  = shaderParam;
    
    output.wsPosition = wsPosition.xyz / wsPosition.w;

#ifdef PARAM_osPosition
    output.osPosition = osPosition.xyz;
#endif        
#ifdef PARAM_wsNormal
    output.wsNormal = PackNormal(wsNormal);
#endif

    return output;

}

VS_WriteDeferred_Output WriteDeferredVS(VS_WriteDeferred_Input input)
{

#if Skinned

    uint4 boneIndex = input.boneIndex;
    
    float4 osPosition =
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.x]) * input.boneWeight.x +
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.y]) * input.boneWeight.y +
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.z]) * input.boneWeight.z +
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.w]) * input.boneWeight.w;

    float3 osNormal    = SkinDirection(boneIndex, input.boneWeight, input.osNormal);
    float3 osBinormal  = SkinDirection(boneIndex, input.boneWeight, input.osBinormal);
    float3 osTangent   = SkinDirection(boneIndex, input.boneWeight, input.osTangent);
    float4 shaderParam = float4(0, 0, 0, 0);
    
    float4x4 objectToWorldMatrixInvTrans = objectToWorldMatrix;

#elif Instanced

    float4x4 objectToWorldMatrix;
            
    objectToWorldMatrix._m00 = input.matrixCol0.x;
    objectToWorldMatrix._m01 = input.matrixCol0.y;
    objectToWorldMatrix._m02 = input.matrixCol0.z;
    objectToWorldMatrix._m03 = 0;
    
    objectToWorldMatrix._m10 = input.matrixCol1.x;
    objectToWorldMatrix._m11 = input.matrixCol1.y;
    objectToWorldMatrix._m12 = input.matrixCol1.z;
    objectToWorldMatrix._m13 = 0;
    
    objectToWorldMatrix._m20 = input.matrixCol2.x;
    objectToWorldMatrix._m21 = input.matrixCol2.y;
    objectToWorldMatrix._m22 = input.matrixCol2.z;
    objectToWorldMatrix._m23 = 0;
    
    objectToWorldMatrix._m30 = input.matrixCol3.x;
    objectToWorldMatrix._m31 = input.matrixCol3.y;
    objectToWorldMatrix._m32 = input.matrixCol3.z;
    objectToWorldMatrix._m33 = 1;
    
    float4x4 objectToWorldMatrixInvTrans = objectToWorldMatrix;
    
    float3 invScale2 = input.invScale * input.invScale;

    objectToWorldMatrixInvTrans._m00 *= invScale2.x;
    objectToWorldMatrixInvTrans._m01 *= invScale2.x;
    objectToWorldMatrixInvTrans._m02 *= invScale2.x;

    objectToWorldMatrixInvTrans._m10 *= invScale2.y;
    objectToWorldMatrixInvTrans._m11 *= invScale2.y;
    objectToWorldMatrixInvTrans._m12 *= invScale2.y;

    objectToWorldMatrixInvTrans._m20 *= invScale2.z;
    objectToWorldMatrixInvTrans._m21 *= invScale2.z;
    objectToWorldMatrixInvTrans._m22 *= invScale2.z;
    
    float4 osPosition  = float4(input.osPosition, 1);
    float3 osNormal    = input.osNormal;
    float3 osBinormal  = input.osBinormal;
    float3 osTangent   = input.osTangent;
    float4 shaderParam = input.shaderParam;

#else

    float4x4 objectToWorldMatrixInvTrans = objectToWorldMatrix;

    float4 osPosition  = float4(input.osPosition, 1);
    float3 osNormal    = input.osNormal;
    float3 osBinormal  = input.osBinormal;
    float3 osTangent   = input.osTangent;
    float4 shaderParam = float4(0, 0, 0, 0);

#endif

    return WriteDeferredOutput(input.texCoord, input.color, osPosition, osNormal, osBinormal, osTangent, objectToWorldMatrix, objectToWorldMatrixInvTrans, shaderParam);

}

PS_WriteDeferred_Output DeferredShadingPS(PS_WriteDeferred_Input input)
{

    Material_Input materialInput;
    materialInput.texCoord = input.texCoord;
    materialInput.color    = input.color;
    
#ifdef PARAM_wsPosition
    materialInput.wsPosition = input.wsPosition;
#endif
#ifdef PARAM_vsPosition
    materialInput.vsPosition = mul(float4(input.wsPosition, 1), worldToCameraMatrix);
#endif
#ifdef PARAM_osPosition
    materialInput.osPosition = input.osPosition;
#endif
#ifdef PARAM_wsNormal
    materialInput.wsNormal = UnpackNormal(input.wsNormal);
#endif    
#ifdef PARAM_vsNormal
    materialInput.vsNormal = input.vsNormal;
#endif
#ifdef PARAM_vsBinormal
    materialInput.vsBinormal = input.vsBinormal;
#endif
#ifdef PARAM_vsTangent
    materialInput.vsTangent = input.vsTangent;
#endif

    materialInput.shaderParam = input.shaderParam;

    Material material = RunMaterialShader(materialInput);

     // Alpha testing.
#ifdef PARAM_alphaTest
    clip( material.opacity - 0.5 );
#endif   
    
    PS_WriteDeferred_Output output;
    
    // Transform the normal into view space.
    float3 vsNormal = normalize(material.tsNormal.x * input.vsTangent +
                                material.tsNormal.y * input.vsBinormal +
                                material.tsNormal.z * input.vsNormal);  

    output.normal           = ConvertNormal(vsNormal);
    output.depth            = float4(input.depth.r, input.depth.g, 0, 0);
    output.specularGloss    = float4( material.specular, material.gloss );
    output.albedo           = float4( material.albedo, material.opacity );
    
    return output;
    
}

#ifdef PARAM_translucent

    float4 DecodeRGBE(float4 m)
    {
        return m * pow(2, 256 * (m.w - 0.5));
    }

    float4 ForwardShadingProbePS(PS_WriteDeferred_Input input) : COLOR0
    {

        Material_Input materialInput;
        materialInput.texCoord = input.texCoord;
        materialInput.color    = input.color;
        
        // TODO: eliminate the need for multiplication by passing vsPosition?
        float3 vsPosition = mul(float4(input.wsPosition, 1), worldToCameraMatrix);
        
    #ifdef PARAM_wsPosition
        materialInput.wsPosition = input.wsPosition;
    #endif
    #ifdef PARAM_vsPosition
        materialInput.vsPosition = vsPosition;
    #endif
    #ifdef PARAM_osPosition
        materialInput.osPosition = input.osPosition;
    #endif
    #ifdef PARAM_wsNormal
        materialInput.wsNormal = UnpackNormal(input.wsNormal);
    #endif    
    #ifdef PARAM_vsNormal
        materialInput.vsNormal = input.vsNormal;
    #endif
    #ifdef PARAM_vsBinormal
        materialInput.vsBinormal = input.vsBinormal;
    #endif
    #ifdef PARAM_vsTangent
        materialInput.vsTangent = input.vsTangent;
    #endif

        materialInput.shaderParam = input.shaderParam;

        Material material = RunMaterialShader(materialInput);

         // Alpha testing.
    #ifdef PARAM_alphaTest
        clip( material.opacity - 0.5 );
    #endif   
        
        // Transform the normal into view space.
        float3 vsNormal = normalize(material.tsNormal.x * input.vsTangent +
                                    material.tsNormal.y * input.vsBinormal +
                                    material.tsNormal.z * input.vsNormal); 


        // Compute the normalized view direction.
        float3 vsView = normalize(-vsPosition);    

        // Compute the reflection direction.
        float3 vsReflect = reflect(-vsView, vsNormal);
        
        float attenuation;
        
        // Update the reflection direction to take into account the position
        // of the point relative to the reflection probe. We do this by intersecting
        // the reflection ray with a sphere around the reflection probe, and using
        // the intersection point to determine where to sample in the cube map.
        
        float3 l = vsProbePosition - vsPosition;
        float  d = dot(vsReflect, l);
        
        float r2 = probeRadius2 * 2; // Hack to make the probes show up better on glass.
        
        // Note, we assume the point is inside the sphere so we don't need to do
        // any checking for rays that miss the sphere.
        float l2 = dot(l, l);
        float m2 = l2 - d * d;
        float q  = sqrt(r2 - m2);
        float t  = d + q;

        // Fade out the reflection over the volume of the reflection probe.
        attenuation = saturate(1 - l2 / r2);

        // Compute the new reflection direction based on the intersection point
        // with the sphere.
        vsReflect = vsPosition + vsReflect * t - vsProbePosition;
        
        const float maxBias = 2;
        float bias = maxBias - material.gloss / (255 / maxBias);
        
        float3 wsReflect = mul(vsReflect, cameraToWorldMatrix);
        float3 env = DecodeRGBE(texCUBEbias(environmentTexture, float4(wsReflect, bias))) * attenuation;
        return float4( env * material.specular * probeTint.rgb, attenuation );
        
    }

#endif    

float4 WriteDepthPS(PS_WriteDepth_Input input) : COLOR0
{
    Material_Input materialInput;
    materialInput.texCoord = input.texCoord;
    materialInput.color    = input.color;
    
#ifdef PARAM_wsPosition
    materialInput.wsPosition = input.wsPosition;
#endif
#ifdef PARAM_vsPosition
    materialInput.vsPosition = mul(input.wsPosition, worldToCameraMatrix);
#endif
#ifdef PARAM_osPosition
    materialInput.osPosition = input.osPosition;
#endif          
#ifdef PARAM_wsNormal
    materialInput.wsNormal = UnpackNormal(input.wsNormal);
#endif    
#ifdef PARAM_vsNormal
    materialInput.vsNormal = input.vsNormal;
#endif
#ifdef PARAM_vsBinormal
    materialInput.vsBinormal = input.vsBinormal;
#endif      
#ifdef PARAM_vsTangent
    materialInput.vsTangent = input.vsTangent;
#endif          

    materialInput.shaderParam = float4(0, 0, 0, 0);

    Material material = RunMaterialShader(materialInput);
    
    // Alpha testing.
#ifdef PARAM_alphaTest
    clip( material.opacity - 0.5 );
#endif   
    
    return float4( input.depth.z, input.depth.z * input.depth.z, 0, material.opacity );
}

float4 WriteEmissivePS(PS_WriteDepth_Input input) : COLOR0
{
    Material_Input materialInput;
    materialInput.texCoord = input.texCoord;
    materialInput.color    = input.color;
    
#ifdef PARAM_wsPosition
    materialInput.wsPosition = input.wsPosition;
#endif
#ifdef PARAM_vsPosition
    materialInput.vsPosition = mul(float4(input.wsPosition, 1), worldToCameraMatrix);
#endif
#ifdef PARAM_osPosition
    materialInput.osPosition = input.osPosition;
#endif
#ifdef PARAM_wsNormal
    materialInput.wsNormal = UnpackNormal(input.wsNormal);
#endif    
#ifdef PARAM_vsNormal
    materialInput.vsNormal = input.vsNormal;
#endif
#ifdef PARAM_vsBinormal
    materialInput.vsBinormal = input.vsBinormal;
#endif
#ifdef PARAM_vsTangent
    materialInput.vsTangent = input.vsTangent;
#endif

    materialInput.shaderParam = float4(0, 0, 0, 0);

    Material material = RunMaterialShader(materialInput);
    return float4(material.emissive, material.opacity);
}

/** Returns the amount that a surface should be faded out based on its proximity
to to avoid harsh lines where the it intersects the scene. */
float GetFadeFactor(float particleDepth, float sceneDepth)
{
    float sharpness = 2.0;
    float delta = sceneDepth - particleDepth;
    return sceneDepth > 0.0 ? saturate( delta * sharpness ) : 1.0;
}
                
/** Vertex shader used when rendering particles .*/
VS_Particles_Output ParticlesVS(VS_Particles_Input input)
{
        
    VS_Particles_Output output;
    
    float3 wsPosition = mul(float4(input.osPosition, 1.0), objectToWorldMatrix).xyz;
    
    float3x3 cameraToWorldMatrix = transpose( (float3x3)worldToCameraMatrix );
    float3 viewUp = mul(float3(0, 1, 0), cameraToWorldMatrix);
    
    float  angle = input.misc.x;
    float2 size  = input.misc.yz;
    float  frame = floor(input.misc.w * frameRate);

    // "Billboard" the particle by moving this vertex to the appropriate spot.
    
    float3 xAxis;
    float3 yAxis;
    float3 zAxis;
    
#if AlignVelocity   
    float3 wsVelocity = mul(input.osVelocity, (float3x3)objectToWorldMatrix);
    zAxis = normalize(wsCameraOrigin - wsPosition);
    yAxis = motionStretch * normalize(wsVelocity);
    xAxis = normalize(cross(yAxis, zAxis)); 
#elif AlignWorld
    zAxis = float3(0.0f, 1.0f, 0.0f);
    yAxis = float3(0.0f, 0.0f, 1.0f);
    xAxis = normalize(cross(yAxis, zAxis));
#else
    zAxis = normalize(wsCameraOrigin - wsPosition);
    yAxis = viewUp;
    xAxis = normalize(cross(yAxis, zAxis)); 
#endif

    xAxis *= size.x;
    yAxis *= size.y;
    
    // do 2d rotation;
    float cx = input.texCoord.x - 0.5f;
    float cy = 1 - input.texCoord.y - 0.5f;
    float rx = cx * cos(angle) - cy * sin(angle);
    float ry = cx * sin(angle) + cy * cos(angle);
    
    wsPosition += (xAxis * rx + yAxis * ry) * 2.0f;
    
    output.wsPosition = wsPosition;
    
#ifdef PARAM_osPosition
    output.osPosition = input.osPosition;
#endif      
#ifdef PARAM_wsNormal
    output.wsNormal = PackNormal(zAxis);
#endif      

    output.vsNormal   = mul(zAxis, (float3x3)worldToCameraMatrix);
    output.vsBinormal = mul(xAxis, (float3x3)worldToCameraMatrix);
    output.vsTangent  = mul(yAxis, (float3x3)worldToCameraMatrix);

    output.ssPosition       = mul(float4(wsPosition, 1.0), worldToScreenMatrix);
    output.color            = input.color;
    
    output.texCoord.x       = input.texCoord.x;
    output.texCoord.y       = (input.texCoord.y + frame) * frameHeight;
            
    // Comupute the information necessary to get the screen space texture coordinate
    // for sampling the depth texture.

    output.ssTexCoord.x =  (output.ssPosition.x + output.ssPosition.w) * 0.5;
    output.ssTexCoord.y =  (output.ssPosition.w - output.ssPosition.y) * 0.5;
    output.ssTexCoord.z =  output.ssPosition.z;
    output.ssTexCoord.w =  output.ssPosition.w;
    
    // Account for texel/pixel sampling differences.
    output.ssTexCoord.xy += texelCenter * output.ssPosition.w;
    
    return output;
    
}

/** Pixel shader used when rendering particles. */
float4 ParticlesPS(PS_Particles_Input input) : COLOR0
{

    float fadeFactor = 1.0;

    float3 ssTexCoord = input.ssTexCoord.xyz / input.ssTexCoord.w;
    float sceneDepth = tex2D(depthTexture, ssTexCoord.xy).r; 
    // ss.w is actually vs.z, after multiplying by the worldToScreenMatrix
    // But, keep it at Z for now since that's how things were tuned before..
    float particleDepth = input.ssTexCoord.z;
    fadeFactor = GetFadeFactor(particleDepth, sceneDepth);

    Material_Input materialInput;
    materialInput.texCoord = input.texCoord;
    materialInput.color    = input.color;
    
#ifdef PARAM_wsPosition
    materialInput.wsPosition = input.wsPosition;
#endif
#ifdef PARAM_vsPosition
    materialInput.vsPosition = mul(float4(input.wsPosition, 1), worldToCameraMatrix);
#endif      
#ifdef PARAM_osPosition
    materialInput.osPosition = input.osPosition;
#endif              
#ifdef PARAM_wsNormal
    materialInput.wsNormal = UnpackNormal(input.wsNormal);
#endif    
#ifdef PARAM_vsNormal
    materialInput.vsNormal = input.vsNormal;
#endif  
#ifdef PARAM_vsBinormal
    materialInput.vsBinormal = input.vsBinormal;
#endif  
#ifdef PARAM_vsTangent
    materialInput.vsTangent = input.vsTangent;
#endif  

    materialInput.shaderParam = float4(0, 0, 0, 0);

    Material material = RunMaterialShader(materialInput);
    return float4(material.emissive, material.opacity) * fadeFactor;
    
}

/** Pixel shader used when rendering particles. */
float4 ParticlesRefractionPS(PS_Particles_Input input) : COLOR0
{

    float3 ssTexCoord = input.ssTexCoord.xyz / input.ssTexCoord.w;

    float sceneDepth = tex2D(depthTexture, ssTexCoord.xy).r; 
    // ss.w is actually vs.z, after multiplying by the worldToScreenMatrix
    // But, keep it at Z for now since that's how things were tuned before..
    float particleDepth = input.ssTexCoord.z;
    float fadeFactor = GetFadeFactor(particleDepth, sceneDepth);

    Material_Input materialInput;
    materialInput.texCoord = input.texCoord;
    materialInput.color    = input.color;
    
#ifdef PARAM_wsPosition
    materialInput.wsPosition = input.wsPosition;
#endif
#ifdef PARAM_vsPosition
    materialInput.vsPosition = mul(float4(input.wsPosition, 1), worldToCameraMatrix);
#endif                
#ifdef PARAM_osPosition
    materialInput.osPosition = input.osPosition;
#endif                
#ifdef PARAM_wsNormal
    materialInput.wsNormal = UnpackNormal(input.wsNormal);
#endif    
#ifdef PARAM_vsNormal
    materialInput.vsNormal = input.vsNormal;
#endif    
#ifdef PARAM_vsBinormal
    materialInput.vsBinormal = input.vsBinormal;
#endif    
#ifdef PARAM_vsTangent
    materialInput.vsTangent = input.vsTangent;
#endif    

    materialInput.shaderParam = float4(0, 0, 0, 0);

    Material material = RunMaterialShader(materialInput);
    
    float3 refraction = tex2D(refractionTexture, ssTexCoord.xy + material.ssDistortion * material.opacity * fadeFactor).rgb;
    return float4( refraction * material.transmissionColor, 1 );
    
}

VS_Decal_Output DecalVS(VS_Decal_Input input)
{

    VS_Decal_Output output;
    
    // Unpack the object to world space transformation for the decal instance.
    
    float4x4 objectToWorldMatrix;
    
    objectToWorldMatrix._m00 = input.matrixCol0.x;
    objectToWorldMatrix._m01 = input.matrixCol0.y;
    objectToWorldMatrix._m02 = input.matrixCol0.z;
    objectToWorldMatrix._m03 = 0;
    
    objectToWorldMatrix._m10 = input.matrixCol1.x;
    objectToWorldMatrix._m11 = input.matrixCol1.y;
    objectToWorldMatrix._m12 = input.matrixCol1.z;
    objectToWorldMatrix._m13 = 0;
    
    objectToWorldMatrix._m20 = input.matrixCol2.x;
    objectToWorldMatrix._m21 = input.matrixCol2.y;
    objectToWorldMatrix._m22 = input.matrixCol2.z;
    objectToWorldMatrix._m23 = 0;
    
    objectToWorldMatrix._m30 = input.matrixCol3.x;
    objectToWorldMatrix._m31 = input.matrixCol3.y;
    objectToWorldMatrix._m32 = input.matrixCol3.z;
    objectToWorldMatrix._m33 = 1;
    
    float4 wsPosition = mul(float4(input.osPosition, 1.0), objectToWorldMatrix);
    float4 ssPosition = mul(wsPosition, worldToScreenMatrix);

    output.ssPosition   = ssPosition;
    output.projected    = ssPosition;
    
    // Compensate for texture coordinates being mapped differently than the screen
    // y coordinate.
    output.projected.y = -output.projected.y;

    output.wsPosition = wsPosition.xyz;

    float3 scale;
    scale.x = length(objectToWorldMatrix[0]);
    scale.y = length(objectToWorldMatrix[1]);
    scale.z = length(objectToWorldMatrix[2]);
    output.scale = scale;
#ifdef PARAM_osPosition
    output.osPosition = input.osPosition;
#endif                      
#ifdef PARAM_wsNormal
    output.wsNormal   = PackNormal(objectToWorldMatrix[2]);
#endif    

    float3 invScale = 1.0f / scale;

    output.vsTangent.xyz  = mul( input.matrixCol0 * invScale.x, (float3x3)worldToCameraMatrix);
    output.vsNormal.xyz   = mul( input.matrixCol1 * invScale.y, (float3x3)worldToCameraMatrix);
    output.vsBinormal.xyz = mul( input.matrixCol2 * invScale.z, (float3x3)worldToCameraMatrix);
    
    float3 vsOrigin         = mul( float4(input.matrixCol3, 1), worldToCameraMatrix).xyz;

    output.vsTangent.w  = -dot(vsOrigin, output.vsTangent.xyz);
    output.vsNormal.w   = -dot(vsOrigin, output.vsNormal.xyz);
    output.vsBinormal.w = -dot(vsOrigin, output.vsBinormal.xyz);
    
    output.vsTangent  *= invScale.x;
    output.vsNormal   *= invScale.y;
    output.vsBinormal *= invScale.z;            

    return output;

}

Material DecalMaterial(PS_Decal_Input input)
{

    float2 projected = (input.projected.xy / input.projected.w);
    float2 texCoord  = projected * 0.5 + 0.5 + texelCenter;

    float3 vsPosition = GetPosition( texCoord, float3(projected * -imagePlaneSize, 1) );
    
    // Tranform the point into "decal" or object space.
    float3 dsPosition;
    dsPosition.x = dot( input.vsTangent,  float4(vsPosition, 1) );
    dsPosition.y = dot( input.vsNormal,   float4(vsPosition, 1) );
    dsPosition.z = dot( input.vsBinormal, float4(vsPosition, 1) );
                                                    
    // Clip to the decal box and anything that has an id < 0.49 (static objects)
    float id = GetId( texCoord );
    clip( float4( 1 - abs(dsPosition), 0.49 - id ) );

    Material_Input materialInput;
    materialInput.texCoord = (dsPosition.xz + 1) * 0.5;
    materialInput.color    = float4(1, 1, 1, 1);
    
#ifdef PARAM_wsPosition
    materialInput.wsPosition = input.wsPosition;
#endif
#ifdef PARAM_vsPosition
    materialInput.vsPosition = mul(float4(input.wsPosition, 1), worldToCameraMatrix);
#endif
#ifdef PARAM_osPosition
    materialInput.osPosition = dsPosition * input.scale;
#endif           
#ifdef PARAM_wsNormal
    materialInput.wsNormal = UnpackNormal(input.wsNormal);
#endif        
#ifdef PARAM_vsNormal
    materialInput.vsNormal = input.vsNormal;
#endif    
#ifdef PARAM_vsBinormal
    materialInput.vsBinormal = input.vsBinormal;
#endif    
#ifdef PARAM_vsTangent
    materialInput.vsTangent = input.vsTangent;
#endif    

    materialInput.shaderParam = float4(0, 0, 0, 0);

    Material material = RunMaterialShader(materialInput);    
    
    // Attenuate based on the distance from the center plane of the box
    //float attenuate = sqrt(1 - abs(dsPosition.y));
    //material.opacity *= attenuate;
    
    return material;
    
}
    
PS_Decal_Output DecalPS(PS_Decal_Input input)
{

    Material material = DecalMaterial(input);

    PS_Decal_Output output;
    
    // Transform the normal into view space.
    float3 vsNormal = normalize(material.tsNormal.x * input.vsTangent.xyz * input.scale.x +
                                material.tsNormal.y * input.vsBinormal.xyz * input.scale.z +
                                material.tsNormal.z * input.vsNormal.xyz * input.scale.y);    

    output.normal           = float4( ConvertNormal(vsNormal).xyz, material.opacity );
    output.specularGloss    = float4( material.specular, material.opacity );
    output.albedo           = float4( material.albedo, material.opacity );
    
    return output;

}

float4 DecalEmissivePS(PS_Decal_Input input) : COLOR0
{
    Material material = DecalMaterial(input);    
    return float4(material.emissive, material.opacity);
}    

float4 DecalRefractionMaskPS(PS_Decal_Input input) : COLOR0
{
    Material material = DecalMaterial(input);    
    return float4( 0, 0, 0, 1 );
}            

float4 DecalRefractionPS(PS_Decal_Input input) : COLOR0
{

    Material material = DecalMaterial(input);    
    
    float2 projected = (input.projected.xy / input.projected.w);
    float2 texCoord  = projected * 0.5 + 0.5 + texelCenter;
    
    float4 refraction = tex2D(refractionTexture, texCoord + material.ssDistortion * material.opacity);
    float4 original   = tex2D(refractionTexture, texCoord);
    
    float3 transmissionColor = lerp(1, material.transmissionColor, material.opacity);
    
    return float4( lerp(original.rgb, refraction.rgb, refraction.a) * transmissionColor, 1 );
    
}   

VS_WriteInfestation_Output WriteInfestationMaskVS(VS_WriteDeferred_Input input)
{

    float4 osPosition = float4(input.osPosition, 1);
    float3 osNormal   = input.osNormal;
    float3 osBinormal = input.osBinormal;
    float3 osTangent  = input.osTangent;
    
#if Skinned

    uint4 boneIndex = input.boneIndex;
    
    osPosition =
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.x]) * input.boneWeight.x +
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.y]) * input.boneWeight.y +
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.z]) * input.boneWeight.z +
        mul(float4(input.osPosition, 1), meshToObjectMatrix[boneIndex.w]) * input.boneWeight.w;

#endif    
    
#if Instanced

    float4x4 objectToWorldMatrix;
    
    objectToWorldMatrix._m00 = input.matrixCol0.x;
    objectToWorldMatrix._m01 = input.matrixCol0.y;
    objectToWorldMatrix._m02 = input.matrixCol0.z;
    objectToWorldMatrix._m03 = 0;
    
    objectToWorldMatrix._m10 = input.matrixCol1.x;
    objectToWorldMatrix._m11 = input.matrixCol1.y;
    objectToWorldMatrix._m12 = input.matrixCol1.z;
    objectToWorldMatrix._m13 = 0;
    
    objectToWorldMatrix._m20 = input.matrixCol2.x;
    objectToWorldMatrix._m21 = input.matrixCol2.y;
    objectToWorldMatrix._m22 = input.matrixCol2.z;
    objectToWorldMatrix._m23 = 0;
    
    objectToWorldMatrix._m30 = input.matrixCol3.x;
    objectToWorldMatrix._m31 = input.matrixCol3.y;
    objectToWorldMatrix._m32 = input.matrixCol3.z;
    objectToWorldMatrix._m33 = 1;

    float4 shaderParam = input.shaderParam;
    
#else

    float4 shaderParam = float4(0, 0, 0, 0);

#endif
    
    float4 wsPosition  = mul(osPosition, objectToWorldMatrix);
    float3 wsNormal    = mul(osNormal,   (float3x3)objectToWorldMatrix);
    float3 wsBinormal  = mul(osBinormal, (float3x3)objectToWorldMatrix);
    float3 wsTangent   = mul(osTangent,  (float3x3)objectToWorldMatrix);

    // Run the material shader to get the vertex displacement (if any).

    Material_Input materialInput;
    materialInput.texCoord = input.texCoord;
    materialInput.color    = input.color;
    
    
#ifdef PARAM_wsPosition
    materialInput.wsPosition = wsPosition.xyz;
#endif
#ifdef PARAM_vsPosition
    materialInput.vsPosition = mul(wsPosition, worldToCameraMatrix);
#endif
#ifdef PARAM_osPosition
    materialInput.osPosition = osPosition.xyz;
#endif                
#ifdef PARAM_wsNormal
    materialInput.wsNormal = wsNormal;
#endif
#ifdef PARAM_vsNormal
    materialInput.vsNormal = mul(wsNormal, worldToCameraMatrix);
#endif
#ifdef PARAM_vsBinormal
    materialInput.vsBinormal = mul(wsBinormal, worldToCameraMatrix);
#endif        
#ifdef PARAM_vsTangent
    materialInput.vsTangent = mul(wsTangent, worldToCameraMatrix);
#endif                    
#ifdef PARAM_wsOrigin
    materialInput.wsOrigin = mul( float4(0, 0, 0, 1), objectToWorldMatrix).xyz;
#endif

    materialInput.shaderParam = shaderParam;

    Material material = RunMaterialShader(materialInput);
    wsPosition = mul( float4(osPosition.xyz * material.scale, 1), objectToWorldMatrix);
    wsPosition.xyz += material.wsOffset;

    VS_WriteInfestation_Output output;

    output.ssPosition = mul(wsPosition, worldToScreenMatrix);
    output.projected  = output.ssPosition;    

    // Compensate for texture coordinates being mapped differently than the screen
    // y coordinate.
    output.projected.y = -output.projected.y;
    
    float4 wsOrigin = objectToWorldMatrix[3];
    output.vsOrigin = mul(wsOrigin, worldToCameraMatrix).xyz;

    // Square of the lengths since we want to normalize them and then divide by the scale.            
    float length0 = dot(objectToWorldMatrix[0].xyz, objectToWorldMatrix[0].xyz);
    float length1 = dot(objectToWorldMatrix[1].xyz, objectToWorldMatrix[1].xyz);
    float length2 = dot(objectToWorldMatrix[2].xyz, objectToWorldMatrix[2].xyz);
    
    output.vsAxis0 = mul(objectToWorldMatrix[0].xyz / length0, (float3x3)worldToCameraMatrix).xyz;
    output.vsAxis1 = mul(objectToWorldMatrix[1].xyz / length1, (float3x3)worldToCameraMatrix).xyz;
    output.vsAxis2 = mul(objectToWorldMatrix[2].xyz / length2, (float3x3)worldToCameraMatrix).xyz;
    
    return output;
    
}

float4 WriteInfestationMaskPS(PS_WriteInfestation_Input input) : COLOR0
{

    float2 projected = (input.projected.xy / input.projected.w);
    float2 texCoord  = projected * 0.5 + 0.5 + texelCenter;

    // Don't put infestation on dynamic things.
    clip( 0.5 - GetId(texCoord));
    
    float3 vsPosition = GetPosition( texCoord, float3(projected * -imagePlaneSize, 1) );    
    
    const float shellScale = 1.25;    // scale applied to blob to get the shell
    
    const float maxDist = 0.98; // don't go all the way to the edge, to hide tesselation
    const float minDist = 1.0 / shellScale;
    
    const float maxDist2 = maxDist * maxDist;
    const float minDist2 = minDist * minDist;
    
    // For an ellipsoid, this normal isn't correct. To correct it we
    // would need to divide by the scaling factors, but the calculation
    // would need to be done in object space, which would require an
    // expensive transformation.
    float3 vsNormal = vsPosition - input.vsOrigin;
    
    // Transform the view space vector into object space.
    
    float3 osNormal;
    osNormal.x = dot(vsNormal, input.vsAxis0);
    osNormal.y = dot(vsNormal, input.vsAxis1);
    osNormal.z = dot(vsNormal, input.vsAxis2);
    
    float dist2  = dot(osNormal, osNormal);
    float blend  = saturate((maxDist2 - dist2) / (maxDist2 - minDist2));
    
    return float4( blend.rrrr );
    
}

float4 WriteRefractionPS(PS_WriteDepth_Input input) : COLOR0
{
    Material_Input materialInput;
    materialInput.texCoord = input.texCoord;
    materialInput.color    = input.color;
    
#ifdef PARAM_wsPosition
    materialInput.wsPosition = input.wsPosition;
#endif
#ifdef PARAM_vsPosition
    materialInput.vsPosition = mul(float4(input.wsPosition, 1), worldToCameraMatrix);
#endif        
#ifdef PARAM_osPosition
    materialInput.osPosition = input.osPosition;
#endif
#ifdef PARAM_wsNormal
    materialInput.wsNormal = PackNormal(input.wsNormal);
#endif    
#ifdef PARAM_vsNormal
    materialInput.vsNormal = input.vsNormal;
#endif    
#ifdef PARAM_vsBinormal
    materialInput.vsBinormal = input.vsBinormal;
#endif    
#ifdef PARAM_vsTangent
    materialInput.vsTangent = input.vsTangent;
#endif    

    materialInput.shaderParam = float4(0, 0, 0, 0);

    Material material = RunMaterialShader(materialInput);
    
    float2 texCoord = input.depth.xy / input.depth.z * 0.5 + 0.5;
    texCoord.y = 1 - texCoord.y;
    
    float4 refraction = tex2D(refractionTexture, texCoord + material.ssDistortion * material.opacity);
    float4 original   = tex2D(refractionTexture, texCoord);
    
    return float4( lerp(original.rgb, refraction.rgb, refraction.a) * material.transmissionColor, 1 );

}

float4 WriteRefractionMaskPS(PS_WriteDeferred_Input input) : COLOR0
{

    Material_Input materialInput;
    materialInput.texCoord = input.texCoord;
    materialInput.color    = input.color;
    
#ifdef PARAM_wsPosition
    materialInput.wsPosition = input.wsPosition;
#endif
#ifdef PARAM_vsPosition
    materialInput.vsPosition = mul(float4(input.wsPosition, 1), worldToCameraMatrix);
#endif        
#ifdef PARAM_osPosition
    materialInput.osPosition = input.osPosition;
#endif                  
#ifdef PARAM_wsNormal
    materialInput.wsNormal = UnpackNormal(input.wsNormal);
#endif    
#ifdef PARAM_vsNormal
    materialInput.vsNormal = input.vsNormal;
#endif    
#ifdef PARAM_vsBinormal
    materialInput.vsBinormal = input.vsBinormal;
#endif    
#ifdef PARAM_vsTangent
    materialInput.vsTangent = input.vsTangent;
#endif    

    materialInput.shaderParam = input.shaderParam;

    Material material = RunMaterialShader(materialInput);
    return float4(0, 0, 0, 1);
    
}