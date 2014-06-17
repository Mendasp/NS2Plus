
// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIUnitStatus.lua
//
// Created by: Andreas Urwalek (a_urwa@sbox.tugraz.at)
//
// Manages the blips that are displayed on the HUD, indicating status of nearby units.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Badges_Shared.lua")

class 'GUIUnitStatus' (GUIAnimatedScript)

GUIUnitStatus.kFontName = "fonts/AgencyFB_small.fnt"
GUIUnitStatus.kActionFontName = "fonts/AgencyFB_smaller_bordered.fnt"
GUIUnitStatus.kUnitStatusSize = Vector(60, 60, 0)

GUIUnitStatus.kAlphaPerSecond = 0.8
GUIUnitStatus.kImpulseIntervall = 2.5

local kBadgeSize = Vector(26, 26, 0)

GUIUnitStatus.kBlackTexture = "ui/black_dot.dds"

local kStatusBgTexture = { [kMarineTeamType] = "ui/unitstatus_marine.dds", [kAlienTeamType] = "ui/unitstatus_alien.dds", [kNeutralTeamType] = "ui/unitstatus_neutral.dds" }
local kStatusFontColor = { [kMarineTeamType] = Color(kMarineTeamColorFloat), [kAlienTeamType] = Color(kAlienTeamColorFloat), [kNeutralTeamType] = Color(1,1,1,1) }

GUIUnitStatus.kStatusBgSize = GUIScale( Vector(168, 80, 0) )
GUIUnitStatus.kStatusBgNoHintSize = GUIScale( Vector(168, 66, 0) )

GUIUnitStatus.kStatusBgOffset= GUIScale( Vector(0, -16, 0) )
GUIUnitStatus.kStatusBackgroundPixelCoords = { 256, 896 , 256 + 178, 896 + 53}

GUIUnitStatus.kUnpoweredColor = Color(1,0.2,0.2,1)
GUIUnitStatus.kEnemyColor = Color(1,0.3,0.3,1)

GUIUnitStatus.kFontScale = GUIScale( Vector(1,1,1) ) * 1.2
GUIUnitStatus.kActionFontScale = GUIScale( Vector(1,1,1) )
GUIUnitStatus.kFontScaleProgress = GUIScale( Vector(1,1,1) ) * 0.8
GUIUnitStatus.kFontScaleSmall = GUIScale( Vector(1,1,1) ) * 0.9

GUIUnitStatus.kUnitStatusBarWidth = GUIScale(512) * 0.4
GUIUnitStatus.kUnitStatusBarHeight = GUIScale(48) * 0.4
GUIUnitStatus.kUnitStatusBarTexCoords = { 256, 0, 256 + 512, 64 }
GUIUnitStatus.kBarYOffset = GUIScale(-40)

GUIUnitStatus.kProgressFontSize = GUIScale(20)

GUIUnitStatus.kProgressingIconSize = GUIScale(Vector(128, 128, 0))
GUIUnitStatus.kProgressingIconCoords = { 256, 68, 256 + 128, 68 + 128 }
GUIUnitStatus.kProgressingIconOffset = GUIScale(Vector(0, 128, 0))

GUIUnitStatus.kRotationDuration = 8
GUIUnitStatus.kResearchRotationDuration = 2

kHealthBarBgColors = { [kMarineTeamType] = Color(0.725 * 0.5, 0.921 * 0.5, 0.949 * 0.5, 1),
                     [kAlienTeamType] = Color(0.776 * 0.5, 0.364 * 0.5, 0.031 * 0.5, 1),
                     [kNeutralTeamType] = Color(1 * 0.5, 1 * 0.5, 1 * 0.5, 1) }
         
kArmorBarBgColors = { [kMarineTeamType] = Color(0.078 * 0.5, 0.878 * 0.5, 0.984 * 0.5, 1),
                    [kAlienTeamType] = Color(0.576 * 0.5, 0.194 * 0.5, 0.011 * 0.5, 1),
                    [kNeutralTeamType] = Color(0.5 * 0.5, 0.5 * 0.5, 0.5 * 0.5, 1) }


