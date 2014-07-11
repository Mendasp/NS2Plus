local originalClipWeaponOnTag
originalClipWeaponOnTag = Class_ReplaceMethod( "ClipWeapon", "OnTag",
	function(self, tagName)
		originalClipWeaponOnTag(self, tagName)
		
		if tagName == "shoot" and self.clip == 0 and self.ammo > 0 then
			self:GetParent():Reload()
		end
	end)