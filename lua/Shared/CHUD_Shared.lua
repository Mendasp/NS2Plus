kCHUDElixerVersion = 1.6
Script.Load("lua/CHUD/Elixer_Utility.lua")
Elixer.UseVersion( kCHUDElixerVersion ) 

function BuildCHUDDamageMessage( target, amount, hitpos, weapon, overkill )
	
	local t = BuildDamageMessage( target, amount, hitpos )
	t.isPlayer = target:isa("Player")
	t.weapon = weapon
	t.overkill = overkill
	return t
	
end

local kCHUDDamageMessage =
{
    posx = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posy = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    posz = string.format("float (%d to %d by 0.05)", -kHitEffectMaxPosition, kHitEffectMaxPosition),
    targetId = "entityid",
    isPlayer = "boolean",
	amount = "float",
	overkill = "float",
	weapon = "enum kTechId",	
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

Shared.RegisterNetworkMessage( "CHUDDamage", kCHUDDamageMessage )
Shared.RegisterNetworkMessage( "CHUDOption", kCHUDOptionMessage )
Shared.RegisterNetworkMessage( "SetCHUDAutopickup", kCHUDAutopickupMessage)

Script.Load("lua/Shared/CHUD_Utility.lua")
Script.Load("lua/Shared/CHUD_Autopickup.lua")
Script.Load("lua/Shared/CHUD_CommanderSelection.lua")
Script.Load("lua/Shared/CHUD_LayMines.lua")
Script.Load("lua/Shared/CHUD_AmmoPack.lua")
Script.Load("lua/Shared/CHUD_Grenade.lua")
Script.Load("lua/Shared/CHUD_BoneWall.lua")
Script.Load("lua/Shared/CHUD_LerkBite.lua")

Script.Load("lua/Shared/CHUD_ReadyRoom.lua")

CHUDTagBitmask = {
	mcr = 0x1,
	ambient = 0x2,
	mapparticles = 0x4,
	nsllights = 0x8,
	deathstats = 0x0,
}

local embryoNetworkVars =
{
	evolvePercentage = "float",
}

local pickupableNetworkVars =
{
	expireTime = "time (by 0.1)",
}

local catpackNetworkVars =
{
	catpackboost = "boolean",
}

Class_Reload("Embryo", embryoNetworkVars)
Class_Reload("Weapon", pickupableNetworkVars)
Class_Reload("DropPack", pickupableNetworkVars)
Class_Reload("Marine", catpackNetworkVars)
Class_Reload("Exo", catpackNetworkVars)