local kWelderTexCoords = GetTextureCoordinatesForIcon(kTechId.Welder)
local kWelderTexture = "ui/buildmenu.dds"

local kWelderIconSize = GUIScale(Vector(48, 48, 0))
local kWelderIconPos = GUIScale(Vector(0, -24, 0))

local kBorderCoords = { 256, 256, 256 + 512, 256 + 128 }
local kBorderMaskPixelCoords = { 256, 384, 256 + 512, 384 + 512 }
local kBorderMaskCircleRadius = GUIScale(130)

local kHealthBarWidth = GUIScale(130)
local kHealthBarHeight = GUIScale(8)

local kArmorBarWidth = GUIScale(130)
local kArmorBarHeight = GUIScale(4)

local kBackgroundNoiseTexture = "ui/alien_commander_bg_smoke.dds"
local kSmokeyBackgroundSize = GUIScale(Vector(256, 130, 0))

local kNameDefaultPos = GUIScale(Vector(0, 4, 0))
local kActionDefaultPos = GUIScale(Vector(0, -16, 0))

local kAmmoBarColors = 
{
    [kTechId.Rifle] = Color(0,1,1,1),            // teal
    [kTechId.Shotgun] = Color(0,1,0,1),          // green
    [kTechId.Flamethrower] = Color(1,1,0,1),     // yellow
    [kTechId.GrenadeLauncher] = Color(1,0,1,1),  // magenta
}

local function GetUnitStatusTextureCoordinates(unitStatus)

    local x1 = 0
    local x2 = 256
    
    local y1 = (unitStatus - 1) * 256
    local y2 = unitStatus * 256

    return x1, y1, x2, y2

end

local function GetColorForUnitState(unitStatus)

    local color = Color(1,1,1,1)

    if unitStatus == kUnitStatus.Unpowered then
        color = GUIUnitStatus.kUnpoweredColor
    //elseif unitStatus == kUnitStatus.Researching then
    //    color = Color(0, 204/255, 1, 1)
    elseif unitStatus == kUnitStatus.Damaged then
        color = Color(1, 227/255, 69/255, 0.75)
    end

    return color    

end

local function DestroyActiveBlips(self)

    for _, blip in ipairs(self.activeBlipList) do
        GUI.DestroyItem(blip.statusBg)
        blip.GraphicsItem:Destroy()
    end

    self.activeBlipList = { }
    
end

function GUIUnitStatus:Initialize()

    GUIAnimatedScript.Initialize(self)
    
    self.activeBlipList = { }
    
    self.useMarineStyle = false
    self.fullHUD = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
    
end

function GUIUnitStatus:Uninitialize()

    GUIAnimatedScript.Uninitialize(self)
    
    DestroyActiveBlips(self)
    
end

function GUIUnitStatus:EnableMarineStyle()
    self.useMarineStyle = true
end

function GUIUnitStatus:EnableAlienStyle()
    self.useMarineStyle = false
end

local function Pulsate(script, item)

    item:SetColor(Color(1, 1, 1, 0.5), 0.3, "UNIT_STATE_ANIM_ALPHA", AnimateLinear,
        function(script, item)
            item:SetColor(Color(1, 1, 1, 1), 0.3, "UNIT_STATE_ANIM_ALPHA", AnimateLinear, Pulsate)
        end)
    
end

local function GetPixelCoordsForFraction(fraction)

    local width = GUIUnitStatus.kUnitStatusBarTexCoords[3] - GUIUnitStatus.kUnitStatusBarTexCoords[1]
    local x1 = GUIUnitStatus.kUnitStatusBarTexCoords[1]
    local x2 = x1 + width * fraction
    local y1 = GUIUnitStatus.kUnitStatusBarTexCoords[2]
    local y2 = GUIUnitStatus.kUnitStatusBarTexCoords[4]
    
    return x1, y1, x2, y2
    
end

