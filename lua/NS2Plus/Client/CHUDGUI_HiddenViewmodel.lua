Script.Load("lua/GUIAnimatedScript.lua")

class 'CHUDGUI_HiddenViewmodel' (GUIAnimatedScript)

local obsIndicatorTexture = PrecacheAsset("ui/chud_scanindicator.dds")
local obsTextureCoords = {0, 0, 64, 64}
local buildTexture = PrecacheAsset("ui/buildmenu.dds")
local iconSize = GUIScale(Vector(64, 64, 0))

function CHUDGUI_HiddenViewmodel:Initialize()

	GUIAnimatedScript.Initialize(self)
	
	self.leftIndicator = self:CreateAnimatedGraphicItem()
	self.leftIndicator:SetAnchor(GUIItem.Left, GUIItem.Bottom)
	self.leftIndicator:SetLayer(kGUILayerPlayerHUD)
	self.leftIndicator:SetIsVisible(true)
	self.leftIndicator:SetIsScaling(false)
	self.leftIndicator:SetSize(iconSize)

	self.umbraIndicator = self:CreateAnimatedGraphicItem()
	self.umbraIndicator:SetAnchor(GUIItem.Right, GUIItem.Bottom)
	self.umbraIndicator:SetLayer(kGUILayerPlayerHUD)
	self.umbraIndicator:SetIsVisible(true)
	self.umbraIndicator:SetIsScaling(false)
	self.umbraIndicator:SetTexture(buildTexture)
	self.umbraIndicator:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.Umbra)))
	self.umbraIndicator:SetSize(iconSize)
	self.umbraIndicator:SetColor(kAlienFontColor)
	
	self.enzymeIndicator = self:CreateAnimatedGraphicItem()
	self.enzymeIndicator:SetAnchor(GUIItem.Right, GUIItem.Bottom)
	self.enzymeIndicator:SetLayer(kGUILayerPlayerHUD)
	self.enzymeIndicator:SetIsVisible(true)
	self.enzymeIndicator:SetIsScaling(false)
	self.enzymeIndicator:SetTexture(buildTexture)
	self.enzymeIndicator:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.EnzymeCloud)))
	self.enzymeIndicator:SetSize(iconSize)
	self.enzymeIndicator:SetColor(kAlienFontColor)
	
end


function CHUDGUI_HiddenViewmodel:Update(deltaTime)
	local alienHUDScript = ClientUI.GetScript("GUIAlienHUD")
	if alienHUDScript then
		local healthBall = alienHUDScript.healthBall:GetBackground()
		local energyBall = alienHUDScript.energyBall:GetBackground()
		local size = healthBall:GetSize()
		local leftPos = healthBall:GetPosition() + Vector(size.x-16, 0, 0)
		local rightPos = energyBall:GetPosition() - Vector(size.x-48, 0, 0)
		
		local player = Client.GetLocalPlayer()
		
		local obs = player:GetIsDetected()
		local cloak = player:GetCloakFraction() > 0.2
		local umbra = player.umbraIntensity > 0
		local enzyme = player:GetIsEnzymed()
		
		-- When under obs/scan, it removes cloaking, so only one of them happen at a time
		self.leftIndicator:SetIsVisible(obs or cloak)
		self.leftIndicator:SetPosition(leftPos)
		
		self.umbraIndicator:SetIsVisible(umbra)
		self.enzymeIndicator:SetIsVisible(enzyme)
		
		if obs then
			self.leftIndicator:SetTexture(obsIndicatorTexture)
			self.leftIndicator:SetTexturePixelCoordinates(unpack(obsTextureCoords))
			self.leftIndicator:SetColor(Color(1,1,1,1))
		elseif cloak then
			self.leftIndicator:SetTexture(buildTexture)
			self.leftIndicator:SetTexturePixelCoordinates(unpack(GetTextureCoordinatesForIcon(kTechId.Phantom)))
			
			local color = kAlienFontColor
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
	end
end

function CHUDGUI_HiddenViewmodel:Uninitialize()
	
	GUIAnimatedScript.Uninitialize(self)
	
	self.leftIndicator:Destroy()
	self.leftIndicator = nil
	
	self.umbraIndicator:Destroy()
	self.umbraIndicator = nil
	
	self.enzymeIndicator:Destroy()
	self.enzymeIndicator = nil
	
end

