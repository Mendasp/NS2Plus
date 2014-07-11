local originalWeaponOnUpdateRender
originalWeaponOnUpdateRender = Class_ReplaceMethod( "Weapon", "OnUpdateRender",
	function(self)
		originalWeaponOnUpdateRender(self)
		if self.ammoDisplayUI then
			self.ammoDisplayUI:SetGlobal("globalTime", Shared.GetTime())
		end
	end)