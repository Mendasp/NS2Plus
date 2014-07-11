// ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua\GUIBulletDisplay.lua
//
// Created by: Max McGuire (max@unknownworlds.com)
//
// Displays the current number of bullets and clips for the ammo counter on a bullet weapon
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIScript.lua")
Script.Load("lua/Utility.lua")

class 'GUIBulletDisplay' (GUIScript)

function GUIBulletDisplay:Initialize()

    self.weaponClip     = 0
	self.weaponVariant  = 1
    self.weaponAmmo     = 0
    self.weaponClipSize = 50
	self.globalTime     = 0
    
    self.onDraw = 0
    self.onHolster = 0

    self.background = GUIManager:CreateGraphicItem()
    self.background:SetSize( Vector(256, 512, 0) )
    self.background:SetPosition( Vector(0, 0, 0))    
    self.background:SetTexture("ui/rifledisplay0.dds")
    self.background:SetIsVisible(true)
	
    self.lowAmmoOverlay = GUIManager:CreateGraphicItem()
    self.lowAmmoOverlay:SetSize( Vector(256, 512, 0) )
    self.lowAmmoOverlay:SetPosition( Vector(0, 0, 0))

    // Slightly larger copy of the text for a glow effect
    self.ammoTextBg = GUIManager:CreateTextItem()
    self.ammoTextBg:SetFontName("fonts/MicrogrammaDMedExt_large.fnt")
    self.ammoTextBg:SetFontIsBold(true)
    self.ammoTextBg:SetFontSize(135)
    self.ammoTextBg:SetTextAlignmentX(GUIItem.Align_Center)
    self.ammoTextBg:SetTextAlignmentY(GUIItem.Align_Center)
    self.ammoTextBg:SetPosition(Vector(135, 88, 0))
    self.ammoTextBg:SetColor(Color(1, 1, 1, 0.25))

    // Text displaying the amount of ammo in the clip
    self.ammoText = GUIManager:CreateTextItem()
    self.ammoText:SetFontName("fonts/MicrogrammaDMedExt_large.fnt")
    self.ammoText:SetFontIsBold(true)
    self.ammoText:SetFontSize(120)
    self.ammoText:SetTextAlignmentX(GUIItem.Align_Center)
    self.ammoText:SetTextAlignmentY(GUIItem.Align_Center)
    self.ammoText:SetPosition(Vector(135, 88, 0))
    
    // Create the indicators for the number of bullets in reserve.

    self.clipTop    = 400 - 256
    self.clipHeight = 69
    self.clipWidth  = 21
    
    self.numClips   = 4
    self.clip = { }
    
    for i =1,self.numClips do
        self.clip[i] = GUIManager:CreateGraphicItem()
        self.clip[i]:SetTexture("ui/rifledisplay0.dds")
        self.clip[i]:SetSize( Vector(21, self.clipHeight, 0) )
        self.clip[i]:SetBlendTechnique( GUIItem.Add )
    end
    
    self.clip[1]:SetPosition(Vector( 74, self.clipTop, 0))
    self.clip[2]:SetPosition(Vector( 112, self.clipTop, 0))
    self.clip[3]:SetPosition(Vector( 145, self.clipTop, 0))
    self.clip[4]:SetPosition(Vector( 178, self.clipTop, 0))
    
    // Force an update so our initial state is correct.
    self:Update(0)

end

function GUIBulletDisplay:InitlowAmmoOverlay()

end

function GUIBulletDisplay:Update(deltaTime)

    PROFILE("GUIBulletDisplay:Update")
    
    // Update the ammo counter.
    
    local ammoFormat = string.format("%02d", self.weaponClip) 
    self.ammoText:SetText( ammoFormat )
    self.ammoTextBg:SetText( ammoFormat )
    
    // Update the reserve clip.
    
    local reserveMax      = self.numClips * self.weaponClipSize
    local reserve         = self.weaponAmmo
    local reserveFraction = (reserve / reserveMax) * self.numClips

    for i=1,self.numClips do
        self:SetClipFraction( i, Math.Clamp(reserveFraction - i + 1, 0, 1) )
    end
    
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

function GUIBulletDisplay:SetClip(weaponClip)
    self.weaponClip = weaponClip
end

function GUIBulletDisplay:SetWeaponVariant(weaponVariant)
	if weaponVariant ~= -1 then
		self.background:SetTexture("ui/rifledisplay" .. weaponVariant-1 .. ".dds")
		for i =1,self.numClips do
			self.clip[i]:SetTexture("ui/rifledisplay" .. weaponVariant-1 .. ".dds")
		end
	end
end

function GUIBulletDisplay:SetClipSize(weaponClipSize)
    self.weaponClipSize = weaponClipSize
end

function GUIBulletDisplay:SetAmmo(weaponAmmo)
    self.weaponAmmo = weaponAmmo
end

function GUIBulletDisplay:SetGlobalTime(globalTime)
    self.globalTime = globalTime
end

function GUIBulletDisplay:SetClipFraction(clipIndex, fraction)

    local offset   = (1 - fraction) * self.clipHeight
    local position = Vector( self.clip[clipIndex]:GetPosition().x, self.clipTop + offset, 0 )
    local size     = self.clip[clipIndex]:GetSize()
    
    self.clip[clipIndex]:SetPosition( position )
    self.clip[clipIndex]:SetSize( Vector( size.x, fraction * self.clipHeight, 0 ) )
    self.clip[clipIndex]:SetTexturePixelCoordinates( position.x, position.y + 256, position.x + self.clipWidth, self.clipTop + self.clipHeight + 256 )

end