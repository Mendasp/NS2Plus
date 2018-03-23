class 'CHUDGUI_HiddenViewmodel' (GUIScript)

local fireTexture = PrecacheAsset("ui/chud_fireindicator.dds")
local obsIndicatorTexture = PrecacheAsset("ui/chud_scanindicator.dds")
local obsTextureCoords = {0, 0, 64, 64}
local buildTexture = PrecacheAsset("ui/buildmenu.dds")
local iconSize, exoHUDSize

function CHUDGUI_HiddenViewmodel:Initialize()

	iconSize = GUIScale(Vector(64, 64, 0))
	exoHUDSize = GUIScale(Vector(160, 160, 0))
	
	local player = Client.GetLocalPlayer()
	
	self.fireIndicator = GUIManager:CreateGraphicItem()
	self.fireIndicator:SetAnchor(GUIItem.Left, GUIItem.Bottom)
	self.fireIndicator:SetLayer(kGUILayerPlayerHUD)
	self.fireIndicator:SetIsVisible(false)
	self.fireIndicator:SetTexture(fireTexture)
	self.fireIndicator:SetSize(iconSize)
	self.fireIndicator:SetColor(kAlienFontColor)

	self.leftIndicator = GUIManager:CreateGraphicItem()
	self.leftIndicator:SetAnchor(GUIItem.Left, GUIItem.Bottom)
	self.leftIndicator:SetLayer(kGUILayerPlayerHUD)
	self.leftIndicator:SetIsVisible(false)
	self.leftIndicator:SetColor(kAlienFontColor)
	self.leftIndicator:SetSize(iconSize)

	self.umbraIndicator = GUIManager:CreateGraphicItem()
	self.umbraIndicator:SetAnchor(GUIItem.Right, GUIItem.Bottom)
	self.umbraIndicator:SetLayer(kGUILayerPlayerHUD)
	self.umbraIndicator:SetIsVisible(false)
	self.umbraIndicator:SetTexture(buildTexture)
	self.umbraIndicator:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.Umbra)))
	self.umbraIndicator:SetSize(iconSize)
	self.umbraIndicator:SetColor(kAlienFontColor)
	
	self.enzymeIndicator = GUIManager:CreateGraphicItem()
	self.enzymeIndicator:SetAnchor(GUIItem.Right, GUIItem.Bottom)
	self.enzymeIndicator:SetLayer(kGUILayerPlayerHUD)
	self.enzymeIndicator:SetIsVisible(false)
	self.enzymeIndicator:SetTexture(buildTexture)
	self.enzymeIndicator:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.EnzymeCloud)))
	self.enzymeIndicator:SetSize(iconSize)
	self.enzymeIndicator:SetColor(kAlienFontColor)

	-- Set the texture to a temp one, avoids crash
	self.leftExo = GUIManager:CreateGraphicItem()
	self.leftExo:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
	self.leftExo:SetBlendTechnique(GUIItem.Add)
	self.leftExo:SetPosition(Vector(-exoHUDSize.x, -exoHUDSize.y, 0))
	self.leftExo:SetLayer(kGUILayerPlayerHUD)
	self.leftExo:SetIsVisible(false)
	
	-- Set the texture to a temp one, avoids crash
	self.rightExo = GUIManager:CreateGraphicItem()
	self.rightExo:SetAnchor(GUIItem.Middle, GUIItem.Bottom)
	self.rightExo:SetBlendTechnique(GUIItem.Add)
	self.rightExo:SetPosition(Vector(exoHUDSize.x, -exoHUDSize.y, 0))
	self.rightExo:SetLayer(kGUILayerPlayerHUD)
	self.rightExo:SetIsVisible(false)
end

