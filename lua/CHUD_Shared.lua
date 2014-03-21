local kCHUDStatsMessage =
{
    isPlayer = "boolean",
    weapon = "enum kTechId",
    targetId = "entityid",
    damage = "float",
}

Shared.RegisterNetworkMessage( "CHUDStats", kCHUDStatsMessage )