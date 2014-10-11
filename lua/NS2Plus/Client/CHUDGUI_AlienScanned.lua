Script.Load("lua/GUIAnimatedScript.lua")

class 'CHUDGUI_AlienScanned' (GUIAnimatedScript)

local indicatorTex = PrecacheAsset("ui/bi0_scanindicator.dds")

function CHUDGUI_AlienScanned:Initialize()
	GUIAnimatedScript.Initialize(self)
	self.indicator = self:CreateAnimatedGraphicItem()
	self.indicator:SetAnchor(GUIItem.Left, GUIItem.Bottom)
	//self.indicator:SetAnchor(GUIItem.Middle, GUIItem.Center)
	self.indicator:SetLayer(kGUILayerPlayerHUD)
	self.indicator:SetIsVisible(true)
	self.indicator:SetIsScaling(false)
	self.indicator:SetTexture(indicatorTex)
	self.indicator:SetTexturePixelCoordinates(unpack({0, 0, 64, 64}))
	self.indicator:SetSize(Vector(64, 64, 0))
	self.indicator:SetPosition(Vector(175, -64 -((160 - 64) / 2) - 64, 0))
	//self.indicator:SetPosition(Vector(0, 0, 0))
	self.indicator:SetColor(Color(1, 1, 1, 1))
end


function CHUDGUI_AlienScanned:Update(deltaTime)
	local player = Client.GetLocalPlayer()
	if player:isa("Alien") then
		if player.GetIsDetected then
			self.indicator:SetIsVisible(player:GetIsDetected())
		end
		if player.GetHasUmbra then
			if player:GetHasUmbra() then
				Print "Umbra"
			end
		end
		if player.GetIsEnzymed then
			if player:GetIsEnzymed() then
				Print "Enzymed"
			end
		end
		if player.GetCloakFraction then
			local cloakfraction = player:GetCloakFraction()
			local string = string.format("%f", cloakfraction)
			//Print(string)
		end
	end
end

function CHUDGUI_AlienScanned:Uninitialize()
	GUIAnimatedScript.Uninitialize(self)
	self.indicator:Destroy()
	self.indicator = nil
end

