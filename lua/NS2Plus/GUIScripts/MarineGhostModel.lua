Script.Load("lua/Hud/Commander/GhostModel.lua")

local kTextName = Fonts.kAgencyFB_Small

local oldMarineGhostModelInit
oldMarineGhostModelInit = Class_ReplaceMethod("MarineGhostModel", "Initialize",
	function(self)
		oldMarineGhostModelInit(self)
		
		if not self.powerLocationText then    
			self.powerLocationText = GetGUIManager():CreateTextItem()
			self.powerLocationText:SetTextAlignmentY(GUIItem.Align_Center)
			self.powerLocationText:SetFontName(kTextName)
			self.powerLocationText:SetScale(GetScaledVector())
			
			self.powerIcon:AddChild(self.powerLocationText)
		end
	end)
	
local oldMarineGhostModelUpdate
oldMarineGhostModelUpdate = Class_ReplaceMethod("MarineGhostModel", "Update",
	function(self)
		oldMarineGhostModelUpdate(self)
		
		local modelCoords = GhostModelUI_GetGhostModelCoords()
		local location = modelCoords and GetLocationForPoint(modelCoords.origin)
		
		if location and self.powerIcon and self.powerIcon:GetIsVisible() then
			local screenPos = Client.WorldToScreen(modelCoords.origin)
			local textPos = self.powerIcon:GetPosition()
			local powerPoint = GetPowerPointForLocation(location:GetName())
			local text = string.format("%s", location:GetName())
			local builtFraction = powerPoint:GetBuiltFraction()
			local healthFraction = powerPoint:GetHealthScalar()
			if builtFraction < 1 then
				text = text .. string.format(" (%d%% Built)", builtFraction*100)
			elseif builtFraction > 0 and healthFraction < 1 then
				text = text .. string.format(" (%d%% Health)", healthFraction*100)
			end
			self.powerLocationText:SetText(text)
			self.powerLocationText:SetColor(self.powerIcon:GetColor())
			
			if screenPos.x > textPos.x then
				self.powerLocationText:SetAnchor(GUIItem.Left, GUIItem.Middle)
				self.powerLocationText:SetTextAlignmentX(GUIItem.Align_Max)
				self.powerLocationText:SetPosition(GUIScale(Vector(-10, 0, 0)))
			else
				self.powerLocationText:SetAnchor(GUIItem.Right, GUIItem.Middle)
				self.powerLocationText:SetTextAlignmentX(GUIItem.Align_Min)
				self.powerLocationText:SetPosition(GUIScale(Vector(10, 0, 0)))
			end
		else
			self.powerLocationText:SetText("")
		end
	end)