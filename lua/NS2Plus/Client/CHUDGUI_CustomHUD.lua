Script.Load("lua/GUIAnimatedScript.lua")

class 'CHUDGUI_CustomHUD' (GUIAnimatedScript)

local kBarSize, kXOffset, leftBarXOffset, rightBarXOffset, yOffset, leftBarXAnchor, rightBarXAnchor, yAnchor, kBarBgTexCoords, kBarTexCoords, hudbars
local kCenterBarTexture = PrecacheAsset("ui/centerhudbar.dds")
local kBottomBar1BgTexture = PrecacheAsset("ui/bottomhudbar1bg.dds")
local kBottomBar1Texture = PrecacheAsset("ui/bottomhudbar1.dds")
local kBottomBar2BgTexture = PrecacheAsset("ui/bottomhudbar2bg.dds")
local kBottomBar2HPTexture = PrecacheAsset("ui/bottomhudbar2hp.dds")
local kBottomBar2APTexture = PrecacheAsset("ui/bottomhudbar2ap.dds")
local kBottomBar2RightTexture = PrecacheAsset("ui/bottomhudbar2right.dds")
local kFontName = Fonts.kAgencyFB_Tiny

local kHealthColors = { Color(0, 0.6117, 1, 1), Color(1,1,0,1) }
local kArmorColors = { Color(0, 0.25, 0.45, 1), Color(1, 0.4941, 0, 1) }
local kAmmoColors = { Color(0, 0.6117, 1, 1), Color(1,1,0,1) }

local kBarBgTextures = { kBottomBar1BgTexture, kBottomBar2BgTexture, kCenterBarTexture }
local kBarHPTextures = { kBottomBar1Texture, kBottomBar2HPTexture, kCenterBarTexture }
local kBarAPTextures = { kBottomBar1Texture, kBottomBar2APTexture, kCenterBarTexture }
local kBarRightTextures = { kBottomBar1Texture, kBottomBar2RightTexture, kCenterBarTexture }

function CHUDGUI_CustomHUD:Initialize()

	GUIAnimatedScript.Initialize(self)
	
	local kBottomBarBgTexture, kBottomBarHPTexture, kBottomBarAPTexture, kBottomBarRightTexture
	local isMarine = Client.GetLocalPlayer():GetTeamNumber() == kTeam1Index
	hudbars = isMarine and CHUDGetOption("customhud_m") or CHUDGetOption("customhud_a")
	
	local textureMode = hudbars == 1 and 3 or Client.GetLocalPlayer():GetTeamNumber()
	kBarSize = { Vector(32, 64, 0), GUIScale(Vector(128, kBaseScreenHeight/3, 0)) }
	kXOffset = { 32, 0 }
	leftBarXOffset = { -kXOffset[hudbars]-kBarSize[hudbars].x, 0 }
	rightBarXOffset = { -leftBarXOffset[1], 0 }
	yOffset = { kBarSize[hudbars].y/2, 0 }
	leftBarXAnchor = { GUIItem.Middle, GUIItem.Left }
	rightBarXAnchor = { GUIItem.Middle, GUIItem.Right }
	yAnchor = { GUIItem.Center, GUIItem.Bottom }
	kBarBgTexCoords = ConditionalValue(hudbars == 1, { 0, 127, 31, 63 }, {0, 359, 127, 0})
	kBarTexCoords = ConditionalValue(hudbars == 1, { 0, 63, 31, 0 },  {0, 359, 127, 0})
	
	self.leftBarBg = self:CreateAnimatedGraphicItem()
	self.leftBarBg:SetAnchor(leftBarXAnchor[hudbars], yAnchor[hudbars])
	self.leftBarBg:SetLayer(kGUILayerPlayerHUD)
	self.leftBarBg:SetIsVisible(true)
	self.leftBarBg:SetIsScaling(false)
	self.leftBarBg:SetTexture(kBarBgTextures[textureMode])
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
	self.rightBarBg:SetTexture(kBarBgTextures[textureMode])
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
	self.healthTextBg:SetPosition(Vector(leftBarXOffset[hudbars]/2-10, kBarSize[hudbars].y/2+10, 0))
	
	self.healthText = self:CreateAnimatedTextItem()
	self.healthText:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.healthText:SetFontName(kFontName)
	self.healthText:SetTextAlignmentX(GUIItem.Align_Center)
	self.healthText:SetLayer(kGUILayerPlayerHUD)
	self.healthText:SetIsVisible(true)
	self.healthText:SetIsScaling(false)
	self.healthText:SetColor(Color(1,1,1,1))
	self.healthText:SetPosition(Vector(leftBarXOffset[hudbars]/2-12, kBarSize[hudbars].y/2+8, 0))
	
	self.ammoTextBg = self:CreateAnimatedTextItem()
	self.ammoTextBg:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.ammoTextBg:SetFontName(kFontName)
	self.ammoTextBg:SetTextAlignmentX(GUIItem.Align_Center)
	self.ammoTextBg:SetLayer(kGUILayerPlayerHUD)
	self.ammoTextBg:SetIsVisible(true)
	self.ammoTextBg:SetIsScaling(false)
	self.ammoTextBg:SetColor(Color(0,0,0,1))
	self.ammoTextBg:SetPosition(Vector(rightBarXOffset[hudbars]/2+12, kBarSize[hudbars].y/2+10, 0))
	
	self.ammoText = self:CreateAnimatedTextItem()
	self.ammoText:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.ammoText:SetFontName(kFontName)
	self.ammoText:SetTextAlignmentX(GUIItem.Align_Center)
	self.ammoText:SetLayer(kGUILayerPlayerHUD)
	self.ammoText:SetIsVisible(true)
	self.ammoText:SetIsScaling(false)
	self.ammoText:SetColor(Color(1,1,1,1))
	self.ammoText:SetPosition(Vector(rightBarXOffset[hudbars]/2+10, kBarSize[hudbars].y/2+8, 0))
	
	self.lastReserveAmmo = 0
	self.lastHealth = 0
	self.lastArmor = 0

