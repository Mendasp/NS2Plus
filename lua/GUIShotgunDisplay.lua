// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIShotgunDisplay.lua
//
// Created by: Max McGuire (max@unknownworlds.com)
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
globalTime     = 0

bulletDisplay  = nil

class 'GUIShotgunDisplay'

function GUIShotgunDisplay:Initialize()

    self.weaponClip     = 0
    self.weaponAmmo     = 0
    self.weaponClipSize = 6
	self.globalTime     = 0
    
    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize( Vector(256, 128, 0) )
    self.background:SetPosition( Vector(0, 0, 0))    
    self.background:SetTexture("ui/ShotgunDisplay.dds")
	
    self.lowAmmoOverlay = GUIManager:CreateGraphicItem()
    self.lowAmmoOverlay:SetSize( Vector(256, 128, 0) )
    self.lowAmmoOverlay:SetPosition( Vector(0, 0, 0))    
    self.background:AddChild(self.lowAmmoOverlay)
    
    self.clipText, self.clipTextBg = self:CreateItem(52, 66)
    self.ammoText, self.ammoTextBg = self:CreateItem(177, 66)
    
    local slash, slashBg = self:CreateItem(100, 66)
    slash:SetFontName("fonts/AgencyFB_large_bold.fnt")
    slash:SetText("/")
    slashBg:SetFontName("fonts/AgencyFB_large_bold.fnt")
    slashBg:SetText("/")
    
    // Force an update so our initial state is correct.
    self:Update(0)

end

function GUIShotgunDisplay:CreateItem(x, y)

    local textBg = GUIManager:CreateTextItem()
    textBg:SetFontName("fonts/MicrogrammaDMedExt_medium.fnt")
    textBg:SetFontSize(85)
    textBg:SetTextAlignmentX(GUIItem.Align_Center)
    textBg:SetTextAlignmentY(GUIItem.Align_Center)
    textBg:SetPosition(Vector(x, y, 0))
    textBg:SetColor(Color(0.88, 0.98, 1, 0.25))

    // Text displaying the amount of reserve ammo
    local text = GUIManager:CreateTextItem()
    text:SetFontName("fonts/MicrogrammaDMedExt_medium2.fnt")
    text:SetFontSize(75)
    text:SetTextAlignmentX(GUIItem.Align_Center)
    text:SetTextAlignmentY(GUIItem.Align_Center)
    text:SetPosition(Vector(x, y, 0))
    text:SetColor(Color(0.88, 0.98, 1))
    
    return text, textBg
    
end

function GUIShotgunDisplay:Update(deltaTime)

    PROFILE("GUIShotgunDisplay:Update")
    
    // Update the ammo counter.
    
    local clipFormat = string.format("%d", self.weaponClip) 
    local ammoFormat = string.format("%02d", self.weaponAmmo) 
    
    self.clipText:SetText( clipFormat )
    self.clipTextBg:SetText( clipFormat )
    
    self.ammoText:SetText( ammoFormat )
    self.ammoTextBg:SetText( ammoFormat )
    
	local fraction = self.weaponClip / self.weaponClipSize
	local alpha = 0
	local pulseSpeed = 5
	
	if fraction <= 0.4 then
		
		if fraction == 0 then
			pulseSpeed = 25
		elseif fraction < 0.25 then
			pulseSpeed = 10
		end
		
		alpha = (math.sin(self.globalTime * pulseSpeed) + 1) / 2
	end
	
	self.lowAmmoOverlay:SetColor(Color(1, 0, 0, alpha * 0.7))
    
end

function GUIShotgunDisplay:SetClip(weaponClip)
    self.weaponClip = weaponClip
end

function GUIShotgunDisplay:SetClipSize(weaponClipSize)
    self.weaponClipSize = weaponClipSize
end

function GUIShotgunDisplay:SetAmmo(weaponAmmo)
    self.weaponAmmo = weaponAmmo
end

function GUIShotgunDisplay:SetGlobalTime(globalTime)
    self.globalTime = globalTime
end

/**
 * Called by the player to update the components.
 */
function Update(deltaTime)

    bulletDisplay:SetClip(weaponClip)
    bulletDisplay:SetAmmo(weaponAmmo)
	bulletDisplay:SetGlobalTime(globalTime)
    bulletDisplay:Update(deltaTime)
        
end

/**
 * Initializes the player components.
 */
function Initialize()

    GUI.SetSize( 256, 128 )

    bulletDisplay = GUIShotgunDisplay()
    bulletDisplay:Initialize()
    bulletDisplay:SetClipSize(6)
	bulletDisplay:SetGlobalTime(globalTime)

end

Initialize()