local function CreateBlipItem(self)

    local newBlip = { }
    local teamType = PlayerUI_GetTeamType()
    local neutralTexture = "ui/unitstatus_neutral.dds"
    
    newBlip.ScreenX = 0
    newBlip.ScreenY = 0
    
    local texture = kStatusBgTexture[teamType]
    local fontColor = kStatusFontColor[teamType]

    newBlip.GraphicsItem = self:CreateAnimatedGraphicItem()
    newBlip.GraphicsItem:SetAnchor(GUIItem.Left, GUIItem.Top)
    if self.useMarineStyle then
        newBlip.GraphicsItem:SetBlendTechnique(GUIItem.Add)
    end
    newBlip.GraphicsItem:SetSize(GUIUnitStatus.kUnitStatusSize)
    newBlip.GraphicsItem:SetIsScaling(false)
    newBlip.GraphicsItem:SetColor(Color(1,1,1,0.4))
    newBlip.GraphicsItem:SetTexture(texture)
    newBlip.GraphicsItem:SetLayer(kGUILayerPlayerNameTags)
    
    newBlip.OverLayGraphic = self:CreateAnimatedGraphicItem()
    newBlip.OverLayGraphic:SetAnchor(GUIItem.Left, GUIItem.Top)
    newBlip.OverLayGraphic:SetBlendTechnique(GUIItem.Add)
    newBlip.OverLayGraphic:SetSize(GUIUnitStatus.kUnitStatusSize)
    newBlip.OverLayGraphic:SetIsScaling(false)
    newBlip.OverLayGraphic:SetColor(Color(1,1,1,0.4))
    newBlip.OverLayGraphic:SetTexture(texture)
    newBlip.OverLayGraphic:SetLayer(kGUILayerPlayerNameTags)

    newBlip.ProgressingIcon = GetGUIManager():CreateGraphicItem()
    newBlip.ProgressingIcon:SetTexture(texture)
    newBlip.ProgressingIcon:SetAnchor(GUIItem.Middle, GUIItem.Top)
    newBlip.ProgressingIcon:SetBlendTechnique(GUIItem.Add) 
    newBlip.ProgressingIcon:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kProgressingIconCoords))
    newBlip.ProgressingIcon:SetSize(GUIUnitStatus.kProgressingIconSize)
    newBlip.ProgressingIcon:SetPosition(-GUIUnitStatus.kProgressingIconSize/2 + GUIUnitStatus.kProgressingIconOffset )
    newBlip.ProgressingIcon:SetIsVisible(false)
    
    newBlip.ProgressBackground = GetGUIManager():CreateGraphicItem()
    newBlip.ProgressBackground:SetTexture(GUIUnitStatus.kBlackTexture)
    newBlip.ProgressBackground:SetSize(GUIUnitStatus.kProgressingIconSize)
    newBlip.ProgressingIcon:AddChild(newBlip.ProgressBackground)
    
    newBlip.ProgressText = GetGUIManager():CreateTextItem()
    newBlip.ProgressText:SetAnchor(GUIItem.Middle, GUIItem.Center)
    newBlip.ProgressText:SetTextAlignmentX(GUIItem.Align_Center)
    newBlip.ProgressText:SetTextAlignmentY(GUIItem.Align_Center)
    newBlip.ProgressText:SetFontSize(GUIUnitStatus.kProgressFontSize)
    newBlip.ProgressText:SetColor(fontColor)
    newBlip.ProgressText:SetFontIsBold(true)
    newBlip.ProgressingIcon:AddChild(newBlip.ProgressText)
    
    newBlip.statusBg = GetGUIManager():CreateGraphicItem()
    
    newBlip.statusBg:SetSize(GUIUnitStatus.kStatusBgSize)
    newBlip.statusBg:SetPosition(-GUIUnitStatus.kStatusBgSize * .5 + GUIUnitStatus.kStatusBgOffset )
    newBlip.statusBg:SetClearsStencilBuffer(true)
    newBlip.statusBg:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kStatusBackgroundPixelCoords))
	
    if self.fullHUD and teamType == kAlienTeamType then
    
        newBlip.smokeyBackground = GetGUIManager():CreateGraphicItem()
        newBlip.smokeyBackground:SetAnchor(GUIItem.Middle, GUIItem.Center)
        newBlip.smokeyBackground:SetSize(kSmokeyBackgroundSize)
        newBlip.smokeyBackground:SetPosition(-kSmokeyBackgroundSize * .5)
        newBlip.smokeyBackground:SetShader("shaders/GUISmoke.surface_shader")
        newBlip.smokeyBackground:SetAdditionalTexture("noise", kBackgroundNoiseTexture)
        newBlip.smokeyBackground:SetFloatParameter("correctionX", 0.6)
        newBlip.smokeyBackground:SetFloatParameter("correctionY", 0.3)
        newBlip.smokeyBackground:SetTexture("ui/alien_logout_smkmask.dds")
        newBlip.smokeyBackground:SetColor(Color(1,1,1,0.6))
    
    end
    
    newBlip.HealthBarBg = GetGUIManager():CreateGraphicItem()
    newBlip.HealthBarBg:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    newBlip.HealthBarBg:SetSize(Vector(kHealthBarWidth, kHealthBarHeight, 0))
    newBlip.HealthBarBg:SetPosition(Vector(-kHealthBarWidth / 2, -kHealthBarHeight - kArmorBarHeight - 10, 0))
    newBlip.HealthBarBg:SetTexture(neutralTexture)
    newBlip.HealthBarBg:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kUnitStatusBarTexCoords))
    newBlip.HealthBarBg:SetColor(Color(0,0,0,0))
    
    newBlip.HealthBar = GetGUIManager():CreateGraphicItem()
    newBlip.HealthBar:SetColor(kHealthBarColors[teamType])
    newBlip.HealthBar:SetSize(Vector(kHealthBarWidth, kHealthBarHeight, 0))
    newBlip.HealthBar:SetTexture(neutralTexture)
    newBlip.HealthBar:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kUnitStatusBarTexCoords))
    newBlip.HealthBar:SetBlendTechnique(GUIItem.Add)
    newBlip.HealthBarBg:AddChild(newBlip.HealthBar)
    
    newBlip.ArmorBarBg = GetGUIManager():CreateGraphicItem()
    newBlip.ArmorBarBg:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    newBlip.ArmorBarBg:SetSize(Vector(kArmorBarWidth, kArmorBarHeight, 0))
    newBlip.ArmorBarBg:SetPosition(Vector(-kArmorBarWidth / 2, -kArmorBarHeight - 10, 0))
    newBlip.ArmorBarBg:SetTexture(neutralTexture)
    newBlip.ArmorBarBg:SetColor(Color(0,0,0,0))
    newBlip.ArmorBarBg:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kUnitStatusBarTexCoords))
    
    newBlip.ArmorBar = GUIManager:CreateGraphicItem()
    newBlip.ArmorBar:SetColor(kArmorBarColors[teamType])
    newBlip.ArmorBar:SetSize(Vector(kArmorBarWidth, kArmorBarHeight, 0))
    newBlip.ArmorBar:SetTexture(neutralTexture)
    newBlip.ArmorBar:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kUnitStatusBarTexCoords))
    newBlip.ArmorBar:SetBlendTechnique(GUIItem.Add)
    newBlip.ArmorBarBg:AddChild(newBlip.ArmorBar)
    
    newBlip.NameText = GUIManager:CreateTextItem()
    newBlip.NameText:SetAnchor(GUIItem.Middle, GUIItem.Top)
    newBlip.NameText:SetFontName(GUIUnitStatus.kFontName)
    newBlip.NameText:SetTextAlignmentX(GUIItem.Align_Center)
    newBlip.NameText:SetTextAlignmentY(GUIItem.Align_Min)
    newBlip.NameText:SetScale(GUIUnitStatus.kFontScale)
    newBlip.NameText:SetPosition(kNameDefaultPos)  
    
    newBlip.ActionText = GUIManager:CreateTextItem()
    newBlip.ActionText:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    newBlip.ActionText:SetFontName(GUIUnitStatus.kActionFontName)
    newBlip.ActionText:SetTextAlignmentX(GUIItem.Align_Center)
    newBlip.ActionText:SetTextAlignmentY(GUIItem.Align_Min)
    newBlip.ActionText:SetScale(GUIUnitStatus.kActionFontScale)
    newBlip.ActionText:SetPosition(kActionDefaultPos)  
    
    newBlip.HintText = GUIManager:CreateTextItem()
    newBlip.HintText:SetAnchor(GUIItem.Middle, GUIItem.Top)
    newBlip.HintText:SetFontName(GUIUnitStatus.kFontName)
    newBlip.HintText:SetTextAlignmentX(GUIItem.Align_Center)
    newBlip.HintText:SetTextAlignmentY(GUIItem.Align_Min)
    newBlip.HintText:SetScale(GUIUnitStatus.kFontScaleSmall)
    newBlip.HintText:SetPosition(GUIScale(Vector(0, 28, 0)))
    
    if self.fullHUD then
    
        newBlip.Border = GUIManager:CreateGraphicItem()
        newBlip.Border:SetAnchor(GUIItem.Left, GUIItem.Top)
        newBlip.Border:SetSize(GUIUnitStatus.kStatusBgSize)
        newBlip.Border:SetTexture(neutralTexture)
        newBlip.Border:SetTexturePixelCoordinates(unpack(kBorderCoords))
        newBlip.Border:SetIsStencil(true)
        
        newBlip.BorderMask = GUIManager:CreateGraphicItem()
        newBlip.BorderMask:SetTexture(neutralTexture)
        newBlip.BorderMask:SetAnchor(GUIItem.Middle, GUIItem.Center)
        newBlip.BorderMask:SetBlendTechnique(GUIItem.Add)
        newBlip.BorderMask:SetTexturePixelCoordinates(unpack(kBorderMaskPixelCoords))
        newBlip.BorderMask:SetSize(Vector(kBorderMaskCircleRadius * 2, kBorderMaskCircleRadius * 2, 0))
        newBlip.BorderMask:SetPosition(Vector(-kBorderMaskCircleRadius, -kBorderMaskCircleRadius, 0))
        newBlip.BorderMask:SetStencilFunc(GUIItem.NotEqual)
        newBlip.Border:AddChild(newBlip.BorderMask)
    
    end
    
    // Create badge icon items
    newBlip.Badges = {}
    for i = 1,Badges_GetMaxBadges() do

        local badge = GUIManager:CreateGraphicItem()
        badge:SetAnchor(GUIItem.Left, GUIItem.Top)
        badge:SetSize(kBadgeSize)
        badge:SetPosition(Vector(-i * (kBadgeSize.x+5), kNameDefaultPos.y, 0))
        badge:SetIsVisible(false)

        table.insert( newBlip.Badges, badge )
        newBlip.statusBg:AddChild(badge)

    end
    
    if newBlip.smokeyBackground then
        newBlip.statusBg:AddChild(newBlip.smokeyBackground)
    end
    
    newBlip.statusBg:AddChild(newBlip.HealthBarBg)
    newBlip.statusBg:AddChild(newBlip.ArmorBarBg)
    newBlip.statusBg:AddChild(newBlip.NameText)
    newBlip.statusBg:AddChild(newBlip.HintText)
    
    if self.fullHUD then
        newBlip.statusBg:AddChild(newBlip.Border)
    end
    
    newBlip.statusBg:SetColor(Color(0,0,0,0))
    
    newBlip.GraphicsItem:AddChild(newBlip.ProgressingIcon)
    newBlip.GraphicsItem:AddChild(newBlip.OverLayGraphic)
    
    newBlip.ProgressingIcon:AddChild(newBlip.ActionText)
    
    return newBlip
    
