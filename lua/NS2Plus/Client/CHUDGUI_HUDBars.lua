Script.Load("lua/GUIAnimatedScript.lua")

-- I had to reorganize this code at least 10 times because of varying and increasingly specific conditions.
-- Please, forgive me if something is super twisted, I can't be bothered going through this again.

class 'CHUDGUI_HUDBars' (GUIAnimatedScript)

local kBarSize, kXOffset, leftBarXOffset, rightBarXOffset, yOffset, leftBarXAnchor, rightBarXAnchor, yAnchor, kBarBgTexCoords, kBarTexCoords, hudbars
local kCenterBarTexture = PrecacheAsset("ui/centerhudbar.dds")
local kBottomBar1MainTexture = PrecacheAsset("ui/bottomhudbar1main.dds")
local kBottomBar1SecTexture = PrecacheAsset("ui/bottomhudbar1sec.dds")
local kBottomBar1BgTexture = PrecacheAsset("ui/bottomhudbar1bg.dds")
local kBottomBar2BgLTexture = PrecacheAsset("ui/bottomhudbar2bg-l.dds")
local kBottomBar2BgRTexture = PrecacheAsset("ui/bottomhudbar2bg-r.dds")
local kBottomBar2HPTexture = PrecacheAsset("ui/bottomhudbar2hp.dds")
local kBottomBar2APTexture = PrecacheAsset("ui/bottomhudbar2ap.dds")
local kBottomBar2RightTexture = PrecacheAsset("ui/bottomhudbar2right.dds")
local kFontName = Fonts.kAgencyFB_Tiny

local kHealthColors = { Color(0, 0.6117, 1, 1), Color(1,1,0,1) }
local kArmorColors = { Color(0, 0.25, 0.45, 1), Color(1, 0.4941, 0, 1) }
local kAmmoColors = { Color(0, 0.6117, 1, 1), Color(1,1,0,1) }

local kBarBgLTextures = { kBottomBar1BgTexture, kBottomBar2BgLTexture, kCenterBarTexture }
local kBarBgRTextures = { kBottomBar1BgTexture, kBottomBar2BgRTexture, kCenterBarTexture }
local kBarHPTextures = { kBottomBar1MainTexture, kBottomBar2HPTexture, kCenterBarTexture }
local kBarAPTextures = { kBottomBar1SecTexture, kBottomBar2APTexture, kCenterBarTexture }
local kBarRightTextures = { kBottomBar1MainTexture, kBottomBar2RightTexture, kCenterBarTexture }

local kBottomBar1SecSizeProportion = 0.925
local crosshairScale = 1

