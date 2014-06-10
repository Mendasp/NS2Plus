Script.Load("lua/Hud/GUIEvent.lua")

local originalEventUpdate
originalEventUpdate = Class_ReplaceMethod( "GUIEvent", "Update",
	function (self, deltaTime, parameters)
		originalEventUpdate(self, deltaTime, parameters)
		
		if CHUDGetOption("mingui") then
			self.borderTop:SetIsVisible(false)
			self.unlockBackground:SetColor(Color(1,1,1,0))
			self.unlockFlash:SetIsVisible(false)
			self.unlockFlashStencil:SetIsVisible(false)
		end
		
		self.unlockFrame:SetIsVisible(CHUDGetOption("unlocks"))
	end
)