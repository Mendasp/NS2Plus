Script.Load("lua/CHUD/Elixer_Utility.lua")
Elixer.UseVersion( 1.3 ) 

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
	autoPickupBetter = "boolean",
}

Shared.RegisterNetworkMessage( "CHUDStats", kCHUDStatsMessage )
Shared.RegisterNetworkMessage( "CHUDOption", kCHUDOptionMessage )
Shared.RegisterNetworkMessage( "SetCHUDAutopickup", kCHUDAutopickupMessage)

Script.Load("lua/Shared/CHUD_Utility.lua")
Script.Load("lua/Shared/CHUD_Autopickup.lua")
Script.Load("lua/Shared/CHUD_CommanderSelection.lua")
Script.Load("lua/Shared/CHUD_LayMines.lua")
Script.Load("lua/Shared/CHUD_AmmoPack.lua")
Script.Load("lua/Shared/CHUD_Grenade.lua")
Script.Load("lua/Shared/CHUD_BoneWall.lua")

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

local pickupableNetworkVars =
{
	expireTime = "time (by 0.1)",
}

Class_Reload("PlayerInfoEntity", playerInfoNetworkVars)
Class_Reload("Embryo", embryoNetworkVars)
Class_Reload("Weapon", pickupableNetworkVars)
Class_Reload("DropPack", pickupableNetworkVars)