end

local function AddWelderIcon(blipItem)

    blipItem.welderIcon = GetGUIManager():CreateGraphicItem()
    blipItem.welderIcon:SetTexture(kWelderTexture)
    blipItem.welderIcon:SetTexturePixelCoordinates(unpack(kWelderTexCoords))
    blipItem.welderIcon:SetSize(kWelderIconSize)
    blipItem.welderIcon:SetPosition(kWelderIconPos)
    blipItem.welderIcon:SetAnchor(GUIItem.Right, GUIItem.Center)    
    
    blipItem.statusBg:AddChild(blipItem.welderIcon)

end

function AddAbilityBar(blipItem)

    blipItem.AbilityBarBg = GetGUIManager():CreateGraphicItem()
    blipItem.AbilityBarBg:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    blipItem.AbilityBarBg:SetSize(Vector(kArmorBarWidth, kArmorBarHeight * 2, 0))
    blipItem.AbilityBarBg:SetPosition(Vector(-kArmorBarWidth / 2, -kArmorBarHeight * 2, 0))
    blipItem.AbilityBarBg:SetTexture("ui/unitstatus_neutral.dds")
    blipItem.AbilityBarBg:SetColor(Color(0,0,0,1))
    blipItem.AbilityBarBg:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kUnitStatusBarTexCoords))
    
    blipItem.AbilityBar = GUIManager:CreateGraphicItem()
    blipItem.AbilityBar:SetColor(Color(0.65, 0.65, 0.65, 1))
    blipItem.AbilityBar:SetSize(Vector(kArmorBarWidth, kArmorBarHeight *2, 0))
    blipItem.AbilityBar:SetTexture("ui/unitstatus_neutral.dds")
    blipItem.AbilityBar:SetTexturePixelCoordinates(unpack(GUIUnitStatus.kUnitStatusBarTexCoords))
    blipItem.AbilityBar:SetBlendTechnique(GUIItem.Add)
    blipItem.AbilityBarBg:AddChild(blipItem.AbilityBar)

    blipItem.statusBg:AddChild(blipItem.AbilityBarBg)

