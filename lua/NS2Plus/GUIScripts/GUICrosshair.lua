local originalCrossInit
originalCrossInit = Class_ReplaceMethod("GUICrosshair", "Initialize",
	function(self)
		originalCrossInit(self)
		
		if CHUDGetOption("crosshairscaling") then
			self.crosshairs:SetSize(Vector(GUIScale(GUICrosshair.kCrosshairSize), GUIScale(GUICrosshair.kCrosshairSize), 0))
			self.damageIndicator:SetSize(Vector(GUIScale(GUICrosshair.kCrosshairSize), GUIScale(GUICrosshair.kCrosshairSize), 0))
		end
	end)
	
// For reasons unknown to science the crosshair sets its position again every single frame
local originalCrossUpdate
originalCrossUpdate = Class_ReplaceMethod("GUICrosshair", "Update",
	function(self, deltaTime)
		originalCrossUpdate(self)
		
		if CHUDGetOption("crosshairscaling") then
			local scaledSize = GUIScale(GUICrosshair.kCrosshairSize)
			self.crosshairs:SetPosition(Vector(-scaledSize / 2, -scaledSize / 2, 0))
		end
	end)