local kCHUDStatsMessage =
{
    isPlayer = "boolean",
    weapon = "enum kTechId",
    targetId = "entityid",
    damage = "float",
}

local kCHUDOptionMessage =
{
	disabledOption = "string (32)"
}

local kCHUDAutopickupMessage =
{
	autoPickup = "boolean",
}

Shared.RegisterNetworkMessage( "CHUDStats", kCHUDStatsMessage )
Shared.RegisterNetworkMessage( "CHUDOption", kCHUDOptionMessage )
Shared.RegisterNetworkMessage( "SetCHUDAutopickup", kCHUDAutopickupMessage)

Script.Load("lua/Shared/CHUD_Utility.lua")
Script.Load("lua/Shared/CHUD_Autopickup.lua")

CHUDTagBitmask = {
	mcr = 0x1,
	ambient = 0x2,
	mapparticles = 0x4,
	nsllights = 0x8,
	deathstats = 0x0,
}

local playerInfoNetworkVars =
{
	extraTech = "string (128)",
	isParasited = "boolean",
}

local embryoNetworkVars =
{
    evolvePercentage = "float",
}

Class_Reload("PlayerInfoEntity", playerInfoNetworkVars)
Class_Reload("Embryo", embryoNetworkVars)