end

local function UpdateUnitStatusBlip( self, blipData, updateBlip, baseResearchRot, showHints, playerTeamType )

    local teamType = blipData.TeamType
    local isEnemy = false
    local isCrosshairTarget = blipData.IsCrossHairTarget 
    if playerTeamType ~= kNeutralTeamType then
        isEnemy = (playerTeamType ~= teamType) and (teamType ~= kNeutralTeamType)
        teamType = playerTeamType
    end

    local blipNameText = blipData.Name
    local healthFraction = 0
    local armorFraction = 0
    local abilityFraction = 0
    local statusFraction = 0

    local alpha = 0

    if isCrosshairTarget then
        healthFraction = blipData.HealthFraction
        armorFraction = blipData.ArmorFraction
        abilityFraction = blipData.AbilityFraction
        statusFraction = blipData.StatusFraction
        alpha = 1
    end

    if blipData.SpawnFraction ~= nil and not isEnemy and not isCrosshairTarget then
        // Show spawn progress
        blipNameText = blipData.SpawnerName
        healthFraction = math.max(0.01, blipData.SpawnFraction ) // always show at least 1% so there is a black bar
        alpha = 1
    end

    if blipData.EvolvePercentage ~= nil and not isEnemy and ( blipData.IsPlayer or isCrosshairTarget ) then
        // If evolving show evolve progress and hide the researching spinner
        abilityFraction = math.max(0.01, blipData.EvolvePercentage ) // always show at least 1% so there is a black bar
        statusFraction = 0
        alpha = 1
    end

    local textColor
    if isEnemy then
        textColor = GUIUnitStatus.kEnemyColor
    elseif blipData.IsParasited and blipData.IsFriend then
        textColor = kCommanderColorFloat
    elseif blipData.IsSteamFriend then
        textColor = kSteamFriendColor
    else
        textColor = kNameTagFontColors[teamType]
    end
        
    // status icon, color and unit name
    updateBlip.GraphicsItem:SetTexturePixelCoordinates(GetUnitStatusTextureCoordinates(blipData.Status))
    updateBlip.GraphicsItem:SetPosition(blipData.Position - GUIUnitStatus.kUnitStatusSize * .5 )

    updateBlip.OverLayGraphic:SetTexturePixelCoordinates(GetUnitStatusTextureCoordinates(blipData.Status))

    local showBacking = self.fullHUD and isCrosshairTarget and not PlayerUI_IsACommander() and healthFraction ~= 0

    updateBlip.statusBg:SetColor(Color(1,1,1,1))
    updateBlip.statusBg:SetTexture(showBacking and kStatusBgTexture[teamType] or kTransparentTexture )
    updateBlip.statusBg:SetPosition(blipData.HealthBarPosition - GUIUnitStatus.kStatusBgSize * .5 )

    if updateBlip.BorderMask then
        if teamType == kMarineTeamType and showBacking then			
            updateBlip.BorderMask:SetRotation(Vector(0, 0, -2 * math.pi * baseResearchRot))
            updateBlip.BorderMask:SetIsVisible(true)
        else
            updateBlip.BorderMask:SetIsVisible(false)
        end
    end
    if updateBlip.smokeyBackground then
        updateBlip.smokeyBackground:SetIsVisible(teamType == kAlienTeamType and showBacking)
    end

    // Name
    if ( blipData.ForceName and blipData.IsPlayer ) or alpha > 0 then
        updateBlip.NameText:SetIsVisible(true)
        updateBlip.NameText:SetText(blipNameText)
        updateBlip.NameText:SetColor(textColor) // use the entities team color here, so you can make a difference between enemy or friend
    else
        updateBlip.NameText:SetIsVisible(false)
    end

    // Health Bar
    if alpha > 0 and healthFraction ~= 0 then
        updateBlip.HealthBarBg:SetIsVisible(true)
        updateBlip.HealthBarBg:SetColor(kHealthBarBgColors[teamType])

        updateBlip.HealthBar:SetColor(kHealthBarColors[teamType])
        updateBlip.HealthBar:SetSize(Vector(kHealthBarWidth * healthFraction, kHealthBarHeight, 0))
        updateBlip.HealthBar:SetTexturePixelCoordinates(GetPixelCoordsForFraction(healthFraction))
    else
        updateBlip.HealthBarBg:SetIsVisible(false)
    end

    // Armor Bar
    if alpha > 0 and armorFraction ~= 0 then
        updateBlip.ArmorBarBg:SetIsVisible(true)
        updateBlip.ArmorBarBg:SetColor(kArmorBarBgColors[teamType])

        updateBlip.ArmorBar:SetColor(kArmorBarColors[teamType])
        updateBlip.ArmorBar:SetSize(Vector(kArmorBarWidth * armorFraction, kArmorBarHeight, 0))
        updateBlip.ArmorBar:SetTexturePixelCoordinates(GetPixelCoordsForFraction(armorFraction)) 
    else
        updateBlip.ArmorBarBg:SetIsVisible(false)
    end

    // Ammo/Ability Bar
    if abilityFraction > 0 then
        if not updateBlip.AbilityBarBg then    
            AddAbilityBar(updateBlip)
        end

        if alpha > 0 then      
            updateBlip.AbilityBarBg:SetIsVisible( true )
            updateBlip.AbilityBar:SetSize(Vector(kArmorBarWidth * abilityFraction, kArmorBarHeight * 2, 0))
            updateBlip.AbilityBar:SetTexturePixelCoordinates(GetPixelCoordsForFraction(abilityFraction)) 

            local ammoBarColor = blipData.PrimaryWeapon and kAmmoBarColors[blipData.PrimaryWeapon]
            if ammoBarColor then
                updateBlip.AbilityBar:SetColor(ammoBarColor)
            end
        else
            updateBlip.AbilityBarBg:SetIsVisible( false )
        end
    else
        if updateBlip.AbilityBarBg then
            GUI.DestroyItem(updateBlip.AbilityBarBg)
            updateBlip.AbilityBarBg = nil
            updateBlip.AbilityBar = nil
        end
    end

    // Hints
    if showHints and blipData.Hint ~= nil and string.len(blipData.Hint) > 0 and alpha > 0 then
        updateBlip.HintText:SetIsVisible(true)
        updateBlip.HintText:SetText(blipData.Hint)
        updateBlip.HintText:SetColor(textColor)

        updateBlip.statusBg:SetSize(GUIUnitStatus.kStatusBgSize)
        if updateBlip.Border then
            updateBlip.Border:SetSize(GUIUnitStatus.kStatusBgSize)
        end
    else
        updateBlip.HintText:SetIsVisible(false)
        updateBlip.statusBg:SetSize(GUIUnitStatus.kStatusBgNoHintSize)
        if updateBlip.Border then
            updateBlip.Border:SetSize(GUIUnitStatus.kStatusBgNoHintSize)
        end
    end

    // Research Progress
    if isCrosshairTarget and statusFraction > 0 and statusFraction < 1 then        
        updateBlip.ProgressingIcon:SetIsVisible(true)
        updateBlip.ProgressingIcon:SetRotation(Vector(0, 0, -2 * math.pi * baseResearchRot))
        updateBlip.ProgressText:SetText(math.floor(statusFraction * 100) .. "%")
        updateBlip.ActionText:SetText(blipData.Action)
        updateBlip.ActionText:SetColor(textColor)
    else
        updateBlip.ProgressingIcon:SetIsVisible(false)
    end

    // Badges
    if alpha > 0 then
        assert( #updateBlip.Badges >= #blipData.BadgeTextures )
        for i = 1, #updateBlip.Badges do

            local badge = updateBlip.Badges[i]
            local texture = blipData.BadgeTextures[i]

            if texture ~= nil then

                badge:SetTexture(texture)
                badge:SetIsVisible(true)

            else
                badge:SetIsVisible(false)
            end

        end
    else
        for i = 1, #updateBlip.Badges do
            updateBlip.Badges[i]:SetIsVisible(false)
        end
    end

    // Has Welder Icon
    local showWelderIcon = blipData.HasWelder and isCrosshairTarget
    if showWelderIcon and not updateBlip.welderIcon then

        AddWelderIcon(updateBlip)

    elseif not showWelderIcon and updateBlip.welderIcon then

        GUI.DestroyItem(updateBlip.welderIcon)
        updateBlip.welderIcon = nil

    end

end

local function UpdateUnitStatusList(self, activeBlips, deltaTime)

    PROFILE("GUIUnitStatus:UpdateUnitStatusList")
    
    local numBlips = #activeBlips
    
    while numBlips > table.count(self.activeBlipList) do
    
        local newBlipItem = CreateBlipItem(self)
        table.insert(self.activeBlipList, newBlipItem)
        newBlipItem.GraphicsItem:DestroyAnimations()
        newBlipItem.GraphicsItem:FadeIn(0.3, "UNIT_STATE_ANIM_ALPHA", AnimateLinear, Pulsate)
        
    end
    
    while numBlips < table.count(self.activeBlipList) do
    
        // fade out and destroy
        self.activeBlipList[1].GraphicsItem:Destroy()
        GUI.DestroyItem(self.activeBlipList[1].statusBg)
        table.remove(self.activeBlipList, 1)
        
    end
    
    local baseResearchRot = (Shared.GetTime() % GUIUnitStatus.kResearchRotationDuration) / GUIUnitStatus.kResearchRotationDuration
    local showHints = Client.GetOptionBoolean("showHints", true) == true
    local playerTeamType = PlayerUI_GetTeamType()
    
    // Update current blip state.
    local currentIndex = 1
    for i = 1, #self.activeBlipList do
        
        UpdateUnitStatusBlip( self, activeBlips[i], self.activeBlipList[i], baseResearchRot, showHints, playerTeamType )
        
    end

end

function GUIUnitStatus:Update(deltaTime)

    PROFILE("GUIUnitStatus:Update")
    
    GUIAnimatedScript.Update(self, deltaTime)
    
    local fullHUD = Client.GetOptionInteger("hudmode", kHUDMode.Full) == kHUDMode.Full
    if self.fullHUD ~= fullHUD then
        
        self.fullHUD = fullHUD
        DestroyActiveBlips(self)
        
    end
    
    UpdateUnitStatusList(self, PlayerUI_GetUnitStatusInfo(), deltaTime)
    
end
