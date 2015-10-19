local originalJetpackFuelInit
originalJetpackFuelInit = Class_ReplaceMethod( "GUIJetpackFuel", "Initialize",
function(self)
	originalJetpackFuelInit(self)
	
	if CHUDGetOption("hudbars_m") == 2 then
		self.background:SetPosition(Vector(GUIJetpackFuel.kBackgroundWidth / 2 + GUIJetpackFuel.kBackgroundOffsetX * 2.5, -GUIJetpackFuel.kBackgroundHeight / 2 + GUIJetpackFuel.kBackgroundOffsetY, 0))
	end
end)