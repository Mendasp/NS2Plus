Script.Load("lua/Hud/Marine/GUIMarineStatus.lua")

local originalMarineStatusUpdate
originalMarineStatusUpdate = Class_ReplaceMethod( "GUIMarineStatus", "Update",
	function (self, deltaTime, parameters)
		originalMarineStatusUpdate(self, deltaTime, parameters)
		
		if CHUDGetOption("mingui") or not CHUDGetOption("hpbar") then		
			self.healthBorderMask:SetColor(Color(1,1,1,0))
			self.armorBorderMask:SetColor(Color(1,1,1,0))
		end
	end
)