Script.Load("lua/CHUD_Utility.lua")

local kCHUDStatsMessage =
{
    isPlayer = "boolean",
    weapon = "enum kTechId",
    targetId = "entityid",
    damage = "float",
}

Shared.RegisterNetworkMessage( "CHUDStats", kCHUDStatsMessage )

local kMaxPrintLength = 128
local kServerConfigMessage =
{
    message = string.format("string (%d)", kMaxPrintLength),
}
Shared.RegisterNetworkMessage("CHUDServerConfig", kServerConfigMessage)