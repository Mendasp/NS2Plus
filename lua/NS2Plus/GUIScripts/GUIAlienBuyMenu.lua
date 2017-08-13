local originalAlienBuyMenuInit = GUIAlienBuyMenu.Initialize
function GUIAlienBuyMenu:Initialize()
	originalAlienBuyMenuInit(self)

	if CHUDGetOption("mingui") then
		self.backgroundCircle:SetIsVisible(false)
		self.glowieParticles:Uninitialize()
		self.smokeParticles:Uninitialize()
		for cornerName, cornerItem in pairs(self.corners) do
			GUI.DestroyItem(cornerItem)
		end
		self.corners = { }

		self.cornerTweeners = { }
	end
end