local lastLeft, lastRight, lastChange
function CHUDGUI_HiddenViewmodel:Update(deltaTime)
	local alienHUDScript = ClientUI.GetScript("GUIAlienHUD")
	local exoHUDScript = ClientUI.GetScript("Hud/Marine/GUIExoHUD")
	local player = Client.GetLocalPlayer()
	if alienHUDScript then
		local healthBall = alienHUDScript.healthBall:GetBackground()
		local energyBall = alienHUDScript.energyBall:GetBackground()
		local size = healthBall:GetSize()
		local leftPos = healthBall:GetPosition() + Vector(size.x-GUIScale(16), 0, 0)
		local rightPos = energyBall:GetPosition() - Vector(size.x-GUIScale(48), 0, 0)
		
		local fire = player:GetIsOnFire()
		local obs = player:GetIsDetected()
		local cloak = player:GetCloakFraction() > 0.2
		local umbra = player.umbraIntensity > 0
		local enzyme = player:GetIsEnzymed()
		
		self.fireIndicator:SetIsVisible(player:GetIsAlive() and fire)
		-- When under obs/scan, it removes cloaking, so only one of them happen at a time
		self.leftIndicator:SetIsVisible(player:GetIsAlive() and (obs or cloak))
		self.umbraIndicator:SetIsVisible(player:GetIsAlive() and umbra)
		self.enzymeIndicator:SetIsVisible(player:GetIsAlive() and enzyme)
		
		if fire then
			self.fireIndicator:SetPosition(leftPos)
			leftPos = leftPos + Vector(iconSize.x, 0, 0)
		end

		self.leftIndicator:SetPosition(leftPos)

		if obs then
			self.leftIndicator:SetTexture(obsIndicatorTexture)
			self.leftIndicator:SetTexturePixelCoordinates(GUIUnpackCoords(obsTextureCoords))
			self.leftIndicator:SetColor(Color(1,1,1,1))
		elseif cloak then
			self.leftIndicator:SetTexture(buildTexture)
			self.leftIndicator:SetTexturePixelCoordinates(GUIUnpackCoords(GetTextureCoordinatesForIcon(kTechId.Vampirism)))
			self.leftIndicator:SetColor(kAlienFontColor)
			
			-- Do this to not override the original kAlienFontColor
			local color = self.leftIndicator:GetColor()
			color.a = player:GetCloakFraction()
			self.leftIndicator:SetColor(color)
		end
		
		if umbra then
			self.umbraIndicator:SetPosition(rightPos)
			rightPos = rightPos - Vector(iconSize.x, 0, 0)
		end
		
		if enzyme then
			self.enzymeIndicator:SetPosition(rightPos)
		end
	elseif exoHUDScript then
		local weapon = player:GetActiveWeapon()
		if weapon and weapon:isa("ExoWeaponHolder") then
			local leftWeapon = Shared.GetEntity(weapon.leftWeaponId)
			local rightWeapon = Shared.GetEntity(weapon.rightWeaponId)
			if lastLeft ~= leftWeapon or lastRight ~= rightWeapon then
				lastLeft = leftWeapon
				lastRight = rightWeapon
				lastChange = Shared.GetTime()
				self.leftExo:SetTexture("ui/transparent.dds")
				self.rightExo:SetTexture("ui/transparent.dds")
			end
			-- Delay creation to allow the HUD to be created (avoids crashes)
			if lastChange < Shared.GetTime() - 2.5 then
				lastChange = 0
				local leftVisible = leftWeapon:isa("Minigun") or leftWeapon:isa("Railgun")
				local rightVisible = rightWeapon:isa("Minigun") or rightWeapon:isa("Railgun")
				self.leftExo:SetIsVisible(leftVisible)
				self.rightExo:SetIsVisible(rightVisible)
				if leftVisible then
					self.leftExo:SetTexture(leftWeapon:isa("Minigun") and "*exo_minigun_left" or leftWeapon:isa("Railgun") and "*exo_railgun_left")
					self.leftExo:SetSize(Vector(-(leftWeapon:isa("Minigun") and exoHUDSize.x/2 or exoHUDSize.x),exoHUDSize.y,0))
				end
				if rightVisible then
					self.rightExo:SetTexture(rightWeapon:isa("Minigun") and "*exo_minigun_right" or rightWeapon:isa("Railgun") and "*exo_railgun_right")
					self.rightExo:SetSize(Vector(rightWeapon:isa("Minigun") and exoHUDSize.x/2 or exoHUDSize.x,exoHUDSize.y,0))
				end
			end
		end
	end
end

function CHUDGUI_HiddenViewmodel:OnResolutionChanged(oldX, oldY, newX, newY)
	self:Uninitialize()
	self:Initialize()
end

function CHUDGUI_HiddenViewmodel:Uninitialize()
	if self.fireIndicator then
		GUI.DestroyItem(self.fireIndicator)
		self.fireIndicator = nil
	end

	if self.leftIndicator then
		GUI.DestroyItem(self.leftIndicator)
		self.leftIndicator = nil
	end
	
	if self.umbraIndicator then
		GUI.DestroyItem(self.umbraIndicator)
		self.umbraIndicator = nil
	end
	
	if self.enzymeIndicator then
		GUI.DestroyItem(self.enzymeIndicator)
		self.enzymeIndicator = nil
	end
	
	if self.leftExo then
		GUI.DestroyItem(self.leftExo)
		self.leftExo = nil
	end
	
	if self.rightExo then
		GUI.DestroyItem(self.rightExo)
		self.rightExo = nil
	end
end

