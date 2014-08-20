local originalWeaponOnUpdateRender
originalWeaponOnUpdateRender = Class_ReplaceMethod( "Weapon", "OnUpdateRender",
	function(self)
		originalWeaponOnUpdateRender(self)
		if self.ammoDisplayUI then
			self.ammoDisplayUI:SetGlobal("lowAmmoWarning", tostring(CHUDGetOption("lowammowarning")))
		end
	end)