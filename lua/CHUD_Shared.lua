Script.Load("lua/CHUD_Utility.lua")

local kCHUDStatsMessage =
{
    isPlayer = "boolean",
    weapon = "enum kTechId",
    targetId = "entityid",
    damage = "float",
}

Shared.RegisterNetworkMessage( "CHUDStats", kCHUDStatsMessage )