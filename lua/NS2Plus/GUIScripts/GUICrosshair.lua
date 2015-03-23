local originalCrossInit
originalCrossInit = Class_ReplaceMethod("GUICrosshair", "Initialize",
	function(self)
		originalCrossInit(self)
		
		self.crosshairs:SetSize(Vector(1, 1, 0)*GUICrosshair.kCrosshairSize*CHUDGetOption("crosshairscale"))
		self.damageIndicator:SetSize(Vector(1, 1, 0)*GUICrosshair.kCrosshairSize*CHUDGetOption("crosshairscale"))
	end)
	
// For reasons unknown to science the crosshair sets its position again every single frame
local originalCrossUpdate
originalCrossUpdate = Class_ReplaceMethod("GUICrosshair", "Update",
	function(self, deltaTime)
		originalCrossUpdate(self)
		
		self.crosshairs:SetPosition(-Vector(0.5, 0.5, 0)*GUICrosshair.kCrosshairSize*CHUDGetOption("crosshairscale"))
	end)