function CHUDGUI_HUDBars:Initialize()

	GUIAnimatedScript.Initialize(self)
	
	self.team = Client.GetLocalPlayer():GetTeamNumber()
	
	-- Only scale if crosshair is scaling up
	crosshairScale = ConditionalValue(CHUDGetOption("crosshairscale") > 1, CHUDGetOption("crosshairscale"), 1)
	
	local kBottomBarBgTexture, kBottomBarHPTexture, kBottomBarAPTexture, kBottomBarRightTexture
	local isMarine = self.team == kTeam1Index
	hudbars = isMarine and CHUDGetOption("hudbars_m") or CHUDGetOption("hudbars_a")
	
	local textureMode = hudbars == 1 and 3 or self.team
	kBarSize = { GUIScale(Vector(32, 64, 0))*crosshairScale, Vector(GUIScale(128), Client.GetScreenHeight()/3, 0) }
	kXOffset = { GUIScale(32)*crosshairScale, 0 }
	leftBarXOffset = { -kXOffset[hudbars]-kBarSize[hudbars].x, 0 }
	rightBarXOffset = { -leftBarXOffset[1], 0 }
	yOffset = { kBarSize[hudbars].y/2, hudbars == 2 and isMarine and GUIScale(-16) or 0 }
	leftBarXAnchor = { GUIItem.Middle, GUIItem.Left }
	rightBarXAnchor = { GUIItem.Middle, GUIItem.Right }
	yAnchor = { GUIItem.Center, GUIItem.Bottom }
	kBarBgTexCoords = ConditionalValue(hudbars == 1, { 0, 255, 63, 127 }, {0, 359, 127, 0})
	kBarTexCoords = ConditionalValue(hudbars == 1, { 0, 127, 63, 0 },  {0, 359, 127, 0})
	
	self.leftBarBg = self:CreateAnimatedGraphicItem()
	self.leftBarBg:SetAnchor(leftBarXAnchor[hudbars], yAnchor[hudbars])
	self.leftBarBg:SetLayer(kGUILayerPlayerHUD)
	self.leftBarBg:SetIsVisible(true)
	self.leftBarBg:SetIsScaling(false)
	self.leftBarBg:SetTexture(kBarBgLTextures[textureMode])
	self.leftBarBg:SetTexturePixelCoordinates(unpack(kBarBgTexCoords))
	self.leftBarBg:SetSize(Vector(kBarSize[hudbars].x, -kBarSize[hudbars].y, 0))
	self.leftBarBg:SetPosition(Vector(leftBarXOffset[hudbars], yOffset[hudbars], 0))
	
	self.healthBar = self:CreateAnimatedGraphicItem()
	self.healthBar:SetAnchor(leftBarXAnchor[hudbars], yAnchor[hudbars])
	self.healthBar:SetLayer(kGUILayerPlayerHUD)
	self.healthBar:SetIsVisible(true)
	self.healthBar:SetIsScaling(false)
	self.healthBar:SetTexture(kBarHPTextures[textureMode])
	self.healthBar:SetPosition(Vector(leftBarXOffset[hudbars], yOffset[hudbars], 0))
	
	self.armorBar = self:CreateAnimatedGraphicItem()
	self.armorBar:SetAnchor(leftBarXAnchor[hudbars], yAnchor[hudbars])
	self.armorBar:SetLayer(kGUILayerPlayerHUD)
	self.armorBar:SetIsVisible(true)
	self.armorBar:SetIsScaling(false)
	self.armorBar:SetTexture(kBarAPTextures[textureMode])
	
	self.rightBarBg = self:CreateAnimatedGraphicItem()
	self.rightBarBg:SetAnchor(rightBarXAnchor[hudbars], yAnchor[hudbars])
	self.rightBarBg:SetLayer(kGUILayerPlayerHUD)
	self.rightBarBg:SetIsVisible(true)
	self.rightBarBg:SetIsScaling(false)
	self.rightBarBg:SetTexture(kBarBgRTextures[textureMode])
	self.rightBarBg:SetTexturePixelCoordinates(unpack(kBarBgTexCoords))
	self.rightBarBg:SetSize(Vector(-kBarSize[hudbars].x, -kBarSize[hudbars].y, 0))
	self.rightBarBg:SetPosition(Vector(rightBarXOffset[hudbars], yOffset[hudbars], 0))
	
	self.rightBar = self:CreateAnimatedGraphicItem()
	self.rightBar:SetAnchor(rightBarXAnchor[hudbars], yAnchor[hudbars])
	self.rightBar:SetLayer(kGUILayerPlayerHUD)
	self.rightBar:SetIsVisible(true)
	self.rightBar:SetIsScaling(false)
	self.rightBar:SetTexture(kBarRightTextures[textureMode])
	self.rightBar:SetPosition(Vector(rightBarXOffset[hudbars], yOffset[hudbars], 0))
	
	self.healthTextBg = self:CreateAnimatedTextItem()
	self.healthTextBg:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.healthTextBg:SetFontName(kFontName)
	self.healthTextBg:SetTextAlignmentX(GUIItem.Align_Center)
	self.healthTextBg:SetLayer(kGUILayerPlayerHUD)
	self.healthTextBg:SetIsVisible(true)
	self.healthTextBg:SetIsScaling(false)
	self.healthTextBg:SetColor(Color(0,0,0,1))
	self.healthTextBg:SetPosition(Vector(leftBarXOffset[hudbars]/2-GUIScale(10), kBarSize[hudbars].y/2+GUIScale(10), 0))
	self.healthTextBg:SetScale(GetScaledVector())
	GUIMakeFontScale(self.healthTextBg)
	
	self.healthText = self:CreateAnimatedTextItem()
	self.healthText:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.healthText:SetFontName(kFontName)
	self.healthText:SetTextAlignmentX(GUIItem.Align_Center)
	self.healthText:SetLayer(kGUILayerPlayerHUD)
	self.healthText:SetIsVisible(true)
	self.healthText:SetIsScaling(false)
	self.healthText:SetColor(Color(1,1,1,1))
	self.healthText:SetPosition(Vector(leftBarXOffset[hudbars]/2-GUIScale(12), kBarSize[hudbars].y/2+GUIScale(8), 0))
	self.healthText:SetScale(GetScaledVector())
	GUIMakeFontScale(self.healthText)
	
	self.ammoTextBg = self:CreateAnimatedTextItem()
	self.ammoTextBg:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.ammoTextBg:SetFontName(kFontName)
	self.ammoTextBg:SetTextAlignmentX(GUIItem.Align_Center)
	self.ammoTextBg:SetLayer(kGUILayerPlayerHUD)
	self.ammoTextBg:SetIsVisible(true)
	self.ammoTextBg:SetIsScaling(false)
	self.ammoTextBg:SetColor(Color(0,0,0,1))
	self.ammoTextBg:SetPosition(Vector(rightBarXOffset[hudbars]/2+GUIScale(12), kBarSize[hudbars].y/2+GUIScale(10), 0))
	self.ammoTextBg:SetScale(GetScaledVector())
	GUIMakeFontScale(self.ammoTextBg)
	
	self.ammoText = self:CreateAnimatedTextItem()
	self.ammoText:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.ammoText:SetFontName(kFontName)
	self.ammoText:SetTextAlignmentX(GUIItem.Align_Center)
	self.ammoText:SetLayer(kGUILayerPlayerHUD)
	self.ammoText:SetIsVisible(true)
	self.ammoText:SetIsScaling(false)
	self.ammoText:SetColor(Color(1,1,1,1))
	self.ammoText:SetPosition(Vector(rightBarXOffset[hudbars]/2+GUIScale(10), kBarSize[hudbars].y/2+GUIScale(8), 0))
	self.ammoText:SetScale(GetScaledVector())
	GUIMakeFontScale(self.ammoText)

	self.reloadIndicatorTextBG = self:CreateAnimatedTextItem()
	self.reloadIndicatorTextBG:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.reloadIndicatorTextBG:SetFontName(kFontName)
	self.reloadIndicatorTextBG:SetTextAlignmentX(GUIItem.Align_Center)
	self.reloadIndicatorTextBG:SetLayer(kGUILayerPlayerHUD)
	self.reloadIndicatorTextBG:SetIsVisible(false)
	self.reloadIndicatorTextBG:SetIsScaling(false)
	self.reloadIndicatorTextBG:SetText("R")
	self.reloadIndicatorTextBG:SetColor(Color(0,0,0,1))
	self.reloadIndicatorTextBG:SetPosition(Vector(GUIScale(2), kBarSize[hudbars].y/2+GUIScale(10), 0))
	self.reloadIndicatorTextBG:SetScale(GetScaledVector())
	GUIMakeFontScale(self.reloadIndicatorTextBG)

	self.reloadIndicatorText = self:CreateAnimatedTextItem()
	self.reloadIndicatorText:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.reloadIndicatorText:SetFontName(kFontName)
	self.reloadIndicatorText:SetTextAlignmentX(GUIItem.Align_Center)
	self.reloadIndicatorText:SetLayer(kGUILayerPlayerHUD)
	self.reloadIndicatorText:SetIsVisible(false)
	self.reloadIndicatorText:SetIsScaling(false)
	self.reloadIndicatorText:SetText("R")
	self.reloadIndicatorText:SetColor(Color(1,1,1,1))
	self.reloadIndicatorText:SetPosition(Vector(0, kBarSize[hudbars].y/2+GUIScale(8), 0))
	self.reloadIndicatorText:SetScale(GetScaledVector())
	GUIMakeFontScale(self.reloadIndicatorText)
	
	if hudbars == 2 and isMarine then
		self.reserveBar = self:CreateAnimatedGraphicItem()
		self.reserveBar:SetAnchor(rightBarXAnchor[hudbars], yAnchor[hudbars])
		self.reserveBar:SetLayer(kGUILayerPlayerHUD)
		self.reserveBar:SetIsVisible(true)
		self.reserveBar:SetIsScaling(false)
		self.reserveBar:SetTexture(kBottomBar1SecTexture)
		self.reserveBar:SetPosition(Vector(rightBarXOffset[hudbars], yOffset[hudbars], 0))
	end
	
	self.lastReserveAmmo = -1
	self.lastHealth = -1
	self.lastArmor = -1
	
	HelpScreen_AddObserver(self)
	
	self.vis = true -- ie, not forcibly hidden by something else.

