Script.Load("lua/UnitStatusMixin.lua")

local originalWeaponOnCreate
originalWeaponOnCreate = Class_ReplaceMethod( "Weapon", "OnCreate",
	function(self)
		originalWeaponOnCreate(self)
		InitMixin(self, UnitStatusMixin)
	end)