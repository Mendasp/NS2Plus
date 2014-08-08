// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIGrenadelauncherDisplay.lua
//
// Created by: Andreas Urwalek (andi@unknownworlds.com)
//
// Displays the ammo counter for the shotgun.
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")
Script.Load("lua/Utility.lua")

// Global state that can be externally set to adjust the display.
weaponClip     = 0
weaponAmmo     = 0
weaponAuxClip  = 0
pitch          = 0
globalTime     = 0
lowAmmoWarning = true

bulletDisplay  = nil

//GUIGrenadelauncherDisplay.kammoDisplay = { 0, 198, 20, 103 }
local kViewPitchTexCoords = { 12, 32, 105, 221 }
local kBgTexCoords = { 128, 0, 256, 225 }
local kGrenadeBlueTexCoords = { 104, 231, 175, 252 }
local kGrenadeRedTexCoords = { 181, 231, 252, 252 }
local kClipHeight = 200
local kNumGrenades = 4
local kGrenadeHeight = 30
local kGrenadeOffset = -4
local kGrenadeWidth = 75

local kTexture = "models/marine/grenadelauncher/grenade_launcher_view_display.dds"

class 'GUIGrenadelauncherDisplay' (GUIScript)

function GUIGrenadelauncherDisplay:Initialize()

    self.maxClip = 4
    self.weaponClip = 0
    self.weaponAmmo = 0
    self.globalTime = 0
    self.lowAmmoWarning = true
    
    self.viewPitch = GUIManager:CreateGraphicItem()
    self.viewPitch:SetSize( Vector(128, 256, 0) )
    self.viewPitch:SetPosition( Vector(0, 0, 0))    
    self.viewPitch:SetTexture(kTexture)
    self.viewPitch:SetTexturePixelCoordinates(unpack(kViewPitchTexCoords))
    
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize( Vector(128, 256, 0) )
    self.background:SetPosition( Vector(128, 0, 0))    
    self.background:SetTexture(kTexture)
    self.background:SetTexturePixelCoordinates(unpack(kBgTexCoords))
    
    self.lowAmmoOverlay = GUIManager:CreateGraphicItem()
    self.lowAmmoOverlay:SetSize( Vector(128, 256, 0) )
    self.lowAmmoOverlay:SetPosition( Vector(0, 0, 0))
    
    self.ammoDisplay = GUIManager:CreateTextItem()
    self.ammoDisplay:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
    self.ammoDisplay:SetFontName(Fonts.kMicrogrammaDMedExt_Large)
    self.ammoDisplay:SetScale(Vector(0.5, 0.5, 0))
    self.ammoDisplay:SetPosition(Vector(0, -50, 0))
    self.ammoDisplay:SetTextAlignmentX(GUIItem.Align_Center)
    self.ammoDisplay:SetTextAlignmentY(GUIItem.Align_Center)

    self.background:SetIsVisible(true)
    
    self.background:AddChild(self.ammoDisplay)
    self.background:AddChild(self.lowAmmoOverlay)
    
    self.grenadeIcons = {}
    
    for i = 1, kNumGrenades do
    
        local grenadeIcon = GUIManager:CreateGraphicItem()
        grenadeIcon:SetTexture(kTexture)
        grenadeIcon:SetSize(Vector(kGrenadeWidth, kGrenadeHeight, 0))
        grenadeIcon:SetAnchor(GUIItem.Middle, GUIItem.Top)
        grenadeIcon:SetPosition(Vector(kGrenadeWidth * -.5, (kGrenadeHeight + 6) * i + kGrenadeOffset, 0))
        grenadeIcon:SetTexturePixelCoordinates(unpack(kGrenadeBlueTexCoords))
        grenadeIcon:SetBlendTechnique(GUIItem.Add)
        
        self.background:AddChild(grenadeIcon)
        
        table.insert(self.grenadeIcons, grenadeIcon)
    
    end
    
    // Force an update so our initial state is correct.
    self:Update(0)

end

function GUIGrenadelauncherDisplay:Update(deltaTime)

    PROFILE("GUIGrenadelauncherDisplay:Update")

    self.ammoDisplay:SetText(ToString(self.weaponAmmo))

    for i = 1, kNumGrenades do
    
        local grenadeIcon = self.grenadeIcons[i]
        grenadeIcon:SetIsVisible(kNumGrenades - weaponClip < i)
    
        if i == kNumGrenades then
        
            if self.weaponClip == 1 then
                grenadeIcon:SetTexturePixelCoordinates(unpack(kGrenadeRedTexCoords))
            else
                grenadeIcon:SetTexturePixelCoordinates(unpack(kGrenadeBlueTexCoords))
            end
            
        end
    
    end

    local alpha = 0
    local pulseSpeed = 5
    
    if self.weaponClip <= 2 then
        
        if self.weaponClip == 1 then
            pulseSpeed = 10
        elseif fraction == 0 then
            pulseSpeed = 25
        end
        
        alpha = (math.sin(self.globalTime * pulseSpeed) + 1) / 2
    end
    
    if not self.lowAmmoWarning then alpha = 0 end
    
    self.lowAmmoOverlay:SetColor(Color(1, 0, 0, alpha * 0.5))
    
end

function GUIGrenadelauncherDisplay:SetClip(weaponClip)
    self.weaponClip = weaponClip
end

function GUIGrenadelauncherDisplay:SetClipSize(weaponClipSize)
    self.weaponClipSize = weaponClipSize
end

function GUIGrenadelauncherDisplay:SetAmmo(weaponAmmo)
    self.weaponAmmo = weaponAmmo
end

function GUIGrenadelauncherDisplay:SetGlobalTime(globalTime)
    self.globalTime = globalTime
end

function GUIGrenadelauncherDisplay:SetLowAmmoWarning(lowAmmoWarning)
    self.lowAmmoWarning = ConditionalValue(lowAmmoWarning == "true", true, false)
end

/**
 * Called by the player to update the components.
 */
function Update(deltaTime)

    bulletDisplay:SetClip(weaponClip)
    bulletDisplay:SetAmmo(weaponAmmo)
    bulletDisplay:SetGlobalTime(globalTime)
    bulletDisplay:SetLowAmmoWarning(lowAmmoWarning)
    bulletDisplay:Update(deltaTime)
        
end

/**
 * Initializes the player components.
 */
function Initialize()

    GUI.SetSize( 256, 256 )

    bulletDisplay = GUIGrenadelauncherDisplay()
    bulletDisplay:Initialize()
    bulletDisplay:SetGlobalTime(globalTime)
    bulletDisplay:SetLowAmmoWarning(lowAmmoWarning)

end

Initialize()