end

function CHUDGUI_HUDBars:OnHelpScreenVisChange(state)
	
	self.vis = not state
	self:Update(0)
	
end

function CHUDGUI_HUDBars:Uninitialize()

	GUIAnimatedScript.Uninitialize(self)
	
	self.leftBarBg:Destroy()
	self.healthBar:Destroy()
	self.armorBar:Destroy()
	self.rightBarBg:Destroy()
	self.rightBar:Destroy()
	self.healthTextBg:Destroy()
	self.healthText:Destroy()
	self.ammoTextBg:Destroy()
	self.ammoText:Destroy()
	self.reloadIndicatorText:Destroy()
	self.reloadIndicatorTextBG:Destroy()
	if self.reserveBar then
		self.reserveBar:Destroy()
		self.reserveBar = nil
	end
	
	HelpScreen_RemoveObserver(self)

end

function CHUDGUI_HUDBars:Reset()

	GUIAnimatedScript.Reset(self)
	
	self:Uninitialize()
	self:Initialize()

end

function CHUDGUI_HUDBars:Update(deltaTime)
	local player = Client.GetLocalPlayer()
	local teamIndex = player:GetTeamNumber()
	
	-- If we get team swapped reinit the script
	if self.team ~= teamIndex then
		self:Reset()
	end
	
	local pulsatingRed = Color(0.5+((math.sin(Shared.GetTime() * 10) + 1) / 2)*0.5, 0, 0, 1)

	GUIAnimatedScript.Update(self, deltaTime)

	if player and player:GetIsAlive() and self.vis then
		self.leftBarBg:SetIsVisible(true)
		self.rightBarBg:SetIsVisible(true)
	
		-- This is what vanilla is doing with health display so might as well do the same
		-- Except for the Exo shenanigans, but still
		local health = player:isa("Exo") and 0 or math.max(1, math.floor(player:GetHealth()))
		-- Do not multiply by kHealthPointsPerArmor here so we can display the armor number directly later
		local armor = player:isa("Exo") and math.max(1, math.floor(player:GetArmor())) or math.floor(player:GetArmor())
		local armorHP = player:GetArmor() * kHealthPointsPerArmor
		local maxHealth = player:isa("Exo") and 0 or player:GetMaxHealth()
		local maxArmor = player:GetMaxArmor() * kHealthPointsPerArmor
		-- For the mode 2 of hudbars the bars show on top of each other, so we need the fractions independent of each other
		local healthFraction = hudbars == 2 and health/maxHealth or health/(maxHealth+maxArmor)
		local armorFraction = hudbars == 2 and armorHP/maxArmor or armorHP/(maxHealth+maxArmor)
		if self.reserveBar then armorFraction = armorFraction * kBottomBar1SecSizeProportion end
		local activeWeapon = player:GetActiveWeapon()
		local rightFraction = 0
		local reserveFraction = 0
		local rightPulsatingRed = false
		
		if activeWeapon then
			if player:isa("Alien") then
				local energy = player:GetEnergy()
				local maxEnergy = player:GetMaxEnergy()
				local energyCost = activeWeapon:GetEnergyCost()
				
				self.rightBar:SetIsVisible(false)
				rightFraction = energy / maxEnergy
				rightPulsatingRed = energy < energyCost
			elseif player:isa("Marine") or player:isa("Exo") then
				rightFraction = CHUDGetWeaponAmmoFraction(activeWeapon)
				reserveFraction = CHUDGetWeaponReserveAmmoFraction(activeWeapon)
				if reserveFraction ~= -1 then
					rightPulsatingRed = rightFraction <= 0.4 or (activeWeapon:isa("GrenadeLauncher") and rightFraction <= 0.5)
				end
			end
		end
		
		-- Don't display the text for the NS1 bars, we will reuse the existing UI elements
		if (player:isa("Marine") or player:isa("Exo") or player:isa("Alien")) and hudbars == 1 then
			if self.lastHealth ~= health or self.lastArmor ~= armor then
				if not player:isa("Exo") then
					self.healthText:SetText(string.format("%s / %s", health, armor))
					self.healthTextBg:SetText(string.format("%s / %s", health, armor))
				else
					self.healthText:SetText(string.format("%s", armor))
					self.healthTextBg:SetText(string.format("%s", armor))
				end
				
				self.healthText:SetIsVisible(true)
				self.healthTextBg:SetIsVisible(true)
				self.healthText:SetColor(Color(1,1,1,1))
				self.healthTextBg:SetColor(Color(0,0,0,1))
				
				self.healthText:FadeOut(3, "HP_FADEOUT")
				self.healthTextBg:FadeOut(3, "HP_FADEOUT")
				
				self.lastHealth = health
				self.lastArmor = armor
			end
			
			if activeWeapon and player:isa("Marine") or player:isa("Exo") then
				local clip = CHUDGetWeaponAmmoString(activeWeapon)
				local ammo = CHUDGetWeaponReserveAmmoString(activeWeapon)
				local isReloading = activeWeapon:isa("ClipWeapon") and activeWeapon:GetIsReloading()

				self.reloadIndicatorText:SetIsVisible(isReloading)
				self.reloadIndicatorTextBG:SetIsVisible(isReloading)
				
				if reserveFraction ~= -1 then
					self.ammoText:SetText(string.format("%s / %s", clip, ammo))
					self.ammoTextBg:SetText(string.format("%s / %s", clip, ammo))
				else
					self.ammoText:SetText(string.format("%s", clip))
					self.ammoTextBg:SetText(string.format("%s", clip))
					-- If we have no reserve ammo, use the actual "ammo" as clip
					ammo = clip
				end
				
				if self.lastReserveAmmo ~= ammo then
					self.ammoText:SetIsVisible(true)
					self.ammoTextBg:SetIsVisible(true)
					self.ammoText:SetColor(Color(1,1,1,1))
					self.ammoTextBg:SetColor(Color(0,0,0,1))
					
					self.ammoText:FadeOut(3, "AMMO_FADEOUT")
					self.ammoTextBg:FadeOut(3, "AMMO_FADEOUT")
					
					self.lastReserveAmmo = ammo
				end
			else
				self.ammoText:SetIsVisible(false)
				self.ammoTextBg:SetIsVisible(false)
				-- When switching to non-clipweapons and switching back we want the text to show up again
				self.lastReserveAmmo = -1
			end
		else
			self.healthText:SetIsVisible(false)
			self.healthTextBg:SetIsVisible(false)
		end
		
		-- The armor bar coordinates and position depend on the mode, since for mode 2 the bars are on top of each other instead of in a single continuous bar
		local hpTextureCoord = kBarTexCoords[2]-kBarTexCoords[2]*healthFraction
		local apTextureBottomCoord = hudbars == 2 and kBarTexCoords[2] or hpTextureCoord
		local apTextureTopCoord = hudbars == 2 and kBarTexCoords[2]-kBarTexCoords[2]*armorFraction or hpTextureCoord-kBarTexCoords[2]*armorFraction
		local armorDistance = hudbars == 2 and 0 or healthFraction
		local healthColor = ConditionalValue(healthFraction < 0.3, pulsatingRed, hudbars == 1 and kHealthColors[teamIndex] or kWhite)
		local armorColor = ConditionalValue(player:isa("Exo") and armor < 100, pulsatingRed, hudbars == 1 and kArmorColors[teamIndex] or kWhite)
		local rightColor = ConditionalValue(rightPulsatingRed, pulsatingRed, hudbars == 1 and kAmmoColors[teamIndex] or kWhite)
		
		self.healthBar:SetIsVisible(healthFraction > 0)
		self.healthBar:SetSize(Vector(kBarSize[hudbars].x, -kBarSize[hudbars].y*healthFraction, 0))
		self.healthBar:SetTexturePixelCoordinates(kBarTexCoords[1], kBarTexCoords[2], kBarTexCoords[3], hpTextureCoord)
		self.healthBar:SetColor(healthColor)
		
		self.armorBar:SetIsVisible(armorFraction > 0)
		self.armorBar:SetSize(Vector(kBarSize[hudbars].x, -kBarSize[hudbars].y*armorFraction, 0))
		self.armorBar:SetPosition(Vector(leftBarXOffset[hudbars], yOffset[hudbars]-kBarSize[hudbars].y*armorDistance, 0))
		self.armorBar:SetTexturePixelCoordinates(kBarTexCoords[1], apTextureBottomCoord, kBarTexCoords[3], apTextureTopCoord)
		self.armorBar:SetColor(armorColor)

		self.rightBar:SetIsVisible(rightFraction > 0)
		self.rightBar:SetSize(Vector(-kBarSize[hudbars].x, -kBarSize[hudbars].y*rightFraction, 0))
		self.rightBar:SetTexturePixelCoordinates(kBarTexCoords[1], kBarTexCoords[2], kBarTexCoords[3], kBarTexCoords[2]-kBarTexCoords[2]*rightFraction)
		self.rightBar:SetColor(rightColor)
		
		if self.reserveBar then
			self.reserveBar:SetIsVisible(reserveFraction > 0)
			self.reserveBar:SetSize(Vector(-kBarSize[hudbars].x, -kBarSize[hudbars].y*reserveFraction*kBottomBar1SecSizeProportion, 0))
			self.reserveBar:SetTexturePixelCoordinates(kBarTexCoords[1], kBarTexCoords[2], kBarTexCoords[3], kBarTexCoords[2]-kBarTexCoords[2]*reserveFraction*kBottomBar1SecSizeProportion)
			self.reserveBar:SetColor(kWhite)
		end

	else
		self.healthBar:SetIsVisible(false)
		self.armorBar:SetIsVisible(false)
		self.rightBar:SetIsVisible(false)
		self.leftBarBg:SetIsVisible(false)
		self.rightBarBg:SetIsVisible(false)
		self.healthText:SetIsVisible(false)
		self.healthTextBg:SetIsVisible(false)
		self.ammoText:SetIsVisible(false)
		self.ammoTextBg:SetIsVisible(false)
		self.reloadIndicatorText:SetIsVisible(false)
		self.reloadIndicatorTextBG:SetIsVisible(false)
		if self.reserveBar then
			self.reserveBar:SetIsVisible(false)
		end
	end

end
