Script.Load("lua/NS2Plus/CHUD_Shared.lua")

// Clear tags on map restart
SetCHUDTagBitmask(0)

Script.Load("lua/NS2Plus/Server/CHUD_ServerSettings.lua")
Script.Load("lua/NS2Plus/Server/CHUD_ModUpdater.lua")
Script.Load("lua/NS2Plus/Server/CHUD_ServerStats.lua")
Script.Load("lua/NS2Plus/Server/CHUD_ClientOptions.lua")
Script.Load("lua/NS2Plus/Server/CHUD_PickupExpire.lua")
Script.Load("lua/NS2Plus/Server/CHUD_DropPack.lua")
Script.Load("lua/NS2Plus/Server/CHUD_Shift.lua")
Script.Load("lua/NS2Plus/Server/CHUD_Drifter.lua")

if rawget( kTechId, "HeavyMachineGun" ) then
	
	local oldHitSoundIsEnabledForWeapon = HitSound_IsEnabledForWeapon
	function HitSound_IsEnabledForWeapon( techId )
		if techId == kTechId.HeavyMachineGun then
			return true
		end
		
		return oldHitSoundIsEnabledForWeapon( techId )
	end

end