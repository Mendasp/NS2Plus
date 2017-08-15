local originalJetpackFuelInit = GUIJetpackFuel.Initialize
function GUIJetpackFuel:Initialize()
	GUIJetpackFuel.kBackgroundOffsetX = ConditionalValue(CHUDGetOption("hudbars_m") == 2, GUIScale(128), 6)

	originalJetpackFuelInit(self)

	if CHUDGetOption("hudbars_m") == 2 then
		self.background:SetPosition(Vector(GUIJetpackFuel.kBackgroundWidth / 2 + GUIJetpackFuel.kBackgroundOffsetX * 2.5, -GUIJetpackFuel.kBackgroundHeight / 2 + GUIJetpackFuel.kBackgroundOffsetY, 0))
	end
end