end

function CHUDGUI_CustomHUD:Reset()

	GUIAnimatedScript.Reset(self)

end

function CHUDGUI_CustomHUD:Update(deltaTime)
	local player = Client.GetLocalPlayer()
	local teamIndex = player:GetTeamNumber()
	local pulsatingRed = Color(0.5+((math.sin(Shared.GetTime() * 10) + 1) / 2)*0.5, 0, 0, 1)

	GUIAnimatedScript.Update(self, deltaTime)

	if player and player:GetIsAlive() then
		local health = player:isa("Exo") and 0 or player:GetHealth()
		-- Do not multiply by kHealthPointsPerArmor here so we can display the armor number directly later
		local armor = player:GetArmor()
		local maxHealth = player:isa("Exo") and 0 or player:GetMaxHealth()
		local maxArmor = player:GetMaxArmor() * kHealthPointsPerArmor
		local healthFraction = player:isa("Exo") and 0 or health/(maxHealth+maxArmor)
		local armorFraction = armor*kHealthPointsPerArmor/(maxHealth+maxArmor)
		local activeWeapon = player:GetActiveWeapon()
		
		local fraction = 0
		local enoughEnergy = true
		if player:isa("Alien") then
			self.rightBar:SetIsVisible(false)
			fraction = player:GetEnergy() / player:GetMaxEnergy()
			
			if activeWeapon then
				enoughEnergy = player:GetEnergy() > activeWeapon:GetEnergyCost()
			end
			
		else
			if activeWeapon then
				if activeWeapon:isa("ClipWeapon") then
					fraction = activeWeapon:GetClip() / activeWeapon:GetClipSize()
				elseif activeWeapon:isa("ExoWeaponHolder") then
					local leftWeapon = Shared.GetEntity(activeWeapon.leftWeaponId)
					local rightWeapon = Shared.GetEntity(activeWeapon.rightWeaponId)

					if rightWeapon:isa("Railgun") then
						fraction = rightWeapon:GetChargeAmount()
						if leftWeapon:isa("Railgun") then
							fraction = (fraction + leftWeapon:GetChargeAmount()) / 2.0
						end
					elseif rightWeapon:isa("Minigun") then
						fraction = rightWeapon.heatAmount
						if leftWeapon:isa("Minigun") then
							fraction = (fraction + leftWeapon.heatAmount) / 2.0
						end
						fraction = 1 - fraction
					end
				end
			end
		end
		
		local hpTextureCoord = kBarTexCoords[2]-kBarTexCoords[2]*healthFraction
		local apTextureCoord = kBarTexCoords[2]*armorFraction
		self.healthBar:SetIsVisible(healthFraction > 0)
		self.healthBar:SetSize(Vector(kBarSize[hudbars].x, -kBarSize[hudbars].y*healthFraction, 0))
		self.healthBar:SetTexturePixelCoordinates(kBarTexCoords[1], kBarTexCoords[2], kBarTexCoords[3], hpTextureCoord)
		self.healthBar:SetColor(ConditionalValue(healthFraction < 0.3, pulsatingRed, hudbars == 1 and kHealthColors[teamIndex] or kWhite))
		
		if (player:isa("Marine") or player:isa("Exo") or player:isa("Alien")) then
			if self.lastHealth ~= health or self.lastArmor ~= armor then
				-- Don't display the text for the NS1 bars, we will reuse the existing UI elements
				self.healthText:SetIsVisible(hudbars == 1)
				self.healthTextBg:SetIsVisible(hudbars == 1)
				self.healthText:SetColor(Color(1,1,1,1))
				self.healthTextBg:SetColor(Color(0,0,0,1))
				
				self.healthText:FadeOut(3, "HP_FADEOUT")
				self.healthTextBg:FadeOut(3, "HP_FADEOUT")
				
				self.lastHealth = health
				self.lastArmor = armor
			end
			
			if not player:isa("Exo") then
				self.healthText:SetText(string.format("%s / %s", health, armor))
				self.healthTextBg:SetText(string.format("%s / %s", health, armor))
			else
				self.healthText:SetText(string.format("%s", armor))
				self.healthTextBg:SetText(string.format("%s", armor))
			end
			
		else
			self.healthText:SetIsVisible(false)
			self.healthTextBg:SetIsVisible(false)
		end
		
		self.armorBar:SetIsVisible(armorFraction > 0)
		self.armorBar:SetSize(Vector(kBarSize[hudbars].x, -kBarSize[hudbars].y*armorFraction, 0))
		self.armorBar:SetPosition(Vector(leftBarXOffset[hudbars], yOffset[hudbars]-kBarSize[hudbars].y*healthFraction, 0))
		self.armorBar:SetTexturePixelCoordinates(kBarTexCoords[1], hpTextureCoord, kBarTexCoords[3], hpTextureCoord-apTextureCoord)
		self.armorBar:SetColor(ConditionalValue(player:isa("Exo") and armor < 100, pulsatingRed, hudbars == 1 and kArmorColors[teamIndex] or kWhite))

		self.rightBar:SetIsVisible(fraction > 0)
		self.rightBar:SetSize(Vector(-kBarSize[hudbars].x, -kBarSize[hudbars].y*fraction, 0))
		self.rightBar:SetTexturePixelCoordinates(kBarTexCoords[1], kBarTexCoords[2], kBarTexCoords[3], kBarTexCoords[2]-kBarTexCoords[2]*fraction)
		self.rightBar:SetColor(ConditionalValue(enoughEnergy, hudbars == 1 and kAmmoColors[teamIndex] or kWhite, pulsatingRed))
		
		if activeWeapon and activeWeapon:isa("ClipWeapon") and not activeWeapon:isa("ExoWeaponHolder") then
			if self.lastReserveAmmo ~= activeWeapon:GetAmmo() then
				-- Don't display the text for the NS1 bars, we will reuse the existing UI elements
				self.ammoText:SetIsVisible(hudbars == 1)
				self.ammoTextBg:SetIsVisible(hudbars == 1)
				self.ammoText:SetColor(Color(1,1,1,1))
				self.ammoTextBg:SetColor(Color(0,0,0,1))
				
				self.ammoText:FadeOut(3, "AMMO_FADEOUT")
				self.ammoTextBg:FadeOut(3, "AMMO_FADEOUT")
				
				self.lastReserveAmmo = activeWeapon:GetAmmo()
			end
			
			if fraction <= 0.4 or (activeWeapon and activeWeapon:isa("GrenadeLauncher") and fraction <= 0.5) then
				self.rightBar:SetColor(pulsatingRed)
			end
			
			self.ammoText:SetText(string.format("%s / %s", activeWeapon:GetClip(), activeWeapon:GetAmmo()))
			self.ammoTextBg:SetText(string.format("%s / %s", activeWeapon:GetClip(), activeWeapon:GetAmmo()))
			
		else
			self.ammoText:SetIsVisible(false)
			self.ammoTextBg:SetIsVisible(false)
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
	end

end