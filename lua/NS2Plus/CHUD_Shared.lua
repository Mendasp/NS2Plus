kCHUDElixerVersion = 1.8
kCHUDVersion = 370

Script.Load("lua/NS2Plus/Shared/CHUD_Utility.lua")
Script.Load("lua/NS2Plus/Elixer_Utility.lua")
Elixer.UseVersion( kCHUDElixerVersion ) 

if not CHUDMainMenu then
	local kCHUDDeathStatsMessage =
	{
		lastAcc = "float (0 to 100 by 0.01)",
		lastAccOnos = "float (-1 to 100 by 0.01)",
		currentAcc = "float (0 to 100 by 0.01)",
		currentAccOnos = "float (-1 to 100 by 0.01)",
		pdmg = "float (0 to 524287 by 0.01)",
		sdmg = "float (0 to 524287 by 0.01)",
		kills = string.format("integer (0 to %d)", kMaxKills),
	}

	local kCHUDEndStatsWeaponMessage =
	{
		wTechId = "enum kTechId",
		accuracy = "float (0 to 100 by 0.01)",
		accuracyOnos = "float (-1 to 100 by 0.01)",
		kills = string.format("integer (0 to %d)", kMaxKills),
		teamNumber = "integer (1 to 2)",
		pdmg = "float (0 to 524287 by 0.01)",
		sdmg = "float (0 to 524287 by 0.01)",
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
	
	local kCHUDGameDataMessage =
	{
		marineAcc = "float (0 to 100 by 0.01)",
		marineOnosAcc = "float (-1 to 100 by 0.01)",
		marineRTsBuilt = "integer (0 to 255)",
		marineRTsLost = "integer (0 to 255)",
		alienAcc = "float (0 to 100 by 0.01)",
		alienRTsBuilt = "integer (0 to 255)",
		alienRTsLost = "integer (0 to 255)",
		gameLengthMinutes = "float (0 to 1023 by 0.01)",
	}
	
	local kCHUDRTGraphMessage =
	{
		teamNumber = "integer (1 to 2)",
		destroyed = "boolean",
		gameMinute = "float (0 to 1023 by 0.01)",
	}
	
	local kCHUDKillGraphMessage =
	{
		killerTeamNumber = "integer (1 to 2)",
		gameMinute = "float (0 to 1023 by 0.01)",
	}
	
	local kCHUDTechLogMessage =
	{
		teamNumber = "integer (1 to 2)",
		techId = "enum kTechId",
		finishedMinute = "float (0 to 1023 by 0.01)",
		activeRTs = "integer (0 to 23)",
		teamRes = "float (0 to " .. kMaxTeamResources .." by 0.01)",
		destroyed = "boolean",
		built = "boolean",
		recycled = "boolean",
	}
	
	local kCHUDBuildingSummaryMessage =
	{
		teamNumber = "integer (1 to 2)",
		techId = "enum kTechId",
		built = "integer (0 to 255)",
		lost = "integer (0 to 255)",
	}
	
	local kCHUDPlayerStatsMessage =
	{
		isMarine = "boolean",
		playerName = string.format("string (%d)", kMaxNameLength * 4 ),
		kills = string.format("integer (0 to %d)", kMaxKills),
		assists = string.format("integer (0 to %d)", kMaxKills),
		deaths = string.format("integer (0 to %d)", kMaxDeaths),
		score = string.format("integer (0 to %d)", kMaxScore),
		accuracy = "float (0 to 100 by 0.01)",
		accuracyOnos = "float (-1 to 100 by 0.01)",
		pdmg = "float (0 to 524287 by 0.01)",
		sdmg = "float (0 to 524287 by 0.01)",
		minutesBuilding = "float (0 to 1023 by 0.01)",
		minutesPlaying = "float (0 to 1023 by 0.01)",
		minutesComm = "float (0 to 1023 by 0.01)",
		killstreak = "integer (0 to 254)",
		steamId = "integer",
		hiveSkill = "integer",
		isRookie = "boolean",
	}

	local kCHUDEndStatsStatusMessage =
	{
		statusId = "enum kPlayerStatus",
		timeMinutes = "float (0 to 1023 by 0.01)",
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
	
	local kCHUDServerBloodMessage =
	{
		serverblood = "boolean",
	}

	Shared.RegisterNetworkMessage( "CHUDOption", kCHUDOptionMessage )
	Shared.RegisterNetworkMessage( "SetCHUDAutopickup", kCHUDAutopickupMessage)
	Shared.RegisterNetworkMessage( "SetCHUDOverkill", kCHUDOverkillMessage)
	Shared.RegisterNetworkMessage( "SetCHUDServerBlood", kCHUDServerBloodMessage)
	Shared.RegisterNetworkMessage( "CHUDDeathStats", kCHUDDeathStatsMessage)
	Shared.RegisterNetworkMessage( "CHUDEndStatsWeapon", kCHUDEndStatsWeaponMessage)
	Shared.RegisterNetworkMessage( "CHUDMarineCommStats", kCHUDMarineCommStatsMessage)
	Shared.RegisterNetworkMessage( "CHUDGlobalCommStats", kCHUDMarineCommStatsMessage)
	Shared.RegisterNetworkMessage( "CHUDPlayerStats", kCHUDPlayerStatsMessage)
	Shared.RegisterNetworkMessage( "CHUDGameData", kCHUDGameDataMessage)
	Shared.RegisterNetworkMessage( "CHUDRTGraph", kCHUDRTGraphMessage)
	Shared.RegisterNetworkMessage( "CHUDKillGraph", kCHUDKillGraphMessage)
	Shared.RegisterNetworkMessage( "CHUDTechLog", kCHUDTechLogMessage)
	Shared.RegisterNetworkMessage( "CHUDBuildingSummary", kCHUDBuildingSummaryMessage)
	Shared.RegisterNetworkMessage( "CHUDEndStatsStatus", kCHUDEndStatsStatusMessage)

	Script.Load("lua/NS2Plus/Shared/CHUD_Autopickup.lua")
	Script.Load("lua/NS2Plus/Shared/CHUD_CommanderSelection.lua")
	Script.Load("lua/NS2Plus/Shared/CHUD_PredictedBlood.lua")
	Script.Load("lua/NS2Plus/Shared/CHUD_Badges.lua")
	
	local gameInfoNetworkVars =
	{
		showAvgSkill = "boolean",
		showPlayerSkill = "boolean",
		showEndStatsAuto = "boolean",
		showEndStatsTeamBreakdown = "boolean",
	}

	Class_Reload("GameInfo", gameInfoNetworkVars)
end

CHUDTagBitmask = {
	deathstats = bit.lshift(1, 0),
	mcr = bit.lshift(1, 1),
	ambient = bit.lshift(1, 2),
	mapparticles = bit.lshift(1, 3),
	nsllights = bit.lshift(1, 4),
	drawviewmodel = bit.lshift(1, 5),
	nslserver = bit.lshift(1, 6),
}
