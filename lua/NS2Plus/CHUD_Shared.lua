kCHUDElixerVersion = 1.72
// Version number is the amount of revisions in the Workshop
// Try to update but only important when changing defaults
kCHUDVersion = 202

Script.Load("lua/NS2Plus/Shared/CHUD_Utility.lua")
Script.Load("lua/NS2Plus/Elixer_Utility.lua")
Elixer.UseVersion( kCHUDElixerVersion ) 

if not CHUDMainMenu then
	local kCHUDDeathStatsMessage =
	{
		lastAcc = "float (0 to 100 by 0.01)",
		currentAcc = "float (0 to 100 by 0.01)",
		pdmg = "float (0 to 524287 by 0.01)",
		sdmg = "float (0 to 524287 by 0.01)",
	}

	local kCHUDEndStatsWeaponMessage =
	{
		wTechId = "enum kTechId",
		accuracy = "float (0 to 100 by 0.01)",
		accuracyOnos = "float (-1 to 100 by 0.01)",
		kills = "integer (0 to 1023)",
	}

	local kCHUDEndStatsOverallMessage =
	{
		accuracy = "float (0 to 100 by 0.01)",
		accuracyOnos = "float (-1 to 100 by 0.01)",
		pdmg = "float (0 to 524287 by 0.01)",
		sdmg = "float (0 to 524287 by 0.01)",
		killstreak = "integer (0 to 1023)",
	}

	local kCHUDMarineCommStatsMessage =
	{
		medpackAccuracy = "float (0 to 100 by 0.01)",
		medpackResUsed = "integer (0 to 65535)",
		medpackResExpired = "integer (0 to 65535)",
		medpackEfficiency = "float (0 to 100 by 0.01)",
		medpackRefill = "integer (0 to 262143)",
		ammopackResUsed = "integer (0 to 65535)",
		ammopackResExpired = "integer (0 to 65535)",
		ammopackEfficiency = "float (0 to 100 by 0.01)",
		ammopackRefill = "integer (0 to 262143)",
		catpackResUsed = "integer (0 to 65535)",
		catpackResExpired = "integer (0 to 65535)",
		catpackEfficiency = "float (0 to 100 by 0.01)",
	}

	local kCHUDOptionMessage =
	{
		disabledOption = "string (32)"
	}

	local kCHUDAutopickupMessage =
	{
		autoPickup = "boolean",
		autoPickupBetter = "boolean",
	}

	local kCHUDOverkillMessage =
	{
		overkill = "boolean",
	}

	Shared.RegisterNetworkMessage( "CHUDOption", kCHUDOptionMessage )
	Shared.RegisterNetworkMessage( "SetCHUDAutopickup", kCHUDAutopickupMessage)
	Shared.RegisterNetworkMessage( "SetCHUDOverkill", kCHUDOverkillMessage)
	Shared.RegisterNetworkMessage( "CHUDDeathStats", kCHUDDeathStatsMessage)
	Shared.RegisterNetworkMessage( "CHUDEndStatsWeapon", kCHUDEndStatsWeaponMessage)
	Shared.RegisterNetworkMessage( "CHUDEndStatsOverall", kCHUDEndStatsOverallMessage)
	Shared.RegisterNetworkMessage( "CHUDMarineCommStats", kCHUDMarineCommStatsMessage)

	Script.Load("lua/NS2Plus/Shared/CHUD_Autopickup.lua")
	Script.Load("lua/NS2Plus/Shared/CHUD_CommanderSelection.lua")
	Script.Load("lua/NS2Plus/Shared/CHUD_LayMines.lua")
end

CHUDTagBitmask = {
	mcr = 0x1,
	ambient = 0x2,
	mapparticles = 0x4,
	nsllights = 0x8,
	deathstats = 0x0,
}